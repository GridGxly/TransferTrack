import SwiftUI
import SwiftData
import Charts

@available(iOS 17.0, *)
struct DashboardView: View {
    @State private var viewModel = DashboardViewModel()
    @Environment(\.modelContext) var context

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 30) {
                VStack(spacing: 5) {
                    Text("Transfer Simulation").font(.headline).foregroundStyle(.gray)
                    Text(viewModel.sliderValue > 0.5 ? "Moving to Orlando" : "Living at Home")
                        .font(.title2).bold().foregroundStyle(.white).contentTransition(.numericText())
                }
                .padding(.top, 40)

                FinancialCliffChart(data: viewModel.chartData)
                    .background(RoundedRectangle(cornerRadius: 20).fill(Color(white: 0.1)).shadow(radius: 10))
                    .padding(.horizontal)

                VStack(alignment: .leading) {
                    Text("Reality Adjustment").font(.caption).foregroundStyle(.gray).textCase(.uppercase)
                    HStack {
                        Image(systemName: "house.fill").foregroundStyle(.green)
                        Slider(value: Binding(
                            get: { viewModel.sliderValue },
                            set: { newValue in
                                viewModel.sliderValue = newValue
                                viewModel.calculateProjection()
                            }
                        )).tint(viewModel.sliderValue > 0.5 ? .red : .green)
                        Image(systemName: "building.2.fill").foregroundStyle(.red)
                    }
                }
                .padding().background(.ultraThinMaterial).cornerRadius(15).padding(.horizontal)
                Spacer()
            }
        }
    }
}

@available(iOS 17.0, *)
@Observable
class DashboardViewModel {
    var sliderValue: Double = 0.0
    var chartData: [MonthlyBalance] = []
    let initialSavings: Double = 2500.0
    let homeBurnRate: Double = 300.0
    let apartmentBurnRate: Double = 1850.0

    init() {
        let savedHousingMode = UserDefaults.standard.double(forKey: "initialSliderValue")
        self.sliderValue = savedHousingMode
        calculateProjection()
    }
    
    func calculateProjection() {
        var data: [MonthlyBalance] = []
        let currentBurn = homeBurnRate + (apartmentBurnRate - homeBurnRate) * sliderValue
        var currentBalance = initialSavings
        for month in 0...12 {
            data.append(MonthlyBalance(month: month, balance: currentBalance))
            currentBalance -= currentBurn
        }
        chartData = data
    }
}

struct MonthlyBalance: Identifiable {
    let id = UUID()
    let month: Int
    let balance: Double
}

@available(iOS 17.0, *)
struct FinancialCliffChart: View {
    var data: [MonthlyBalance]
    var body: some View {
        Chart(data) { item in
            LineMark(x: .value("Month", item.month), y: .value("Balance", item.balance))
                .interpolationMethod(.catmullRom)
                .foregroundStyle(item.balance > 0 ? Color.green : Color.red)
                .lineStyle(StrokeStyle(lineWidth: 4, lineCap: .round))
            AreaMark(x: .value("Month", item.month), y: .value("Balance", item.balance))
                .interpolationMethod(.catmullRom)
                .foregroundStyle(LinearGradient(colors: [(item.balance > 0 ? Color.green : Color.red).opacity(0.5), .clear], startPoint: .top, endPoint: .bottom))
        }
        .chartYAxis { AxisMarks(position: .leading) }
        .chartXAxis { AxisMarks(values: [0, 3, 6, 9, 12]) }
        .frame(height: 300).padding()
    }
}
