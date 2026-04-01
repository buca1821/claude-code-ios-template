#!/bin/bash
set -e

# Claude Code iOS Template — Setup Script
# Copies skills, commands, rules, and generates CLAUDE.md for a new iOS project.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET_DIR="${1:-.}"

echo "🔧 Claude Code iOS Template Setup"
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

# Create directory structure
mkdir -p "$TARGET_DIR/.claude/skills"
mkdir -p "$TARGET_DIR/.claude/commands"
mkdir -p "$TARGET_DIR/.claude/rules"

# Copy skills
echo "📦 Copying skills..."
for skill in performance swift-concurrency testing-tdd app-store review-pr xcode-qa; do
    if [ -d "$SCRIPT_DIR/.claude/skills/$skill" ]; then
        cp -r "$SCRIPT_DIR/.claude/skills/$skill" "$TARGET_DIR/.claude/skills/"
        echo "  ✓ $skill"
    fi
done

# Copy commands
echo "📦 Copying commands..."
for cmd in "$SCRIPT_DIR"/.claude/commands/*.md; do
    [ -f "$cmd" ] && cp "$cmd" "$TARGET_DIR/.claude/commands/" && echo "  ✓ $(basename "$cmd")"
done

# Copy rules
echo "📦 Copying rules..."
for rule in "$SCRIPT_DIR"/.claude/rules/*.md; do
    [ -f "$rule" ] && cp "$rule" "$TARGET_DIR/.claude/rules/" && echo "  ✓ $(basename "$rule")"
done

# Generate CLAUDE.md from template
echo "📝 Generating CLAUDE.md..."
sed \
    -e "s|{{PROJECT_NAME}}|$PROJECT_NAME|g" \
    -e "s|{{PROJECT_DESCRIPTION}}|$PROJECT_DESCRIPTION|g" \
    -e "s|{{GITHUB_REPO}}|$GITHUB_REPO|g" \
    -e "s|{{SCHEME}}|$SCHEME|g" \
    -e "s|{{SIMULATOR}}|$SIMULATOR|g" \
    "$SCRIPT_DIR/CLAUDE.md.template" > "$TARGET_DIR/CLAUDE.md"
echo "  ✓ CLAUDE.md"

echo ""
echo "✅ Setup complete!"
echo ""
echo "Files created:"
find "$TARGET_DIR/.claude" -name "*.md" | sort | sed 's|^|  |'
echo "  $TARGET_DIR/CLAUDE.md"
echo ""
echo "Next steps:"
echo "  1. Review and customize CLAUDE.md for your project"
echo "  2. Add project-specific rules in .claude/rules/"
echo "  3. Add project-specific commands in .claude/commands/"
echo "  4. Commit the .claude/ directory to your repo"
