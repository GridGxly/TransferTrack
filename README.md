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

## Why This Exists

Every year, **2.6 million students** transfer from community colleges to four-year universities. Most have no idea what the financial shock will look like until it's too late. Tuition doubles. Rent spikes. Credits get rejected and cost thousands. The academic path is mapped by advisors, but the financial transition is completely uncharted.

I know because I live it. I'm a first-generation CS student at Valencia College transferring to UCF. I built TransferTrack because no tool existed that could show me (in one screen) whether I could actually afford to transfer.



---

## What It Does

TransferTrack is a **100% offline, on-device financial forecasting tool** built for community college transfer students. It calculates your exact monthly deficit (or surplus) after transferring, scores your overall transfer viability from 0 to 100, and gives you a personalized, state-specific action plan to close the gap.

**One screen. Full picture. No guesswork.**

---

## Design Philosophy

TransferTrack follows Apple's Human Interface Guidelines with a dark-first, glassmorphic design language built on a custom `TTBrand` design system.

| Principle | Implementation |
|-----------|----------------|
| **Glanceability** | Hero card unifies Monthly Gap + Viability Ring — one glance = "I'm losing $331/mo and my score is 62" |
| **Bento Grid** | `LazyVGrid` organizes secondary stats (Runway, Credits at Risk) into scannable tiles below the hero |
| **Glassmorphism** | `.regularMaterial` cards, `.thickMaterial` for active timeline nodes, `.ultraThinMaterial` tab bar |
| **Semantic Color** | Score > 75 = mint→teal gradient, 50–75 = amber→orange, < 50 = coral→red. Applied to ring, spine, and shadows. |
| **Motion** | Custom `Animatable` protocol on `CountingDollarText` for frame-by-frame counting. Spring physics on ring bounce (0.15s → 1.12x → 1.0x) |
| **Dark-Only** | UIKit `window.overrideUserInterfaceStyle = .dark` forces dark mode globally — including system alerts, VisionKit scanner, and permission dialogs |
| **Typography** | `.fontDesign(.rounded)` globally, 42pt hero numbers, `.caption2` uppercase section headers with 1.2pt tracking |

---

## Features

### Forecast Tab — Hero + Bento Dashboard
The most important screen. Monthly Gap and Viability Score sit side-by-side in a single hero card (Apple HIG "Glanceability" pattern). Below it, a 2-column bento grid shows Runway and Credits at Risk. Transport Advisor and Tuition Impact chart complete the vertical flow. Every number animates from zero on appear.

### Timeline Tab — Zig-Zag Transfer Path
A central spine with alternating left/right cards showing every milestone from FAFSA to move-in day. Past events show solid gradient lines and checkmark nodes. The current event pulses amber with a "NOW" badge. Future events use dashed lines and hollow nodes. Each actionable card has a **"See Guide"** button that opens a state-specific step-by-step sheet with 5 concrete instructions per milestone.

### Academics Tab — Credit Analysis
Transfer Efficiency gauge with AA/AS badge at ≥ 60 credits. Transferable courses listed with subject icons and grade badges. Wasted credits section shows per-course dollar cost with tap-for-explanation sheets. State-specific surcharge alerts (e.g., Florida's Excess Credit Surcharge: 50% more per credit past 120%). SwiftData-backed user courses with swipe-to-delete. VisionKit transcript scanner for instant course code recognition.

### Housing Tab — Interactive Map Deck
MapKit map with color-coded pins (green = High Odds, amber = Medium, red = Low). Draggable bottom sheet with three detents (peek, half, full). Swipeable apartment cards with gradient headers, rent comparison pills, featured badges ("NO CREDIT CHECK", "PER-BED LEASE"), and insider tips per approval type. Bidirectional selection: tap a pin and the card swipes to match, or swipe a card and the map pans.

### Solutions Tab — Action Plan Checklist
State-specific solutions ranked by point value. Progress bar with earned/total points. Each completed action recalculates the Viability Score in real-time. When the score crosses 75 (green threshold), a confetti celebration triggers with haptic feedback. Monthly savings from completed actions display as a running total pill.

### Transport Advisor — Full Comparison Modal
Three options: Keep Current Car, Swap to Used Car, Campus Transit. Each shows itemized monthly costs (gas, insurance, maintenance, parking permit), pros/cons, and a total. University-specific: parking permit costs, shuttle names, bus systems, and rail lines adapt to the selected school. Summary bar at the bottom for instant visual comparison.

### Siri Integration
"Hey Siri, check my transfer plan in TransferTrack." AppIntents read your Monthly Gap and Viability Score hands-free from a cold app state via `UserDefaults` cache. Ten phrase variations registered through `AppShortcutsProvider`.

### VisionKit Transcript Scanner
Point your camera at a paper transcript. `DataScannerViewController` with regex pattern `[A-Z]{2,4}\s?\d{4}[A-Z]?` detects course codes in real-time. Recognized codes are auto-mapped to transferable vs. wasted credit buckets and inserted as SwiftData records.

### Onboarding
Six-screen cinematic flow: Hero → Name → Path (state/CC/uni pickers with animated beam) → Academics (clamped GPA 0.0–4.0 with live gauge) → Finances → Loading (pulsing orb with sequential checkmarks). Background color shifts through deep blue → indigo → purple → teal → amber → emerald. Custom `staggerFade` modifier with configurable delay and y-offset.

### Liquid Glass Tab Bar
iOS 26+ glass segmented control via `UISegmentedControl` bridge (`GlassTabBar`). iOS 17 fallback: custom `FloatingTabBar` with `.ultraThinMaterial` capsule and animated blob that slides behind the selected tab with stretch/compress physics. `.sensoryFeedback(.selection)` on every tab change.

> **Note:** Xcode app playgrounds run in Simulator. Camera features (transcript scanner) require a physical device.

---

## Tech Stack

| Layer | Technology | Why |
|-------|-----------|-----|
| UI | SwiftUI | Declarative, single `.swiftpm` constraint compatible |
| State | `@Observable` (iOS 17) | Reactive ViewModel without `ObservableObject` boilerplate |
| Persistence | SwiftData + `@Query` | User-added courses survive app restarts |
| ML | CoreML | On-device viability prediction from GPA, credits, savings, rent |
| Vision | VisionKit `DataScannerViewController` | Live camera text recognition for transcript scanning |
| Voice | AppIntents + `AppShortcutsProvider` | Background-capable Siri integration with cached state |
| Animation | `Animatable` protocol | Frame-by-frame counting text for financial figures |
| Tips | TipKit | Contextual education (Excess Credit Surcharge) |
| Maps | MapKit | Interactive apartment pins with bidirectional selection sync |
| Charts | Swift Charts | Tuition comparison with hidden axes and bar annotations |
| Haptics | `UIImpactFeedbackGenerator` + `.sensoryFeedback` | Tactile response on score changes, tab switches, completions |

---

## Accessibility

| Guideline | Implementation |
|-----------|---------------|
| **Dynamic Type** | All text uses semantic styles (`.headline`, `.caption`) with `minimumScaleFactor` |
| **VoiceOver** | Viability Ring: `.accessibilityLabel("Viability Score")` + `.accessibilityValue("\(score) out of 100")` + `.accessibilityAddTraits(.updatesFrequently)`. Timeline rows: `.accessibilityElement(children: .combine)`. Path header: custom `.accessibilityLabel` |
| **Color Independence** | Every color-coded indicator has an accompanying icon + text label |
| **Reduce Motion** | Spring animations respect system preference via implicit SwiftUI handling |
| **Hands-Free** | Full Siri integration via AppIntents for screen-free operation |

---

## Architecture

```
TransferTrack.swiftpm/
├── App/
│   └── TransferTrackApp.swift        # @main, force dark mode, TipKit, Siri config
├── Components/
│   ├── LiquidDesign.swift            # CountingText, ViabilityRing, GlassCard, TTBrand
│   ├── LiquidTabBar.swift            # Glass (iOS 26) + Floating (iOS 17) tab bars
│   └── TranscriptScanner.swift       # VisionKit camera integration
├── Models/
│   ├── Models.swift                  # UserCourse, TransferViewModel, AppIntents, CoreML
│   └── SchoolDatabase.swift          # 7-state data: schools, tuition, housing, courses, solutions
├── Theme/
│   └── TTTheme.swift                 # Design tokens, semantic gradients, materials
├── Views/
│   ├── Dashboard/
│   │   ├── DashboardView.swift       # Tab container + EditPathSheet
│   │   └── ForecastTab.swift         # Hero card, Bento grid, Transport, Tuition chart
│   ├── Academics/
│   │   └── AcademicsTab.swift        # Credits, scanner, wasted alerts, surcharge
│   ├── Onboarding/
│   │   └── OnboardingFlow.swift      # 6-screen cinematic onboarding
│   ├── Housing/
│   │   └── HousingTab.swift          # Map + draggable sheet + apartment cards
│   ├── Solutions/
│   │   └── SolutionsTab.swift        # Checklist, progress, celebrations
│   ├── Timeline/
│   │   └── TimelineTab.swift         # Zig-zag spine, See Guide sheets, Canvas spine
│   └── Transport/
│       └── TransportComparisonSheet.swift  # 3-option comparison modal
└── Assets/                           # College logos, app icon
```

---

## State Coverage

| State | Community Colleges | Universities | Transfer Agreement | Timeline Events |
|-------|-------------------|-------------|-------------------|-----------------|
| Florida | 5 | 5 | DirectConnect | FAFSA + DirectConnect eligibility |
| California | 5 | 5 | TAG | TAG application + Cal Grant deadline |
| Texas | 5 | 5 | Texas Core | 42-credit Core Curriculum completion |
| Virginia | 4 | 5 | GAA | Guaranteed Admission GPA verification |
| Washington | 4 | 4 | DTA | Direct Transfer Agreement completion |
| North Carolina | 4 | 5 | CAA | Comprehensive Articulation cross-check |
| New Jersey | 4 | 5 | NJ Transfer | njtransfer.org equivalency evaluation |

**31 community colleges · 34 universities · 7 states · 12 guide sheet templates**

Each state has custom courses, solutions, surcharge warnings, transfer agreement steps, and timeline events. Nothing is generic.

---

## Prerequisites & Installation

1. **Xcode 15.3+** on macOS Sonoma or later
2. Clone the repo:
   ```bash
   git clone https://github.com/GridGxly/TransferTrack.git
   ```
3. Open `TransferTrack.swiftpm` in Xcode (or Swift Playgrounds on iPad)
4. Build and run on **iPad Simulator** (iOS 17+) or a physical device
5. No external dependencies. No SPM packages. No API keys. No internet required.

---

## Demo Flow (3 Minutes)

1. **Onboarding** — Enter name, select Santa Fe College → FIU, input GPA 3.2 / 31 credits / $2,800 savings / $1,200 rent
2. **Forecast** — Watch Monthly Gap tick from $0 to -$346. See Viability Ring count to 75. Hero card shows both at a glance.
3. **Transport** — Tap Compare. See Keep Car at $473/mo vs. Transit at $0/mo (free FIU shuttle). Apply Transit.
4. **Academics** — 7 transferable courses (22 cr), 3 wasted ($1,800 lost). Tap "Art Appreciation" → see why it doesn't transfer.
5. **Housing** — Swipe apartment cards. Pull sheet to full. Read insider tip about per-bed leases.
6. **Solutions** — Complete "Renew FAFSA" and "Get Work-Study." Watch score bounce and gap improve.
7. **Timeline** — Scroll the zig-zag path. Tap "See Guide" on DirectConnect → 5-step walkthrough appears.
8. **Siri** — "Hey Siri, check my transfer plan in TransferTrack."

---

## Testing Checklist

| Test | What to Verify |
|------|---------------|
| **Timeline card width** | Cards fill half the screen on iPad. No 60px crushed cards. No ghost duplicates. |
| **See Guide sheet** | Tapping "See Guide" opens an opaque sheet with 5 numbered steps. No blank/green screen. |
| **State switching** | Change Florida → California in Edit Path. Timeline shows TAG + Cal Grant (not DirectConnect). |
| **Dark mode enforcement** | VisionKit scanner, system alerts, and permission dialogs all render dark. |
| **Siri cold start** | Force-quit app → "Hey Siri, check my transfer plan" → Siri reads gap + score without opening app. |
| **SwiftData flow** | Add a course in Academics → Forecast tab updates credits/gap in real-time. |
| **GPA clamping** | Enter 5.0 in onboarding → clamped to 4.0. Enter -1 → clamped to 0.0. |
| **Wasted credits scroll** | Tap "View Wasted Credits" in surcharge alert → scrolls to wasted section after 0.6s delay. |
| **Transcript scanner** | Point camera at "ENC 1101" text → regex match highlights → course added to SwiftData. |

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

Built from personal adversity. Designed for every transfer student who deserves a plan.
