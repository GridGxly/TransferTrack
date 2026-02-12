import SwiftUI

// MARK: - liquid glass tab bar
// Using Apple's strict Liquid Glass framework

@available(iOS 26.0, *)
struct LiquidTabBar: View {
    @Binding var selectedTab: Int
    let tabs: [(icon: String, label: String)]
    
    // animation state
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging: Bool = false
    
    // configuration
    private let barHeight: CGFloat = 60
    private let iconSize: CGFloat = 24
    private let blobSize: CGFloat = 50
    
    // native spring for fluid response
    private let liquidSpring: Animation = .spring(response: 0.5, dampingFraction: 0.7, blendDuration: 0.7)

    var body: some View {
        GeometryReader { geo in
            let tabWidth = geo.size.width / CGFloat(tabs.count)
            
            ZStack(alignment: .bottom) {
                
                // MARK: 1. native liquid glass layer
                ZStack {
                    Capsule()
                        .frame(height: barHeight)
                        .glassEffect(.regular, in: Capsule())
                    
                    
                    let activeX = (CGFloat(selectedTab) * tabWidth) + (tabWidth / 2)
                    let currentPos = isDragging ? dragOffset : activeX
                    
                    Capsule()
                        .frame(width: blobSize, height: blobSize)
                        .position(x: currentPos, y: barHeight / 2) // center in bar
                        .glassEffect(.regular, in: Capsule()) // native glass
                        .shadow(color: .black.opacity(0.15), radius: 8, y: 4) // subtle 3D lift
                }
                .frame(height: barHeight)
                // add padding to lift it up slightly
                .padding(.bottom, 20)
                
                // MARK: icons & labels
                iconLayer(size: geo.size, tabWidth: tabWidth)
            }
            .gesture(dragGesture(tabWidth: tabWidth))
        }
        .frame(height: barHeight + 20)
        .padding(.horizontal, 24)
        .padding(.bottom, 10)
    }
    
    // MARK: - subviews
    
    private func iconLayer(size: CGSize, tabWidth: CGFloat) -> some View {
        HStack(spacing: 0) {
            ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                VStack(spacing: 4) {
                    Image(systemName: tab.icon)
                        .font(.system(size: iconSize, weight: .semibold))
                        .foregroundStyle(selectedTab == index ? .white : .secondary)
                        .scaleEffect(selectedTab == index ? 1.2 : 1.0)
                        .offset(y: selectedTab == index ? -6 : 0)
                        .animation(liquidSpring, value: selectedTab)
                    
                    Text(tab.label)
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(selectedTab == index ? .primary : .secondary)
                        .offset(y: selectedTab == index ? -2 : 0)
                }
                .frame(maxWidth: .infinity)
                .frame(height: barHeight)
                .contentShape(Rectangle())
                .onTapGesture {
                    withAnimation(liquidSpring) {
                        selectedTab = index
                    }
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
            }
        }
    }
    
    // MARK: - gestures
    
    private func dragGesture(tabWidth: CGFloat) -> some Gesture {
        DragGesture(minimumDistance: 0)
            .onChanged { value in
                if !isDragging {
                    dragOffset = (CGFloat(selectedTab) * tabWidth) + (tabWidth / 2)
                }
                isDragging = true
                dragOffset = value.location.x
            }
            .onEnded { value in
                isDragging = false
                let locationX = value.location.x
                let index = Int(max(0, min(CGFloat(tabs.count) - 1, round(locationX / tabWidth))))
                
                if index != selectedTab {
                    UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                }
                
                withAnimation(liquidSpring) {
                    selectedTab = index
                }
            }
    }
}


