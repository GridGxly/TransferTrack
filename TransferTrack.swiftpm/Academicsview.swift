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

    private var wastedCredits: Int { wasted.reduce(0) { $0 + $1.credits } }
    private var wastedCost: Int { wasted.reduce(0) { $0 + $1.costIfWasted } }
    private var wastedMonths: Int { max(1, wastedCredits / 3) }

    var body: some View {
        VStack(spacing: 20) {
            // MARK: degree applicable section
            VStack(alignment: .leading, spacing: 16) {
                SectionHeader(
                    title: "Degree Applicable",
                    subtitle: "These credits transfer directly to your major."
                )

                ForEach(Array(transferable.enumerated()), id: \.offset) { _, course in
                    CourseRow(course: course, isWasted: false)
                }
            }
            .padding(20)
            .background(TTColors.cardBg)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .padding(.horizontal, 20)

            // MARK: wasted credits section
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    SectionHeader(
                        title: "Elective Only — \"Wasted\" Credits",
                        subtitle: "These won't count toward your \(uniName) degree."
                    )
                }

                ForEach(Array(wasted.enumerated()), id: \.offset) { _, course in
                    CourseRow(course: course, isWasted: true)
                }

                // total cost summary
                if !wasted.isEmpty {
                    Divider()
                    HStack {
                        Text("Total Impact")
                            .font(.subheadline.weight(.medium))
                        Spacer()
                        Text("$\(wastedCost) / \(wastedMonths)mo Lost")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(Color.red)
                            .clipShape(Capsule())
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

// MARK: - course row
struct CourseRow: View {
    let course: SchoolDatabase.CourseTransfer
    let isWasted: Bool

    var body: some View {
        HStack(spacing: 12) {
            // status icon
            Image(systemName: isWasted ? "exclamationmark.triangle.fill" : "checkmark.circle.fill")
                .foregroundStyle(isWasted ? .orange : .green)
                .font(.title3)

            // course info
            VStack(alignment: .leading, spacing: 2) {
                Text(course.name)
                    .font(.subheadline.weight(.medium))

                Text("\(course.code) · \(course.credits) cr · \(course.grade)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // cost tag for wasted courses
            if isWasted && course.costIfWasted > 0 {
                Text("Cost: $\(course.costIfWasted) / 4mo Lost")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(.red)
            }
        }
        .padding(.vertical, 6)
    }
}
