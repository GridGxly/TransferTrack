import SwiftUI
import SwiftData

@available(iOS 17.0, *)
struct DashboardView: View {
    @State private var viewModel = DashboardViewModel()
    @Environment(\.modelContext) var context

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 30) {
                VStack(spacing: 5) {
                    Text("Transfer Simulation")
                        .font(.headline)
                        .foregroundStyle(.gray)
                    Text(viewModel.sliderValue > 0.5 ? "Moving to Orlando" : "Living at Home")
                        .font(.title2)
                        .bold()
                        .foregroundStyle(.white)
                        .contentTransition(.numericText())
                }
                .padding(.top, 40)


                FinancialCliffChart(data: viewModel.chartData)
                    .background(
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color(white: 0.1))
                            .shadow(radius: 10)
                    )
                    .padding(.horizontal)

                // the reality slider
                VStack(alignment: .leading) {
                    Text("Reality Adjustment")
                        .font(.caption)
                        .foregroundStyle(.gray)
                        .textCase(.uppercase)
                    
                    HStack {
                        Image(systemName: "house.fill").foregroundStyle(.green)
                        Slider(value: Binding(
                            get: { viewModel.sliderValue },
                            set: { newValue in
                                viewModel.sliderValue = newValue
                                viewModel.calculateProjection()
                            }
                        ))
                        .tint(viewModel.sliderValue > 0.5 ? .red : .green)
                        Image(systemName: "building.2.fill").foregroundStyle(.red)
                    }
                }
                .padding()
                .background(.ultraThinMaterial)
                .cornerRadius(15)
                .padding(.horizontal)

                Spacer()
            }
        }
    }
}
