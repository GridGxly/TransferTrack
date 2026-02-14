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
        case half = 0.50
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

                    if currentDetent == .peek {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(Array(apartments.enumerated()), id: \.element.id) { index, apt in
                                    Button {
                                        withAnimation(.spring(response: 0.3)) {
                                            selectedApartment = index
                                            currentDetent = .half
                                            sheetOffset = SheetDetent.half.height(in: totalH)
                                        }
                                        panTo(aptCoord(apt, index: index))
                                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                    } label: {
                                        MiniApartmentCard(apartment: apt, isSelected: selectedApartment == index)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.horizontal, 20)
                            .padding(.bottom, 12)
                        }
                    } else {
                        TabView(selection: Binding(
                            get: { selectedApartment ?? 0 },
                            set: { newVal in
                                withAnimation(.spring(response: 0.3)) {
                                    selectedApartment = newVal
                                }
                                panTo(aptCoord(apartments[newVal], index: newVal))
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            }
                        )) {
                            ForEach(Array(apartments.enumerated()), id: \.element.id) { index, apt in
                                ApartmentCardView(
                                    apartment: apt,
                                    isSelected: selectedApartment == index,
                                    userRent: Int(vm.userRent)
                                )
                                .tag(index)
                            }
                        }
                        .tabViewStyle(.page(indexDisplayMode: .always))
                        .frame(height: currentDetent == .full ? nil : 260)

                        
                        if currentDetent == .full, let idx = selectedApartment, idx < apartments.count {
                            let apt = apartments[idx]
                            ScrollView(showsIndicators: false) {
                                VStack(alignment: .leading, spacing: 16) {
                                    ApartmentDetailSection(apartment: apt, userRent: Int(vm.userRent))
                                }
                                .padding(.horizontal, 20)
                                .padding(.bottom, 120)
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
struct MiniApartmentCard: View {
    let apartment: SchoolDatabase.Apartment
    var isSelected: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Text(apartment.name)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                if apartment.odds == "High Odds" && apartment.oddsDetail.contains("No Credit") {
                    Text("NO CREDIT CHK")
                        .font(.system(size: 7, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(Color.green)
                        .clipShape(Capsule())
                }
            }
            HStack(spacing: 8) {
                Text("$\(apartment.rent)/mo")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.primary)
                Text(apartment.distance)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            isSelected
                ? RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(Color.blue, lineWidth: 2)
                : nil
        )
    }
}



@available(iOS 17.0, *)
struct ApartmentCardView: View {
    let apartment: SchoolDatabase.Apartment
    var isSelected: Bool = false
    var userRent: Int = 1200

    private var rentDiff: Int { apartment.rent - userRent }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ZStack(alignment: .topTrailing) {
                LinearGradient(
                    colors: gradientColors,
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(height: 72)
                .overlay(alignment: .leading) {
                    HStack(spacing: 12) {
                        Image(systemName: "building.2.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(.white.opacity(0.9))
                        VStack(alignment: .leading, spacing: 2) {
                            Text(apartment.name)
                                .font(.headline)
                                .foregroundStyle(.white)
                                .lineLimit(1)
                            HStack(spacing: 4) {
                                Image(systemName: "mappin.circle.fill").font(.caption2)
                                Text(apartment.distance)
                                    .font(.caption)
                            }
                            .foregroundStyle(.white.opacity(0.8))
                        }
                    }
                    .padding(.horizontal, 16)
                }

                if let badge = featureBadge {
                    Text(badge)
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(badgeColor)
                        .clipShape(Capsule())
                        .padding(10)
                }
            }
            .clipShape(
                UnevenRoundedRectangle(topLeadingRadius: 16, bottomLeadingRadius: 0, bottomTrailingRadius: 0, topTrailingRadius: 16)
            )


            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .firstTextBaseline) {
                    HStack(spacing: 0) {
                        Text("$\(apartment.rent)")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(.primary)
                        Text("/mo")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    if rentDiff != 0 {
                        Text("\(rentDiff > 0 ? "+" : "")$\(rentDiff) vs your budget")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(rentDiff > 0 ? .red : .green)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background((rentDiff > 0 ? Color.red : Color.green).opacity(0.1))
                            .clipShape(Capsule())
                    }
                }


                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Image(systemName: "bed.double.fill").font(.caption2).foregroundStyle(.secondary)
                        Text("\(apartment.beds) bed").font(.caption).foregroundStyle(.secondary)
                    }
                    HStack(spacing: 4) {
                        Image(systemName: "shower.fill").font(.caption2).foregroundStyle(.secondary)
                        Text("\(apartment.baths) bath").font(.caption).foregroundStyle(.secondary)
                    }
                    HStack(spacing: 4) {
                        Image(systemName: amenityIcon).font(.caption2).foregroundStyle(.secondary)
                        Text(amenityLabel).font(.caption).foregroundStyle(.secondary)
                    }
                    Spacer()
                }


                OddsBadge(odds: apartment.odds, detail: apartment.oddsDetail)
            }
            .padding(16)
        }
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            isSelected
                ? RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(Color.blue, lineWidth: 2)
                : nil
        )
        .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
        .padding(.horizontal, 20)
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.spring(response: 0.25), value: isSelected)
    }



    private var gradientColors: [Color] {
        switch apartment.odds {
        case "High Odds": return [Color(red: 0.15, green: 0.55, blue: 0.35), Color(red: 0.10, green: 0.40, blue: 0.30)]
        case "Medium Odds": return [Color(red: 0.55, green: 0.40, blue: 0.15), Color(red: 0.45, green: 0.30, blue: 0.10)]
        case "Low Odds": return [Color(red: 0.55, green: 0.20, blue: 0.15), Color(red: 0.45, green: 0.15, blue: 0.10)]
        default: return [.gray, .gray.opacity(0.8)]
        }
    }

    private var featureBadge: String? {
        if apartment.oddsDetail.contains("No Credit") { return "NO CREDIT CHECK" }
        if apartment.oddsDetail.contains("Per-bed") { return "PER-BED LEASE" }
        if apartment.rent <= 750 { return "BEST VALUE" }
        return nil
    }

    private var badgeColor: Color {
        if apartment.oddsDetail.contains("No Credit") { return .green }
        if apartment.oddsDetail.contains("Per-bed") { return .blue }
        return .orange
    }

    private var amenityIcon: String {
        if apartment.oddsDetail.contains("Per-bed") { return "person.2.fill" }
        if apartment.oddsDetail.contains("Student") { return "graduationcap.fill" }
        return "wifi"
    }

    private var amenityLabel: String {
        if apartment.oddsDetail.contains("Per-bed") { return "Individual lease" }
        if apartment.oddsDetail.contains("Student") { return "Student housing" }
        return "Utilities incl."
    }
}




@available(iOS 17.0, *)
struct ApartmentDetailSection: View {
    let apartment: SchoolDatabase.Apartment
    let userRent: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 10) {
                Text("QUICK FACTS")
                    .font(.caption2.weight(.bold))
                    .tracking(0.8)
                    .foregroundStyle(.secondary)

                DetailRow(icon: "dollarsign.circle.fill", color: .green, label: "Monthly Rent", value: "$\(apartment.rent)")
                DetailRow(icon: "mappin.circle.fill", color: .blue, label: "Distance", value: "\(apartment.distance) from campus")
                DetailRow(icon: "bed.double.fill", color: .purple, label: "Layout", value: "\(apartment.beds) bed · \(apartment.baths) bath")
                DetailRow(icon: "checkmark.shield.fill", color: oddsColor, label: "Approval", value: "\(apartment.odds) — \(apartment.oddsDetail)")

                let diff = apartment.rent - userRent
                if diff > 0 {
                    DetailRow(icon: "exclamationmark.triangle.fill", color: .orange, label: "Budget Impact", value: "+$\(diff)/mo over your current rent")
                } else if diff < 0 {
                    DetailRow(icon: "arrow.down.circle.fill", color: .green, label: "Budget Impact", value: "Saves $\(abs(diff))/mo vs. your current rent")
                }
            }


            VStack(alignment: .leading, spacing: 8) {
                Text("INSIDER TIP")
                    .font(.caption2.weight(.bold))
                    .tracking(0.8)
                    .foregroundStyle(.secondary)

                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: "lightbulb.fill")
                        .font(.caption)
                        .foregroundStyle(.yellow)
                    Text(insiderTip)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(12)
                .background(Color.yellow.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .padding(.top, 8)
    }

    private var oddsColor: Color {
        switch apartment.odds {
        case "High Odds": return .green
        case "Medium Odds": return .orange
        default: return .red
        }
    }

    private var insiderTip: String {
        if apartment.oddsDetail.contains("Per-bed") {
            return "Per-bed leases mean you only pay for YOUR room. If a roommate leaves, the complex fills the spot — not you. Best deal for transfer students with thin credit."
        }
        if apartment.oddsDetail.contains("No Credit") {
            return "No credit check means they use your enrollment verification instead. Bring your acceptance letter and financial aid award on your tour — that's all they need."
        }
        if apartment.oddsDetail.contains("Co-signer") {
            return "Co-signer recommended doesn't mean required. Ask about their income-based alternative — some complexes accept 2.5x rent in monthly income as proof."
        }
        if apartment.oddsDetail.contains("Guarantor Required") {
            return "Guarantor required usually means 3x rent annual income. If your parents can't qualify, ask about third-party guarantor services like Leap or TheGuarantors ($200–400 one-time fee)."
        }
        return "Tour in person if you can — online photos always look better than reality. Check the parking lot at 11pm to see how full it actually gets."
    }
}




struct DetailRow: View {
    let icon: String
    let color: Color
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(color)
                .frame(width: 20)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.caption.weight(.medium))
                .foregroundStyle(.primary)
                .multilineTextAlignment(.trailing)
        }
    }
}
