# TransferTrack

**Navigate the 2+2 transfer path without losing credits or cash.**

[![Swift](https://img.shields.io/badge/Swift-5.9-F05138?logo=swift&logoColor=white)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS_17+-007AFF?logo=apple&logoColor=white)](https://developer.apple.com/ios/)
[![SwiftUI](https://img.shields.io/badge/UI-SwiftUI-blue?logo=swift&logoColor=white)](https://developer.apple.com/swiftui/)
[![CoreML](https://img.shields.io/badge/ML-CoreML-green?logo=apple&logoColor=white)](https://developer.apple.com/machine-learning/)
[![Siri](https://img.shields.io/badge/Voice-AppIntents-purple?logo=apple&logoColor=white)](https://developer.apple.com/documentation/appintents)
[![License](https://img.shields.io/badge/License-MIT-lightgrey)](LICENSE)
[![Swift Student Challenge](https://img.shields.io/badge/SSC-2026_Submission-gold?logo=apple&logoColor=white)](https://developer.apple.com/swift-student-challenge/)

---

## The Problem

Every year, 2.6 million students transfer from community colleges to four-year universities. Most of them have no idea what the financial shock will look like until it's too late. Tuition doubles. Rent spikes. Credits get rejected and cost thousands. The academic transfer path is mapped out by advisors, but the financial transition is completely uncharted.

I know because I live it. I'm a first-generation CS student at Valencia College transferring to UCF. I built TransferTrack because no tool existed that could show me (in one screen) whether I could actually afford to transfer.

## What It Does

TransferTrack is a **100% offline, on-device financial forecasting agent** built for community college transfer students. It calculates your exact monthly deficit (or surplus) after transferring, scores your overall viability, maps your entire transfer timeline with state-specific milestones, and gives you actionable steps to close the gap.

## Features

- **Ticking Math Engine** — Custom `CountingText` and `CountingDollarText` views conforming to `Animatable` make your Monthly Gap visually count from $0 to your real number (like $-331) over 1.4 seconds. The Viability Ring counts frame-by-frame alongside the arc. Numbers feel alive, not static.

- **Transfer Timeline** — A zigzag timeline built with SwiftUI `Canvas` that maps your entire transfer journey against real dates. State-specific milestones (DirectConnect, TAG, Cal Grant, Texas Core, GAA, DTA, CAA, NJ Transfer) appear automatically based on your transfer path. A pulsing "NOW" indicator shows where you are. Each event has a "See Guide" button that opens a step-by-step instruction sheet.

- **CoreML Transcript Scanner** — Point your camera at a physical paper transcript. VisionKit + CoreML detect course codes (regex pattern: `[A-Z]{2,4}\s?\d{4}[A-Z]?`), and the app digitizes them into transferable vs. wasted credit buckets instantly.

- **Siri Integration (AppIntents)** — Say "Siri, check my transfer plan in TransferTrack." Siri reads your Monthly Gap and Viability Score hands-free. Ten phrase variations registered.

- **Housing Deck** — Swipeable `TabView(.page)` apartment cards with gradient headers color-coded by approval odds (green/orange/red), featured badges ("NO CREDIT CHECK", "PER-BED LEASE", "BEST VALUE"), rent vs. budget comparison pills, and insider tips per approval type. Map pins sync bidirectionally with card swipes via a custom drag-to-snap bottom sheet.

- **Transport Advisor** — Full-screen comparison modal with real cost breakdowns for three options: Keep Current Car, Swap to Used Car, or Campus Transit. Each option shows itemized monthly costs, pros/cons, and a total. University-specific transit data for 16+ schools: shuttle names (BruinBus, Bear Transit, Bull Runner, Wolfline), bus systems, rail lines, and parking permit costs all adapt when you switch universities.

- **Insider Solutions** — Every solution is hand-written with specific deadlines, dollar amounts, and insider tricks. State-specific paths for Florida, California, Texas, Virginia, Washington, North Carolina, and New Jersey. Progress bar tracks earned points. Confetti celebration triggers when your viability score crosses into green.

- **Wasted Credit Alerts** — Auto-detects courses that won't transfer, calculates the dollar cost, warns about Florida's Excess Credit Surcharge (50% more per credit hour past 120%), and scrolls directly to the problem courses when you tap "View Wasted Credits."

- **Dynamic Everything** — Switch your transfer path from Valencia → UCF to Santa Monica → UCLA and every screen adapts: tuition chart, housing listings, transport costs, transit system names, course mappings, solutions, timeline milestones, and Siri cache.

- **Liquid Glass Tab Bar** — iOS 26 `GlassEffect` tab bar with `UISegmentedControl` bridge via `ImageRenderer` for modern devices, plus a custom `FloatingTabBar` with liquid blob animation (stretch, compress, rim light) as a graceful fallback.

- **Adaptive Design System** — Reusable `TTAdaptiveCardBorder` ViewModifier with environment-aware borders, shadows, and gradients that shift between light and dark mode.

- **Light/Dark/System Themes** — Segmented picker in Edit Plan sheet applies instantly via `.preferredColorScheme`. Cards use adaptive borders in light mode for depth.

> **Note:** Xcode app playgrounds are run in Simulator. Camera features (transcript scanner) require a physical device.

---

## Tech Stack

| Layer | Technology | Why |
|-------|-----------|-----|
| UI | SwiftUI | Declarative, fits the single-file .swiftpm constraint |
| Data | SwiftData + `@Observable` | Persistent user courses with `@Query`, reactive ViewModel |
| ML | CoreML | On-device viability prediction (GPA, Credits, Savings, Rent) |
| Vision | VisionKit `DataScannerViewController` | Live camera text recognition for transcript scanning |
| Voice | AppIntents + `AppShortcutsProvider` | Siri integration with 10 registered phrases |
| Animation | `Animatable` protocol + `Canvas` | Frame-by-frame counting text, zigzag timeline rendering |
| Glass | iOS 26 `GlassEffect` + `GlassEffectContainer` | Liquid glass tab bar with `UISegmentedControl` bridge |
| Tips | TipKit | Contextual Excess Credit Surcharge education |
| Maps | MapKit | Interactive apartment pins with selection sync |
| Charts | Swift Charts | Tuition comparison bar chart with tap interaction |
| Haptics | `UIImpactFeedbackGenerator` + `.sensoryFeedback` | Tactile response on gap changes, tab switches, completions |

---

## Accessibility & HIG Compliance

| Guideline | Implementation |
|-----------|---------------|
| **Dynamic Type** | All text uses semantic styles (`.headline`, `.caption`) with `minimumScaleFactor` |
| **VoiceOver** | Custom `.accessibilityLabel` on all controls; Viability ring announces "Score: X out of 100" |
| **Color Independence** | Icons + text labels accompany every color-coded indicator |
| **Light/Dark Mode** | Adaptive design system with environment-aware borders and shadows |
| **Reduce Motion** | Spring animations respect system preference via implicit SwiftUI handling |
| **Hands-Free** | Full Siri integration via AppIntents for screen-free operation |

---

## Architecture

```
TransferTrack.swiftpm/
├── App/
│   └── TransferTrackApp.swift          # @main, theme, TipKit, Siri config
├── Components/
│   ├── Components.swift                # CountingText, ViabilityRing, StatCard, CollegeLogo
│   ├── LiquidTabBar.swift              # iOS 26 GlassEffect + FloatingTabBar fallback
│   └── TranscriptScanner.swift         # VisionKit camera integration
├── Models/
│   ├── Models.swift                    # UserCourse, TransferViewModel, AppIntents, CoreML
│   └── SchoolDatabase.swift            # 7-state data: schools, tuition, housing, courses, solutions
├── Theme/
│   ├── Adaptivedesign.swift            # TTAdaptiveCardBorder environment-aware ViewModifier
│   └── TTtheme.swift                   # Brand colors, GlassCard, StaggerFade, OnboardingBackground
├── Views/
│   ├── Dashboard/
│   │   ├── DashboardView.swift         # Tab container + EditPathSheet
│   │   └── ForecastTab.swift           # Monthly Gap, Viability Ring, Transport Advisor
│   ├── Academics/
│   │   └── AcademicsTab.swift          # Credit analysis, scanner, wasted alerts, milestones
│   ├── Onboarding/
│   │   └── OnboardingFlow.swift        # 6-step onboarding with staggered animations
│   ├── Housing/
│   │   └── HousingTab.swift            # Map + swipeable deck + drag-to-snap bottom sheet
│   ├── Solutions/
│   │   └── SolutionsView.swift         # Checklist with points, celebrations
│   ├── Timeline/
│   │   └── TimelineTab.swift           # Zigzag timeline, Canvas spine, guide sheets
│   └── Transport/
│       └── TransportComparisonSheet.swift  # 3-option modal with university-specific data
└── Assets/                             # College logos, app icon, CoreML model
```

---

## State Coverage

| State | Community Colleges | Universities | Transfer Agreement |
|-------|-------------------|-------------|-------------------|
| Florida | 5 | 5 | DirectConnect |
| California | 5 | 5 | TAG |
| Texas | 5 | 5 | TEXAS Grant |
| Virginia | 4 | 5 | GAA |
| Washington | 4 | 4 | DTA |
| North Carolina | 4 | 5 | CAA |
| New Jersey | 4 | 5 | NJ Transfer |

**31 community colleges · 34 universities · 7 states**

---

## Prerequisites & Installation

1. **Xcode 15.3+** on macOS Sonoma or later (Xcode 26 for Liquid Glass tab bar)
2. Clone the repo:
   ```bash
   git clone https://github.com/GridGxly/TransferTrack.git
   ```
3. Open `TransferTrack.swiftpm` in Xcode (or Swift Playgrounds on iPad)
4. Build and run on **iPhone Simulator** (iOS 17+) or a physical device
5. No external dependencies. No API keys. No internet required.

---

## Demo Flow (3 Minutes)

1. **Onboarding** — Enter name, select Valencia → UCF, input GPA/savings/rent
2. **Forecast** — Watch Monthly Gap tick from $0 to $-331. See Viability Ring count to 62.
3. **Transport** — Tap Compare Options. See your car at $473/mo vs. transit at $40/mo. Apply transit.
4. **Timeline** — See your entire transfer journey. Tap "See Guide" on FAFSA for step-by-step instructions.
5. **Academics** — See 9 transferable credits, 3 wasted. Tap a wasted course for details.
6. **Solutions** — Complete "Renew FAFSA" and "Get Work-Study." Watch gap improve and ring bounce.
7. **Siri** — "Hey Siri, check my transfer plan in TransferTrack."

---

## Future App Store Roadmap

TransferTrack is built as a Swift Playground for the challenge, but the architecture is designed to scale into a full App Store product.

### Phase 1: App Store Launch (iOS 18)

- **Interactive Home Screen Widget** — A medium-sized widget showing a live Viability Score ring, monthly gap, and a transfer countdown ("42 days to Fall 2026"). Uses `AppIntentTimelineProvider` for background refresh.
- **Lock Screen Widget** — Circular gauge showing Viability Score at a glance.
- **Push Notifications** — Deadline reminders for FAFSA renewal, scholarship applications, and housing deposits.

### Phase 2: Live Data Integration

- **Plaid API** — Securely connect bank accounts to auto-populate savings and track spending patterns.
- **College Scorecard API** — Pull live tuition, graduation rates, and financial aid data from the U.S. Department of Education.
- **Zillow/Apartments.com API** — Real-time rental listings with actual approval requirements.

### Phase 3: Community & Scale

- **Peer Matching** — Connect transfer students heading to the same university for roommate matching.
- **Advisor Dashboard** — Web portal for academic advisors to view aggregate transfer risk data.
- **50-State Coverage** — Expand from 7 states to all 50, covering every major articulation agreement.

### Phase 4: Platform

- **Apple Watch Complication** — Viability Score ring on your wrist.
- **iPad Split View** — Side-by-side forecast comparison for different school paths.
- **visionOS** — Spatial housing map with 3D apartment walkthroughs.

---

## License

MIT License. See [LICENSE](LICENSE) for details.

---

## Author

**[Ralph Clavens Love Noel](https://www.linkedin.com/in/ralphnoel/)**
