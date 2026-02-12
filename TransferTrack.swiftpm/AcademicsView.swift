import SwiftUI

// MARK: - academics tab

@available(iOS 17.0, *)
struct AcademicsTab: View {
    let gpa: Double
    let credits: Int
    let ccName: String
    let uniName: String

    private var courses: [SchoolDatabase.CourseTransfer] {
        SchoolDatabase.courses(from: ccName, to: uniName)
    }

    private var transferable: [SchoolDatabase.CourseTransfer] {
        courses.filter { $0.transfers }
    }

    private var wasted: [SchoolDatabase.CourseTransfer] {
        courses.filter { !$0.transfers }
    }

    private var transferableCredits: Int { transferable.reduce(0) { $0 + $1.credits } }
    private var wastedCredits: Int { wasted.reduce(0) { $0 + $1.credits } }
    private var totalCredits: Int { transferableCredits + wastedCredits }
    private var wastedCost: Int { wasted.reduce(0) { $0 + $1.costIfWasted } }
    private var wastedMonths: Int { max(1, wastedCredits / 3) }

    private var transferEfficiency: Double {
        guard totalCredits > 0 else { return 1.0 }
        return Double(transferableCredits) / Double(totalCredits)
    }

    var body: some View {
        VStack(spacing: 20) {
            // MARK: transfer efficiency gauge
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "gauge.open.with.lines.needle.33percent")
                        .foregroundStyle(transferEfficiency >= 0.8 ? .green : .orange)
                        .font(.title3)
                    Text("Transfer Efficiency")
                        .font(.headline)
                    Spacer()
                    Text("\(Int(transferEfficiency * 100))%")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(transferEfficiency >= 0.8 ? .green : .orange)
                        .contentTransition(.numericText())
                }

                Gauge(value: transferEfficiency) {
                    EmptyView()
                } currentValueLabel: {
                    Text("\(transferableCredits)/\(totalCredits) cr")
                        .font(.caption2.weight(.medium))
                } minimumValueLabel: {
                    Text("0%")
                        .font(.caption2)
                        .foregroundStyle(.red)
                } maximumValueLabel: {
                    Text("100%")
                        .font(.caption2)
                        .foregroundStyle(.green)
                }
                .gaugeStyle(.linearCapacity)
                .tint(Gradient(colors: [.red, .orange, .green]))

                Text("\(transferableCredits) of \(totalCredits) credits transfer. \(wastedCredits) credits (\(wastedCost > 0 ? "$\(wastedCost.formatted())" : "$0")) won't count.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
            }
            .padding(20)
            .background(TTColors.cardBg)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .padding(.horizontal, 20)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Transfer Efficiency: \(Int(transferEfficiency * 100)) percent. \(transferableCredits) of \(totalCredits) credits transfer to \(uniName).")

            // MARK: degree applicable
            VStack(alignment: .leading, spacing: 14) {
                HStack {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundStyle(.green)
                        .font(.title3)
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Degree Applicable")
                            .font(.title3.weight(.semibold))
                        Text("\(transferable.count) courses · \(transferableCredits) credits transfer to \(uniName)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                VStack(spacing: 0) {
                    ForEach(Array(transferable.enumerated()), id: \.offset) { index, course in
                        HStack(spacing: 10) {
                            // SF Symbol per course type
                            Image(systemName: courseIcon(for: course.code))
                                .font(.caption)
                                .foregroundStyle(.green.opacity(0.7))
                                .frame(width: 20)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(course.name)
                                    .font(.subheadline.weight(.medium))
                                Text("\(course.code) · \(course.credits) cr · \(course.grade)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()

                            // grade badge
                            Text(course.grade)
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.green)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color.green.opacity(0.1))
                                .clipShape(Capsule())
                        }
                        .padding(.vertical, 8)
                        .padding(.horizontal, 4)
                        .accessibilityElement(children: .combine)
                        .accessibilityLabel("\(course.name), \(course.code), \(course.credits) credits, grade \(course.grade). Transfers to \(uniName).")

                        if index < transferable.count - 1 {
                            Divider()
                        }
                    }
                }
            }
            .padding(20)
            .background(TTColors.cardBg)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .padding(.horizontal, 20)

            // MARK: wasted credits
            if !wasted.isEmpty {
                VStack(alignment: .leading, spacing: 14) {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                            .font(.title3)
                        VStack(alignment: .leading, spacing: 2) {
                            Text("\"Wasted\" Credits")
                                .font(.title3.weight(.semibold))
                            Text("Won't count toward your \(uniName) degree.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }

                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Total Loss")
                                .font(.caption.weight(.medium))
                                .foregroundStyle(.secondary)
                            HStack(spacing: 4) {
                                Image(systemName: "arrow.down.circle.fill")
                                    .foregroundStyle(.red)
                                    .font(.caption)
                                Text("$\(wastedCost.formatted())")
                                    .font(.title2.weight(.bold))
                                    .foregroundStyle(.red)
                                    .contentTransition(.numericText())
                            }
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("Time Wasted")
                                .font(.caption.weight(.medium))
                                .foregroundStyle(.secondary)
                            HStack(spacing: 4) {
                                Text("\(wastedMonths) months")
                                    .font(.title2.weight(.bold))
                                    .foregroundStyle(.red)
                                    .contentTransition(.numericText())
                                Image(systemName: "hourglass.bottomhalf.filled")
                                    .foregroundStyle(.red)
                                    .font(.caption)
                            }
                        }
                    }
                    .padding(14)
                    .background(Color.red.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Total loss: $\(wastedCost.formatted()). Time wasted: \(wastedMonths) months.")

                    VStack(spacing: 0) {
                        ForEach(Array(wasted.enumerated()), id: \.offset) { index, course in
                            HStack(spacing: 10) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.red.opacity(0.5))
                                    .font(.caption)
                                    .frame(width: 20)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(course.name)
                                        .font(.subheadline.weight(.medium))
                                    Text("\(course.code) · \(course.credits) cr · \(course.grade)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()

                                Text("-$\(course.costIfWasted)")
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(.red)
                            }
                            .padding(.vertical, 8)
                            .accessibilityElement(children: .combine)
                            .accessibilityLabel("\(course.name). Does not transfer. Cost: $\(course.costIfWasted).")

                            if index < wasted.count - 1 {
                                Divider()
                                    .padding(.leading, 30)
                            }
                        }
                    }
                }
                .padding(20)
                .background(TTColors.cardBg)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .padding(.horizontal, 20)
            }
        }
    }

    // MARK: - course type SF symbol mapping

    private func courseIcon(for code: String) -> String {
        let prefix = code.prefix(3).uppercased()
        switch prefix {
        case "ENC", "HUM", "SPC": return "text.book.closed.fill"   // English/Humanities
        case "MAC", "STA", "MTH": return "function"                 // Math/Statistics
        case "PSY", "SOC":        return "brain.head.profile"       // Psychology/Social Science
        case "ECO", "FIN":        return "chart.line.uptrend.xyaxis"// Economics/Finance
        case "COP", "CIS", "CAP": return "chevron.left.forwardslash.chevron.right" // CS/Programming
        case "PHY":               return "atom"                      // Physics
        case "BSC", "BIO", "CHM": return "flask.fill"               // Science/Biology/Chemistry
        case "ARH", "ART":        return "paintpalette.fill"         // Art
        case "MUH", "MUS":        return "music.note"                // Music
        default:                   return "book.fill"                 // Generic
        }
    }
}
