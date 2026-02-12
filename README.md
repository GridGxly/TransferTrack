# TransferTrack

**A financial planning tool for community college students transferring to 4-year universities.**

Built for the [Swift Student Challenge 2026](https://developer.apple.com/swift-student-challenge/) — targeting Distinguished Winner (Top 50).

---

## The Problem

Every year, **2.4 million students** transfer from community college to a 4-year university. They're told it's the smart, cheap path. But thousands get blindsided by **Transfer Shock** — the sudden spike in tuition, rent, and living costs that no one warns you about.

- Tuition triples overnight
- Rent doubles, savings vanish
- Credits get rejected — thousands wasted

**I built this because I realized 2+2 ≠ cheap.** As a Valencia College student planning to transfer to UCF, I didn't want to lose $15k. Neither should you.

## What It Does

TransferTrack predicts your financial cliff *before* you transfer, then gives you a personalized action plan to close the gap.

### Features

- **Viability Score** — A 0–100 score showing how prepared you are for transfer, based on GPA, credits, savings, and rent
- **Tuition Comparison** — Side-by-side CC vs. university costs with actual college logos
- **Credit Transfer Analysis** — See which credits are degree-applicable vs. wasted, with exact dollar cost and months lost
- **Location-Aware Housing** — Apartments near your specific university with beds/baths, distance, monthly rent, and approval odds
- **Personalized Solutions** — State-specific transfer programs (FL DirectConnect, CA TAG, TX Core Curriculum) and actionable steps with point values

### Supported States

Florida · California · Texas · Virginia · Washington · North Carolina · New Jersey

70 schools supported across community colleges and universities.

## Screenshots

*Coming soon*

## Architecture

```
TransferTrack/
├── TransferTrackApp.swift              # App entry point + routing
├── Models/
│   └── SchoolDatabase.swift            # 70 schools, logos, housing, courses, solutions
├── Shared/
│   └── LiquidDesign.swift              # Design system (Liquid Glass, CollegeLogo, StatCard, BottomTabBar)
└── Views/
    ├── Onboarding/
    │   └── EliteOnboarding.swift       # 4-page onboarding with interactive demo
    └── Dashboard/
        ├── DashboardView.swift         # Main dashboard + bottom segmented nav
        ├── ForecastView.swift          # Viability ring, stat cards, tuition comparison
        ├── AcademicsView.swift         # Credit transfer analysis
        ├── HousingView.swift           # University-specific apartments
        └── SolutionsView.swift         # Actionable checklist with point values
```



## Technical Details

- **Platform:** iOS 17+
- **Frameworks:** SwiftUI, Charts, UIKit (haptics only)
- **No external dependencies** — pure Apple frameworks (SSC requirement)
- **No network access** — all data is embedded (SSC apps are offline)
- **Accessibility:** All fonts use semantic styles (Dynamic Type compatible), VoiceOver-ready
- **Design:** Apple Liquid Glass (`.ultraThinMaterial`), semantic fonts, bottom tab navigation

## Design Principles

| Principle | Implementation |
|-----------|---------------|
| **Liquid Glass** | `.ultraThinMaterial` backgrounds with white stroke overlays |
| **Dynamic Type** | All fonts are `.headline`, `.body`, `.caption` — no hardcoded sizes |
| **Show, Don't Tell** | Interactive slider in onboarding lets users *feel* the cost spike |
| **Location-Aware** | Housing, courses, and solutions adapt to the user's CC → University path |
| **Personal Narrative** | No fictional stories — the app speaks from the developer's own experience |

## Getting Started

1. Clone the repo
2. Open in Xcode 15+ or Swift Playgrounds
3. The `Assets/Collegelogos/` folder should contain 70 school logo images (not included in this repo due to licensing)
4. Build and run on iOS 17+ simulator or device

## Submission

**Deadline:** February 28, 2026

This project is a submission for the Apple Swift Student Challenge 2026. The app is a self-contained Swift Playground that demonstrates financial planning for transfer students.

## License

This project is for educational purposes as part of the Swift Student Challenge. All rights reserved.

---

*Built with frustration, determination, and way too much sleepless nights*
