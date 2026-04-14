#!/bin/bash
set -euo pipefail

# iOS Project Scaffolding
# Creates a new Swift project with xcodegen, ready to compile and run.

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${GREEN}iOS Project Scaffolding${NC}"
echo "======================="
echo ""

# --- Check required dependencies ---
if ! command -v xcodegen &> /dev/null; then
    echo -e "${RED}✗ xcodegen not found. Install with: brew install xcodegen${NC}"
    exit 1
fi

if ! command -v swiftlint &> /dev/null; then
    echo -e "${YELLOW}⚠ swiftlint not found (optional): brew install swiftlint${NC}"
fi

if ! command -v swiftformat &> /dev/null; then
    echo -e "${YELLOW}⚠ swiftformat not found (optional): brew install swiftformat${NC}"
fi

echo ""

# --- Gather info ---
read -rp "Project name (e.g., MyApp): " PROJECT_NAME
read -rp "Bundle ID prefix [com.example]: " BUNDLE_PREFIX
BUNDLE_PREFIX=${BUNDLE_PREFIX:-com.example}
read -rp "iOS deployment target [17.0]: " DEPLOY_TARGET
DEPLOY_TARGET=${DEPLOY_TARGET:-17.0}
read -rp "Target directory [.]: " TARGET_DIR
TARGET_DIR=${TARGET_DIR:-.}

echo ""

# --- Options ---
echo -e "${BOLD}Options:${NC}"
read -rp "Include example feature? (shows MVVM pattern) [Y/n]: " INCLUDE_EXAMPLE
INCLUDE_EXAMPLE=${INCLUDE_EXAMPLE:-Y}
read -rp "Include SwiftLint config? [Y/n]: " INCLUDE_SWIFTLINT
INCLUDE_SWIFTLINT=${INCLUDE_SWIFTLINT:-Y}
read -rp "Include SwiftFormat config? [Y/n]: " INCLUDE_SWIFTFORMAT
INCLUDE_SWIFTFORMAT=${INCLUDE_SWIFTFORMAT:-Y}

echo ""

# Resolve paths
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
mkdir -p "$TARGET_DIR"
TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"
SRC_DIR="$TARGET_DIR/$PROJECT_NAME"

echo -e "${BOLD}Creating project: $PROJECT_NAME${NC}"
echo "  Bundle prefix: $BUNDLE_PREFIX"
echo "  Deployment target: iOS $DEPLOY_TARGET"
echo "  Location: $TARGET_DIR"
echo ""

# --- Create directory structure ---
echo "Creating directory structure..."
mkdir -p "$SRC_DIR/App"
mkdir -p "$SRC_DIR/Features"
mkdir -p "$SRC_DIR/Services"
mkdir -p "$SRC_DIR/Core/Models"
mkdir -p "$SRC_DIR/Core/Utilities"
mkdir -p "$SRC_DIR/DesignSystem"
mkdir -p "$TARGET_DIR/${PROJECT_NAME}Tests"

# --- Generate Swift files ---
echo "Generating Swift source files..."

cat > "$SRC_DIR/App/${PROJECT_NAME}App.swift" << SWIFT
import SwiftUI

@main
struct ${PROJECT_NAME}App: App {
    @State private var appEnvironment = AppEnvironment()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(appEnvironment)
        }
    }
}
SWIFT

cat > "$SRC_DIR/App/AppEnvironment.swift" << SWIFT
import Foundation

/// Central dependency container for the app.
/// Add service protocols here and inject via initializer for testability.
@MainActor
@Observable
final class AppEnvironment {
    let greetingService: GreetingServiceProtocol

    init(greetingService: GreetingServiceProtocol = GreetingService()) {
        self.greetingService = greetingService
    }
}

// MARK: - Example Service

protocol GreetingServiceProtocol {
    func greeting() -> String
}

struct GreetingService: GreetingServiceProtocol {
    func greeting() -> String {
        "Welcome to $PROJECT_NAME"
    }
}
SWIFT

cat > "$SRC_DIR/App/ContentView.swift" << 'SWIFT'
import SwiftUI

struct ContentView: View {
    @Environment(AppEnvironment.self) private var environment

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Text(environment.greetingService.greeting())
                    .font(.title2)
            }
            .navigationTitle("Home")
        }
    }
}

#Preview {
    ContentView()
        .environment(AppEnvironment())
}
SWIFT

# --- Example Feature (optional) ---
if [[ "$INCLUDE_EXAMPLE" =~ ^[Yy] ]]; then
    echo "Adding example feature..."
    mkdir -p "$SRC_DIR/Features/Counter"

    cat > "$SRC_DIR/Features/Counter/CounterViewModel.swift" << 'SWIFT'
import Foundation

/// Example ViewModel demonstrating the MVVM pattern with @Observable.
/// Delete this file and its view when you no longer need the reference.
@MainActor
@Observable
final class CounterViewModel {
    private(set) var count = 0

    func increment() {
        count += 1
    }

    func decrement() {
        guard count > 0 else { return }
        count -= 1
    }
}
SWIFT

    cat > "$SRC_DIR/Features/Counter/CounterView.swift" << 'SWIFT'
import SwiftUI

/// Example View demonstrating the MVVM pattern.
/// The view owns its ViewModel via @State and is purely declarative.
/// Delete this file and its ViewModel when you no longer need the reference.
struct CounterView: View {
    @State private var viewModel = CounterViewModel()

    var body: some View {
        VStack(spacing: 24) {
            Text("\(viewModel.count)")
                .font(.system(size: 72, weight: .bold, design: .rounded))

            HStack(spacing: 32) {
                Button("−") { viewModel.decrement() }
                    .font(.title)
                    .disabled(viewModel.count == 0)

                Button("+") { viewModel.increment() }
                    .font(.title)
            }
        }
        .navigationTitle("Counter")
    }
}

#Preview {
    NavigationStack {
        CounterView()
    }
}
SWIFT
fi

# --- Tests ---
cat > "$TARGET_DIR/${PROJECT_NAME}Tests/${PROJECT_NAME}Tests.swift" << SWIFT
import Foundation
import Testing
@testable import $PROJECT_NAME

@Suite("$PROJECT_NAME Tests")
struct ${PROJECT_NAME}Tests {

    @Test("App greeting returns expected message")
    func greetingService() {
        let service = GreetingService()
        #expect(service.greeting().contains("$PROJECT_NAME"))
    }
}
SWIFT

if [[ "${INCLUDE_EXAMPLE:-Y}" =~ ^[Yy] ]]; then
    cat > "$TARGET_DIR/${PROJECT_NAME}Tests/CounterViewModelTests.swift" << 'SWIFT'
import Foundation
import Testing
@testable import __PROJECT_NAME__

@Suite("CounterViewModel")
struct CounterViewModelTests {

    @Test("Starts at zero")
    @MainActor
    func initialCount() {
        let vm = CounterViewModel()
        #expect(vm.count == 0)
    }

    @Test("Increment increases count")
    @MainActor
    func increment() {
        let vm = CounterViewModel()
        vm.increment()
        #expect(vm.count == 1)
    }

    @Test("Decrement does not go below zero")
    @MainActor
    func decrementAtZero() {
        let vm = CounterViewModel()
        vm.decrement()
        #expect(vm.count == 0)
    }
}
SWIFT
    # Substitute project name in counter tests
    sed -i '' "s/__PROJECT_NAME__/$PROJECT_NAME/g" "$TARGET_DIR/${PROJECT_NAME}Tests/CounterViewModelTests.swift"
fi

# --- Config files ---
echo "Copying configuration files..."

# .gitignore
cp "$SCRIPT_DIR/.gitignore" "$TARGET_DIR/.gitignore"

# .swiftformat (optional)
if [[ "$INCLUDE_SWIFTFORMAT" =~ ^[Yy] ]]; then
    cp "$SCRIPT_DIR/.swiftformat" "$TARGET_DIR/.swiftformat"
    echo "  ✓ .swiftformat"
fi

# .swiftlint.yml (optional)
if [[ "$INCLUDE_SWIFTLINT" =~ ^[Yy] ]]; then
    sed "s/__PROJECT_NAME__/$PROJECT_NAME/g" "$SCRIPT_DIR/.swiftlint.yml.template" > "$TARGET_DIR/.swiftlint.yml"
    echo "  ✓ .swiftlint.yml"
fi

# project.yml
sed -e "s/__PROJECT_NAME__/$PROJECT_NAME/g" \
    -e "s/__BUNDLE_ID_PREFIX__/$BUNDLE_PREFIX/g" \
    -e "s/__DEPLOYMENT_TARGET__/$DEPLOY_TARGET/g" \
    "$SCRIPT_DIR/project.yml.template" > "$TARGET_DIR/project.yml"

# --- Generate Xcode project ---
echo "Generating Xcode project..."
cd "$TARGET_DIR"
xcodegen generate

echo ""
echo -e "${GREEN}✅ Project $PROJECT_NAME created successfully!${NC}"
echo ""
echo "Structure:"
find "$SRC_DIR" -name "*.swift" | sort | sed "s|$TARGET_DIR/||" | sed 's/^/  /'
find "$TARGET_DIR/${PROJECT_NAME}Tests" -name "*.swift" | sort | sed "s|$TARGET_DIR/||" | sed 's/^/  /'
echo ""
echo "Next steps:"
echo "  1. Apply Claude Code config:"
echo "     bash $(dirname "$SCRIPT_DIR")/setup.sh $TARGET_DIR"
echo "  2. Initialize git:"
echo "     cd $TARGET_DIR && git init && git add . && git commit -m 'chore: initial project scaffolding'"
echo "  3. Open in Xcode:"
echo "     open $TARGET_DIR/$PROJECT_NAME.xcodeproj"
