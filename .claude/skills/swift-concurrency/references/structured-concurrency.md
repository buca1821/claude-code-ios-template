# Structured Concurrency

## async let — Fixed Parallel Operations

Run a known number of tasks in parallel:

```swift
func loadWorkoutDetail(workout: AnyWorkout) async throws -> WorkoutDetail {
    async let route = fetchRoute(for: workout)
    async let heartRate = fetchHeartRate(for: workout)
    async let elevation = fetchElevation(for: workout)

    // All three run concurrently, awaited together
    return WorkoutDetail(
        route: try await route,
        heartRate: try await heartRate,
        elevation: try await elevation
    )
}
```

**Rules**:
- Child tasks are automatically cancelled if the parent scope exits early
- Each `async let` must be awaited before the scope ends
- If one throws, the others are cancelled

## withTaskGroup — Dynamic Parallel Operations

Run a variable number of tasks:

```swift
func fetchRoutes(for workouts: [AnyWorkout]) async -> [UUID: [WorkoutRoutePoint]] {
    await withTaskGroup(of: (UUID, [WorkoutRoutePoint]).self) { group in
        for workout in workouts {
            group.addTask {
                let route = await self.fetchRoute(for: workout)
                return (workout.id, route)
            }
        }

        var results: [UUID: [WorkoutRoutePoint]] = [:]
        for await (id, route) in group {
            results[id] = route
        }
        return results
    }
}
```

### Throwing variant

```swift
try await withThrowingTaskGroup(of: Data.self) { group in
    // If any child throws, all others are cancelled
}
```

### withDiscardingTaskGroup — Fire-and-Forget

For tasks where you don't need to collect results:

```swift
await withDiscardingTaskGroup { group in
    for workout in workouts {
        group.addTask {
            await preloadThumbnail(for: workout)
        }
    }
}
// All thumbnails preloaded, no results collected
```

## .task { } Modifier

Load data when a view appears. Automatically cancelled when the view disappears:

```swift
struct WorkoutListView: View {
    @State private var viewModel = WorkoutListViewModel()

    var body: some View {
        List(viewModel.workouts) { workout in
            WorkoutRow(workout: workout)
        }
        .task {
            await viewModel.loadWorkouts()
        }
    }
}
```

**Key**: `.task` is tied to view lifecycle — no manual cancellation needed.

## .task(id:) — Re-load on Value Change

Re-runs the task when the `id` value changes (previous task is cancelled automatically):

```swift
struct WorkoutDetailView: View {
    let workoutID: UUID
    @State private var viewModel = WorkoutDetailViewModel()

    var body: some View {
        DetailContent(viewModel: viewModel)
            .task(id: workoutID) {
                await viewModel.load(workoutID: workoutID)
            }
    }
}
```

**Prefer `.task(id:)` over manual `onChange` + Task cancel patterns.**

## Task Cancellation

### Checking Cancellation

```swift
func processLargeDataSet(_ items: [Item]) async throws {
    for item in items {
        try Task.checkCancellation()  // Throws CancellationError
        await process(item)
    }
}

// Or check without throwing
func processLargeDataSet(_ items: [Item]) async {
    for item in items {
        if Task.isCancelled { return }
        await process(item)
    }
}
```

### Cooperative Cancellation

Swift concurrency uses **cooperative cancellation** — tasks must explicitly check. Long-running work should check periodically.

## Structured vs Unstructured Task

| | Structured (.task, TaskGroup) | Unstructured (Task { }) |
|---|---|---|
| Cancellation | Automatic with parent scope | Manual — must store and cancel |
| Lifetime | Tied to scope/view | Independent |
| Error propagation | To parent | Lost unless handled |
| Use when | Default choice | Fire-and-forget, detached work |

**Prefer structured concurrency.** Use `Task { }` only when you need to escape the current scope (e.g., responding to a button tap in a non-async context):

```swift
Button("Export GPX") {
    Task {
        await viewModel.exportGPX()
    }
}
```

## Patterns to Avoid

```swift
// BAD — manual onChange + cancel (use .task(id:) instead)
.onChange(of: selectedID) { oldValue, newValue in
    loadTask?.cancel()
    loadTask = Task { await viewModel.load(id: newValue) }
}

// BAD — unstructured Task in onAppear (use .task instead)
.onAppear {
    Task { await viewModel.load() }
}

// BAD — Task.detached without clear reason
Task.detached {
    await heavyWork()  // Usually @concurrent is better
}
```
