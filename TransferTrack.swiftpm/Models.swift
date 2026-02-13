import SwiftData
import Foundation
import CoreLocation
import SwiftUI
import Observation

// MARK: - SwiftData model for user added courses

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

// MARK: - transfer viewModel (separates logic from views)

@available(iOS 17.0, *)
@Observable
final class TransferViewModel {
    // user inputs
    var userName: String { didSet { save("userName", userName) } }
    var selectedState: String { didSet { save("selectedState", selectedState) } }
    var selectedCC: String { didSet { save("selectedCC", selectedCC) } }
    var selectedUni: String { didSet { save("selectedUni", selectedUni) } }
    var userGPA: Double { didSet { UserDefaults.standard.set(userGPA, forKey: "userGPA") } }
    var userCredits: Double { didSet { UserDefaults.standard.set(userCredits, forKey: "userCredits") } }
    var userSavings: Double { didSet { UserDefaults.standard.set(userSavings, forKey: "userSavings") } }
    var userRent: Double { didSet { UserDefaults.standard.set(userRent, forKey: "userRent") } }
    var transportMode: Int { didSet { UserDefaults.standard.set(transportMode, forKey: "transportMode") } }
    var transferSemester: String { didSet { save("transferSemester", transferSemester) } }

    // solutions completion state
    var completedSolutions: Set<Int> = []

    init() {
        let d = UserDefaults.standard
        self.userName = d.string(forKey: "userName") ?? ""
        self.selectedState = d.string(forKey: "selectedState") ?? "Florida"
        self.selectedCC = d.string(forKey: "selectedCC") ?? "Valencia College"
        self.selectedUni = d.string(forKey: "selectedUni") ?? "UCF"
        self.userGPA = d.double(forKey: "userGPA") == 0 ? 3.2 : d.double(forKey: "userGPA")
        self.userCredits = d.double(forKey: "userCredits") == 0 ? 45 : d.double(forKey: "userCredits")
        self.userSavings = d.double(forKey: "userSavings") == 0 ? 2500 : d.double(forKey: "userSavings")
        self.userRent = d.double(forKey: "userRent") == 0 ? 1200 : d.double(forKey: "userRent")
        self.transportMode = d.integer(forKey: "transportMode")
        self.transferSemester = d.string(forKey: "transferSemester") ?? "Fall 2026"
    }

    private func save(_ key: String, _ value: String) {
        UserDefaults.standard.set(value, forKey: key)
    }

    // MARK: - computed scores

    var viabilityScore: Int {
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

    var transportCost: Int {
        switch transportMode {
        case 0: return userRent > 800 ? 60 : 120  // keep car
        case 1: return 40   // sell car / swap
        case 2: return 0    // public transit
        default: return 60
        }
    }

    var monthlyGap: Int {
        let income = 1800.0
        let tuitionMonthly = Double(SchoolDatabase.uniTuition[selectedUni] ?? 7000) / 12.0
        let expenses = userRent + tuitionMonthly + 400 + Double(transportCost)
        let solutionBonus = solutionMonthlyBonus
        return Int(income - expenses) + solutionBonus
    }

    // bonus from completed solutions that affect finances
    var solutionMonthlyBonus: Int {
        let solutions = SchoolDatabase.solutions(for: selectedUni, from: selectedCC, state: selectedState)
        var bonus = 0
        for idx in completedSolutions {
            guard idx < solutions.count else { continue }
            let s = solutions[idx]
            // map certain solutions to monthly impact
            if s.title.contains("Campus Job") { bonus += 200 }
            if s.title.contains("Roommate") { bonus += Int(userRent * 0.3) }
            if s.title.contains("Scholarships") { bonus += 150 }
        }
        return bonus
    }

    var ccTuition: Int { SchoolDatabase.ccTuition[selectedCC] ?? 3000 }
    var uniTuition: Int { SchoolDatabase.uniTuition[selectedUni] ?? 8000 }
    var tuitionJump: Int { uniTuition - ccTuition }

    var courses: [SchoolDatabase.CourseTransfer] {
        SchoolDatabase.courses(from: selectedCC, to: selectedUni)
    }

    var transferable: [SchoolDatabase.CourseTransfer] { courses.filter { $0.transfers } }
    var wasted: [SchoolDatabase.CourseTransfer] { courses.filter { !$0.transfers } }
    var creditsAtRisk: Int { wasted.reduce(0) { $0 + $1.credits } }
    var creditsAtRiskCost: Int { wasted.reduce(0) { $0 + $1.costIfWasted } }

    var communityColleges: [String] { SchoolDatabase.stateData[selectedState]?.ccs ?? [] }
    var universities: [String] { SchoolDatabase.stateData[selectedState]?.unis ?? [] }
}
