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

        print("🌱 Seeding data from JSON...")

        // 2. load the JSON file
        guard let url = Bundle.main.url(forResource: "mock_data", withExtension: "json") else {
            print("❌ CRITICAL ERROR: mock_data.json not found! Did you rename the file?")
            return
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let payload = try decoder.decode(SeedPayload.self, from: data)

            // 3. insert uni
            for uni in payload.universities {
                let newUni = University(name: uni.name, tuitionRate: uni.tuitionRate, colorHex: uni.colorHex)
                context.insert(newUni)
            }

            // 4. insert clasess
            for course in payload.courses {
                let newCourse = Course(code: course.code, title: course.title, credits: course.credits)
                context.insert(newCourse)
            }

            // 5. insert default state
            let state = SimulationState(userSavings: 2000, rentCost: 0, tuitionGap: 0)
            context.insert(state)

            try context.save()
            print("✅ Seeding Complete!")
        } catch {
            print("❌ Seeding Failed: \(error)")
        }
    }
}

// helper structs for JSON parsing
struct SeedPayload: Codable {
    let universities: [UniversityData]
    let courses: [CourseData]
}
struct UniversityData: Codable {
    let name: String
    let tuitionRate: Double
    let colorHex: String
}
struct CourseData: Codable {
    let code: String
    let title: String
    let credits: Int
}
