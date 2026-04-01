# Bridging Legacy APIs to async/await

## withCheckedContinuation

Bridge a callback-based API to async/await:

```swift
// Example: HealthKit, CoreData, network API, etc.
func executeQuery(_ query: HKQuery) async -> [HKSample]? {
    await withCheckedContinuation { continuation in
        healthStore.execute(query) { _, results, _ in
            continuation.resume(returning: results as? [HKSample])
        }
    }
}
```

### CRITICAL: Call Exactly Once

The continuation **must** be resumed exactly once:
- **Zero calls** → task hangs forever (leaked continuation)
- **Two calls** → runtime crash

```swift
// BAD — callback might not fire, or fires twice
await withCheckedContinuation { continuation in
    someAPI.fetch { result in
        continuation.resume(returning: result)
    }
    // What if fetch() never calls the callback? Hangs forever.
}

// GOOD — handle all paths
await withCheckedContinuation { continuation in
    someAPI.fetch { result in
        continuation.resume(returning: result)
    } onError: { error in
        continuation.resume(returning: nil)  // Still resumes
    }
}
```

## withCheckedThrowingContinuation

For APIs that can fail:

```swift
// Example: HealthKit authorization pattern
func requestAuthorization(types: Set<HKSampleType>) async throws -> Bool {
    try await withCheckedThrowingContinuation { continuation in
        healthStore.requestAuthorization(toShare: [], read: types) { success, error in
            if let error {
                continuation.resume(throwing: error)
            } else {
                continuation.resume(returning: success)
            }
        }
    }
}
```

### Query Pattern Example

A common pattern for bridging query-based APIs (e.g., HealthKit, CoreData):

```swift
let results = await withCheckedContinuation { continuation in
    healthStore.execute(query) { _, result, _ in
        continuation.resume(returning: result)
    }
}
```

For queries that can throw:

```swift
try await withCheckedThrowingContinuation { continuation in
    store.requestAuthorization(toShare: [], read: types) { success, error in
        if let error { continuation.resume(throwing: error) }
        else { continuation.resume(returning: success) }
    }
}
```

## AsyncStream

Bridge delegate or notification patterns to an async sequence.

### makeStream Pattern (Preferred)

```swift
func locationUpdates() -> AsyncStream<CLLocation> {
    let (stream, continuation) = AsyncStream.makeStream(of: CLLocation.self)

    let delegate = LocationDelegate(continuation: continuation)
    locationManager.delegate = delegate

    continuation.onTermination = { _ in
        // Cleanup when consumer stops listening
        locationManager.stopUpdatingLocation()
    }

    locationManager.startUpdatingLocation()
    return stream
}

// Delegate feeds the stream
class LocationDelegate: NSObject, CLLocationManagerDelegate {
    let continuation: AsyncStream<CLLocation>.Continuation

    init(continuation: AsyncStream<CLLocation>.Continuation) {
        self.continuation = continuation
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations {
            continuation.yield(location)
        }
    }
}

// Consumer
for await location in locationUpdates() {
    updateRoute(with: location)
}
```

### NotificationCenter → AsyncStream

```swift
// Built-in support (iOS 15+)
for await notification in NotificationCenter.default.notifications(named: .itemDidUpdate) {
    guard let item = notification.object as? Item else { continue }
    await handleUpdate(item)
}
```

### AsyncThrowingStream for Error-Prone Sources

```swift
// Example: HealthKit observer query, CoreData change notifications, etc.
func itemUpdates() -> AsyncThrowingStream<Item, Error> {
    AsyncThrowingStream { continuation in
        let query = HKObserverQuery(sampleType: sampleType, predicate: nil) { _, completionHandler, error in
            if let error {
                continuation.finish(throwing: error)
            } else {
                continuation.yield(/* fetched item */)
            }
            completionHandler()
        }
        healthStore.execute(query)

        continuation.onTermination = { _ in
            healthStore.stop(query)
        }
    }
}
```

## When to Use Which

| Legacy Pattern | Async Bridge |
|---------------|-------------|
| Single callback | `withCheckedContinuation` |
| Single callback that can fail | `withCheckedThrowingContinuation` |
| Delegate with repeated callbacks | `AsyncStream` |
| Delegate with errors | `AsyncThrowingStream` |
| NotificationCenter | `.notifications(named:)` (built-in) |
| KVO | `publisher(for:).values` (Combine → AsyncSequence) |

## Gotchas

- **Continuation must resume exactly once** — use `withChecked*` (not `withUnsafe*`) in development to catch violations
- **Retain the delegate/observer** — if the delegate is deallocated, callbacks stop but the continuation may never resume
- **onTermination cleanup** — always stop queries/observers when the stream terminates
- **Back-pressure** — `AsyncStream` buffers by default. Use `.bufferingPolicy(.bufferingNewest(1))` for high-frequency updates where only the latest matters
