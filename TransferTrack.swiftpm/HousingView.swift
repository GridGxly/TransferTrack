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
    @State private var hasInitialized = false

    enum SheetDetent: CGFloat {
        case peek = 0.15
        case half = 0.45
        case full = 0.85
        func height(in total: CGFloat) -> CGFloat { total * self.rawValue }
    }

    private var apartments: [SchoolDatabase.Apartment] { SchoolDatabase.housing(for: vm.selectedUni) }
    private var avgRent: Int { SchoolDatabase.averageRent(for: vm.selectedUni) }
    private var rentDiff: Int { avgRent - Int(vm.userRent) }


    private var rentDiffColor: Color {
        if rentDiff > 0 { return .red }
        else if rentDiff < 0 { return .green }
        else { return .secondary }
    }

    private var uniCoord: CLLocationCoordinate2D {
        SchoolDatabase.universityCoordinates[vm.selectedUni]
            ?? CLLocationCoordinate2D(latitude: 28.6024, longitude: -81.2001)
    }

    var body: some View {
        GeometryReader { geo in
            let totalH = max(geo.size.height, 400)

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
                                    if selected {
                                        Circle()
                                            .fill(Color.blue)
                                            .frame(width: 40, height: 40)
                                        Image(systemName: "house.fill")
                                            .font(.system(size: 18))
                                            .foregroundStyle(.white)
                                    } else {
                                        Circle()
                                            .fill(oddsColor(apt.odds))
                                            .frame(width: 16, height: 16)
                                        Circle()
                                            .stroke(Color.white, lineWidth: 2)
                                            .frame(width: 16, height: 16)
                                    }
                                }
                                .shadow(color: .black.opacity(0.2), radius: 3, y: 2)
                                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: selected)
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

                
                VStack(spacing: 0) {
                   
                    VStack(spacing: 0) {
                        Capsule()
                            .fill(Color(uiColor: .tertiaryLabel))
                            .frame(width: 36, height: 5)
                            .padding(.top, 8)
                            .padding(.bottom, 8)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Housing Near \(vm.selectedUni)")
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(.primary)
                            HStack(spacing: 0) {
                                Text("Rent ")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Text("\(rentDiff >= 0 ? "+" : "")$\(rentDiff)/mo")
                                    .font(.subheadline.weight(.medium))
                                    .foregroundStyle(rentDiffColor)
                                Text(" vs. current · \(apartments.count) listings")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 12)
                    }
                    ScrollViewReader { proxy in
                        ScrollView(showsIndicators: false) {
                            LazyVStack(spacing: 12) {
                                ForEach(Array(apartments.enumerated()), id: \.element.id) { index, apt in
                                    Button {
                                        withAnimation(.spring(response: 0.3)) {
                                            selectedApartment = selectedApartment == index ? nil : index
                                        }
                                        if selectedApartment == index {
                                            panTo(aptCoord(apartments[index], index: index))
                                        }
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    } label: {
                                        ApartmentCardView(apartment: apt, isSelected: selectedApartment == index)
                                    }
                                    .buttonStyle(.plain)
                                    .id(index)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 120)
                        }
                        .scrollDisabled(currentDetent == .peek)
                        .onChange(of: selectedApartment) { _, newVal in
                            if let idx = newVal {
                                withAnimation(.spring(response: 0.35)) {
                                    proxy.scrollTo(idx, anchor: .top)
                                }
                            }
                        }
                    }
                }
                .frame(height: max(sheetOffset, SheetDetent.peek.height(in: totalH)))
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color(uiColor: .systemBackground))
                        .shadow(color: .black.opacity(0.15), radius: 12, y: -4)
                )
                .gesture(
                    DragGesture(minimumDistance: 5)
                        .onChanged { value in
                            let peekH = SheetDetent.peek.height(in: totalH)
                            let fullH = SheetDetent.full.height(in: totalH)
                            let newH = dragStartOffset - value.translation.height
                            sheetOffset = max(peekH, min(newH, fullH))
                        }
                        .onEnded { value in
                            let velocity = -value.predictedEndTranslation.height / totalH
                            snapToNearest(totalHeight: totalH, velocity: velocity)
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }
                )
            }
            .onAppear {
                if !hasInitialized {
                    totalHeight = totalH
                    let peekH = SheetDetent.peek.height(in: totalH)
                    sheetOffset = peekH
                    dragStartOffset = peekH
                    hasInitialized = true

                    mapPosition = .region(MKCoordinateRegion(
                        center: uniCoord,
                        span: MKCoordinateSpan(latitudeDelta: 0.06, longitudeDelta: 0.06)
                    ))
                }
            }
            .onChange(of: geo.size.height) { _, newH in
                let safeH = max(newH, 400)
                totalHeight = safeH
                let newSheetH = currentDetent.height(in: safeH)
                sheetOffset = newSheetH
                dragStartOffset = newSheetH
            }
            .onChange(of: sheetOffset) { _, newVal in
                dragStartOffset = newVal
            }
            .onChange(of: vm.selectedUni) { _, _ in
                selectedApartment = nil
                withAnimation(.spring(response: 0.35)) {
                    currentDetent = .peek
                    sheetOffset = SheetDetent.peek.height(in: totalH)
                }
                mapPosition = .region(MKCoordinateRegion(
                    center: uniCoord,
                    span: MKCoordinateSpan(latitudeDelta: 0.06, longitudeDelta: 0.06)
                ))
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
            let dists: [(SheetDetent, CGFloat)] = [
                (.peek, abs(current - peekH)),
                (.half, abs(current - halfH)),
                (.full, abs(current - fullH))
            ]
            target = dists.min(by: { $0.1 < $1.1 }).map { ($0.0, $0.0.height(in: totalHeight)) } ?? (.peek, peekH)
        }

        withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
            sheetOffset = target.1
            currentDetent = target.0
        }
    }



    private func oddsColor(_ odds: String) -> Color {
        switch odds {
        case "High Odds": return .green
        case "Medium Odds": return .orange
        case "Low Odds": return .red
        default: return .gray
        }
    }

    private func panTo(_ coord: CLLocationCoordinate2D) {
        withAnimation(.easeInOut(duration: 0.5)) {
            mapPosition = .region(MKCoordinateRegion(
                center: CLLocationCoordinate2D(
                    latitude: (coord.latitude + uniCoord.latitude) / 2,
                    longitude: (coord.longitude + uniCoord.longitude) / 2
                ),
                span: MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04)
            ))
        }
        if currentDetent == .peek {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                currentDetent = .half
                sheetOffset = SheetDetent.half.height(in: totalHeight)
            }
        }
    }

    private func aptCoord(_ apt: SchoolDatabase.Apartment, index: Int) -> CLLocationCoordinate2D {
        let miles = parseDist(apt.distance)
        let offset = miles * 0.0145
        let angle = (Double(index) / Double(max(1, apartments.count))) * 2 * .pi
        return CLLocationCoordinate2D(
            latitude: uniCoord.latitude + offset * cos(angle),
            longitude: uniCoord.longitude + offset * sin(angle)
        )
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
