import SwiftUI
import SwiftData

@available(iOS 17.0, *)
@Observable
class DashboardViewModel {
    var sliderValue: Double = 0.0
    var chartData: [MonthlyBalance] = []
    
    // hardcoded for simulation speed
    let initialSavings: Double = 2500.0
    let homeBurnRate: Double = 300.0 // gas + food (Valencia)
    let apartmentBurnRate: Double = 1850.0 // rent + tuition + food (UCF)

    init() {
            let savedHousingMode = UserDefaults.standard.double(forKey: "initialSliderValue")
            self.sliderValue = savedHousingMode
            
            calculateProjection()
        }
    func calculateProjection() {
        var data: [MonthlyBalance] = []
        let currentBurn = interpolate(from: homeBurnRate, to: apartmentBurnRate, amount: sliderValue)
        
        var currentBalance = initialSavings
        
        for month in 0...12 {
            data.append(MonthlyBalance(month: month, balance: currentBalance))
            currentBalance -= currentBurn
        }
        chartData = data
    }
    
    // heelper to blend between two numbers
    private func interpolate(from: Double, to: Double, amount: Double) -> Double {
        return from + (to - from) * amount
    }
}

struct MonthlyBalance: Identifiable {
    let id = UUID()
    let month: Int
    let balance: Double
}
