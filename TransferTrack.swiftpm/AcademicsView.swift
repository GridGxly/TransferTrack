import SwiftUI
import SwiftData

// MARK: - academics tab

@available(iOS 17.0, *)
struct AcademicsTab: View {
    @Bindable var vm: TransferViewModel
    @Environment(\.modelContext) private var modelContext
    @Query private var userAddedCourses: [UserCourse]

    @State private var showAddCourse = false
    @State private var wastedInfoCourse: SchoolDatabase.CourseTransfer? = nil

    private var courses: [SchoolDatabase.CourseTransfer] { vm.courses }
    private var transferable: [SchoolDatabase.CourseTransfer] { vm.transferable }
    private var wasted: [SchoolDatabase.CourseTransfer] { vm.wasted }

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
        List {
            // MARK: transfer efficiency gauge
            Section {
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
                        Text("0%").font(.caption2).foregroundStyle(.red)
                    } maximumValueLabel: {
                        Text("100%").font(.caption2).foregroundStyle(.green)
                    }
                    .gaugeStyle(.linearCapacity)
                    .tint(Gradient(colors: [.red, .orange, .green]))

                    Text("\(transferableCredits) of \(totalCredits) credits transfer. \(wastedCredits) credits ($\(wastedCost.formatted())) won't count.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Transfer Efficiency: \(Int(transferEfficiency * 100)) percent")
            }

            // MARK: degree applicable courses
            Section {
                ForEach(transferable) { course in
                    CourseRow(course: course, showTransferIcon: true)
                }
            } header: {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.seal.fill").foregroundStyle(.green)
                    Text("Degree Applicable")
                    Spacer()
                    Text("\(transferable.count) courses · \(transferableCredits) cr")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            // MARK: user added courses
            if !userAddedCourses.isEmpty {
                Section {
                    ForEach(userAddedCourses) { course in
                        HStack {
                            Image(systemName: courseIcon(for: course.code))
                                .font(.caption)
                                .foregroundStyle(.blue)
                                .frame(width: 24)
                            VStack(alignment: .leading, spacing: 2) {
                                Text(course.title)
                                    .font(.subheadline.weight(.medium))
                                Text("\(course.code) · \(course.credits) cr · \(course.grade)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Text(course.grade)
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.blue)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color.blue.opacity(0.1))
                                .clipShape(Capsule())
                        }
                    }
                    .onDelete(perform: deleteUserCourses)
                } header: {
                    HStack {
                        Image(systemName: "plus.circle.fill").foregroundStyle(.blue)
                        Text("Your Added Courses")
                    }
                }
            }

            // MARK: wasted credits with info popovers
            if !wasted.isEmpty {
                Section {
                    // summary row
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Total Loss").font(.caption.weight(.medium)).foregroundStyle(.secondary)
                            HStack(spacing: 4) {
                                Image(systemName: "arrow.down.circle.fill").foregroundStyle(.red).font(.caption)
                                Text("$\(wastedCost.formatted())")
                                    .font(.title3.weight(.bold))
                                    .foregroundStyle(.red)
                                    .contentTransition(.numericText())
                            }
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 2) {
                            Text("Time Wasted").font(.caption.weight(.medium)).foregroundStyle(.secondary)
                            HStack(spacing: 4) {
                                Text("\(wastedMonths) months")
                                    .font(.title3.weight(.bold))
                                    .foregroundStyle(.red)
                                Image(systemName: "hourglass.bottomhalf.filled").foregroundStyle(.red).font(.caption)
                            }
                        }
                    }
                    .listRowBackground(Color.red.opacity(0.06))

                    // each wasted course with info button
                    ForEach(wasted) { course in
                        HStack(spacing: 10) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.red.opacity(0.5))
                                .font(.caption)
                                .frame(width: 24)

                            VStack(alignment: .leading, spacing: 2) {
                                Text(course.name)
                                    .font(.subheadline.weight(.medium))
                                Text("\(course.code) · \(course.credits) cr · \(course.grade)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()

                            // info button instead of repetitive -$600
                            Button {
                                wastedInfoCourse = course
                            } label: {
                                Image(systemName: "info.circle")
                                    .foregroundStyle(.red)
                                    .font(.body)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Why \(course.name) didn't transfer")
                        }
                    }
                } header: {
                    HStack(spacing: 6) {
                        Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(.orange)
                        Text("\"Wasted\" Credits")
                    }
                } footer: {
                    Text("These courses won't count toward your \(vm.selectedUni) degree. Tap ⓘ to see why.")
                }
            }

            // MARK: empty state
            if courses.isEmpty {
                ContentUnavailableView(
                    "No Transfer Data",
                    systemImage: "graduationcap.fill",
                    description: Text("Select your colleges in the header to see your credit analysis.")
                )
            }
        }
        .listStyle(.insetGrouped)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showAddCourse = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                }
                .accessibilityLabel("Add a course")
            }
        }
        .sheet(isPresented: $showAddCourse) {
            AddCourseSheet()
        }
        .popover(item: $wastedInfoCourse) { course in
            WastedCourseInfoView(course: course, uniName: vm.selectedUni)
                .presentationCompactAdaptation(.popover)
        }
        .padding(.bottom, 80)
    }

    private func deleteUserCourses(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(userAddedCourses[index])
        }
    }

    // MARK: course icon mapping

    func courseIcon(for code: String) -> String {
        let prefix = code.prefix(3).uppercased()
        switch prefix {
        case "ENC", "HUM", "SPC": return "text.book.closed.fill"
        case "MAC", "STA", "MTH": return "function"
        case "PSY", "SOC":        return "brain.head.profile"
        case "ECO", "FIN":        return "chart.line.uptrend.xyaxis"
        case "COP", "CIS", "CAP": return "chevron.left.forwardslash.chevron.right"
        case "PHY":               return "atom"
        case "BSC", "BIO", "CHM": return "flask.fill"
        case "ARH", "ART":        return "paintpalette.fill"
        case "MUH", "MUS":        return "music.note"
        default:                   return "book.fill"
        }
    }
}

// MARK: - course row

@available(iOS 17.0, *)
struct CourseRow: View {
    let course: SchoolDatabase.CourseTransfer
    var showTransferIcon: Bool = false

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: iconForCode(course.code))
                .font(.caption)
                .foregroundStyle(.green.opacity(0.7))
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(course.name)
                    .font(.subheadline.weight(.medium))
                Text("\(course.code) · \(course.credits) cr · \(course.grade)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()

            Text(course.grade)
                .font(.caption.weight(.bold))
                .foregroundStyle(.green)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Color.green.opacity(0.1))
                .clipShape(Capsule())
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(course.name), \(course.credits) credits, grade \(course.grade)")
    }

    private func iconForCode(_ code: String) -> String {
        let prefix = code.prefix(3).uppercased()
        switch prefix {
        case "ENC", "HUM", "SPC": return "text.book.closed.fill"
        case "MAC", "STA", "MTH": return "function"
        case "PSY", "SOC":        return "brain.head.profile"
        case "ECO", "FIN":        return "chart.line.uptrend.xyaxis"
        case "COP", "CIS", "CAP": return "chevron.left.forwardslash.chevron.right"
        case "PHY":               return "atom"
        case "BSC", "BIO", "CHM": return "flask.fill"
        case "ARH", "ART":        return "paintpalette.fill"
        case "MUH", "MUS":        return "music.note"
        default:                   return "book.fill"
        }
    }
}

// MARK: - wasted course info popover

@available(iOS 17.0, *)
struct WastedCourseInfoView: View {
    let course: SchoolDatabase.CourseTransfer
    let uniName: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(.red)
                Text(course.name)
                    .font(.headline)
            }

            Text("Why it doesn't transfer:")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.secondary)

            Text(course.reason)
                .font(.subheadline)
                .fixedSize(horizontal: false, vertical: true)

            Divider()

            HStack {
                Label("Cost: $\(course.costIfWasted)", systemImage: "dollarsign.circle")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.red)
                Spacer()
                Label("\(course.credits) credits", systemImage: "book.closed")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(20)
        .frame(minWidth: 280, maxWidth: 320)
    }
}

// MARK: - add course sheet

@available(iOS 17.0, *)
struct AddCourseSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var courseTitle = ""
    @State private var courseCode = ""
    @State private var credits = "3"
    @State private var grade = "A"
    @FocusState private var titleFocused: Bool

    private let grades = ["A", "A-", "B+", "B", "B-", "C+", "C", "C-", "D", "F"]

    var body: some View {
        NavigationStack {
            Form {
                Section("Course Info") {
                    TextField("Course Title", text: $courseTitle)
                        .focused($titleFocused)
                    TextField("Course Code (e.g. COP 2000)", text: $courseCode)
                        .autocorrectionDisabled()
                    HStack {
                        Text("Credits")
                        Spacer()
                        TextField("3", text: $credits)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 60)
                    }
                    Picker("Grade", selection: $grade) {
                        ForEach(grades, id: \.self) { Text($0) }
                    }
                }
            }
            .navigationTitle("Add Course")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let course = UserCourse(
                            code: courseCode.isEmpty ? "GEN 1000" : courseCode,
                            title: courseTitle.isEmpty ? "New Course" : courseTitle,
                            credits: Int(credits) ?? 3,
                            grade: grade,
                            transfers: true,
                            costIfWasted: 0
                        )
                        modelContext.insert(course)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(courseTitle.isEmpty)
                }
            }
            .onAppear { titleFocused = true }
        }
    }
}
