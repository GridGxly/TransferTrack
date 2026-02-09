import SwiftData

@available(iOS 17.0, *)
enum DataController {
    static func makeContainer() -> ModelContainer {
        let schema = Schema([
            University.self,
            Course.self,
            SimulationState.self
        ])
        let config = ModelConfiguration(isStoredInMemoryOnly: true)  // Fixed typo
        return try! ModelContainer(for: schema, configurations: [config])
    }
}
