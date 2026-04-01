# prepare-release

Pre-App Store submission checklist. Run before submitting to App Store Connect.

## Input

Version number: `$ARGUMENTS` (e.g., `1.0.0`)

## Process

### 1. Load App Store skill

Read `.claude/skills/app-store/references/rejection-handler.md` for the full audit checklist.

### 2. Code & build verification

- [ ] App compiles without errors on Release configuration
- [ ] All tests pass: `xcodebuild test -scheme YourApp` (or use your project's test script)
- [ ] Coverage thresholds met (check via Xcode coverage report)
- [ ] No TODO/FIXME/placeholder content in user-facing UI
- [ ] No debug/test code in Release builds

### 3. Localization verification

- [ ] All strings localized in 11 languages
- [ ] Run `validateAllTranslationsArePresent()` test
- [ ] No hardcoded user-facing strings
- [ ] Screenshots match current UI for each locale

### 4. Data access compliance

- [ ] Usage descriptions clearly explain purpose (e.g., `NSHealthShareUsageDescription`, `NSLocationWhenInUseUsageDescription`, etc.)
- [ ] App works gracefully when permissions are denied
- [ ] User data NOT shared with third parties without consent
- [ ] Review notes explain how to test data-dependent features

### 5. Privacy & legal

- [ ] Privacy policy URL valid and accessible
- [ ] Privacy Nutrition Label accurate and complete
- [ ] All third-party SDK data collection disclosed
- [ ] No hardcoded secrets or API keys in the bundle

### 6. App Store metadata

Read `.claude/skills/app-store/references/aso-keywords.md` for guidance.

- [ ] App name (30 chars max)
- [ ] Subtitle (30 chars max)
- [ ] Keywords (100 chars max)
- [ ] Description (4000 chars max)
- [ ] Promotional text (170 chars max)
- [ ] What's New text for this version
- [ ] Screenshots for required device sizes
- [ ] App icon meets guidelines

### 7. Review notes

Draft review notes for App Store Review team:

```
Thank you for reviewing YourApp.

## How to Test
1. Launch the app — sample data loads automatically
2. Tap any item to see the detail view
3. Exercise core features (export, filter, etc.)

## Data Access
[Explain what data the app accesses and why. Example: HealthKit, CoreData, network API, etc.]
No user data is shared with third parties.

## Notes
- No login required
- No in-app purchases
```

### 8. Final checks

- [ ] Version and build number updated
- [ ] Release notes written
- [ ] All changes committed and merged to main
- [ ] Git tag created: `git tag v$ARGUMENTS`

### 9. Output

Present a summary:
- ✅ Items that passed
- ❌ Items that need attention (with specific action items)
- 📋 Metadata ready for App Store Connect
