<div align="center">

# TransferTrack

**Navigate the 2+2 transfer path without losing credits or cash.**

[![Swift](https://img.shields.io/badge/Swift-6.0-F05138?logo=swift&logoColor=white)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS_17+-007AFF?logo=apple&logoColor=white)](https://developer.apple.com/ios/)
[![iOS 26](https://img.shields.io/badge/iOS_26-Liquid_Glass-00C4CC?logo=apple&logoColor=white)](https://developer.apple.com/ios/)
[![SwiftUI](https://img.shields.io/badge/UI-SwiftUI-blue?logo=swift&logoColor=white)](https://developer.apple.com/swiftui/)
[![CoreML](https://img.shields.io/badge/ML-CoreML-green?logo=apple&logoColor=white)](https://developer.apple.com/machine-learning/)
[![Siri](https://img.shields.io/badge/Voice-AppIntents-purple?logo=apple&logoColor=white)](https://developer.apple.com/documentation/appintents)
[![License](https://img.shields.io/badge/License-MIT-lightgrey)](LICENSE)
[![Swift Student Challenge](https://img.shields.io/badge/SSC-2026_Submission-gold?logo=apple&logoColor=white)](https://developer.apple.com/swift-student-challenge/)

</div>

---

## The Problem

Every year, over 1.2 million students transfer between U.S. institutions — nearly 500,000 moving from community colleges to four-year universities each fall. Most of them have no idea what the financial shock will look like until it's too late. Tuition doubles. Rent spikes. Credits get rejected and cost thousands. The academic transfer path is mapped out by advisors, but the financial transition is completely uncharted.

I know because I live it. I'm a first-generation CS student at Valencia College transferring to UCF. I built TransferTrack because no tool existed that could show me (in one screen) whether I could actually afford to transfer.

## What It Does

TransferTrack is a **100% offline, on-device financial forecasting agent** built for community college transfer students. It calculates your exact monthly deficit (or surplus) after transferring, scores your overall viability, maps your entire transfer timeline with state-specific milestones, and gives you actionable steps to close the gap.

---

## Features

### Ticking Math Engine

Custom `CountingText` and `CountingDollarText` views conforming to `Animatable` make your Monthly Gap visually count from $0 to your real number (like -$331) over 1.4 seconds. The Viability Ring counts frame-by-frame alongside the arc. Users said static numbers felt fake — watching the math run in real time changed their perception completely.

### CoreML Viability Score

A tabular regression model trained with Create ML predicts transfer viability (0–100) from GPA, credits, savings, and rent. Inference runs on-device with `.cpuOnly` compute units. If the model fails to load, a heuristic fallback calculates the score from the same four inputs — the app never shows an empty state. The score updates instantly when any input changes.

### Gap Explainer

Tap "How is this calculated?" on the Forecast tab and the app breaks down exactly how your Monthly Gap is computed — income vs. tuition (annualized to monthly) vs. rent vs. living expenses vs. transport. Color-coded line items. If you've completed solutions, it shows the cumulative impact: _"Includes +$450/mo from completed actions."_

### State-Specific Financial Risk Engine

Seven distinct surcharge systems, each tailored to how that state actually penalizes transfer students:

- **Florida** — Excess Credit Surcharge: 50% more per credit hour past 120% of required credits
- **Texas** — Excess Hour Tuition: extra charges for 30+ attempted hours beyond your degree plan
- **California** — Strict UC course equivalency: rejected credits require syllabi for manual review
- **Virginia** — GAA GPA minimums vary by major (Engineering at Virginia Tech needs a 3.4, not the 3.0 on the flyer)
- **Washington** — Without a completed DTA degree, credits are evaluated individually
- **North Carolina** — CAA maps specific courses; anything off-list may not count
- **New Jersey** — njtransfer.org is the source of truth for equivalencies

Each alert tells the student the exact dollar cost of their wasted credits and the exact process to appeal.

### Insider Solutions

Every solution contains specific deadlines, dollar amounts, and advice you'd normally need to pay an advisor for:

> _"TAG locks in your admission — but the window is literally one month in September. Miss it by a day and you're in the regular pool with 80,000 other applicants."_

> _"Your FAFSA from your CC does NOT auto-transfer. Refile it and add the university's school code on studentaid.gov. Do this the week you get accepted — late filers get less aid."_

> _"Most transfer students skip scholarships thinking they're only for freshmen. Wrong. Your university has transfer-specific awards — usually $1,000–$3,000/year. Application takes 20 minutes."_

When you complete a solution, the app recalculates your finances in real time. The roommate solution calculates 30% of _your specific rent_. FAFSA adds $250/mo. Work-study adds $200/mo. Complete enough actions to push your viability score past 75 and confetti rains down.

### Transfer Timeline

A zigzag timeline built with SwiftUI `Canvas` maps your entire transfer journey against real dates. State-specific milestones (DirectConnect, TAG, Cal Grant, Texas Core, GAA, DTA, CAA, NJ Transfer) appear automatically based on your path. A pulsing "NOW" indicator shows where you are. Each event has a "See Guide" button that opens a step-by-step instruction sheet.

### Transcript Scanner

Point your camera at a physical paper transcript. VisionKit's `DataScannerViewController` detects course codes via regex (`[A-Z]{2,4}\s?\d{4}[A-Z]?`), normalizes them, and maps them against a built-in database of 40+ course prefix translations (ENC → English Composition, COP → Computer Science, MAC → Mathematics, etc.). On Simulator or devices without a camera, the app shows a native `ContentUnavailableView` directing users to add courses manually — the scanner is a bonus input method, not a dependency.

### Siri Integration

`AppIntents` with `AppShortcutsProvider` and 10 registered phrase variations. Say "Siri, check my transfer plan in TransferTrack" and Siri reads your Monthly Gap and Viability Score hands-free. The ViewModel caches values to `UserDefaults` so Siri can read them without launching the full UI.

### Housing Deck

Swipeable `TabView(.page)` apartment cards with gradient headers color-coded by approval odds (green/orange/red), featured badges ("NO CREDIT CHECK", "PER-BED LEASE", "BEST VALUE"), rent vs. budget comparison pills, and insider tips per approval type. Map pins sync bidirectionally with card swipes. Five apartments per university with real approval context for students with no credit history.

### Transport Advisor

Full-screen comparison modal with real cost breakdowns for three options: Keep Current Car, Swap to Used Car, or Campus Transit. University-specific transit data for 16+ schools — shuttle names (BruinBus, Bear Transit, Bull Runner, Wolfline), bus systems, rail lines, and parking permit costs all adapt when you switch universities.

### Dynamic Everything

Switch your transfer path from Valencia → UCF to Santa Monica → UCLA and every screen adapts: tuition chart, housing listings, transport costs, transit system names, course mappings, solutions, timeline milestones, surcharge warnings, and Siri cache. All 65 schools have real coordinates, tuition data, and logo assets.

### Graceful Degradation

Three defensive fallback chains run through the app:

- **CoreML** → heuristic score if model fails to load
- **VisionKit DataScanner** → `ContentUnavailableView` with manual entry on unsupported devices
- **iOS 26 GlassEffect tab bar** → custom `FloatingTabBar` with liquid blob animation on older devices

### Liquid Glass Tab Bar

iOS 26 `GlassEffect` with `UISegmentedControl` bridge via `ImageRenderer` for modern devices. The fallback `FloatingTabBar` uses a custom blob that stretches, compresses, and lights up as you switch tabs — not a static highlight, a physics-inspired animation.

### Light/Dark/System Themes

Segmented picker in the Edit Plan sheet applies instantly via `.preferredColorScheme`. The `TTAdaptiveCardBorder` ViewModifier reads the environment and shifts borders, shadows, and gradients between modes. Light mode adds a subtle 0.5pt separator stroke for card depth.

---

## Tech Stack

| Layer     | Technology                                       | Why                                                                                          |
| --------- | ------------------------------------------------ | -------------------------------------------------------------------------------------------- |
| UI        | SwiftUI                                          | Declarative, fits the .swiftpm constraint                                                    |
| Data      | SwiftData + `@Observable`                        | `UserCourse` persisted with `@Model` and `@Query` for reactive display alongside static data |
| ML        | CoreML + Create ML                               | On-device viability prediction with `.cpuOnly` for Simulator compatibility                   |
| Vision    | VisionKit `DataScannerViewController`            | Live camera transcript scanning with `ContentUnavailableView` fallback                       |
| Voice     | AppIntents + `AppShortcutsProvider`              | Siri reads cached gap/score via `UserDefaults` without launching UI                          |
| Animation | `Animatable` protocol + `Canvas`                 | Frame-by-frame counting text, zigzag timeline spine rendering                                |
| Glass     | iOS 26 `GlassEffect` + `GlassEffectContainer`    | Liquid glass tab bar with `FloatingTabBar` fallback                                          |
| Tips      | TipKit                                           | `ExcessCreditTip` fires via `@Parameter` rule when wasted credits are detected               |
| Maps      | MapKit                                           | `Map(position:)` with `MapPolyline` distance lines between apartments and campus             |
| Charts    | Swift Charts                                     | Tuition comparison bar chart with tap interaction                                            |
| Haptics   | `UIImpactFeedbackGenerator` + `.sensoryFeedback` | Tactile response on gap changes, tab switches, solution completions                          |

---

## Accessibility

| Guideline              | Implementation                                                                                                                                                                                                             |
| ---------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **Dynamic Type**       | All text uses semantic styles (`.headline`, `.caption`) with `minimumScaleFactor`                                                                                                                                          |
| **VoiceOver**          | Key controls carry `.accessibilityLabel`; Viability ring announces "Viability Score: X out of 100, [status]" with `.updatesFrequently` trait; tuition chart reads both schools and costs; tab bar uses `.isSelected` trait |
| **Color Independence** | Icons + text labels accompany every color-coded indicator                                                                                                                                                                  |
| **Light/Dark Mode**    | Environment-aware `TTAdaptiveCardBorder` with adaptive borders and shadows                                                                                                                                                 |
| **Reduce Motion**      | Spring animations use implicit SwiftUI handling                                                                                                                                                                            |
| **Hands-Free**         | Full Siri integration via AppIntents for screen-free operation                                                                                                                                                             |

---

## Architecture

```
TransferTrack.swiftpm/
├── App/
│   └── TransferTrackApp.swift          # @main, theme, TipKit, Siri config
├── Components/
│   ├── Components.swift                # CountingText, CountingDollarText, ViabilityRing, StatCard, CollegeLogo
│   ├── LiquidTabBar.swift              # iOS 26 GlassEffect + FloatingTabBar fallback
│   └── TranscriptScanner.swift         # VisionKit camera + 40-prefix course code translator
├── Models/
│   ├── Models.swift                    # UserCourse (@Model), TransferViewModel (@Observable), AppIntents, CoreML + fallback
│   └── SchoolDatabase.swift            # 65 schools: coordinates, tuition, housing, courses, state-specific solutions
├── Theme/
│   ├── Adaptivedesign.swift            # TTAdaptiveCardBorder environment-aware ViewModifier
│   └── TTtheme.swift                   # Brand colors, GlassCard, StaggerFade, OnboardingBackground, ScoreAwareBackground
├── Views/
│   ├── Dashboard/
│   │   ├── DashboardView.swift         # Lazy tab loading, slide transitions, EditPathSheet
│   │   └── ForecastTab.swift           # Monthly Gap, Viability Ring, Bento Grid, Transport Advisor, Tuition Chart, GapExplainerSheet
│   ├── Academics/
│   │   └── AcademicsTab.swift          # Transfer Efficiency gauge, credit analysis, scanner, wasted alerts, surcharge system, TipKit
│   ├── Onboarding/
│   │   └── OnboardingFlow.swift        # 6-step onboarding with progress capsules and input validation
│   ├── Housing/
│   │   └── HousingTab.swift            # MapKit + swipeable deck + bidirectional pin sync + drag-to-snap bottom sheet
│   ├── Solutions/
│   │   └── SolutionsView.swift         # Active/completed split, progress bar, monthly savings banner, confetti at score ≥ 75
│   ├── Timeline/
│   │   └── TimelineTab.swift           # Canvas zigzag spine, state-specific milestones, pulsing NOW, guide sheets
│   └── Transport/
│       └── TransportComparisonSheet.swift  # 3-option modal with university-specific transit data for 16+ schools
└── Assets/                             # 65 college logos, app icon, pre-compiled TransferRiskModel.mlmodelc
```

---

## State Coverage

| State          | Community Colleges | Universities | Transfer Agreement |
| -------------- | ------------------ | ------------ | ------------------ |
| Florida        | 5                  | 5            | DirectConnect      |
| California     | 5                  | 5            | TAG                |
| Texas          | 5                  | 5            | TEXAS Grant        |
| Virginia       | 4                  | 5            | GAA                |
| Washington     | 4                  | 4            | DTA                |
| North Carolina | 4                  | 5            | CAA                |
| New Jersey     | 4                  | 5            | NJ Transfer        |

**31 community colleges · 34 universities · 7 states**

---

## Demo Flow (3 Minutes)

1. **Onboarding** — Enter name, select Valencia → UCF, input GPA/savings/rent
2. **Forecast** — Watch Monthly Gap tick from $0 to -$331. See Viability Ring count to 62. Tap "How is this calculated?" for the full breakdown.
3. **Transport** — Tap Compare Options. See your car at $473/mo vs. campus transit at $40/mo. Apply transit and watch the gap shrink.
4. **Timeline** — See your entire transfer journey with state-specific milestones. Tap "See Guide" on FAFSA for step-by-step instructions.
5. **Academics** — See 9 transferable credits, 3 wasted at $600 each. Tap a wasted course for the exact reason it won't transfer.
6. **Solutions** — Complete "Renew FAFSA" (+$250/mo) and "Get Work-Study" (+$200/mo). Watch the gap improve, the ring bounce, and confetti trigger when you cross green.
7. **Siri** — "Hey Siri, check my transfer plan in TransferTrack."

---

<details>
<summary><strong>Future App Store Roadmap</strong></summary>

<br>

TransferTrack is built as a Swift Playground for the challenge, but the architecture is designed to scale into a full App Store product.

**Phase 1: App Store Launch** — Interactive Home Screen Widget with live Viability Score ring and transfer countdown. Lock Screen Widget. Push notification deadline reminders for FAFSA, scholarships, and housing deposits.

**Phase 2: Live Data** — Plaid API for bank account integration. College Scorecard API for live tuition and graduation rates. Zillow/Apartments.com API for real rental listings.

**Phase 3: Community** — Peer matching for roommate finding. Advisor dashboard for aggregate transfer risk data. 50-state coverage for every major articulation agreement.

**Phase 4: Platform** — Apple Watch complication. iPad Split View for side-by-side path comparison. visionOS spatial housing map.

</details>

---

## Installation

1. **Xcode 15.3+** on macOS Sonoma or later (Xcode 26 beta for Liquid Glass tab bar)
2. Clone the repo:
   ```bash
   git clone https://github.com/GridGxly/TransferTrack.git
   ```
3. Open `TransferTrack.swiftpm` in Xcode
4. Build and run on **iPhone Simulator** (iOS 17+) or a physical device
5. **iPad Note:** Swift Playgrounds on iPad cannot resolve iOS 26 APIs (`GlassEffectContainer`, `GlassEffect`), which will cause a build failure in `LiquidTabBar.swift`. To run on iPad, build and deploy from Xcode on your Mac with your iPad as the run destination. The app includes a `FloatingTabBar` fallback that activates automatically on devices running below iOS 26.
6. No external dependencies. No API keys. No internet required.

---

## License

MIT License. See [LICENSE](LICENSE) for details.

## Author

**[Ralph Clavens Love Noel](https://rnoel.dev)**
