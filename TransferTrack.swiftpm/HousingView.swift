import SwiftUI

// MARK: - housing tab

@available(iOS 17.0, *)
struct HousingTab: View {
    let currentRent: Double
    let uniName: String

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
        return apartments.isEmpty ? 0 : 50
    }

    var body: some View {
        VStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                SectionHeader(
                    title: "Housing Near \(uniName)",
                    subtitle: "Rent \(rentDiff >= 0 ? "+" : "")$\(rentDiff)/mo vs. current · Gas savings -$\(gasSavings)/mo"
                )
            }
            .padding(.horizontal, 20)

            ForEach(Array(apartments.enumerated()), id: \.offset) { _, apt in
                ApartmentCard(apartment: apt)
            }
        }
    }
}

// MARK: - apartment card

struct ApartmentCard: View {
    let apartment: SchoolDatabase.Apartment

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(apartment.name)
                        .font(.headline)

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
        .background(TTColors.cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .padding(.horizontal, 20)
    }
}
