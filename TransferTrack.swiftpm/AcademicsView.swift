import SwiftUI
import SwiftData
import TipKit

@available(iOS 17.0, *)
struct AcademicsTab: View {
    @Bindable var vm: TransferViewModel
    @Environment(\.modelContext) private var modelContext
    @Query private var userAddedCourses: [UserCourse]

    @State private var showAddCourse = false
    @State private var showScanner = false
    @State private var wastedInfoCourse: SchoolDatabase.CourseTransfer? = nil
    @State private var showMilestone = false

    private var courses: [SchoolDatabase.CourseTransfer] { vm.courses }
    private var transferable: [SchoolDatabase.CourseTransfer] { vm.transferable }
    private var wasted: [SchoolDatabase.CourseTransfer] { vm.wasted }
    private var transferableCredits: Int { transferable.reduce(0) { $0 + $1.credits } }
    private var wastedCredits: Int { wasted.reduce(0) { $0 + $1.credits } }
    private var totalCredits: Int { transferableCredits + wastedCredits }
    private var userAddedTotal: Int { userAddedCourses.reduce(0) { $0 + $1.credits } }
    private var grandTotalCredits: Int { totalCredits + userAddedTotal }
    private var wastedCost: Int { wasted.reduce(0) { $0 + $1.costIfWasted } }
    private var wastedMonths: Int { max(1, wastedCredits / 3) }
    private var transferEfficiency: Double {
        guard totalCredits > 0 else { return 1.0 }
        return Double(transferableCredits) / Double(totalCredits)
    }

    private let excessCreditTip = ExcessCreditTip()

    var body: some View {
        ZStack {
            List {
                Section {
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "gauge.open.with.lines.needle.33percent")
                                .foregroundStyle(transferEfficiency >= 0.8 ? .green : .orange)
                                .font(.title3)
                            Text("Transfer Efficiency").font(.headline)
                            Spacer()
                            Text("\(Int(transferEfficiency * 100))%")
                                .font(.title3.weight(.bold))
                                .foregroundStyle(transferEfficiency >= 0.8 ? .green : .orange)
                                .contentTransition(.numericText())
                        }

                        Gauge(value: transferEfficiency) { EmptyView() }
                        currentValueLabel: {
                            Text("\(transferableCredits)/\(totalCredits) cr").font(.caption2.weight(.medium))
                        } minimumValueLabel: {
                            Text("0%").font(.caption2).foregroundStyle(.red)
                        } maximumValueLabel: {
                            Text("100%").font(.caption2).foregroundStyle(.green)
                        }
                        .gaugeStyle(.linearCapacity)
                        .tint(Gradient(colors: [.red, .orange, .green]))

                        if grandTotalCredits >= 60 {
                            HStack(spacing: 6) {
                                Image(systemName: "star.fill").foregroundStyle(.yellow).font(.caption)
                                Text("AA/AS Degree threshold reached (\(grandTotalCredits) credits)")
                                    .font(.caption.weight(.medium)).foregroundStyle(.green)
                            }
                            .padding(8)
                            .frame(maxWidth: .infinity)
                            .background(Color.green.opacity(0.08))
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                }

                if !wasted.isEmpty {
                    Section {
                        TipView(excessCreditTip)
                    }
                    .onAppear { ExcessCreditTip.hasWastedCredits = true }
                }

               
                Section {
                    ForEach(transferable) { course in
                        CourseRow(course: course, style: .transferable)
                    }
                } header: {
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.seal.fill").foregroundStyle(.green)
                        Text("Degree Applicable")
                        Spacer()
                        Text("\(transferable.count) courses · \(transferableCredits) cr")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                }

               
                if !userAddedCourses.isEmpty {
                    Section {
                        ForEach(userAddedCourses) { course in
                            HStack(spacing: 10) {
                                Image(systemName: iconFor(course.code))
                                    .font(.caption)
                                    .foregroundStyle(.blue.opacity(0.7))
                                    .frame(width: 24)
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(course.title)
                                        .font(.subheadline.weight(.medium))
                                    Text("\(course.code) · \(course.credits) cr · \(course.grade)")
                                        .font(.caption).foregroundStyle(.secondary)
                                }
                                Spacer()
                                Text(course.grade)
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(.blue)
                                    .padding(.horizontal, 8).padding(.vertical, 3)
                                    .background(Color.blue.opacity(0.1))
                                    .clipShape(Capsule())
                            }
                        }
                        .onDelete { offsets in
                            for i in offsets { modelContext.delete(userAddedCourses[i]) }
                        }
                    } header: {
                        HStack(spacing: 6) {
                            Image(systemName: "plus.circle.fill").foregroundStyle(.blue)
                            Text("Your Added Courses")
                            Spacer()
                            Text("\(userAddedCourses.count) courses · \(userAddedTotal) cr")
                                .font(.caption).foregroundStyle(.secondary)
                        }
                    }
                }

                
                if !wasted.isEmpty {
                    Section {
                        ForEach(wasted) { course in
                            Button {
                                wastedInfoCourse = course
                            } label: {
                                HStack(spacing: 10) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.red.opacity(0.5))
                                        .font(.caption).frame(width: 24)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(course.name)
                                            .font(.subheadline.weight(.medium))
                                            .foregroundStyle(.primary)
                                        Text("\(course.code) · \(course.credits) cr · \(course.grade)")
                                            .font(.caption).foregroundStyle(.secondary)
                                    }
                                    Spacer()
                                    Text("$\(course.costIfWasted)")
                                        .font(.caption.weight(.bold)).foregroundStyle(.red)
                                    Image(systemName: "chevron.right")
                                        .font(.caption2).foregroundStyle(.tertiary)
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    } header: {
                        HStack(spacing: 6) {
                            Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(.orange)
                            Text("Wasted Credits")
                            Spacer()
                            Text("$\(wastedCost.formatted()) · \(wastedMonths) mo lost")
                                .font(.caption).foregroundStyle(.red)
                        }
                    } footer: {
                        Text("Tap any course to see why it won't transfer to \(vm.selectedUni).")
                    }
                }

               
                Section {
                    Button { showScanner = true } label: {
                        HStack(spacing: 14) {
                            Image(systemName: "doc.text.viewfinder")
                                .font(.title2)
                                .foregroundStyle(.blue)
                                .frame(width: 44, height: 44)
                                .background(Color.blue.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Scan Transcript")
                                    .font(.subheadline.weight(.semibold))
                                    .foregroundStyle(.primary)
                                Text("Use your camera to detect course codes automatically")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                    .lineLimit(2)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.tertiary)
                        }
                        .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                }

                if courses.isEmpty {
                    ContentUnavailableView("No Transfer Data", systemImage: "graduationcap.fill",
                        description: Text("Select your colleges to see your credit analysis."))
                }
            }
            .listStyle(.insetGrouped)
            .safeAreaPadding(.bottom, 80)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button { showAddCourse = true } label: {
                            Label("Add Manually", systemImage: "plus.circle")
                        }
                        Button { showScanner = true } label: {
                            Label("Scan Transcript", systemImage: "doc.text.viewfinder")
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill").font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showAddCourse) { AddCourseSheet() }
            .sheet(isPresented: $showScanner) {
                TranscriptScannerSheet { code in
                    let parts = code.split(separator: " ")
                    let prefix = parts.first.map(String.init) ?? code
                    let number = parts.count > 1 ? String(parts[1]) : ""
                    let newCourse = UserCourse(
                        code: code,
                        title: "\(prefix) \(number)",
                        credits: 3, grade: "B", transfers: true, costIfWasted: 0
                    )
                    modelContext.insert(newCourse)
                    checkMilestone()
                }
            }
            .sheet(item: $wastedInfoCourse) { course in
                WastedCourseInfoSheet(course: course, uniName: vm.selectedUni)
            }

            if showMilestone {
                MilestoneOverlay(totalCredits: grandTotalCredits)
                    .allowsHitTesting(false)
                    .transition(.opacity)
            }
        }
    }

    private func checkMilestone() {
        let newTotal = grandTotalCredits + 3
        if newTotal >= 60 && grandTotalCredits < 60 {
            withAnimation { showMilestone = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation { showMilestone = false }
            }
        }
    }

    func iconFor(_ code: String) -> String {
        let p = code.prefix(3).uppercased()
        switch p {
        case "ENC", "HUM", "SPC": return "text.book.closed.fill"
        case "MAC", "STA", "MTH": return "function"
        case "PSY", "SOC": return "brain.head.profile"
        case "ECO", "FIN": return "chart.line.uptrend.xyaxis"
        case "COP", "CIS", "CAP": return "chevron.left.forwardslash.chevron.right"
        case "PHY": return "atom"
        case "BSC", "BIO", "CHM": return "flask.fill"
        case "ARH", "ART": return "paintpalette.fill"
        case "MUH", "MUS": return "music.note"
        default: return "book.fill"
        }
    }
}

@available(iOS 17.0, *)
struct MilestoneOverlay: View {
    let totalCredits: Int
    @State private var particles: [ConfettiParticle] = []

    var body: some View {
        GeometryReader { geo in
            ZStack {
                Color.black.opacity(0.3).ignoresSafeArea()

                VStack(spacing: 12) {
                    if #available(iOS 18.0, *) {
                        Image(systemName: "graduationcap.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(.yellow)
                            .symbolEffect(.bounce, options: .repeating.speed(0.5))
                    } else {
                        Image(systemName: "graduationcap.fill")
                            .font(.system(size: 48))
                            .foregroundStyle(.yellow)
                    }
                    Text("60 Credits!")
                        .font(.title.weight(.black))
                        .foregroundStyle(.white)
                    Text("You've hit the Associate's Degree transfer threshold.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }

                ForEach(particles) { p in
                    Circle().fill(p.color).frame(width: p.size, height: p.size)
                        .position(x: p.x, y: p.y).opacity(p.opacity)
                }
            }
            .onAppear { spawnConfetti(in: geo.size) }
        }
        .drawingGroup(opaque: false, colorMode: .linear)
    }

    private func spawnConfetti(in size: CGSize) {
        let colors: [Color] = [.green, .yellow, .blue, .orange, .purple, .cyan]
        for i in 0..<40 {
            let p = ConfettiParticle(
                x: CGFloat.random(in: 0...size.width), y: -20,
                size: CGFloat.random(in: 4...10),
                color: colors[i % colors.count], opacity: 1.0
            )
            particles.append(p)
            withAnimation(.easeIn(duration: Double.random(in: 1.0...2.5)).delay(Double(i) * 0.025)) {
                if let idx = particles.firstIndex(where: { $0.id == p.id }) {
                    particles[idx].y = size.height + 20
                    particles[idx].x += CGFloat.random(in: -60...60)
                    particles[idx].opacity = 0
                }
            }
        }
    }
}


@available(iOS 17.0, *)
struct CourseRow: View {
    let course: SchoolDatabase.CourseTransfer
    var style: CourseStyle = .transferable

    enum CourseStyle { case transferable, wasted }

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: iconFor(course.code))
                .font(.caption)
                .foregroundStyle(style == .transferable ? .green.opacity(0.7) : .red.opacity(0.5))
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(course.name).font(.subheadline.weight(.medium))
                Text("\(course.code) · \(course.credits) cr · \(course.grade)")
                    .font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Text(course.grade).font(.caption.weight(.bold))
                .foregroundStyle(style == .transferable ? .green : .red)
                .padding(.horizontal, 8).padding(.vertical, 3)
                .background((style == .transferable ? Color.green : Color.red).opacity(0.1)).clipShape(Capsule())
        }
    }

    private func iconFor(_ code: String) -> String {
        let p = code.prefix(3).uppercased()
        switch p {
        case "ENC", "HUM", "SPC": return "text.book.closed.fill"
        case "MAC", "STA", "MTH": return "function"
        case "PSY", "SOC": return "brain.head.profile"
        case "ECO", "FIN": return "chart.line.uptrend.xyaxis"
        case "COP", "CIS", "CAP": return "chevron.left.forwardslash.chevron.right"
        case "PHY": return "atom"
        case "BSC", "BIO", "CHM": return "flask.fill"
        case "ARH", "ART": return "paintpalette.fill"
        case "MUH", "MUS": return "music.note"
        default: return "book.fill"
        }
    }
}



@available(iOS 17.0, *)
struct WastedCourseInfoSheet: View {
    let course: SchoolDatabase.CourseTransfer
    let uniName: String
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.red).font(.title2)
                    Text(course.name).font(.title3.weight(.bold))
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Why it doesn't transfer:")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                    Text(course.reason)
                        .font(.body)
                        .fixedSize(horizontal: false, vertical: true)
                }

                Divider()

                HStack {
                    Label("Cost: $\(course.costIfWasted)", systemImage: "dollarsign.circle")
                        .font(.subheadline.weight(.medium)).foregroundStyle(.red)
                    Spacer()
                    Label("\(course.credits) credits", systemImage: "book.closed")
                        .font(.subheadline.weight(.medium)).foregroundStyle(.secondary)
                }

                Spacer()
            }
            .padding(24)
            .navigationTitle(course.code)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium])
    }
}


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
                    TextField("Course Title", text: $courseTitle).focused($titleFocused)
                    TextField("Course Code (e.g. COP 2000)", text: $courseCode).autocorrectionDisabled()
                    HStack {
                        Text("Credits"); Spacer()
                        TextField("3", text: $credits).keyboardType(.numberPad).multilineTextAlignment(.trailing).frame(width: 60)
                    }
                    Picker("Grade", selection: $grade) { ForEach(grades, id: \.self) { Text($0) } }
                }
            }
            .navigationTitle("Add Course")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        modelContext.insert(UserCourse(
                            code: courseCode.isEmpty ? "GEN 1000" : courseCode,
                            title: courseTitle.isEmpty ? "New Course" : courseTitle,
                            credits: Int(credits) ?? 3, grade: grade, transfers: true, costIfWasted: 0
                        ))
                        dismiss()
                    }
                    .fontWeight(.semibold).disabled(courseTitle.isEmpty)
                }
            }
            .onAppear { titleFocused = true }
        }
    }
}
