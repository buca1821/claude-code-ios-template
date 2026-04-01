---
trigger:
  - "git"
  - "branch"
  - "commit"
  - "PR"
  - "pull request"
description: "Git workflow and PR guidelines"
---

# Git Workflow

- **Never commit to `main`**. Branch naming: `feat/<name>-<issue>` or `fix/<name>-<issue>`
- **Conventional Commits**: `feat:`, `fix:`, `docs:`, `test:`, `refactor:`, `chore:`
- **PRs**: Title follows Conventional Commits. Reference issues with `Closes #XX`.
- **Never push without confirmation** from the user.
