#!/bin/bash
set -e

# Claude Code iOS Template — Setup Script
# Installs marketplace plugins + generates project-specific config (CLAUDE.md, rules, commands).

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET_DIR="${1:-.}"

echo "Claude Code iOS Project Setup"
echo "==================================="
echo ""

# Gather project info
read -rp "Project name (e.g., SnapGPX): " PROJECT_NAME
read -rp "Short description: " PROJECT_DESCRIPTION
read -rp "GitHub repo (owner/repo): " GITHUB_REPO
read -rp "Xcode scheme name: " SCHEME
read -rp "Simulator (e.g., iPhone 17): " SIMULATOR

echo ""
echo "Setting up in: $(cd "$TARGET_DIR" && pwd)"
echo ""

# --- Step 1: Install marketplace plugins (shared across all projects) ---
echo "Installing marketplace plugins..."
echo "  (Requires buca1821/claude-marketplace registered in known_marketplaces.json)"
echo ""

PLUGINS=("ios-swift-skills" "ios-audit-agents" "ios-tdd-commands" "ios-git-hooks")
for plugin in "${PLUGINS[@]}"; do
    if claude plugin install "${plugin}@claude-marketplace" 2>/dev/null; then
        echo "  + $plugin"
    else
        echo "  ~ $plugin (install manually: claude plugin install ${plugin}@claude-marketplace)"
    fi
done

echo ""

# --- Step 2: Copy project-specific files ---
mkdir -p "$TARGET_DIR/.claude/rules"
mkdir -p "$TARGET_DIR/.claude/commands"

echo "Copying project-specific files..."

# Rules (customizable per project — don't overwrite existing)
for rule in "$SCRIPT_DIR"/.claude/rules/*.md; do
    [ -f "$rule" ] || continue
    basename="$(basename "$rule")"
    if [ -f "$TARGET_DIR/.claude/rules/$basename" ]; then
        echo "  ~ rules/$basename (skipped — already exists)"
    else
        cp "$rule" "$TARGET_DIR/.claude/rules/"
        echo "  + rules/$basename"
    fi
done

# Commands (project-specific only — don't overwrite existing)
for cmd in "$SCRIPT_DIR"/.claude/commands/*.md; do
    [ -f "$cmd" ] || continue
    basename="$(basename "$cmd")"
    if [ -f "$TARGET_DIR/.claude/commands/$basename" ]; then
        echo "  ~ commands/$basename (skipped — already exists)"
    else
        cp "$cmd" "$TARGET_DIR/.claude/commands/"
        echo "  + commands/$basename"
    fi
done

# --- Step 3: Generate CLAUDE.md ---
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
    echo "  + CLAUDE.md"
fi

echo ""
echo "Setup complete!"
echo ""
echo "Project-specific files:"
find "$TARGET_DIR/.claude" -type f | sort | sed 's|^|  |'
[ -f "$TARGET_DIR/CLAUDE.md" ] && echo "  $TARGET_DIR/CLAUDE.md"
echo ""
echo "Plugins installed globally (shared across all projects)."
echo ""
echo "Next steps:"
echo "  1. Review and customize CLAUDE.md"
echo "  2. Customize rules in .claude/rules/ for this project"
echo "  3. Add project-specific commands in .claude/commands/"
echo "  4. Commit .claude/ and CLAUDE.md to your repo"
