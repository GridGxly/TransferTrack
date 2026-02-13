import SwiftUI

// MARK: - liquid glass tab bar

@available(iOS 26.0, *)
struct LiquidTabBar: View {
    @Binding var selectedTab: Int
    let tabs: [(icon: String, label: String)]

    //  two edges of the liquid blob
    @State private var leadingX: CGFloat = 0
    @State private var trailingX: CGFloat = 0

    // tracking for first layout
    @State private var hasAppeared = false
    @State private var tabWidth: CGFloat = 0

    // dimensions
    private let barHeight: CGFloat = 60
    private let blobBaseWidth: CGFloat = 56
    private let blobBaseHeight: CGFloat = 48
    private let iconSize: CGFloat = 20

    // physics springs
    private let leadingSpring = Animation.spring(response: 0.38, dampingFraction: 0.68, blendDuration: 0.1)
    private let trailingSpring = Animation.spring(response: 0.55, dampingFraction: 0.78, blendDuration: 0.1)

    var body: some View {
        GeometryReader { geo in
            let tw = geo.size.width / CGFloat(tabs.count)
            let barWidth = geo.size.width

            ZStack {
                // glass track background
                Capsule()
                    .frame(height: barHeight)
                    .glassEffect(.regular, in: .capsule)

                // MARK: the liquid blob
                liquidBlob(tabWidth: tw)

                // MARK: rim light
                rimLight(tabWidth: tw)

                // MARK: icons and labels
                HStack(spacing: 0) {
                    ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                        let isActive = selectedTab == index

                        Button {
                            moveToTab(index, tabWidth: tw)
                        } label: {
                            VStack(spacing: 2) {
                                Image(systemName: tab.icon)
                                    .font(.system(size: iconSize, weight: isActive ? .bold : .medium))
                                    .symbolVariant(isActive ? .fill : .none)
                                    .foregroundStyle(isActive ? .white : .secondary)
                                    .scaleEffect(isActive ? 1.12 : 1.0)

                                Text(tab.label)
                                    .font(.system(size: 10, weight: isActive ? .semibold : .regular))
                                    .foregroundStyle(isActive ? .white.opacity(0.9) : .secondary)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: barHeight)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("\(tab.label) tab")
                        .accessibilityAddTraits(isActive ? .isSelected : [])
                    }
                }
            }
            .frame(height: barHeight)
            .onAppear {
                tabWidth = tw
                if !hasAppeared {
                    let center = tabCenter(for: selectedTab, tabWidth: tw)
                    leadingX = center
                    trailingX = center
                    hasAppeared = true
                }
            }
            .onChange(of: geo.size.width) { _, _ in
                tabWidth = tw
                let center = tabCenter(for: selectedTab, tabWidth: tw)
                leadingX = center
                trailingX = center
            }
        }
        .frame(height: barHeight)
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
        .accessibilityElement(children: .contain)
        .accessibilityLabel("Tab bar")
    }

    // MARK: - the liquid blob shape

    @ViewBuilder
    private func liquidBlob(tabWidth: CGFloat) -> some View {
        // calculate blob geometry from the two edge positions
        let minX = min(leadingX, trailingX)
        let maxX = max(leadingX, trailingX)
        let stretch = maxX - minX
        let currentWidth = max(blobBaseWidth, stretch + blobBaseWidth)

        
        let volumeRatio = blobBaseWidth / currentWidth
        let currentHeight = max(blobBaseHeight * 0.5, blobBaseHeight * volumeRatio)

        let centerX = (leadingX + trailingX) / 2

        Capsule()
            .frame(width: currentWidth, height: currentHeight)
            .glassEffect(.regular, in: .capsule)
            .shadow(color: .white.opacity(0.08), radius: 1, y: -1) // subtle top glow
            .shadow(color: .black.opacity(0.18), radius: 4, y: 2)  // bottom shadow
            .position(x: centerX, y: barHeight / 2)
    }

    // MARK: - rim light

    @ViewBuilder
    private func rimLight(tabWidth: CGFloat) -> some View {
        let minX = min(leadingX, trailingX)
        let maxX = max(leadingX, trailingX)
        let stretch = maxX - minX
        let currentWidth = max(blobBaseWidth, stretch + blobBaseWidth)
        let volumeRatio = blobBaseWidth / currentWidth
        let currentHeight = max(blobBaseHeight * 0.5, blobBaseHeight * volumeRatio)
        let centerX = (leadingX + trailingX) / 2

        // thin white arc along the top
        Capsule()
            .stroke(
                LinearGradient(
                    colors: [.white.opacity(0.35), .white.opacity(0.05)],
                    startPoint: .top,
                    endPoint: .bottom
                ),
                lineWidth: 1.5
            )
            .frame(width: currentWidth - 4, height: currentHeight - 4)
            .position(x: centerX, y: barHeight / 2)
            .allowsHitTesting(false)
    }

    // MARK: - movement

    private func moveToTab(_ index: Int, tabWidth: CGFloat) {
        guard index != selectedTab else { return }

        let oldCenter = tabCenter(for: selectedTab, tabWidth: tabWidth)
        let newCenter = tabCenter(for: index, tabWidth: tabWidth)
        let movingRight = newCenter > oldCenter

        selectedTab = index

        
        withAnimation(leadingSpring) {
            if movingRight {
                leadingX = newCenter
            } else {
                trailingX = newCenter
            }
        }

        
        withAnimation(trailingSpring.delay(0.06)) {
            if movingRight {
                trailingX = newCenter
            } else {
                leadingX = newCenter
            }
        }

        // Haptic
        UIImpactFeedbackGenerator(style: .medium).impactOccurred(intensity: 0.7)
    }

    // MARK: - helpers

    private func tabCenter(for index: Int, tabWidth: CGFloat) -> CGFloat {
        (CGFloat(index) * tabWidth) + (tabWidth / 2)
    }
}

// MARK: - pre-iOS 26 fallback with similar physics but using ultraThinMaterial

@available(iOS 17.0, *)
struct FloatingTabBar: View {
    @Binding var selectedTab: Int
    let tabs: [(icon: String, label: String)]

    @State private var leadingX: CGFloat = 0
    @State private var trailingX: CGFloat = 0
    @State private var hasAppeared = false

    private let barHeight: CGFloat = 56
    private let blobBaseWidth: CGFloat = 52
    private let blobBaseHeight: CGFloat = 44

    private let leadingSpring = Animation.spring(response: 0.38, dampingFraction: 0.68)
    private let trailingSpring = Animation.spring(response: 0.55, dampingFraction: 0.78)

    var body: some View {
        GeometryReader { geo in
            let tw = geo.size.width / CGFloat(tabs.count)

            ZStack {
                // bar background
                Capsule()
                    .fill(.ultraThinMaterial)
                    .frame(height: barHeight)
                    .shadow(color: .black.opacity(0.15), radius: 10, y: 5)

                // liquid blob
                let minX = min(leadingX, trailingX)
                let maxX = max(leadingX, trailingX)
                let stretch = maxX - minX
                let currentWidth = max(blobBaseWidth, stretch + blobBaseWidth)
                let volumeRatio = blobBaseWidth / currentWidth
                let currentHeight = max(blobBaseHeight * 0.5, blobBaseHeight * volumeRatio)
                let centerX = (leadingX + trailingX) / 2

                Capsule()
                    .fill(TTColors.accent)
                    .frame(width: currentWidth, height: currentHeight)
                    .shadow(color: TTColors.accent.opacity(0.3), radius: 6, y: 2)
                    .position(x: centerX, y: barHeight / 2)

                // rim light
                Capsule()
                    .stroke(
                        LinearGradient(
                            colors: [.white.opacity(0.4), .white.opacity(0.0)],
                            startPoint: .top,
                            endPoint: .center
                        ),
                        lineWidth: 1
                    )
                    .frame(width: currentWidth - 2, height: currentHeight - 2)
                    .position(x: centerX, y: barHeight / 2)
                    .allowsHitTesting(false)

                // icons
                HStack(spacing: 0) {
                    ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                        let isActive = selectedTab == index

                        Button {
                            moveToTab(index, tabWidth: tw)
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: tab.icon)
                                    .font(.subheadline)
                                    .symbolVariant(isActive ? .fill : .none)
                                if isActive {
                                    Text(tab.label)
                                        .font(.caption.weight(.semibold))
                                        .lineLimit(1)
                                }
                            }
                            .foregroundStyle(isActive ? .white : .secondary)
                            .frame(maxWidth: .infinity)
                            .frame(height: barHeight)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityLabel("\(tab.label) tab")
                        .accessibilityAddTraits(isActive ? .isSelected : [])
                    }
                }
            }
            .frame(height: barHeight)
            .onAppear {
                if !hasAppeared {
                    let center = (CGFloat(selectedTab) * tw) + (tw / 2)
                    leadingX = center
                    trailingX = center
                    hasAppeared = true
                }
            }
        }
        .frame(height: barHeight)
        .padding(.horizontal, 20)
        .padding(.bottom, 28)
    }

    private func moveToTab(_ index: Int, tabWidth: CGFloat) {
        guard index != selectedTab else { return }

        let oldCenter = (CGFloat(selectedTab) * tabWidth) + (tabWidth / 2)
        let newCenter = (CGFloat(index) * tabWidth) + (tabWidth / 2)
        let movingRight = newCenter > oldCenter

        selectedTab = index

        withAnimation(leadingSpring) {
            if movingRight { leadingX = newCenter } else { trailingX = newCenter }
        }
        withAnimation(trailingSpring.delay(0.06)) {
            if movingRight { trailingX = newCenter } else { leadingX = newCenter }
        }

        UIImpactFeedbackGenerator(style: .medium).impactOccurred(intensity: 0.7)
    }
}
