import SwiftUI
import MapKit

@available(iOS 17.0, *)
struct HousingTab: View {
    @Bindable var vm: TransferViewModel

    @State private var selectedApartment: Int? = nil
    @State private var mapPosition: MapCameraPosition = .automatic
    @State private var sheetOffset: CGFloat = 0
    @State private var dragStartOffset: CGFloat = 0
    @State private var currentDetent: SheetDetent = .peek
    @State private var totalHeight: CGFloat = 800

    enum SheetDetent: CGFloat {
        case peek = 0.15
        case half = 0.45
        case full = 0.85
        func height(in total: CGFloat) -> CGFloat { total * self.rawValue }
    }

    private var apartments: [SchoolDatabase.Apartment] { SchoolDatabase.housing(for: vm.selectedUni) }
    private var avgRent: Int { SchoolDatabase.averageRent(for: vm.selectedUni) }
    private var rentDiff: Int { avgRent - Int(vm.userRent) }
    private var uniCoord: CLLocationCoordinate2D {
        SchoolDatabase.universityCoordinates[vm.selectedUni]
            ?? CLLocationCoordinate2D(latitude: 28.6024, longitude: -81.2001)
    }

    var body: some View {
        GeometryReader { geo in
            let totalH = geo.size.height
            ZStack(alignment: .bottom) {
                Map(position: $mapPosition) {
                    Annotation(vm.selectedUni, coordinate: uniCoord) {
                        ZStack {
                            Circle().fill(Color.blue).frame(width: 36, height: 36)
                            Image(systemName: "graduationcap.fill").font(.system(size: 16)).foregroundStyle(.white)
                        }
                        .shadow(color: .blue.opacity(0.4), radius: 4, y: 2)
                    }

                    ForEach(Array(apartments.enumerated()), id: \.element.id) { index, apt in
                        let coord = aptCoord(apt, index: index)
                        let selected = selectedApartment == index
                        Annotation(apt.name, coordinate: coord) {
                            Button {
                                withAnimation(.spring(response: 0.3)) {
                                    selectedApartment = selectedApartment == index ? nil : index
                                }
                                if selectedApartment == index { panTo(coord) }
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            } label: {
                                ZStack {
                                    Circle().fill(selected ? Color.blue : oddsColor(apt.odds))
                                        .frame(width: selected ? 40 : 30, height: selected ? 40 : 30)
                                    Image(systemName: "house.fill").font(.system(size: selected ? 18 : 13)).foregroundStyle(.white)
                                }
                                .shadow(color: .black.opacity(0.2), radius: 3, y: 2)
                            }
                        }
                    }

                    if let idx = selectedApartment, idx < apartments.count {
                        MapPolyline(coordinates: [aptCoord(apartments[idx], index: idx), uniCoord])
                            .stroke(.blue.opacity(0.6), lineWidth: 3)
                    }
                }
                .mapStyle(.standard(elevation: .flat, pointsOfInterest: .excludingAll))
                .ignoresSafeArea(edges: .top)
                .onAppear {
                    mapPosition = .region(MKCoordinateRegion(center: uniCoord, span: MKCoordinateSpan(latitudeDelta: 0.06, longitudeDelta: 0.06)))
                    totalHeight = totalH
                    sheetOffset = SheetDetent.peek.height(in: totalH)
                }

                VStack(spacing: 0) {
                    VStack(spacing: 0) {
                        Capsule().fill(Color.secondary.opacity(0.4)).frame(width: 36, height: 5).padding(.top, 8).padding(.bottom, 8)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Housing Near \(vm.selectedUni)").font(.title3.weight(.semibold))
                            Text("Rent \(rentDiff >= 0 ? "+" : "")$\(rentDiff)/mo vs. current · \(apartments.count) listings")
                                .font(.subheadline).foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20).padding(.bottom, 12)

                        if let idx = selectedApartment, idx < apartments.count {
                            let apt = apartments[idx]
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(apt.name).font(.headline)
                                    Text("\(apt.distance) · \(apt.beds)bd/\(apt.baths)ba").font(.caption).foregroundStyle(.secondary)
                                    OddsBadge(odds: apt.odds, detail: apt.oddsDetail)
                                }
                                Spacer()
                                VStack(alignment: .trailing, spacing: 2) {
                                    Text("$\(apt.rent)").font(.title2.weight(.bold))
                                    Text("/mo").font(.caption).foregroundStyle(.secondary)
                                }
                            }
                            .padding(16)
                            .background(Color(uiColor: .secondarySystemGroupedBackground))
                            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                            .padding(.horizontal, 20).padding(.bottom, 8)
                            .transition(.move(edge: .top).combined(with: .opacity))
                        }
                    }

                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 12) {
                            ForEach(Array(apartments.enumerated()), id: \.element.id) { index, apt in
                                Button {
                                    withAnimation(.spring(response: 0.3)) {
                                        selectedApartment = selectedApartment == index ? nil : index
                                    }
                                    if selectedApartment == index { panTo(aptCoord(apartments[index], index: index)) }
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                } label: {
                                    ApartmentCardView(apartment: apt, isSelected: selectedApartment == index)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 20).padding(.bottom, 120)
                    }
                    .scrollDisabled(currentDetent == .peek)
                }
                .frame(height: sheetOffset)
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(.regularMaterial)
                        .shadow(color: .black.opacity(0.15), radius: 12, y: -4)
                )
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            let newH = dragStartOffset - value.translation.height
                            sheetOffset = max(SheetDetent.peek.height(in: totalH), min(newH, SheetDetent.full.height(in: totalH)))
                        }
                        .onEnded { value in
                            let velocity = -value.predictedEndTranslation.height / totalH
                            snapToNearest(totalHeight: totalH, velocity: velocity)
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }
                        .simultaneously(with: TapGesture().onEnded { })
                )
                .onAppear {
                    totalHeight = totalH
                    sheetOffset = SheetDetent.peek.height(in: totalH)
                    dragStartOffset = sheetOffset
                }
                .onChange(of: sheetOffset) { _, newVal in dragStartOffset = newVal }
            }
        }
        .toolbarBackground(.visible, for: .navigationBar)
    }

    private func snapToNearest(totalHeight: CGFloat, velocity: CGFloat) {
        let peekH = SheetDetent.peek.height(in: totalHeight)
        let halfH = SheetDetent.half.height(in: totalHeight)
        let fullH = SheetDetent.full.height(in: totalHeight)
        let current = sheetOffset
        var target: (SheetDetent, CGFloat)

        if velocity > 0.3 {
            target = current < halfH ? (.half, halfH) : (.full, fullH)
        } else if velocity < -0.3 {
            target = current > halfH ? (.half, halfH) : (.peek, peekH)
        } else {
            let dists: [(SheetDetent, CGFloat)] = [(.peek, abs(current - peekH)), (.half, abs(current - halfH)), (.full, abs(current - fullH))]
            target = dists.min(by: { $0.1 < $1.1 }).map { ($0.0, $0.0.height(in: totalHeight)) } ?? (.peek, peekH)
        }

        withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
            sheetOffset = target.1; currentDetent = target.0
        }
    }

    private func oddsColor(_ odds: String) -> Color {
        switch odds { case "High Odds": return .green; case "Medium Odds": return .orange; case "Low Odds": return .red; default: return .gray }
    }

    private func panTo(_ coord: CLLocationCoordinate2D) {
        withAnimation(.easeInOut(duration: 0.5)) {
            mapPosition = .region(MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: (coord.latitude + uniCoord.latitude) / 2, longitude: (coord.longitude + uniCoord.longitude) / 2),
                span: MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04)
            ))
        }
        if currentDetent == .peek {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                currentDetent = .half; sheetOffset = SheetDetent.half.height(in: totalHeight)
            }
        }
    }

    private func aptCoord(_ apt: SchoolDatabase.Apartment, index: Int) -> CLLocationCoordinate2D {
        let miles = parseDist(apt.distance)
        let offset = miles * 0.0145
        let angle = (Double(index) / Double(max(1, apartments.count))) * 2 * .pi
        return CLLocationCoordinate2D(latitude: uniCoord.latitude + offset * cos(angle), longitude: uniCoord.longitude + offset * sin(angle))
    }

    private func parseDist(_ d: String) -> Double {
        if d == "Adjacent" { return 0.15 }
        return Double(d.components(separatedBy: CharacterSet.decimalDigits.union(CharacterSet(charactersIn: ".")).inverted).joined()) ?? 1.0
    }
}

@available(iOS 17.0, *)
struct ApartmentCardView: View {
    let apartment: SchoolDatabase.Apartment
    var isSelected: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(apartment.name).font(.headline).foregroundStyle(.primary)
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.circle.fill").font(.caption).foregroundStyle(.secondary)
                        Text("\(apartment.distance) from campus").font(.caption).foregroundStyle(.secondary)
                    }
                }
                Spacer()
                HStack(spacing: 0) {
                    Text("$\(apartment.rent)").font(.title2.weight(.bold)).foregroundStyle(.primary)
                    Text("/mo").font(.subheadline).foregroundStyle(.secondary)
                }
            }
            HStack(spacing: 16) {
                Label("\(apartment.beds) bed", systemImage: "bed.double.fill").font(.caption).foregroundStyle(.secondary)
                Label("\(apartment.baths) bath", systemImage: "shower.fill").font(.caption).foregroundStyle(.secondary)
                Spacer()
                OddsBadge(odds: apartment.odds, detail: apartment.oddsDetail)
            }
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            isSelected
            ? RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color.blue, lineWidth: 2)
            : nil
        )
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.spring(response: 0.25), value: isSelected)
    }
}

