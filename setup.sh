#!/bin/bash
set -e

# Claude Code iOS Template — Setup Script
# Installs marketplace plugins + generates project-specific config (CLAUDE.md, rules, commands).
# Designed for existing iOS projects that want Claude Code integration.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET_DIR="${1:-.}"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${GREEN}Claude Code iOS Project Setup${NC}"
echo "=============================="
echo ""

# --- Gather project info ---
read -rp "Project name (e.g., SnapGPX): " PROJECT_NAME
read -rp "Short description: " PROJECT_DESCRIPTION
read -rp "GitHub repo (owner/repo): " GITHUB_REPO
read -rp "Xcode scheme name [$PROJECT_NAME]: " SCHEME
SCHEME=${SCHEME:-$PROJECT_NAME}
read -rp "Simulator (e.g., iPhone 17 Pro) [iPhone 17 Pro]: " SIMULATOR
SIMULATOR=${SIMULATOR:-iPhone 17 Pro}

echo ""
echo -e "Setting up in: ${BOLD}$(cd "$TARGET_DIR" && pwd)${NC}"
echo ""

# --- Validate inputs (warnings only) ---
if [ -d "$TARGET_DIR" ]; then
    XCODEPROJ=$(find "$TARGET_DIR" -maxdepth 1 -name "*.xcodeproj" -o -name "*.xcworkspace" 2>/dev/null | head -1)
    if [ -n "$XCODEPROJ" ]; then
        if ! xcodebuild -list -project "$XCODEPROJ" 2>/dev/null | grep -q "$SCHEME"; then
            echo -e "${YELLOW}⚠ Scheme '$SCHEME' not found in project. You can fix this in CLAUDE.md later.${NC}"
        fi
    fi
fi

if ! xcrun simctl list devices available 2>/dev/null | grep -q "$SIMULATOR"; then
    echo -e "${YELLOW}⚠ Simulator '$SIMULATOR' not found. Available simulators:${NC}"
    xcrun simctl list devices available 2>/dev/null | grep "iPhone\|iPad" | head -5 | sed 's/^/    /'
    echo "    ..."
    echo ""
fi

# --- Step 1: Register marketplace if needed ---
echo -e "${BOLD}Step 1: Marketplace${NC}"
if claude plugin marketplace list 2>/dev/null | grep -q "buca1821-marketplace"; then
    echo "  ✓ buca1821-marketplace already registered"
else
    echo "  Registering buca1821-marketplace..."
    if claude plugin marketplace add buca1821/claude-marketplace 2>&1 | grep -q "Successfully"; then
        echo "  ✓ Marketplace registered"
    else
        echo -e "${RED}  ✗ Could not register marketplace automatically.${NC}"
        echo "  Run this inside Claude Code:"
        echo "    claude plugin marketplace add buca1821/claude-marketplace"
        echo ""
        echo "  Or add to ~/.claude/settings.json:"
        echo '  "extraKnownMarketplaces": { "buca1821-marketplace": { "source": { "source": "git", "url": "https://github.com/buca1821/claude-marketplace.git" }, "autoUpdate": true } }'
    fi
fi
echo ""

# --- Step 2: Select and install plugins ---
echo -e "${BOLD}Step 2: Plugins${NC}"
echo "Select which plugins to install (enter numbers separated by spaces, or 'all'):"
echo ""
echo "  1) ios-swift-skills       — 12 iOS/SwiftUI skills (SwiftUI, concurrency, testing, etc.)"
echo "  2) ios-audit-agents       — 4 audit agents (architecture, code health, API, UX)"
echo "  3) ios-git-hooks          — Guard main branch + pre-commit quality checks"
echo "  4) implement-issue        — End-to-end GitHub issue → PR workflow"
echo "  5) claude-notifications-macos — macOS notifications on task completion"
echo ""
read -rp "Plugins [all]: " PLUGIN_SELECTION
PLUGIN_SELECTION=${PLUGIN_SELECTION:-all}

ALL_PLUGINS=("ios-swift-skills" "ios-audit-agents" "ios-git-hooks" "implement-issue" "claude-notifications-macos")

if [ "$PLUGIN_SELECTION" = "all" ]; then
    SELECTED_PLUGINS=("${ALL_PLUGINS[@]}")
else
    SELECTED_PLUGINS=()
    for num in $PLUGIN_SELECTION; do
        idx=$((num - 1))
        if [ $idx -ge 0 ] && [ $idx -lt ${#ALL_PLUGINS[@]} ]; then
            SELECTED_PLUGINS+=("${ALL_PLUGINS[$idx]}")
        fi
    done
fi

echo ""
for plugin in "${SELECTED_PLUGINS[@]}"; do
    if claude plugin install "${plugin}@buca1821-marketplace" 2>/dev/null; then
        echo "  ✓ $plugin"
    else
        echo -e "  ${YELLOW}~ $plugin (install manually: claude plugin install ${plugin}@buca1821-marketplace)${NC}"
    fi
done
echo ""

# --- Step 3: Select and copy rules/commands ---
echo -e "${BOLD}Step 3: Rules & Commands${NC}"
echo "Select which rules to include (enter numbers separated by spaces, or 'all'):"
echo ""
echo "  1) swift-patterns     — MVVM, @Observable, state management, DI"
echo "  2) testing-standards  — Swift Testing, mocks, locale handling"
echo "  3) git-workflow       — Branch naming, conventional commits, PR guidelines"
echo "  4) prepare-release    — Pre-App Store submission checklist (command)"
echo ""
read -rp "Rules [all]: " RULES_SELECTION
RULES_SELECTION=${RULES_SELECTION:-all}

ALL_RULES=("swift-patterns" "testing-standards" "git-workflow")
ALL_COMMANDS=("prepare-release")

if [ "$RULES_SELECTION" = "all" ]; then
    SELECTED_RULES=("${ALL_RULES[@]}")
    SELECTED_COMMANDS=("${ALL_COMMANDS[@]}")
else
    SELECTED_RULES=()
    SELECTED_COMMANDS=()
    for num in $RULES_SELECTION; do
        case $num in
            1) SELECTED_RULES+=("swift-patterns") ;;
            2) SELECTED_RULES+=("testing-standards") ;;
            3) SELECTED_RULES+=("git-workflow") ;;
            4) SELECTED_COMMANDS+=("prepare-release") ;;
        esac
    done
fi

echo ""
mkdir -p "$TARGET_DIR/.claude/rules"
mkdir -p "$TARGET_DIR/.claude/commands"

for rule in "${SELECTED_RULES[@]}"; do
    src="$SCRIPT_DIR/.claude/rules/${rule}.md"
    dst="$TARGET_DIR/.claude/rules/${rule}.md"
    if [ -f "$dst" ]; then
        echo "  ~ rules/$rule.md (skipped — already exists)"
    elif [ -f "$src" ]; then
        cp "$src" "$dst"
        echo "  ✓ rules/$rule.md"
    fi
done

for cmd in "${SELECTED_COMMANDS[@]}"; do
    src="$SCRIPT_DIR/.claude/commands/${cmd}.md"
    dst="$TARGET_DIR/.claude/commands/${cmd}.md"
    if [ -f "$dst" ]; then
        echo "  ~ commands/$cmd.md (skipped — already exists)"
    elif [ -f "$src" ]; then
        cp "$src" "$dst"
        echo "  ✓ commands/$cmd.md"
    fi
done
echo ""

# --- Step 4: Generate CLAUDE.md ---
echo -e "${BOLD}Step 4: CLAUDE.md${NC}"
if [ -f "$TARGET_DIR/CLAUDE.md" ]; then
    echo "  ~ CLAUDE.md (skipped — already exists)"
else
    sed \
        -e "s|{{PROJECT_NAME}}|$PROJECT_NAME|g" \
        -e "s|{{PROJECT_DESCRIPTION}}|$PROJECT_DESCRIPTION|g" \
        -e "s|{{GITHUB_REPO}}|$GITHUB_REPO|g" \
        -e "s|{{SCHEME}}|$SCHEME|g" \
        -e "s|{{SIMULATOR}}|$SIMULATOR|g" \
        "$SCRIPT_DIR/CLAUDE.md.template" > "$TARGET_DIR/CLAUDE.md"
    echo "  ✓ CLAUDE.md"
fi

echo ""
echo -e "${GREEN}✅ Setup complete!${NC}"
echo ""
echo "Files created:"
find "$TARGET_DIR/.claude" -type f 2>/dev/null | sort | sed 's|^|  |'
[ -f "$TARGET_DIR/CLAUDE.md" ] && echo "  $TARGET_DIR/CLAUDE.md"
echo ""
echo "Next steps:"
echo "  1. Review and customize CLAUDE.md for your project"
echo "  2. Customize rules in .claude/rules/ if needed"
echo "  3. Commit .claude/ and CLAUDE.md to your repo"
