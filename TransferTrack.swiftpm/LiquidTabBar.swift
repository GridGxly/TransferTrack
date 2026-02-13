import SwiftUI

// MARK: - liquid glass tab bar
@available(iOS 26.0, *)
struct LiquidTabBar: View {
    @Binding var selectedTab: Int
    let tabs: [(icon: String, label: String)]

    @State private var leadingX: CGFloat = 0
    @State private var trailingX: CGFloat = 0
    @State private var iconScales: [CGFloat] = [1, 1, 1, 1]
    @State private var hasAppeared = false

    private let barHeight: CGFloat = 60
    private let blobW: CGFloat = 58
    private let blobH: CGFloat = 48

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
                                    .scaleEffect(iconScales[min(index, iconScales.count - 1)])
                                Text(tab.label)
                                    .font(.system(size: 10, weight: active ? .semibold : .regular))
                                    .foregroundStyle(active ? .white.opacity(0.9) : .secondary)
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
        let w = max(blobW, stretch + blobW)
        let ratio = blobW / w
        let h = max(blobH * 0.5, blobH * ratio)
        let center = (leadingX + trailingX) / 2


        Capsule()
            .fill(Color.blue)
            .frame(width: w, height: h)
            .shadow(color: .white.opacity(0.06), radius: 1, y: -1)
            .shadow(color: .black.opacity(0.18), radius: 4, y: 2)
            .position(x: center, y: barHeight / 2)
    }

    @ViewBuilder private func rimLightView(tw: CGFloat) -> some View {
        let minE = min(leadingX, trailingX)
        let maxE = max(leadingX, trailingX)
        let stretch = maxE - minE
        let w = max(blobW, stretch + blobW)
        let ratio = blobW / w
        let h = max(blobH * 0.5, blobH * ratio)
        let center = (leadingX + trailingX) / 2

        Capsule()
            .stroke(
                LinearGradient(colors: [.white.opacity(0.3), .white.opacity(0.03)], startPoint: .top, endPoint: .bottom),
                lineWidth: 1.2
            )
            .frame(width: w - 4, height: h - 4)
            .position(x: center, y: barHeight / 2)
            .allowsHitTesting(false)
    }

    private func cx(_ idx: Int, tw: CGFloat) -> CGFloat {
        CGFloat(idx) * tw + tw / 2
    }

    private func moveToTab(_ index: Int, tw: CGFloat) {
        guard index != selectedTab else { return }
        let oldC = cx(selectedTab, tw: tw)
        let newC = cx(index, tw: tw)
        let right = newC > oldC

        selectedTab = index
        UIImpactFeedbackGenerator(style: .medium).impactOccurred(intensity: 0.7)

        withAnimation(.spring(response: 0.32, dampingFraction: 0.65)) {
            if right { leadingX = newC } else { trailingX = newC }
        }

        withAnimation(.spring(response: 0.58, dampingFraction: 0.75).delay(0.08)) {
            if right { trailingX = newC } else { leadingX = newC }
        }

        let i = index
        withAnimation(.spring(response: 0.2, dampingFraction: 0.4).delay(0.18)) {
            iconScales[i] = 0.82
        }
        withAnimation(.spring(response: 0.3, dampingFraction: 0.5).delay(0.32)) {
            iconScales[i] = 1.15
        }
        withAnimation(.spring(response: 0.25, dampingFraction: 0.7).delay(0.48)) {
            iconScales[i] = 1.0
        }
    }
}

// MARK: - floating tab bar fallback
@available(iOS 17.0, *)
struct FloatingTabBar: View {
    @Binding var selectedTab: Int
    let tabs: [(icon: String, label: String)]

    @State private var leadingX: CGFloat = 0
    @State private var trailingX: CGFloat = 0
    @State private var iconScales: [CGFloat] = [1, 1, 1, 1]
    @State private var hasAppeared = false

    private let barHeight: CGFloat = 56
    private let blobW: CGFloat = 52
    private let blobH: CGFloat = 44

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
                let w = max(blobW, stretch + blobW)
                let ratio = blobW / w
                let h = max(blobH * 0.5, blobH * ratio)
                let center = (leadingX + trailingX) / 2

                Capsule()
                    .fill(Color.blue)
                    .frame(width: w, height: h)
                    .shadow(color: Color.blue.opacity(0.3), radius: 6, y: 2)
                    .position(x: center, y: barHeight / 2)

                Capsule()
                    .stroke(LinearGradient(colors: [.white.opacity(0.4), .clear], startPoint: .top, endPoint: .center), lineWidth: 1)
                    .frame(width: w - 2, height: h - 2)
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
                                    .scaleEffect(iconScales[min(index, iconScales.count - 1)])
                                Text(tab.label)
                                    .font(.system(size: 9, weight: active ? .semibold : .regular))
                                    .lineLimit(1)
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
        guard index != selectedTab else { return }
        let oldC = CGFloat(selectedTab) * tw + tw / 2
        let newC = CGFloat(index) * tw + tw / 2
        let right = newC > oldC
        selectedTab = index
        UIImpactFeedbackGenerator(style: .medium).impactOccurred(intensity: 0.7)

        withAnimation(.spring(response: 0.32, dampingFraction: 0.65)) {
            if right { leadingX = newC } else { trailingX = newC }
        }
        withAnimation(.spring(response: 0.58, dampingFraction: 0.75).delay(0.08)) {
            if right { trailingX = newC } else { leadingX = newC }
        }

        let i = index
        withAnimation(.spring(response: 0.2, dampingFraction: 0.4).delay(0.18)) { iconScales[i] = 0.82 }
        withAnimation(.spring(response: 0.3, dampingFraction: 0.5).delay(0.32)) { iconScales[i] = 1.15 }
        withAnimation(.spring(response: 0.25, dampingFraction: 0.7).delay(0.48)) { iconScales[i] = 1.0 }
    }
}
