# Claude Code iOS Template

Reusable Claude Code configuration for iOS/SwiftUI projects. Provides skills, commands, rules, and a setup script to bootstrap any new iOS project with AI-assisted development best practices.

## What's Included

### Skills (`.claude/skills/`)

| Skill | Description |
|---|---|
| **swiftui/** | View composition, layout, animations, Charts, Liquid Glass, macOS APIs. Adapted from [AvdLee/SwiftUI-Agent-Skill](https://github.com/AvdLee/SwiftUI-Agent-Skill) (MIT) |
| **design-system/** | Semantic tokens (color, typography, spacing), components, theming, preview patterns |
| **security/** | Keychain, App Transport Security, certificate pinning, secrets management |
| **networking/** | APIClient with protocol-based DI, async/await URLSession, retry, offline handling |
| **logging/** | OSLog structured logging, MetricKit production diagnostics |
| **cicd/** | GitHub Actions workflows for iOS — build, test, lint on PRs |
| **performance/** | SwiftUI debugging, Instruments/xctrace profiling, memory, energy |
| **swift-concurrency/** | Swift 6.2 patterns, actors, @concurrent, async bridging |
| **testing-tdd/** | Red-green-refactor, reproduce-first bug fixes, test data factories |
| **app-store/** | ASO keywords, rejection prevention, review responses |
| **review-pr/** | Pre-PR code review with deprecated API detection |
| **xcode-qa/** | Build, test, and QA with XcodeBuildMCP |

### Agents (`.claude/agents/`)

| Agent | Description |
|---|---|
| **api-freshness-auditor** | Deprecated APIs, outdated patterns, iOS target updates |
| **architecture-auditor** | MVVM compliance, DI, concurrency, feature structure |
| **code-health-auditor** | File sizes, complexity, tech debt markers, clean code |
| **ux-accessibility-auditor** | VoiceOver, Dynamic Type, UI states, user feedback |

### Commands (`.claude/commands/`)

| Command | Usage |
|---|---|
| `/tdd-feature` | Build a feature test-first with TDD |
| `/tdd-bug-fix` | Fix a bug with a reproduction test first |
| `/performance-audit` | Audit SwiftUI performance for a view or feature |
| `/prepare-release` | Pre-App Store submission checklist |
| `/run-audits` | Run all 4 audit agents in parallel (or a single one) |

### Rules (`.claude/rules/`)

| Rule | Trigger |
|---|---|
| `swift-patterns.md` | ViewModel, Pattern, MVVM |
| `testing-standards.md` | test, XCTest, coverage |
| `git-workflow.md` | git, branch, PR, commit |

## Installation

### Option 1: Setup script (recommended)

```bash
cd your-ios-project
curl -sL https://raw.githubusercontent.com/buca1821/claude-code-ios-template/main/setup.sh | bash
```

The script will:
1. Copy skills, commands, and rules to your project
2. Ask for project-specific configuration (name, repo, scheme)
3. Generate a tailored `CLAUDE.md`

### Option 2: Manual

```bash
git clone https://github.com/buca1821/claude-code-ios-template.git /tmp/ios-template
cp -r /tmp/ios-template/.claude your-ios-project/
# Edit CLAUDE.md to match your project
```

## Conventions

- **Architecture**: MVVM with `@Observable` + `@MainActor` ViewModels
- **Swift version**: 6.2+ with strict concurrency
- **UI**: SwiftUI (iOS 26+)
- **Testing**: Swift Testing (`@Test`, `#expect`) preferred
- **Localization**: String Catalogs (`.xcstrings`)
- **Git**: Conventional Commits, feature branches

## Customization

After setup, customize for your project:

1. **`.claude/CLAUDE.md`** — Project-specific context, structure, conventions
2. **`.claude/rules/`** — Add project-specific rules (design system, data layer patterns)
3. **`.claude/agents/`** — Adapt audit agents to your project's frameworks and patterns
4. **`.claude/commands/`** — Add project-specific commands (e.g., `/implement-issue`)

## License

MIT
