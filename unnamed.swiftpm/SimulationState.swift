import SwiftData

@available(iOS 17.0, *)
@Model
final class SimulationState {
    var userSavings: Double
    var rentCost: Double
    var tuitionGap: Double

    init(userSavings: Double, rentCost: Double, tuitionGap: Double) {
        self.userSavings = userSavings
        self.rentCost = rentCost
        self.tuitionGap = tuitionGap
    }
}
