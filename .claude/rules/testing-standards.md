---
trigger:
  - "test"
  - "XCTest"
  - "coverage"
  - ".*Tests.swift"
description: "Standards for writing tests"
---

# Testing Standards

- **Framework**: Swift Testing (`import Testing`, `@Test`, `#expect`) — preferred for all new tests
- **UI Tests**: XCTest (`XCUITest`) only — Swift Testing does not support UI automation
- **Mocks**: Use protocol-based mocks for dependency injection
- **Locale-dependent tests**: MUST inject explicit `Locale` for deterministic results
