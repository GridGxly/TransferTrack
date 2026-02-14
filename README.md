<div align="center">

# TransferTrack

**Navigate the 2+2 transfer path without losing credits or cash.**

The on-device financial forecasting agent built for community college transfer students.

![Swift](https://img.shields.io/badge/Swift-5.9+-F05138?style=flat-square&logo=swift&logoColor=white)
![SwiftUI](https://img.shields.io/badge/SwiftUI-iOS%2017+-007AFF?style=flat-square&logo=apple&logoColor=white)
![CoreML](https://img.shields.io/badge/CoreML-VisionKit-34C759?style=flat-square&logo=apple&logoColor=white)
![Siri](https://img.shields.io/badge/Siri-AppIntents-5856D6?style=flat-square&logo=apple&logoColor=white)
![Offline](https://img.shields.io/badge/100%25-Offline%20First-FF9500?style=flat-square)
![License](https://img.shields.io/badge/License-MIT-lightgrey?style=flat-square)

*2026 Apple Swift Student Challenge Submission*

</div>

---

## The Problem

The "2+2" transfer path is sold as the smart, cheap way to get a degree. For thousands of students, it's a trap.

Students transfer from community college to university and get hit with **Transfer Shock**: credits get rejected, tuition doubles, financial aid formulas change, and they suddenly need to qualify for an apartment with no credit history.

Standard budgeting apps track what you spent yesterday. **TransferTrack predicts exactly what your life will look like the day you step onto the university campus.**

---

## Features

### 📊 Financial Forecast Engine
- **Monthly Gap Calculator** — Projects your income vs. expenses *after* transfer, factoring in tuition jumps, rent changes, and transport costs
- **Viability Score** — A dynamic 0–100 score computed from GPA, credits, savings, and rent (with optional CoreML model inference)
- **Tuition Jump Visualization** — Interactive Swift Charts comparing CC vs. university tuition with tap-to-inspect details

### 📷 Transcript Scanner (CoreML + VisionKit)
- Point your camera at a paper transcript
- Regex-backed `DataScannerViewController` detects course codes like `MAC 1105` in real-time
- Auto-maps 60+ course prefixes to human-readable titles
- Tap detected codes to add — no manual typing required

### 🗣️ Siri Integration (AppIntents)
- *"Hey Siri, check my transfer plan in TransferTrack"*
- Returns your Monthly Gap and Viability Score entirely hands-free
- 10 phrase variations with `INAlternativeAppNames` for natural speech recognition
- Works even when the app is backgrounded

### 🏠 Interactive Housing Map
- MapKit-powered apartment listings positioned by distance from campus
- Color-coded approval odds (High/Medium/Low) based on student-friendly criteria
- Custom bottom sheet with peek/half/full detents and gesture-driven snapping
- Route polylines from apartment to campus

### 📚 Academic Credit Analysis
- Automatic transfer eligibility checking per school pair
- **Wasted Credits Alert** — Native `.alert()` warns about Florida's Excess Credit Surcharge (50% penalty above 120% degree credits)
- SwiftData persistence for user-added courses with swipe-to-delete

### 💡 Solutions Tab (Gamified Recovery)
- Actionable steps: find a roommate, apply for state scholarships, get a campus job
- Each solution **dynamically recalculates** the Viability Score and Monthly Gap in real-time
- State-specific: DirectConnect (FL), TAG (CA), TEXAS Grant (TX), GAA (VA), DTA (WA), CAA (NC), NJ Transfer (NJ)
- Progress bar with points system — celebrate when score turns green

### 🎨 UI/UX Polish
- **Framer Motion onboarding** — Custom `.framerFade(delay:yOffset:)` ViewModifier creates staggered cascading entrance animations
- **Liquid Glass Tab Bar** — iOS 26 `GlassEffect` with fallback `FloatingTabBar` featuring gooey blob physics, rim lighting, and bounce animations
- **Light/Dark Mode** — `systemGroupedBackground` + `.cardBorder()` modifier for perfect contrast in both modes
- **Confetti celebrations** — 60-credit milestone overlay and green-score celebration with particle effects

---

## The Tech Stack

| Layer | Technology | Why |
|-------|-----------|-----|
| **UI Framework** | SwiftUI + iOS 17 | Declarative, composable, challenge-compliant |
| **Data Persistence** | SwiftData (`@Model`) | Native Swift ORM for user courses |
| **State Management** | `@Observable` + `updateTrigger` pattern | Forces computed property recalc after async dismissals |
| **Camera/OCR** | VisionKit `DataScannerViewController` | On-device text recognition, no API calls |
| **ML Inference** | CoreML (`MLModel`) | Optional viability prediction with CPU-only config |
| **Voice Assistant** | AppIntents + Siri Shortcuts | Hands-free access to financial data |
| **Maps** | MapKit + `MapPolyline` | Housing visualization with route overlays |
| **Charts** | Swift Charts | Tuition comparison bar charts |
| **Tips** | TipKit | Contextual education (Excess Credit Surcharge) |
| **Concurrency** | `@MainActor`, Swift strict concurrency | Zero warnings under strict checking |
| **Animations** | Custom ViewModifiers, `.spring()`, `.symbolEffect` | 60fps cascading and bouncing transitions |

**Architecture**: Single-target `.swiftpm` App Playground. Zero external dependencies. Zero network calls. 100% offline.

---

## Prerequisites & Installation

### For Swift Student Challenge Judges
1. Open the `.swiftpm` file in **Xcode 16+**
2. Select **iPhone 14 Plus** simulator (or any iOS 17+ device)
3. Press **Run** (⌘R)
4. The app can be experienced within **3 minutes**

### Requirements
- Xcode 16.0+
- iOS 17.0+ deployment target
- No external packages or CocoaPods required

> **Note**: Xcode app playgrounds are run in Simulator. Camera features (transcript scanner) require a physical device.

---

## Accessibility & HIG Compliance

| Guideline | Implementation |
|-----------|---------------|
| **Dynamic Type** | All text uses semantic styles (`.headline`, `.caption`) with `minimumScaleFactor` |
| **VoiceOver** | Custom `.accessibilityLabel` on all controls; Viability ring announces "Score: X out of 100" |
| **Color Independence** | Icons + text labels accompany every color-coded indicator |
| **Light/Dark Mode** | `systemGroupedBackground` / `secondarySystemGroupedBackground` with conditional card borders |
| **Reduce Motion** | Spring animations respect system preference via implicit SwiftUI handling |
| **Hands-Free** | Full Siri integration via AppIntents for screen-free operation |

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

**31 community colleges • 34 universities • 7 states**

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

## Author

**Ralph Clavens Love Noel**
Computer Science Major


*Built from personal adversity. Designed for every transfer student who deserves a plan.*

---

<div align="center">

*TransferTrack — Because your future shouldn't be a surprise.*

</div>
