import SwiftUI
import SwiftData
import Foundation

@available(iOS 17.0, *)
struct Seeder {
    @MainActor
    static func seedIfNeeded(_ context: ModelContext) {
        // 1. check if data exists
        let descriptor = FetchDescriptor<University>()
        let existingCount = (try? context.fetchCount(descriptor)) ?? 0

        if existingCount > 0 {
            print("✅ Data already seeded.")
            return
        }

        print("🌱 Seeding data manually...")

        // 2. hardcoded data
        let universities = [
            University(name: "Valencia College", tuitionRate: 103.0, colorHex: "#8C2131"),
            University(name: "UCF", tuitionRate: 212.0, colorHex: "#FFC904"),
            University(name: "Univ. of Florida", tuitionRate: 212.0, colorHex: "#FA4616"),
            University(name: "FIU", tuitionRate: 205.0, colorHex: "#081E3F"),
            University(name: "Miami Dade College", tuitionRate: 118.0, colorHex: "#00578A"),
            University(name: "Santa Fe College", tuitionRate: 106.0, colorHex: "#004C97"),
            University(name: "UCLA", tuitionRate: 450.0, colorHex: "#2D68C4"),
            University(name: "Santa Monica College", tuitionRate: 46.0, colorHex: "#005596"),
            University(name: "Wake Tech", tuitionRate: 76.0, colorHex: "#003366"),
            University(name: "NC State", tuitionRate: 263.0, colorHex: "#CC0000")
        ]

        let courses = [
            Course(code: "COP 2800", title: "Intro to Java", credits: 3),
            Course(code: "MAC 2311", title: "Calculus I", credits: 4),
            Course(code: "ENC 1101", title: "Composition I", credits: 3)
        ]

        // 3. insert into database
        for uni in universities {
            context.insert(uni)
        }
        
        for course in courses {
            context.insert(course)
        }

        // 4. insert default simulation state
        let state = SimulationState(userSavings: 2000, rentCost: 0, tuitionGap: 0)
        context.insert(state)

        do {
            try context.save()
            print("✅ Seeding Complete! Data is ready.")
        } catch {
            print("❌ Seeding Failed: \(error)")
        }
    }
}
