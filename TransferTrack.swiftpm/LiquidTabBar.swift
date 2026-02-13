import SwiftUI

@available(iOS 26.0, *)
struct LiquidTabBar: View {
    @Binding var selectedTab: Int
    let tabs: [(icon: String, label: String)]

    @State private var leadingX: CGFloat = 0
    @State private var trailingX: CGFloat = 0
    @State private var iconScales: [CGFloat] = [1, 1, 1, 1]
    @State private var iconOffsetY: [CGFloat] = [0, 0, 0, 0]
    @State private var hasAppeared = false
    @State private var isAnimating = false

    private let barHeight: CGFloat = 62
    private let blobBaseW: CGFloat = 60
    private let blobBaseH: CGFloat = 46

    var body: some View {
        GeometryReader { geo in
            let tw = geo.size.width / CGFloat(tabs.count)

            ZStack {
                Capsule()
                    .frame(height: barHeight)
                    .glassEffect(.regular, in: .capsule)

                blobView(tw: tw)
                rimLightView(tw: tw)

                HStack(spacing: 0) {
                    ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                        let active = selectedTab == index
                        Button { moveToTab(index, tw: tw) } label: {
                            VStack(spacing: 2) {
                                Image(systemName: tab.icon)
                                    .font(.system(size: 20, weight: active ? .bold : .medium))
                                    .symbolVariant(active ? .fill : .none)
                                    .foregroundStyle(active ? .white : .secondary)
                                    .scaleEffect(iconScales[safe: index] ?? 1.0)
                                    .offset(y: iconOffsetY[safe: index] ?? 0)
                                Text(tab.label)
                                    .font(.system(size: 10, weight: active ? .semibold : .regular))
                                    .foregroundStyle(active ? .white.opacity(0.9) : .secondary)
                                    .scaleEffect(iconScales[safe: index] ?? 1.0)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: barHeight)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("\(tab.label) tab")
                        .accessibilityAddTraits(active ? .isSelected : [])
                    }
                }
            }
            .frame(height: barHeight)
            .onAppear {
                if !hasAppeared {
                    let c = cx(selectedTab, tw: tw)
                    leadingX = c; trailingX = c; hasAppeared = true
                }
            }
            .onChange(of: geo.size.width) { _, _ in
                let c = cx(selectedTab, tw: tw)
                leadingX = c; trailingX = c
            }
        }
        .frame(height: barHeight)
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }

    @ViewBuilder private func blobView(tw: CGFloat) -> some View {
        let minE = min(leadingX, trailingX)
        let maxE = max(leadingX, trailingX)
        let stretch = maxE - minE
        let blobW = max(blobBaseW, stretch + blobBaseW * 0.4)
        let compressionRatio = blobBaseW / blobW
        let blobH = max(blobBaseH * 0.55, blobBaseH * sqrt(compressionRatio))
        let center = (leadingX + trailingX) / 2

        Capsule()
            .fill(
                LinearGradient(
                    colors: [
                        Color.blue,
                        Color.blue.opacity(0.85),
                        Color(red: 0.2, green: 0.4, blue: 0.95)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: blobW, height: blobH)
            .shadow(color: .blue.opacity(0.25), radius: 8, y: 3)
            .shadow(color: .white.opacity(0.06), radius: 1, y: -1)
            .position(x: center, y: barHeight / 2)
    }

    @ViewBuilder private func rimLightView(tw: CGFloat) -> some View {
        let minE = min(leadingX, trailingX)
        let maxE = max(leadingX, trailingX)
        let stretch = maxE - minE
        let blobW = max(blobBaseW, stretch + blobBaseW * 0.4)
        let compressionRatio = blobBaseW / blobW
        let blobH = max(blobBaseH * 0.55, blobBaseH * sqrt(compressionRatio))
        let center = (leadingX + trailingX) / 2
        let normalizedX = (center / (CGFloat(tabs.count) * (blobBaseW + 20))) * 2 - 1

        Capsule()
            .stroke(
                LinearGradient(
                    colors: [
                        .white.opacity(0.35 + normalizedX * 0.1),
                        .white.opacity(0.08),
                        .white.opacity(0.02)
                    ],
                    startPoint: .init(x: 0.3 - Double(normalizedX) * 0.2, y: 0),
                    endPoint: .init(x: 0.7 - Double(normalizedX) * 0.2, y: 1)
                ),
                lineWidth: 1.0
            )
            .frame(width: blobW - 3, height: blobH - 3)
            .position(x: center, y: barHeight / 2)
            .allowsHitTesting(false)
    }

    private func cx(_ idx: Int, tw: CGFloat) -> CGFloat {
        CGFloat(idx) * tw + tw / 2
    }

    private func moveToTab(_ index: Int, tw: CGFloat) {
        guard index != selectedTab, !isAnimating else { return }
        isAnimating = true

        let oldIdx = selectedTab
        let newC = cx(index, tw: tw)
        let right = newC > cx(oldIdx, tw: tw)
        let distance = abs(index - oldIdx)
        let stretchFactor = min(1.0, Double(distance) * 0.35)

        selectedTab = index
        UIImpactFeedbackGenerator(style: .medium).impactOccurred(intensity: 0.6 + stretchFactor * 0.3)

        withAnimation(.spring(response: 0.28, dampingFraction: 0.58)) {
            if right { leadingX = newC } else { trailingX = newC }
        }

        withAnimation(.spring(response: 0.50 + stretchFactor * 0.12, dampingFraction: 0.68).delay(0.10 + stretchFactor * 0.04)) {
            if right { trailingX = newC } else { leadingX = newC }
        }

        let i = index
        withAnimation(.spring(response: 0.15, dampingFraction: 0.35).delay(0.12)) {
            iconScales[i] = 0.72
            iconOffsetY[i] = 3
        }
        withAnimation(.spring(response: 0.25, dampingFraction: 0.45).delay(0.28)) {
            iconScales[i] = 1.18
            iconOffsetY[i] = -2
        }
        withAnimation(.spring(response: 0.3, dampingFraction: 0.65).delay(0.46)) {
            iconScales[i] = 1.0
            iconOffsetY[i] = 0
        }

        let old = oldIdx
        withAnimation(.spring(response: 0.2, dampingFraction: 0.6).delay(0.05)) {
            iconScales[old] = 0.92
        }
        withAnimation(.spring(response: 0.25, dampingFraction: 0.7).delay(0.2)) {
            iconScales[old] = 1.0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) { isAnimating = false }
    }
}

@available(iOS 17.0, *)
struct FloatingTabBar: View {
    @Binding var selectedTab: Int
    let tabs: [(icon: String, label: String)]

    @State private var leadingX: CGFloat = 0
    @State private var trailingX: CGFloat = 0
    @State private var iconScales: [CGFloat] = [1, 1, 1, 1]
    @State private var iconOffsetY: [CGFloat] = [0, 0, 0, 0]
    @State private var hasAppeared = false
    @State private var isAnimating = false

    private let barHeight: CGFloat = 58
    private let blobBaseW: CGFloat = 54
    private let blobBaseH: CGFloat = 42

    var body: some View {
        GeometryReader { geo in
            let tw = geo.size.width / CGFloat(tabs.count)

            ZStack {
                Capsule()
                    .fill(.ultraThinMaterial)
                    .frame(height: barHeight)
                    .shadow(color: .black.opacity(0.15), radius: 10, y: 5)

                let minE = min(leadingX, trailingX)
                let maxE = max(leadingX, trailingX)
                let stretch = maxE - minE
                let blobW = max(blobBaseW, stretch + blobBaseW * 0.4)
                let compressionRatio = blobBaseW / blobW
                let blobH = max(blobBaseH * 0.55, blobBaseH * sqrt(compressionRatio))
                let center = (leadingX + trailingX) / 2

                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color.blue, Color.blue.opacity(0.85), Color(red: 0.2, green: 0.4, blue: 0.95)],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                    .frame(width: blobW, height: blobH)
                    .shadow(color: Color.blue.opacity(0.3), radius: 6, y: 2)
                    .position(x: center, y: barHeight / 2)

                Capsule()
                    .stroke(
                        LinearGradient(colors: [.white.opacity(0.4), .white.opacity(0.05)], startPoint: .top, endPoint: .bottom),
                        lineWidth: 1
                    )
                    .frame(width: blobW - 2, height: blobH - 2)
                    .position(x: center, y: barHeight / 2)
                    .allowsHitTesting(false)

                HStack(spacing: 0) {
                    ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                        let active = selectedTab == index
                        Button { moveToTab(index, tw: tw) } label: {
                            VStack(spacing: 2) {
                                Image(systemName: tab.icon)
                                    .font(.system(size: 18, weight: active ? .bold : .medium))
                                    .symbolVariant(active ? .fill : .none)
                                    .scaleEffect(iconScales[safe: index] ?? 1.0)
                                    .offset(y: iconOffsetY[safe: index] ?? 0)
                                Text(tab.label)
                                    .font(.system(size: 9, weight: active ? .semibold : .regular))
                                    .lineLimit(1)
                                    .scaleEffect(iconScales[safe: index] ?? 1.0)
                            }
                            .foregroundStyle(active ? .white : .secondary)
                            .frame(maxWidth: .infinity)
                            .frame(height: barHeight)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("\(tab.label) tab")
                        .accessibilityAddTraits(active ? .isSelected : [])
                    }
                }
            }
            .frame(height: barHeight)
            .onAppear {
                if !hasAppeared {
                    let c = CGFloat(selectedTab) * tw + tw / 2
                    leadingX = c; trailingX = c; hasAppeared = true
                }
            }
        }
        .frame(height: barHeight)
        .padding(.horizontal, 20)
        .padding(.bottom, 28)
    }

    private func moveToTab(_ index: Int, tw: CGFloat) {
        guard index != selectedTab, !isAnimating else { return }
        isAnimating = true

        let oldIdx = selectedTab
        let oldC = CGFloat(oldIdx) * tw + tw / 2
        let newC = CGFloat(index) * tw + tw / 2
        let right = newC > oldC
        let distance = abs(index - oldIdx)
        let stretchFactor = min(1.0, Double(distance) * 0.35)

        selectedTab = index
        UIImpactFeedbackGenerator(style: .medium).impactOccurred(intensity: 0.6 + stretchFactor * 0.3)

        withAnimation(.spring(response: 0.28, dampingFraction: 0.58)) {
            if right { leadingX = newC } else { trailingX = newC }
        }
        withAnimation(.spring(response: 0.50 + stretchFactor * 0.12, dampingFraction: 0.68).delay(0.10 + stretchFactor * 0.04)) {
            if right { trailingX = newC } else { leadingX = newC }
        }

        let i = index
        withAnimation(.spring(response: 0.15, dampingFraction: 0.35).delay(0.12)) {
            iconScales[i] = 0.72; iconOffsetY[i] = 3
        }
        withAnimation(.spring(response: 0.25, dampingFraction: 0.45).delay(0.28)) {
            iconScales[i] = 1.18; iconOffsetY[i] = -2
        }
        withAnimation(.spring(response: 0.3, dampingFraction: 0.65).delay(0.46)) {
            iconScales[i] = 1.0; iconOffsetY[i] = 0
        }

        let old = oldIdx
        withAnimation(.spring(response: 0.2, dampingFraction: 0.6).delay(0.05)) { iconScales[old] = 0.92 }
        withAnimation(.spring(response: 0.25, dampingFraction: 0.7).delay(0.2)) { iconScales[old] = 1.0 }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) { isAnimating = false }
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
