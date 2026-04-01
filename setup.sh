#!/bin/bash
set -e

# Claude Code iOS Template — Setup Script
# Copies skills, commands, rules, hooks, and generates CLAUDE.md for a new iOS project.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TARGET_DIR="${1:-.}"

echo "Claude Code iOS Template Setup"
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
mkdir -p "$TARGET_DIR/.claude/hooks"

# Copy skills
echo "Copying skills..."
for skill in performance swift-concurrency testing-tdd app-store review-pr xcode-qa; do
    if [ -d "$SCRIPT_DIR/.claude/skills/$skill" ]; then
        cp -r "$SCRIPT_DIR/.claude/skills/$skill" "$TARGET_DIR/.claude/skills/"
        echo "  + $skill"
    fi
done

# Copy commands
echo "Copying commands..."
for cmd in "$SCRIPT_DIR"/.claude/commands/*.md; do
    [ -f "$cmd" ] && cp "$cmd" "$TARGET_DIR/.claude/commands/" && echo "  + $(basename "$cmd")"
done

# Copy rules (don't overwrite existing project rules)
echo "Copying rules..."
for rule in "$SCRIPT_DIR"/.claude/rules/*.md; do
    [ -f "$rule" ] || continue
    basename="$(basename "$rule")"
    if [ -f "$TARGET_DIR/.claude/rules/$basename" ]; then
        echo "  ~ $basename (skipped — already exists)"
    else
        cp "$rule" "$TARGET_DIR/.claude/rules/"
        echo "  + $basename"
    fi
done

# Copy hooks
echo "Copying hooks..."
for hook in "$SCRIPT_DIR"/.claude/hooks/*.sh; do
    [ -f "$hook" ] && cp "$hook" "$TARGET_DIR/.claude/hooks/" && chmod +x "$TARGET_DIR/.claude/hooks/$(basename "$hook")" && echo "  + $(basename "$hook")"
done

# Merge settings.json (hooks config)
echo "Configuring hooks..."
if [ -f "$TARGET_DIR/.claude/settings.json" ]; then
    # Project already has settings — merge hooks into it
    TEMPLATE_HOOKS=$(jq '.hooks' "$SCRIPT_DIR/.claude/settings.json")
    TMP=$(mktemp)
    jq --argjson hooks "$TEMPLATE_HOOKS" '.hooks = $hooks' "$TARGET_DIR/.claude/settings.json" > "$TMP" && mv "$TMP" "$TARGET_DIR/.claude/settings.json"
    echo "  ~ settings.json (merged hooks into existing)"
else
    cp "$SCRIPT_DIR/.claude/settings.json" "$TARGET_DIR/.claude/settings.json"
    echo "  + settings.json"
fi

# Generate CLAUDE.md from template (only if it doesn't exist)
if [ -f "$TARGET_DIR/CLAUDE.md" ]; then
    echo "Skipping CLAUDE.md — already exists. Template saved as CLAUDE.md.template-generated"
    sed \
        -e "s|{{PROJECT_NAME}}|$PROJECT_NAME|g" \
        -e "s|{{PROJECT_DESCRIPTION}}|$PROJECT_DESCRIPTION|g" \
        -e "s|{{GITHUB_REPO}}|$GITHUB_REPO|g" \
        -e "s|{{SCHEME}}|$SCHEME|g" \
        -e "s|{{SIMULATOR}}|$SIMULATOR|g" \
        "$SCRIPT_DIR/CLAUDE.md.template" > "$TARGET_DIR/CLAUDE.md.template-generated"
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
echo "Files:"
find "$TARGET_DIR/.claude" -type f | sort | sed 's|^|  |'
echo ""
echo "Next steps:"
echo "  1. Review CLAUDE.md — add project-specific context"
echo "  2. Customize skills in .claude/skills/ for your project"
echo "  3. Add project-specific rules in .claude/rules/"
echo "  4. Add project-specific commands in .claude/commands/"
echo "  5. Commit .claude/ to your repo"
