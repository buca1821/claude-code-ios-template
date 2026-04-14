# Claude Code iOS Template

Lightweight setup for iOS/SwiftUI projects using Claude Code. Two scripts, two purposes:

- **`setup.sh`** — Adds Claude Code config (CLAUDE.md, rules, commands, plugins) to an **existing** iOS project
- **`ios-project-template/setup-project.sh`** — Scaffolds a **new** Swift project from scratch with xcodegen

## Quick Start

### Existing project

```bash
git clone https://github.com/buca1821/claude-code-ios-template.git /tmp/claude-code-ios-template
cd your-existing-project
bash /tmp/claude-code-ios-template/setup.sh
```

You'll be asked to:
1. Enter project info (name, scheme, simulator)
2. Pick which **plugins** to install (iOS skills, audit agents, git hooks, etc.)
3. Pick which **rules** to include (MVVM patterns, testing, git workflow)

Output:
```
your-project/
├── CLAUDE.md                     ← Project context for Claude
└── .claude/
    ├── rules/
    │   ├── swift-patterns.md     ← MVVM, @Observable, DI
    │   ├── testing-standards.md  ← Swift Testing, mocks
    │   └── git-workflow.md       ← Branches, conventional commits
    └── commands/
        └── prepare-release.md    ← App Store submission checklist
```

### New project from scratch

```bash
git clone https://github.com/buca1821/claude-code-ios-template.git /tmp/claude-code-ios-template
bash /tmp/claude-code-ios-template/ios-project-template/setup-project.sh
```

This creates a compilable Swift project with:
- MVVM architecture with `@Observable`
- Example feature (Counter) showing the full pattern
- AppEnvironment with protocol-based DI
- Swift Testing unit tests that pass
- SwiftLint + SwiftFormat configs (optional)

Then apply Claude Code config:
```bash
bash /tmp/claude-code-ios-template/setup.sh /path/to/new-project
```

## Prerequisites

| Tool | Required | Install |
|------|----------|---------|
| Claude Code | Yes | [claude.ai/code](https://claude.ai/code) |
| xcodegen | For new projects only | `brew install xcodegen` |
| swiftlint | Optional | `brew install swiftlint` |
| swiftformat | Optional | `brew install swiftformat` |

## What's included

### Marketplace Plugins (global, shared across projects)

| Plugin | What it does |
|--------|-------------|
| **ios-swift-skills** | 12 skills: SwiftUI, concurrency, security, networking, testing, performance, design system, CI/CD, App Store, PR review, Xcode QA |
| **ios-audit-agents** | 4 audit agents (architecture, code health, API freshness, UX/accessibility) + `/run-audits` |
| **ios-git-hooks** | Guard main branch + pre-commit quality checks on Swift files |
| **implement-issue** | End-to-end GitHub issue → branch → implement → PR workflow |
| **claude-notifications-macos** | macOS notifications when Claude finishes or needs permission |

### Rules & Commands (per-project, customizable)

| File | Triggers on | What it does |
|------|------------|-------------|
| `swift-patterns.md` | "ViewModel", "MVVM", "@Observable" | MVVM with @Observable, state management, DI patterns |
| `testing-standards.md` | "test", "XCTest", "coverage" | Swift Testing preferred, protocol mocks, locale handling |
| `git-workflow.md` | "git", "branch", "commit", "PR" | Branch naming, conventional commits, PR guidelines |
| `prepare-release.md` | `/prepare-release 1.0.0` | Full App Store submission checklist |

## Conventions

- **Architecture**: MVVM with `@MainActor` + `@Observable`
- **Testing**: Swift Testing for unit tests, XCTest for UI tests only
- **Git**: Conventional Commits, never commit to main
- **Language**: Code in English, conversations in Spanish

## Customization

After setup, customize for your project:

1. **`CLAUDE.md`** — Project-specific context and build settings
2. **`.claude/rules/`** — Relax or extend rules as needed
3. **`.claude/commands/`** — Add project-specific commands

## Updating plugins

Plugins update automatically if your marketplace has `"autoUpdate": true`. To force:

```bash
claude plugin update ios-swift-skills@buca1821-marketplace
```

## License

MIT
