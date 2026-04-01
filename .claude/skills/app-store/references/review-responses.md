# App Store Review Responses

## When to Respond

| Review Type | Respond? | Why |
|-------------|----------|-----|
| Bug report | ✅ Yes | Shows you care, builds trust |
| Feature request | ✅ Yes | Engages power users, gathers feedback |
| Negative with actionable feedback | ✅ Yes | Opportunity to convert critic to fan |
| Positive review (4-5 stars) | ✅ Brief | Quick thank you, reinforces engagement |
| Trolling / off-topic | ❌ No | Don't feed trolls |
| Non-constructive ("this sucks") | ❌ No | No actionable feedback to address |
| Rating-only (no text) | ❌ No | Nothing to respond to |

## Response Templates

### Bug Report

```
Thanks for reporting this — we take bugs seriously. 

[If already fixed]: This was fixed in version X.X, now available. 
Please update and let us know if the issue persists.

[If investigating]: We're looking into this. Could you email us at 
support@yourapp.com with more details? That helps us reproduce 
and fix it faster.
```

### Feature Request

```
Great suggestion! [Feature] is something we've been considering.

[If planned]: It's on our roadmap — stay tuned for an upcoming release.

[If not planned]: We'll add it to our feature backlog. We prioritize 
based on user demand, so your feedback counts.

Thanks for helping us improve YourApp!
```

### Negative Experience

```
We're sorry YourApp didn't meet your expectations. 

[Address specific complaint with empathy]

[Offer concrete solution or workaround]

We'd love a chance to make it right — please reach out at 
support@yourapp.com so we can help directly.
```

### Positive Review

```
Thank you! Glad YourApp is working well for your [activity type] workouts. 🙏
```

Keep positive responses brief — don't over-explain.

## Tone Guidelines

- **Professional** — never defensive, never sarcastic
- **Empathetic** — acknowledge frustration before solving
- **Concise** — respect the reader's time
- **Specific** — reference the exact issue they mentioned
- **Action-oriented** — always include what you're doing about it
- **Personal** — sign with a name if appropriate ("— The YourApp Team")

## What NOT to Do

- Don't argue with reviewers publicly
- Don't ask users to change their rating
- Don't blame the user ("you should have...")
- Don't make promises you can't keep ("next week we'll...")
- Don't copy-paste the same response to every review
- Don't include marketing speak in bug responses

## Review Prompt — SKStoreReviewController

### When to Prompt

- After a **positive action** (successful export, completed filter)
- After **3+ sessions** (user is engaged)
- **Not on first launch** (too soon)
- **Not after errors** (wrong moment)
- **60-day cooldown** between prompts
- Apple limits to **3 prompts per 365-day period**

### Implementation

```swift
import StoreKit

@MainActor
@Observable
final class ReviewPromptManager {
    private static let sessionCountKey = "reviewPrompt.sessionCount"
    private static let lastPromptDateKey = "reviewPrompt.lastPromptDate"
    private static let minimumSessions = 3
    private static let cooldownDays = 60

    func incrementSession() {
        let count = UserDefaults.standard.integer(forKey: Self.sessionCountKey)
        UserDefaults.standard.set(count + 1, forKey: Self.sessionCountKey)
    }

    func requestReviewIfAppropriate() {
        let sessionCount = UserDefaults.standard.integer(forKey: Self.sessionCountKey)
        guard sessionCount >= Self.minimumSessions else { return }

        if let lastPrompt = UserDefaults.standard.object(forKey: Self.lastPromptDateKey) as? Date {
            let daysSince = Calendar.current.dateComponents([.day], from: lastPrompt, to: Date()).day ?? 0
            guard daysSince >= Self.cooldownDays else { return }
        }

        guard let scene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
        else { return }

        SKStoreReviewController.requestReview(in: scene)
        UserDefaults.standard.set(Date(), forKey: Self.lastPromptDateKey)
    }
}
```

### Good Trigger Points

- After a successful core action (export, save, share, etc.)
- After viewing 5+ detail screens
- After using a filter that shows results
- After the user returns for the 3rd+ session
