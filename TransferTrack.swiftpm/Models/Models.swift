import SwiftData
import Foundation
import CoreLocation
import SwiftUI
import Observation
import TipKit
import AppIntents
import CoreML



func clampGPA(_ val: Double) -> Double {
    min(4.0, max(0.0, val))
}

func clampGPAInput(_ text: String) -> String {

    if text.isEmpty { return text }

    if text == "." || text == "0." { return "0." }

    let cleaned = text.filter { $0.isNumber || $0 == "." }

    let parts = cleaned.split(separator: ".", maxSplits: 2, omittingEmptySubsequences: false)
    var result: String
    if parts.count > 1 {
        let intPart = String(parts[0])
        let decPart = String(parts[1].prefix(2))
        result = "\(intPart).\(decPart)"
    } else {
        result = cleaned
    }

    if let val = Double(result) {
        if val > 4.0 { return "4.0" }
        if val < 0.0 { return "0.0" }
    }
    return result
}



@available(iOS 17.0, *)
@Model
final class UserCourse {
    var code: String
    var title: String
    var credits: Int
    var grade: String
    var transfers: Bool
    var costIfWasted: Int
    var dateAdded: Date

    init(code: String, title: String, credits: Int, grade: String, transfers: Bool, costIfWasted: Int) {
        self.code = code
        self.title = title
        self.credits = credits
        self.grade = grade
        self.transfers = transfers
        self.costIfWasted = costIfWasted
        self.dateAdded = Date()
    }
}



@available(iOS 17.0, *)
struct ExcessCreditTip: Tip {
    var title: Text { Text("Excess Credit Surcharge") }
    var message: Text? {
        Text("Some states charge extra per credit hour once you exceed the required credits for your degree. Check the wasted credits section below.")
    }
    var image: Image? { Image(systemName: "exclamationmark.triangle.fill") }

    @Parameter
    static var hasWastedCredits: Bool = false

    var rules: [Rule] {
        [#Rule(Self.$hasWastedCredits) { $0 == true }]
    }
}



enum AppTheme: String, CaseIterable, Identifiable {
    case system, light, dark
    var id: String { rawValue }

    var label: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }

    var icon: String {
        switch self {
        case .system: return "circle.lefthalf.filled"
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}



@available(iOS 17.0, *)
@Observable
final class TransferViewModel {
    var userName: String { didSet { save("userName", userName) } }
    var selectedState: String { didSet { save("selectedState", selectedState) } }
    var selectedCC: String { didSet { save("selectedCC", selectedCC) } }
    var selectedUni: String { didSet { save("selectedUni", selectedUni) } }
    var userGPA: Double { didSet { UserDefaults.standard.set(clampGPA(userGPA), forKey: "userGPA") } }
    var userCredits: Double { didSet { UserDefaults.standard.set(userCredits, forKey: "userCredits") } }
    var userSavings: Double { didSet { UserDefaults.standard.set(userSavings, forKey: "userSavings") } }
    var userRent: Double { didSet { UserDefaults.standard.set(userRent, forKey: "userRent") } }
    var transportMode: Int { didSet { UserDefaults.standard.set(transportMode, forKey: "transportMode") } }
    var transferSemester: String { didSet { save("transferSemester", transferSemester) } }
    var completedSolutions: Set<Int> {
        didSet { persistCompletedSolutions() }
    }

    var updateTrigger: Int = 0

    init() {
        let d = UserDefaults.standard
        self.userName = d.string(forKey: "userName") ?? ""
        self.selectedState = d.string(forKey: "selectedState") ?? "Florida"
        self.selectedCC = d.string(forKey: "selectedCC") ?? "Valencia College"
        self.selectedUni = d.string(forKey: "selectedUni") ?? "UCF"
        self.userGPA = clampGPA(d.double(forKey: "userGPA") == 0 ? 3.2 : d.double(forKey: "userGPA"))
        self.userCredits = d.double(forKey: "userCredits") == 0 ? 45 : d.double(forKey: "userCredits")
        self.userSavings = d.double(forKey: "userSavings") == 0 ? 2500 : d.double(forKey: "userSavings")
        self.userRent = d.double(forKey: "userRent") == 0 ? 1200 : d.double(forKey: "userRent")
        self.transportMode = d.integer(forKey: "transportMode")
        self.transferSemester = d.string(forKey: "transferSemester") ?? "Fall 2026"

        if let stored = d.array(forKey: "completedSolutions") as? [Int] {
            self.completedSolutions = Set(stored)
        } else {
            self.completedSolutions = []
        }
    }

    private func save(_ key: String, _ value: String) {
        UserDefaults.standard.set(value, forKey: key)
    }

    private func persistCompletedSolutions() {
        UserDefaults.standard.set(Array(completedSolutions), forKey: "completedSolutions")
    }

    func cacheForSiri() {
        let d = UserDefaults.standard
        d.set(monthlyGap, forKey: "cachedMonthlyGap")
        d.set(selectedUni, forKey: "cachedUni")
        d.set(viabilityScore, forKey: "cachedViability")
    }

    func forceRecalculate() {
        updateTrigger += 1
        cacheForSiri()
    }



    var viabilityScore: Int {
        _ = updateTrigger
        let base: Int
        if let mlScore = predictViabilityWithML() {
            base = mlScore
        } else {
            base = fallbackViabilityScore
        }
        return min(100, max(0, base + solutionViabilityBonus))
    }

    var solutionViabilityBonus: Int {
        let solutions = SchoolDatabase.solutions(for: selectedUni, from: selectedCC, state: selectedState)
        var bonus = 0
        for idx in completedSolutions {
            guard idx < solutions.count else { continue }
            bonus += solutions[idx].points
        }
        return bonus
    }

    private var fallbackViabilityScore: Int {
        var score = 50
        if userGPA >= 3.5 { score += 20 }
        else if userGPA >= 3.0 { score += 12 }
        else if userGPA >= 2.5 { score += 5 }

        if userCredits >= 60 { score += 15 }
        else if userCredits >= 45 { score += 10 }
        else if userCredits >= 30 { score += 5 }

        if userSavings >= 10000 { score += 15 }
        else if userSavings >= 5000 { score += 8 }
        else { score -= 5 }

        if userRent > 1500 { score -= 10 }
        else if userRent > 1000 { score -= 5 }

        return min(100, max(0, score))
    }

    private func predictViabilityWithML() -> Int? {
        let compiledName = "TransferRiskModel"
        let compiledURL: URL? = Bundle.main.url(forResource: compiledName, withExtension: "mlmodelc")
            ?? {
                guard let sourceURL = Bundle.main.url(forResource: compiledName, withExtension: "mlmodel") else { return nil }
                return try? MLModel.compileModel(at: sourceURL)
            }()

        guard let url = compiledURL else { return nil }

        let config = MLModelConfiguration()
        config.computeUnits = .cpuOnly

        guard let model = try? MLModel(contentsOf: url, configuration: config) else { return nil }

        let input: [String: NSNumber] = [
            "GPA": NSNumber(value: clampGPA(userGPA)),
            "Credits": NSNumber(value: userCredits),
            "Savings": NSNumber(value: userSavings),
            "Rent": NSNumber(value: userRent)
        ]

        guard let provider = try? MLDictionaryFeatureProvider(dictionary: input),
              let prediction = try? model.prediction(from: provider),
              let score = prediction.featureValue(for: "ViabilityScore")?.doubleValue else { return nil }

        return min(100, max(0, Int(score)))
    }



    var transportCost: Int {
        switch transportMode {
        case 0: return userRent > 800 ? 60 : 120
        case 1: return 40
        case 2: return 0
        default: return 60
        }
    }



    var monthlyGap: Int {
        _ = updateTrigger
        let income = 1800.0
        let tuitionMonthly = Double(SchoolDatabase.uniTuition[selectedUni] ?? 7000) / 12.0
        let expenses = userRent + tuitionMonthly + 400 + Double(transportCost)
        let gap = Int(income - expenses) + solutionMonthlyBonus
        return gap
    }

    var solutionMonthlyBonus: Int {
        let solutions = SchoolDatabase.solutions(for: selectedUni, from: selectedCC, state: selectedState)
        var bonus = 0
        for idx in completedSolutions {
            guard idx < solutions.count else { continue }
            let s = solutions[idx]
            if s.monthlyImpact > 0 { bonus += s.monthlyImpact }
            if s.title.contains("Campus Job") && s.monthlyImpact == 0 { bonus += 200 }
            if s.title.contains("Roommate") { bonus += Int(userRent * 0.3) }
        }
        return bonus
    }



    var ccTuition: Int { SchoolDatabase.ccTuition[selectedCC] ?? 3000 }
    var uniTuition: Int { SchoolDatabase.uniTuition[selectedUni] ?? 8000 }
    var tuitionJump: Int { uniTuition - ccTuition }
    var courses: [SchoolDatabase.CourseTransfer] { SchoolDatabase.courses(from: selectedCC, to: selectedUni) }
    var transferable: [SchoolDatabase.CourseTransfer] { courses.filter { $0.transfers } }
    var wasted: [SchoolDatabase.CourseTransfer] { courses.filter { !$0.transfers } }
    var creditsAtRisk: Int { wasted.reduce(0) { $0 + $1.credits } }
    var creditsAtRiskCost: Int { wasted.reduce(0) { $0 + $1.costIfWasted } }
    var communityColleges: [String] { SchoolDatabase.stateData[selectedState]?.ccs ?? [] }
    var universities: [String] { SchoolDatabase.stateData[selectedState]?.unis ?? [] }



    var surchargeAlertTitle: String {
        switch selectedState {
        case "Florida": return "Florida Excess Credit Surcharge"
        case "Texas": return "Texas Excess Hour Tuition"
        case "California": return "Wasted Credits Warning"
        case "Virginia": return "Virginia Credit Transfer Warning"
        case "Washington": return "Washington Credit Transfer Alert"
        case "North Carolina": return "NC Credit Loss Warning"
        case "New Jersey": return "NJ Transfer Credit Alert"
        default: return "Excess Credit Warning"
        }
    }

    var surchargeAlertMessage: String {
        let wastedCount = wasted.count
        let wastedCreds = wasted.reduce(0) { $0 + $1.credits }
        let wastedCost = wasted.reduce(0) { $0 + $1.costIfWasted }

        switch selectedState {
        case "Florida":
            return "You have \(wastedCreds) credits (\(wastedCount) courses) that won't transfer to \(selectedUni), costing ~$\(wastedCost.formatted()). Florida charges 50% more per credit hour once you exceed 120% of required credits. Check the Solutions tab to appeal."
        case "Texas":
            return "You have \(wastedCreds) credits (\(wastedCount) courses) that won't transfer to \(selectedUni), costing ~$\(wastedCost.formatted()). Texas charges extra tuition for students who attempt 30+ hours beyond their degree plan. Appeal via the Solutions tab."
        case "California":
            return "You have \(wastedCreds) credits (\(wastedCount) courses) that won't transfer to \(selectedUni), costing ~$\(wastedCost.formatted()). California UCs are strict about course equivalency — submit syllabi for manual review via the Solutions tab."
        case "Virginia":
            return "You have \(wastedCreds) credits (\(wastedCount) courses) that won't transfer to \(selectedUni), costing ~$\(wastedCost.formatted()). Virginia's GAA only covers courses on the approved transfer list. Check the Solutions tab for next steps."
        case "Washington":
            return "You have \(wastedCreds) credits (\(wastedCount) courses) that won't transfer to \(selectedUni), costing ~$\(wastedCost.formatted()). Without a completed DTA degree, credits are evaluated individually. See Solutions for guidance."
        case "North Carolina":
            return "You have \(wastedCreds) credits (\(wastedCount) courses) that won't transfer to \(selectedUni), costing ~$\(wastedCost.formatted()). The CAA maps specific courses — anything off-list may not count. Check Solutions to appeal."
        case "New Jersey":
            return "You have \(wastedCreds) credits (\(wastedCount) courses) that won't transfer to \(selectedUni), costing ~$\(wastedCost.formatted()). Use njtransfer.org to verify equivalencies and appeal through Solutions."
        default:
            return "You have \(wastedCreds) credits (\(wastedCount) courses) that won't transfer to \(selectedUni), costing ~$\(wastedCost.formatted()). Check the Solutions tab for ways to appeal or recover these credits."
        }
    }
}


@available(iOS 17.0, *)
struct CheckTransferPlanIntent: AppIntent {
    static let title: LocalizedStringResource = "Check Transfer Plan"
    static let description = IntentDescription("Check your transfer budget and viability score.")
    static let openAppWhenRun: Bool = false

    func perform() async throws -> some IntentResult & ProvidesDialog {
        let gap = UserDefaults.standard.integer(forKey: "cachedMonthlyGap")
        let uni = UserDefaults.standard.string(forKey: "cachedUni") ?? "your university"
        let score = UserDefaults.standard.integer(forKey: "cachedViability")

        if gap < 0 {
            return .result(dialog: "Your plan to \(uni) has a deficit of $\(abs(gap)) per month with a viability score of \(score). Open TransferTrack to find solutions.")
        } else {
            return .result(dialog: "Great news! Your plan to \(uni) has a surplus of $\(gap) per month with a viability score of \(score). You're on track for a smooth transfer.")
        }
    }
}

@available(iOS 17.0, *)
struct TransferTrackShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: CheckTransferPlanIntent(),
            phrases: [
                "Check my transfer plan in \(.applicationName)",
                "How's my transfer budget in \(.applicationName)",
                "What's my monthly gap in \(.applicationName)",
                "How's my budget in \(.applicationName)",
                "What's my gap in \(.applicationName)",
                "Show my transfer score in \(.applicationName)",
                "Am I ready to transfer in \(.applicationName)",
                "How much will I spend in \(.applicationName)",
                "Open \(.applicationName)",
                "Check \(.applicationName)",
            ],
            shortTitle: "Check Transfer Plan",
            systemImageName: "graduationcap.fill"
        )
    }
}
