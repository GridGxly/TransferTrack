import SwiftUI
import Charts

@available(iOS 17.0, *)
struct FinancialCliffChart: View {
    var data: [MonthlyBalance]
    
    var body: some View {
        Chart(data) { item in
            LineMark(
                x: .value("Month", item.month),
                y: .value("Balance", item.balance)
            )
            .interpolationMethod(.catmullRom)
            .foregroundStyle(item.balance > 0 ? Color.green : Color.red)
            .lineStyle(StrokeStyle(lineWidth: 4, lineCap: .round))

            AreaMark(
                x: .value("Month", item.month),
                y: .value("Balance", item.balance)
            )
            .interpolationMethod(.catmullRom)
            .foregroundStyle(
                LinearGradient(
                    colors: [
                        (item.balance > 0 ? Color.green : Color.red).opacity(0.5),
                        .clear
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .chartXAxis {
            AxisMarks(values: [0, 3, 6, 9, 12])
        }
        .frame(height: 300)
        .padding()
    }
}
