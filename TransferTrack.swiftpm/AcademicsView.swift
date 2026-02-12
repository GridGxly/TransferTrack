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
    private var wastedCost: Int { wasted.reduce(0) { $0 + $1.costIfWasted } }
    private var wastedMonths: Int { max(1, wastedCredits / 3) }

    var body: some View {
        VStack(spacing: 20) {
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
                        HStack(spacing: 0) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text(course.name)
                                    .font(.subheadline.weight(.medium))
                                Text("\(course.code) · \(course.credits) cr · \(course.grade)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 4)

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
                            Text("$\(wastedCost.formatted())")
                                .font(.title2.weight(.bold))
                                .foregroundStyle(.red)
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("Time Wasted")
                                .font(.caption.weight(.medium))
                                .foregroundStyle(.secondary)
                            Text("\(wastedMonths) months")
                                .font(.title2.weight(.bold))
                                .foregroundStyle(.red)
                        }
                    }
                    .padding(14)
                    .background(Color.red.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                    VStack(spacing: 0) {
                        ForEach(Array(wasted.enumerated()), id: \.offset) { index, course in
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(Color.orange.opacity(0.3))
                                    .frame(width: 8, height: 8)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(course.name)
                                        .font(.subheadline.weight(.medium))
                                    Text("\(course.code) · \(course.credits) cr · \(course.grade)")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Spacer()
                            }
                            .padding(.vertical, 8)

                            if index < wasted.count - 1 {
                                Divider()
                                    .padding(.leading, 20)
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
}
