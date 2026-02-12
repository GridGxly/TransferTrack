import SwiftUI
import MapKit

// MARK: - housing tab

@available(iOS 17.0, *)
struct HousingTab: View {
    let currentRent: Double
    let uniName: String

    @State private var selectedApartment: Int? = nil
    @State private var mapPosition: MapCameraPosition = .automatic

    private var apartments: [SchoolDatabase.Apartment] {
        SchoolDatabase.housing(for: uniName)
    }

    private var avgRent: Int {
        SchoolDatabase.averageRent(for: uniName)
    }

    private var rentDiff: Int {
        avgRent - Int(currentRent)
    }

    private var gasSavings: Int {
        apartments.isEmpty ? 0 : 50
    }

    // university location for map
    private var uniCoord: CLLocationCoordinate2D {
        SchoolDatabase.universityCoordinates[uniName]
            ?? CLLocationCoordinate2D(latitude: 28.6024, longitude: -81.2001)
    }

    var body: some View {
        VStack(spacing: 20) {
            // MARK: header
            VStack(alignment: .leading, spacing: 8) {
                SectionHeader(
                    title: "Housing Near \(uniName)",
                    subtitle: "Rent \(rentDiff >= 0 ? "+" : "")$\(rentDiff)/mo vs. current · Gas savings -$\(gasSavings)/mo"
                )
            }
            .padding(.horizontal, 20)

            // MARK: mapKit view
            Map(position: $mapPosition) {
                // university pin
                Annotation(uniName, coordinate: uniCoord) {
                    ZStack {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: 32, height: 32)
                        Image(systemName: "graduationcap.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(.white)
                    }
                    .shadow(color: .blue.opacity(0.4), radius: 4, y: 2)
                }

                // apartment pins
                ForEach(Array(apartments.enumerated()), id: \.offset) { index, apt in
                    let coord = apartmentCoordinate(for: apt, index: index)
                    let isSelected = selectedApartment == index

                    Annotation(apt.name, coordinate: coord) {
                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                selectedApartment = selectedApartment == index ? nil : index
                            }
                        } label: {
                            ZStack {
                                Circle()
                                    .fill(isSelected ? Color.orange : oddsColor(apt.odds))
                                    .frame(width: isSelected ? 36 : 28, height: isSelected ? 36 : 28)
                                Image(systemName: "house.fill")
                                    .font(.system(size: isSelected ? 16 : 12))
                                    .foregroundStyle(.white)
                            }
                            .shadow(color: .black.opacity(0.2), radius: 3, y: 2)
                        }
                    }
                }

                // route line from selected apartment to university
                if let idx = selectedApartment, idx < apartments.count {
                    let aptCoord = apartmentCoordinate(for: apartments[idx], index: idx)
                    MapPolyline(coordinates: [aptCoord, uniCoord])
                        .stroke(.blue.opacity(0.6), lineWidth: 3)
                }
            }
            .frame(height: 220)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .padding(.horizontal, 20)
            .onAppear {
                mapPosition = .region(MKCoordinateRegion(
                    center: uniCoord,
                    span: MKCoordinateSpan(latitudeDelta: 0.06, longitudeDelta: 0.06)
                ))
            }
            .accessibilityLabel("Map showing \(uniName) and \(apartments.count) nearby apartments")

            // MARK: selected apartment detail
            if let idx = selectedApartment, idx < apartments.count {
                let apt = apartments[idx]
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(apt.name)
                            .font(.headline)
                        Text("\(apt.distance) · \(apt.beds)bd/\(apt.baths)ba")
                            .font(.caption)
                            .foregroundStyle(.secondary)
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
                .transition(.move(edge: .top).combined(with: .opacity))
            }

            // MARK: apartment list with scroll transitions
            ForEach(Array(apartments.enumerated()), id: \.offset) { index, apt in
                ApartmentCard(
                    apartment: apt,
                    isSelected: selectedApartment == index,
                    onSelect: {
                        withAnimation(.spring(response: 0.3)) {
                            selectedApartment = selectedApartment == index ? nil : index
                            // pan map to selected apartment
                            if selectedApartment == index {
                                let coord = apartmentCoordinate(for: apt, index: index)
                                mapPosition = .region(MKCoordinateRegion(
                                    center: CLLocationCoordinate2D(
                                        latitude: (coord.latitude + uniCoord.latitude) / 2,
                                        longitude: (coord.longitude + uniCoord.longitude) / 2
                                    ),
                                    span: MKCoordinateSpan(latitudeDelta: 0.04, longitudeDelta: 0.04)
                                ))
                            }
                        }
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }
                )
                .scrollTransition { content, phase in
                    content
                        .scaleEffect(phase.isIdentity ? 1 : 0.95)
                        .opacity(phase.isIdentity ? 1 : 0.7)
                }
            }
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

 
    private func apartmentCoordinate(for apt: SchoolDatabase.Apartment, index: Int) -> CLLocationCoordinate2D {
        let miles = parseDistance(apt.distance)
        let degreesPerMile = 0.0145
        let offset = miles * degreesPerMile

        // spread apartments in a circle around campus
        let angle = (Double(index) / Double(max(1, apartments.count))) * 2 * .pi
        let latOffset = offset * cos(angle)
        let lonOffset = offset * sin(angle)

        return CLLocationCoordinate2D(
            latitude: uniCoord.latitude + latOffset,
            longitude: uniCoord.longitude + lonOffset
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
struct ApartmentCard: View {
    let apartment: SchoolDatabase.Apartment
    var isSelected: Bool = false
    var onSelect: (() -> Void)? = nil

    var body: some View {
        Button {
            onSelect?()
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(apartment.name)
                            .font(.headline)
                            .foregroundStyle(.primary)

                        HStack(spacing: 4) {
                            Image(systemName: "mappin.circle.fill")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Text("\(apartment.distance) from campus")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        HStack(spacing: 0) {
                            Text("$\(apartment.rent)")
                                .font(.title2.weight(.bold))
                                .foregroundStyle(.primary)
                            Text("/mo")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Image(systemName: "bed.double.fill")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("\(apartment.beds) bed")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    HStack(spacing: 4) {
                        Image(systemName: "shower.fill")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("\(apartment.baths) bath")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                OddsBadge(odds: apartment.odds, detail: apartment.oddsDetail)
            }
            .padding(16)
            .background(isSelected ? Color.blue.opacity(0.08) : TTColors.cardBg)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .overlay(
                isSelected ?
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color.blue.opacity(0.3), lineWidth: 2)
                    : nil
            )
            .padding(.horizontal, 20)
        }
        .buttonStyle(.plain)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(apartment.name). $\(apartment.rent) per month. \(apartment.distance) from campus. \(apartment.beds) bedroom, \(apartment.baths) bathroom. \(apartment.odds).")
        .accessibilityHint("Tap to show on map")
    }
}
