#!/bin/bash
set -euo pipefail

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${GREEN}🚀 iOS Project Scaffolding${NC}"
echo "=========================="
echo ""

# Gather info
read -p "Project name (e.g., MyApp): " PROJECT_NAME
read -p "Bundle ID prefix (e.g., com.company) [com.buca1821]: " BUNDLE_PREFIX
BUNDLE_PREFIX=${BUNDLE_PREFIX:-com.buca1821}
read -p "iOS deployment target [17.0]: " DEPLOY_TARGET
DEPLOY_TARGET=${DEPLOY_TARGET:-17.0}
read -p "Target directory [.]: " TARGET_DIR
TARGET_DIR=${TARGET_DIR:-.}

# Resolve paths
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"
SRC_DIR="$TARGET_DIR/$PROJECT_NAME"

echo ""
echo -e "${YELLOW}Creating project: $PROJECT_NAME${NC}"
echo "  Bundle prefix: $BUNDLE_PREFIX"
echo "  Deployment target: iOS $DEPLOY_TARGET"
echo "  Location: $TARGET_DIR"
echo ""

# Check xcodegen
if ! command -v xcodegen &> /dev/null; then
    echo "❌ xcodegen not found. Install with: brew install xcodegen"
    exit 1
fi

# Create directory structure
echo "📁 Creating directory structure..."
mkdir -p "$SRC_DIR/App"
mkdir -p "$SRC_DIR/Features"
mkdir -p "$SRC_DIR/Services"
mkdir -p "$SRC_DIR/Core/Models"
mkdir -p "$SRC_DIR/Core/Utilities"
mkdir -p "$SRC_DIR/DesignSystem"
mkdir -p "$TARGET_DIR/${PROJECT_NAME}Tests"

# Generate Swift files
echo "📝 Generating Swift source files..."

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

cat > "$SRC_DIR/App/AppEnvironment.swift" << 'SWIFT'
import Foundation

@MainActor
@Observable
final class AppEnvironment {
    // Dependency injection container
}
SWIFT

cat > "$SRC_DIR/App/Constants.swift" << SWIFT
import Foundation

enum AppConstants {
    static let appName = "$PROJECT_NAME"

    #if targetEnvironment(simulator)
    static let isSimulator = true
    #else
    static let isSimulator = false
    #endif
}
SWIFT

cat > "$SRC_DIR/App/ContentView.swift" << 'SWIFT'
import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            Text(String(localized: "app.welcome"))
                .navigationTitle(String(localized: "app.title"))
        }
    }
}

#Preview {
    ContentView()
}
SWIFT

cat > "$TARGET_DIR/${PROJECT_NAME}Tests/${PROJECT_NAME}Tests.swift" << SWIFT
import Foundation
import Testing
@testable import $PROJECT_NAME

@Suite("$PROJECT_NAME")
struct ${PROJECT_NAME}Tests {

    @Test("App launches")
    func appLaunches() {
        // Placeholder test
        #expect(true)
    }
}
SWIFT

# Copy and parametrize config files
echo "⚙️  Copying configuration files..."

# .gitignore (no placeholders)
cp "$SCRIPT_DIR/.gitignore" "$TARGET_DIR/.gitignore"

# .swiftformat (no placeholders)
cp "$SCRIPT_DIR/.swiftformat" "$TARGET_DIR/.swiftformat"

# .swiftlint.yml (replace placeholder)
sed "s/__PROJECT_NAME__/$PROJECT_NAME/g" "$SCRIPT_DIR/.swiftlint.yml.template" > "$TARGET_DIR/.swiftlint.yml"

# project.yml (replace placeholders)
sed -e "s/__PROJECT_NAME__/$PROJECT_NAME/g" \
    -e "s/__BUNDLE_ID_PREFIX__/$BUNDLE_PREFIX/g" \
    -e "s/__DEPLOYMENT_TARGET__/$DEPLOY_TARGET/g" \
    "$SCRIPT_DIR/project.yml.template" > "$TARGET_DIR/project.yml"

# Generate Xcode project
echo "🔨 Generating Xcode project..."
cd "$TARGET_DIR"
xcodegen generate

echo ""
echo -e "${GREEN}✅ Project $PROJECT_NAME created successfully!${NC}"
echo ""
echo "Next steps:"
echo "  1. Apply Claude Code template:"
echo "     cd $TARGET_DIR && bash path/to/claude-code-ios-template/setup.sh"
echo "  2. Initialize git:"
echo "     cd $TARGET_DIR && git init && git add . && git commit -m 'chore: initial project scaffolding'"
echo "  3. Open in Xcode:"
echo "     open $TARGET_DIR/$PROJECT_NAME.xcodeproj"
