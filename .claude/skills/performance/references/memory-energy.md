# Memory, Launch, and Energy Diagnostics

## Memory Profiling

### Leaks Instrument

1. Profile with **Leaks** template (Cmd+I → Leaks)
2. Exercise the app (navigate screens, load data, go back)
3. Leaks instrument highlights leaked objects with stack traces
4. Follow the retain cycle path to find the root cause

### Memory Graph Debugger

In Xcode during a debug session: **Debug → Debug Memory Graph** (or the graph icon in the debug bar).

- Shows all live objects and their retain relationships
- Purple `!` marks potential leaks
- Click an object to see its retain/release history
- Filter by your module name to reduce noise

### Allocations — Generation Analysis

1. Profile with **Allocations** template
2. Tap "Mark Generation" before and after a repeatable action
3. Compare live bytes between generations
4. Growing generations indicate a leak or unbounded cache

### Common Leak Patterns

#### Retain Cycles in Closures

```swift
// BAD — strong capture of self in escaping closure
func startObserving() {
    notificationCenter.addObserver(forName: .didUpdate, object: nil, queue: .main) { notification in
        self.handleUpdate(notification)  // Strong reference to self
    }
}

// GOOD — weak self
func startObserving() {
    notificationCenter.addObserver(forName: .didUpdate, object: nil, queue: .main) { [weak self] notification in
        self?.handleUpdate(notification)
    }
}
```

#### Delegate Retain Cycles

```swift
// BAD — strong delegate
protocol DataDelegate: AnyObject { }
class DataManager {
    var delegate: DataDelegate?  // Should be weak
}

// GOOD — weak delegate
class DataManager {
    weak var delegate: DataDelegate?
}
```

#### autoreleasepool in Tight Loops

```swift
// Processing many ObjC objects (images, Core Graphics)
for imageData in largeDataSet {
    autoreleasepool {
        let image = UIImage(data: imageData)
        processImage(image)
    }  // Temporary objects released here, not at end of loop
}
```

## Launch Optimization

### Measure Launch Time

Profile with **App Launch** template:
- **Pre-main**: dylib loading, static initializers, ObjC setup
- **Post-main**: `@main App.init()` through first frame rendered

### Common Launch Bottlenecks

| Bottleneck | Fix |
|-----------|-----|
| Heavy `App.init()` | Defer non-essential setup (analytics, prefetch) |
| Synchronous network at launch | Make async, show placeholder UI |
| Large asset loading | Load lazily, use thumbnails first |
| Many dynamic frameworks | Prefer static linking where possible |
| Complex initial view hierarchy | Simplify first screen, defer detail loading |

### Deferred Initialization Pattern

```swift
@main
struct SnapGPXApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    // Defer non-critical work
                    await TelemetryManager.shared.initialize()
                    await prefetchInitialData()
                }
        }
    }
}
```

## MetricKit — Production Monitoring

Collect performance metrics from real users:

```swift
import MetricKit

final class PerformanceReporter: NSObject, MXMetricManagerSubscriber {
    func startCollecting() {
        MXMetricManager.shared.add(self)
    }

    func didReceive(_ payloads: [MXMetricPayload]) {
        for payload in payloads {
            if let launch = payload.applicationLaunchMetrics {
                log("Resume time: \(launch.histogrammedResumeTime)")
            }
            if let responsiveness = payload.applicationResponsivenessMetrics {
                log("Hang time: \(responsiveness.histogrammedApplicationHangTime)")
            }
            if let memory = payload.memoryMetrics {
                log("Peak memory: \(memory.peakMemoryUsage)")
            }
        }
    }

    func didReceive(_ payloads: [MXDiagnosticPayload]) {
        for payload in payloads {
            if let hangs = payload.hangDiagnostics {
                for hang in hangs {
                    log("Hang: \(hang.callStackTree)")
                }
            }
        }
    }
}
```

## Energy Diagnostics

### Energy Log Instrument

Profile with **Energy Log** template to see:
- CPU, GPU, network, location, and display energy breakdown
- Energy Impact score (0-20 scale)
- Background task energy usage

### Location Accuracy

```swift
// BAD — maximum accuracy drains battery
locationManager.desiredAccuracy = kCLLocationAccuracyBest

// GOOD — match accuracy to actual need
locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters  // For city-level
locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters  // For route tracking
```

### Timer Tolerance

```swift
// Allow system to coalesce timer fires (saves energy)
let timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
    refreshData()
}
timer.tolerance = 10  // Can fire up to 10s late — allows coalescing
```

### Background Task Best Practices

```swift
import BackgroundTasks

func scheduleBackgroundRefresh() {
    let request = BGProcessingTaskRequest(identifier: "com.snapgpx.refresh")
    request.requiresNetworkConnectivity = true
    request.requiresExternalPower = false
    try? BGTaskScheduler.shared.submit(request)
}
```

### Thermal State Monitoring

```swift
NotificationCenter.default.addObserver(
    forName: ProcessInfo.thermalStateDidChangeNotification,
    object: nil,
    queue: .main
) { _ in
    let state = ProcessInfo.processInfo.thermalState
    switch state {
    case .nominal: break
    case .fair: reduceFidelity()
    case .serious: pauseNonEssentialWork()
    case .critical: minimizeAllWork()
    @unknown default: break
    }
}
```

## Xcode Diagnostic Settings

Enable in **Scheme → Run → Diagnostics**:

| Setting | What It Catches |
|---------|-----------------|
| Main Thread Checker | UI work off main thread |
| Thread Sanitizer | Data races |
| Address Sanitizer | Buffer overflows, use-after-free |
| Malloc Stack Logging | Memory allocation call stacks |
| Zombie Objects | Messages to deallocated objects |

## References

- [WWDC: Ultimate Application Performance Survival Guide](https://developer.apple.com/videos/play/wwdc2021/10181/)
- [WWDC: Analyze Hangs with Instruments](https://developer.apple.com/videos/play/wwdc2023/10248/)
- [WWDC: Detect and Diagnose Memory Issues](https://developer.apple.com/videos/play/wwdc2021/10180/)
- [WWDC: Optimize SwiftUI performance with Instruments](https://developer.apple.com/videos/play/wwdc2025/306/)
