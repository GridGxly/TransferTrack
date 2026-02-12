import SwiftUI

// MARK: - liquid glass tab bar


@available(iOS 26.0, *)
struct LiquidTabBar: View {
    @Binding var selectedTab: Int
    let tabs: [(icon: String, label: String)]

    // animation state
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging: Bool = false


    private let barHeight: CGFloat = 58
    private let iconSize: CGFloat = 22
    private let pillWidth: CGFloat = 60
    private let pillHeight: CGFloat = 50


    private let liquidSpring: Animation = .spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.7)

    var body: some View {
        GeometryReader { geo in
            let tabWidth = geo.size.width / CGFloat(tabs.count)

            ZStack {
                // MARK: glass track
                Capsule()
                    .frame(height: barHeight)
                    .glassEffect(.regular, in: .capsule)

                // MARK: active pill
                let targetX = (CGFloat(selectedTab) * tabWidth) + (tabWidth / 2)
                let currentX = isDragging ? dragOffset : targetX

                Capsule()
                    .frame(width: pillWidth, height: pillHeight)
                    .glassEffect(.regular, in: .capsule)
                    .shadow(color: .black.opacity(0.18), radius: 4, y: 2)
                    .position(x: currentX, y: barHeight / 2)
                    .animation(isDragging ? .interactiveSpring() : liquidSpring, value: currentX)

                // MARK: icons & labels
                HStack(spacing: 0) {
                    ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                        let isActive = selectedTab == index

                        Button {
                            withAnimation(liquidSpring) {
                                selectedTab = index
                            }
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        } label: {
                            VStack(spacing: 3) {
                                Image(systemName: tab.icon)
                                    .font(.system(size: iconSize, weight: isActive ? .bold : .medium))
                                    .symbolVariant(isActive ? .fill : .none)
                                    .foregroundStyle(isActive ? .white : .secondary)
                                    .scaleEffect(isActive ? 1.15 : 1.0)
                                    .animation(liquidSpring, value: selectedTab)

                                Text(tab.label)
                                    .font(.system(size: 10, weight: isActive ? .semibold : .regular))
                                    .foregroundStyle(isActive ? .primary : .secondary)
                                    .animation(liquidSpring, value: selectedTab)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: barHeight)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("\(tab.label) tab, \(isActive ? "selected" : "not selected")")
                        .accessibilityAddTraits(isActive ? .isSelected : [])
                    }
                }
            }
            .frame(height: barHeight)
            .gesture(liquidDrag(tabWidth: tabWidth))
        }
        .frame(height: barHeight)
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Tab bar")
    }

    // MARK: - drag gesture

    private func liquidDrag(tabWidth: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 10)
            .onChanged { value in
                if !isDragging {
                    dragOffset = (CGFloat(selectedTab) * tabWidth) + (tabWidth / 2)
                }
                isDragging = true
                dragOffset = max(tabWidth / 2, min(value.location.x, tabWidth * CGFloat(tabs.count) - tabWidth / 2))
            }
            .onEnded { value in
                isDragging = false
                let index = Int(max(0, min(CGFloat(tabs.count - 1), (value.location.x / tabWidth).rounded(.down))))

                if index != selectedTab {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }

                withAnimation(liquidSpring) {
                    selectedTab = index
                }
            }
    }
}
