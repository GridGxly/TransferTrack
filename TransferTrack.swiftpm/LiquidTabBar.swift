import SwiftUI



@available(iOS 26.0, *)
struct LiquidTabBar: View {
    @Binding var selectedTab: Int
    let tabs: [(icon: String, label: String)]

    var body: some View {
        GlassEffectContainer(spacing: 0) {
            GeometryReader { geo in
                GlassSegmentedTabBar(
                    size: geo.size,
                    selectedTab: $selectedTab,
                    tabs: tabs
                )
                .glassEffect(.regular.interactive(), in: .capsule)
            }
        }
        .frame(height: 58)
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }
}

@available(iOS 26.0, *)
struct GlassSegmentedTabBar: UIViewRepresentable {
    var size: CGSize
    @Binding var selectedTab: Int
    let tabs: [(icon: String, label: String)]

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> UISegmentedControl {
        let items = tabs.map(\.label)
        let control = UISegmentedControl(items: items)
        control.selectedSegmentIndex = selectedTab

        for (index, tab) in tabs.enumerated() {
            let isActive = index == selectedTab
            let content = VStack(spacing: 2) {
                Image(systemName: tab.icon)
                    .font(.system(size: 18, weight: isActive ? .bold : .medium))
                    .symbolVariant(isActive ? .fill : .none)
                Text(tab.label)
                    .font(.system(size: 9, weight: isActive ? .semibold : .regular))
            }
            .foregroundStyle(isActive ? Color.primary : Color.secondary)
            .frame(width: size.width / CGFloat(tabs.count), height: size.height)

            let renderer = ImageRenderer(content: content)
            renderer.scale = 2
            if let image = renderer.uiImage {
                control.setImage(image, forSegmentAt: index)
            }
        }

        DispatchQueue.main.async {
            for subview in control.subviews {
                if subview is UIImageView && subview != control.subviews.last {
                    subview.alpha = 0
                }
            }
        }

        control.selectedSegmentTintColor = UIColor.systemGray.withAlphaComponent(0.3)
        control.addTarget(context.coordinator, action: #selector(context.coordinator.tabSelected(_:)), for: .valueChanged)
        return control
    }

    func updateUIView(_ uiView: UISegmentedControl, context: Context) {
        uiView.selectedSegmentIndex = selectedTab
    }

    func sizeThatFits(_ proposal: ProposedViewSize, uiView: UISegmentedControl, context: Context) -> CGSize? {
        return size
    }

    class Coordinator: NSObject {
        var parent: GlassSegmentedTabBar
        init(parent: GlassSegmentedTabBar) {
            self.parent = parent
        }

        @objc func tabSelected(_ control: UISegmentedControl) {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                parent.selectedTab = control.selectedSegmentIndex
            }
            UIImpactFeedbackGenerator(style: .medium).impactOccurred(intensity: 0.7)
        }
    }
}



@available(iOS 17.0, *)
struct FloatingTabBar: View {
    @Binding var selectedTab: Int
    let tabs: [(icon: String, label: String)]
    @Environment(\.colorScheme) private var colorScheme

    @State private var leadingX: CGFloat = 0
    @State private var trailingX: CGFloat = 0
    @State private var iconScales: [CGFloat] = [1, 1, 1, 1]
    @State private var iconOffsetY: [CGFloat] = [0, 0, 0, 0]
    @State private var hasAppeared = false
    @State private var isAnimating = false

    private let barHeight: CGFloat = 58
    private let blobBaseW: CGFloat = 56
    private let blobBaseH: CGFloat = 42

    var body: some View {
        GeometryReader { geo in
            let tw = geo.size.width / CGFloat(tabs.count)

            ZStack {
                Capsule()
                    .fill(.ultraThinMaterial)
                    .overlay(
                        Capsule()
                            .stroke(
                                colorScheme == .dark
                                    ? Color.white.opacity(0.12)
                                    : Color.black.opacity(0.06),
                                lineWidth: 0.5
                            )
                    )
                    .frame(height: barHeight)
                    .shadow(color: .black.opacity(colorScheme == .dark ? 0.25 : 0.10), radius: 12, y: 5)

                blobView(tw: tw)

                
                rimLightView(tw: tw)

               
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
            .onChange(of: geo.size.width) { _, _ in
                let c = CGFloat(selectedTab) * tw + tw / 2
                leadingX = c; trailingX = c
            }
        }
        .frame(height: barHeight)
        .padding(.horizontal, 20)
        .padding(.bottom, 28)
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
                    colors: colorScheme == .dark
                        ? [Color.white.opacity(0.30), Color.white.opacity(0.14), Color.white.opacity(0.06)]
                        : [Color.black.opacity(0.55), Color.black.opacity(0.35), Color.black.opacity(0.20)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .frame(width: blobW, height: blobH)
            .shadow(color: colorScheme == .dark ? .white.opacity(0.06) : .black.opacity(0.12), radius: 8, y: 3)
            .shadow(color: colorScheme == .dark ? .white.opacity(0.04) : .clear, radius: 1, y: -1)
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
        let totalW = CGFloat(tabs.count) * tw
        let normalizedX = totalW > 0 ? (center / totalW) * 2 - 1 : 0

        Capsule()
            .stroke(
                LinearGradient(
                    colors: colorScheme == .dark
                        ? [.white.opacity(0.30 + normalizedX * 0.08), .white.opacity(0.06), .white.opacity(0.02)]
                        : [.white.opacity(0.60 + normalizedX * 0.10), .white.opacity(0.15), .white.opacity(0.04)],
                    startPoint: .init(x: 0.3 - Double(normalizedX) * 0.2, y: 0),
                    endPoint: .init(x: 0.7 - Double(normalizedX) * 0.2, y: 1)
                ),
                lineWidth: 1.0
            )
            .frame(width: blobW - 2, height: blobH - 2)
            .position(x: center, y: barHeight / 2)
            .allowsHitTesting(false)
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

       
        withAnimation(.spring(response: 0.25, dampingFraction: 0.58)) {
            if right { leadingX = newC } else { trailingX = newC }
        }

        withAnimation(.spring(response: 0.48 + stretchFactor * 0.12, dampingFraction: 0.68).delay(0.08 + stretchFactor * 0.04)) {
            if right { trailingX = newC } else { leadingX = newC }
        }

        
        let i = index
        withAnimation(.spring(response: 0.15, dampingFraction: 0.35).delay(0.10)) {
            iconScales[i] = 0.75
            iconOffsetY[i] = 4
        }
        withAnimation(.spring(response: 0.25, dampingFraction: 0.45).delay(0.26)) {
            iconScales[i] = 1.15
            iconOffsetY[i] = -3
        }
        withAnimation(.spring(response: 0.3, dampingFraction: 0.65).delay(0.44)) {
            iconScales[i] = 1.0
            iconOffsetY[i] = 0
        }

        let old = oldIdx
        withAnimation(.spring(response: 0.2, dampingFraction: 0.6).delay(0.05)) {
            iconScales[old] = 0.88
        }
        withAnimation(.spring(response: 0.22, dampingFraction: 0.55).delay(0.18)) {
            iconScales[old] = 1.04
        }
        withAnimation(.spring(response: 0.25, dampingFraction: 0.7).delay(0.32)) {
            iconScales[old] = 1.0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.65) { isAnimating = false }
    }
}


extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
