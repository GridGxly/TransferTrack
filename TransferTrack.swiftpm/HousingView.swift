import SwiftUI
import MapKit

// MARK: - housing tab (full-screen map + OVERLAY bottom sheet)
// FIX: No system .sheet — that blocks the entire window and traps the user.
// Instead: a ZStack overlay with DragGesture that snaps between 3 heights.
// The tab bar remains fully tappable because the sheet is INSIDE the view hierarchy.

@available(iOS 17.0, *)
struct HousingTab: View {
    @Bindable var vm: TransferViewModel

    @State private var selectedApartment: Int? = nil
    @State private var mapPosition: MapCameraPosition = .automatic

    // Overlay sheet state
    @State private var sheetOffset: CGFloat = 0       // current Y offset from bottom
    @State private var dragStartOffset: CGFloat = 0
    @State private var currentDetent: SheetDetent = .peek
    @State private var totalHeight: CGFloat = 800     // updated on appear

    enum SheetDetent: CGFloat {
        case peek = 0.15    // just header visible
        case half = 0.45    // half screen
        case full = 0.85    // nearly full

        func height(in total: CGFloat) -> CGFloat { total * self.rawValue }
    }

    private var apartments: [SchoolDatabase.Apartment] {
        SchoolDatabase.housing(for: vm.selectedUni)
    }

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
                // MARK: full-screen map
                Map(position: $mapPosition) {
                    Annotation(vm.selectedUni, coordinate: uniCoord) {
                        ZStack {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 36, height: 36)
                            Image(systemName: "graduationcap.fill")
                                .font(.system(size: 16))
                                .foregroundStyle(.white)
                        }
                        .shadow(color: .blue.opacity(0.4), radius: 4, y: 2)
                    }

                    ForEach(Array(apartments.enumerated()), id: \.element.id) { index, apt in
                        let coord = apartmentCoordinate(for: apt, index: index)
                        let isSelected = selectedApartment == index

                        Annotation(apt.name, coordinate: coord) {
                            Button {
                                withAnimation(.spring(response: 0.3)) {
                                    selectedApartment = selectedApartment == index ? nil : index
                                }
                                if selectedApartment == index {
                                    panToApartment(coord)
                                }
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            } label: {
                                ZStack {
                                    Circle()
                                        .fill(isSelected ? Color.blue : oddsColor(apt.odds))
                                        .frame(width: isSelected ? 40 : 30, height: isSelected ? 40 : 30)
                                    Image(systemName: "house.fill")
                                        .font(.system(size: isSelected ? 18 : 13))
                                        .foregroundStyle(.white)
                                }
                                .shadow(color: .black.opacity(0.2), radius: 3, y: 2)
                            }
                        }
                    }

                    if let idx = selectedApartment, idx < apartments.count {
                        let aptCoord = apartmentCoordinate(for: apartments[idx], index: idx)
                        MapPolyline(coordinates: [aptCoord, uniCoord])
                            .stroke(.blue.opacity(0.6), lineWidth: 3)
                    }
                }
                .ignoresSafeArea(edges: .top)
                .onAppear {
                    mapPosition = .region(MKCoordinateRegion(
                        center: uniCoord,
                        span: MKCoordinateSpan(latitudeDelta: 0.06, longitudeDelta: 0.06)
                    ))
                    // Start at peek
                    totalHeight = totalH
                    sheetOffset = SheetDetent.peek.height(in: totalH)
                }
                .accessibilityLabel("Map showing \(vm.selectedUni) and \(apartments.count) nearby apartments")

                // MARK: overlay bottom sheet (NOT a system .sheet)
                VStack(spacing: 0) {
                    // drag handle
                    Capsule()
                        .fill(Color.secondary.opacity(0.4))
                        .frame(width: 36, height: 5)
                        .padding(.top, 8)
                        .padding(.bottom, 8)

                    // header (always visible at peek)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Housing Near \(vm.selectedUni)")
                            .font(.title3.weight(.semibold))
                        Text("Rent \(rentDiff >= 0 ? "+" : "")$\(rentDiff)/mo vs. current · \(apartments.count) listings")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)

                    // selected apartment detail
                    if let idx = selectedApartment, idx < apartments.count {
                        let apt = apartments[idx]
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(apt.name).font(.headline)
                                Text("\(apt.distance) · \(apt.beds)bd/\(apt.baths)ba")
                                    .font(.caption).foregroundStyle(.secondary)
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 2) {
                                Text("$\(apt.rent)/mo")
                                    .font(.title3.weight(.bold))
                                OddsBadge(odds: apt.odds, detail: apt.oddsDetail)
                            }
                        }
                        .padding(16)
                        .background(Color.blue.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .padding(.horizontal, 20)
                        .padding(.bottom, 8)
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }

                    // scrollable apartment list
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 12) {
                            ForEach(Array(apartments.enumerated()), id: \.element.id) { index, apt in
                                Button {
                                    withAnimation(.spring(response: 0.3)) {
                                        selectedApartment = selectedApartment == index ? nil : index
                                    }
                                    if selectedApartment == index {
                                        let coord = apartmentCoordinate(for: apartments[index], index: index)
                                        panToApartment(coord)
                                    }
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                } label: {
                                    ApartmentCardView(
                                        apartment: apt,
                                        isSelected: selectedApartment == index
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 120) // space for tab bar
                    }
                    // only allow scroll when sheet is at half or full
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
                            let clamped = max(
                                SheetDetent.peek.height(in: totalH),
                                min(newH, SheetDetent.full.height(in: totalH))
                            )
                            sheetOffset = clamped
                        }
                        .onEnded { value in
                            let velocity = -value.predictedEndTranslation.height / totalH
                            snapToNearest(totalHeight: totalH, velocity: velocity)
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }
                        .simultaneously(with: TapGesture().onEnded { }) // prevent conflict
                )
                .onAppear {
                    totalHeight = totalH
                    sheetOffset = SheetDetent.peek.height(in: totalH)
                    dragStartOffset = sheetOffset
                }
                .onChange(of: sheetOffset) { _, newVal in
                    dragStartOffset = newVal
                }
            }
        }
    }

    // MARK: - snap to nearest detent

    private func snapToNearest(totalHeight: CGFloat, velocity: CGFloat) {
        let peekH = SheetDetent.peek.height(in: totalHeight)
        let halfH = SheetDetent.half.height(in: totalHeight)
        let fullH = SheetDetent.full.height(in: totalHeight)

        let current = sheetOffset
        var target: (detent: SheetDetent, height: CGFloat)

        // using velocity to determine intent
        if velocity > 0.3 {
            // flicking up
            if current < halfH { target = (.half, halfH) }
            else { target = (.full, fullH) }
        } else if velocity < -0.3 {
            // flicking down
            if current > halfH { target = (.half, halfH) }
            else { target = (.peek, peekH) }
        } else {
            // snap to closest
            let distances: [(SheetDetent, CGFloat)] = [
                (.peek, abs(current - peekH)),
                (.half, abs(current - halfH)),
                (.full, abs(current - fullH))
            ]
            target = distances.min(by: { $0.1 < $1.1 }).map { ($0.0, $0.0.height(in: totalHeight)) }
                ?? (.peek, peekH)
        }

        withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
            sheetOffset = target.height
            currentDetent = target.detent
        }
    }

    // MARK: - helpers

    private func oddsColor(_ odds: String) -> Color {
        switch odds {
        case "High Odds": return .green
        case "Medium Odds": return .orange
        case "Low Odds": return .red
        default: return .gray
        }
    }

    private func panToApartment(_ coord: CLLocationCoordinate2D) {
        withAnimation(.easeInOut(duration: 0.5)) {
            mapPosition = .region(MKCoordinateRegion(
                center: CLLocationCoordinate2D(
                    latitude: (coord.latitude + uniCoord.latitude) / 2,
                    longitude: (coord.longitude + uniCoord.longitude) / 2
                ),
                span: MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04)
            ))
        }
        // also expand sheet to half if at peek
        if currentDetent == .peek {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.82)) {
                currentDetent = .half
                sheetOffset = SheetDetent.half.height(in: totalHeight)
            }
        }
    }

    private func apartmentCoordinate(for apt: SchoolDatabase.Apartment, index: Int) -> CLLocationCoordinate2D {
        let miles = parseDistance(apt.distance)
        let degreesPerMile = 0.0145
        let offset = miles * degreesPerMile
        let angle = (Double(index) / Double(max(1, apartments.count))) * 2 * .pi
        return CLLocationCoordinate2D(
            latitude: uniCoord.latitude + offset * cos(angle),
            longitude: uniCoord.longitude + offset * sin(angle)
        )
    }

    private func parseDistance(_ distance: String) -> Double {
        if distance == "Adjacent" { return 0.15 }
        let numbers = distance.components(separatedBy: CharacterSet.decimalDigits.union(CharacterSet(charactersIn: ".")).inverted).joined()
        return Double(numbers) ?? 1.0
    }
}

// MARK: - apartment card

@available(iOS 17.0, *)
struct ApartmentCardView: View {
    let apartment: SchoolDatabase.Apartment
    var isSelected: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(apartment.name)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.circle.fill").font(.caption).foregroundStyle(.secondary)
                        Text("\(apartment.distance) from campus")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                }
                Spacer()
                HStack(spacing: 0) {
                    Text("$\(apartment.rent)")
                        .font(.title2.weight(.bold)).foregroundStyle(.primary)
                    Text("/mo")
                        .font(.subheadline).foregroundStyle(.secondary)
                }
            }

            HStack(spacing: 16) {
                Label("\(apartment.beds) bed", systemImage: "bed.double.fill")
                    .font(.caption).foregroundStyle(.secondary)
                Label("\(apartment.baths) bath", systemImage: "shower.fill")
                    .font(.caption).foregroundStyle(.secondary)
            }

            OddsBadge(odds: apartment.odds, detail: apartment.oddsDetail)
        }
        .padding(16)
        .background(isSelected ? Color.blue.opacity(0.08) : Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            isSelected ? RoundedRectangle(cornerRadius: 16)
                .stroke(Color.blue.opacity(0.3), lineWidth: 2) : nil
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(apartment.name). $\(apartment.rent) per month. \(apartment.distance). \(apartment.odds).")
        .accessibilityHint("Tap to show on map")
    }
}
