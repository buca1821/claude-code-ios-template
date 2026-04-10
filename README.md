# Claude Code iOS Template

Lightweight setup for iOS/SwiftUI projects. Installs shared plugins from [claude-marketplace](https://github.com/buca1821/claude-marketplace) and generates project-specific configuration.

## Architecture

| Layer | What | Updates |
|-------|------|---------|
| **Marketplace plugins** | Skills (12), audit agents (4), TDD commands, git hooks | Centralized — update once, all projects benefit |
| **This template** | CLAUDE.md, rules, project-specific commands | Per-project — customizable after setup |

### Plugins installed

| Plugin | Contents |
|--------|----------|
| `ios-swift-skills` | 12 skills: SwiftUI, design-system, swift-concurrency, security, networking, testing-tdd, performance, logging, cicd, app-store, review-pr, xcode-qa |
| `ios-audit-agents` | 4 audit agents + `/run-audits` command |
| `ios-tdd-commands` | `/tdd-feature`, `/tdd-bug-fix`, `/performance-audit` |
| `ios-git-hooks` | Guard main branch + pre-commit quality checks |

### Template files (per-project)

| File | Purpose |
|------|---------|
| `CLAUDE.md` | Project name, scheme, simulator, conventions |
| `.claude/rules/swift-patterns.md` | MVVM, state management, DI patterns |
| `.claude/rules/testing-standards.md` | Swift Testing, mocking, locale handling |
| `.claude/rules/git-workflow.md` | Branch naming, conventional commits |
| `.claude/commands/prepare-release.md` | Pre-App Store submission checklist |

## Installation

### Prerequisites

Register the marketplace (one-time):

```bash
# The setup script installs plugins from buca1821/claude-marketplace
# Make sure it's registered in ~/.claude/plugins/known_marketplaces.json
```

### Setup

```bash
cd your-ios-project
curl -sL https://raw.githubusercontent.com/buca1821/claude-code-ios-template/main/setup.sh | bash
```

The script will:
1. Install 4 marketplace plugins (shared globally)
2. Copy customizable rules and commands to your project
3. Generate a tailored `CLAUDE.md`

## Conventions

- **Architecture**: MVVM with `@Observable` + `@MainActor` ViewModels
- **Swift version**: 6.2+ with strict concurrency
- **UI**: SwiftUI (iOS 26+)
- **Testing**: Swift Testing (`@Test`, `#expect`) preferred
- **Localization**: String Catalogs (`.xcstrings`)
- **Git**: Conventional Commits, feature branches

## Customization

After setup, customize for your project:

1. **`CLAUDE.md`** — Project-specific context and structure
2. **`.claude/rules/`** — Relax or extend rules per project
3. **`.claude/commands/`** — Add project-specific commands

## Updating plugins

When skills or agents improve, update all projects at once:

```bash
claude plugin update ios-swift-skills@claude-marketplace
claude plugin update ios-audit-agents@claude-marketplace
claude plugin update ios-tdd-commands@claude-marketplace
claude plugin update ios-git-hooks@claude-marketplace
```

## License

MIT
