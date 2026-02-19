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
    @State private var isEditing = false
    @State private var showSurchargeAlert = false
    @State private var hasShownSurchargeAlert = false
    @State private var shouldScrollToWasted = false

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

  
    private var surchargeTitle: String { vm.surchargeAlertTitle }
    private var surchargeMessage: String { vm.surchargeAlertMessage }

    var body: some View {
        ZStack {
            ScrollViewReader { proxy in
                List {
                    Section {
                        VStack(spacing: 12) {
                            HStack {
                                Image(systemName: "gauge.open.with.lines.needle.33percent")
                                    .foregroundStyle(transferEfficiency >= 0.8 ? TTBrand.mint : TTBrand.amber)
                                    .font(.title3)
                                Text("Transfer Efficiency")
                                    .font(.system(.headline, design: .rounded))
                                Spacer()
                                Text("\(Int(transferEfficiency * 100))%")
                                    .font(.system(.title3, design: .rounded).weight(.bold))
                                    .foregroundStyle(transferEfficiency >= 0.8 ? TTBrand.mint : TTBrand.amber)
                                    .contentTransition(.numericText())
                            }

                            Gauge(value: transferEfficiency) { EmptyView() }
                            currentValueLabel: {
                                Text("\(transferableCredits)/\(totalCredits) cr")
                                    .font(.system(.caption2, design: .rounded).weight(.medium))
                            } minimumValueLabel: {
                                Text("0%").font(.caption2).foregroundStyle(TTBrand.coral)
                            } maximumValueLabel: {
                                Text("100%").font(.caption2).foregroundStyle(TTBrand.mint)
                            }
                            .gaugeStyle(.linearCapacity)
                            .tint(Gradient(colors: [TTBrand.coral, TTBrand.amber, TTBrand.mint]))

                            if grandTotalCredits >= 60 {
                                HStack(spacing: 6) {
                                    Image(systemName: "star.fill").foregroundStyle(.yellow).font(.caption)
                                    Text("AA/AS Degree threshold reached (\(grandTotalCredits) credits)")
                                        .font(.system(.caption, design: .rounded).weight(.medium))
                                        .foregroundStyle(TTBrand.mint)
                                }
                                .padding(8)
                                .frame(maxWidth: .infinity)
                                .background(TTBrand.mint.opacity(0.08))
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }

                    if !wasted.isEmpty {
                        Section { TipView(excessCreditTip) }
                        .onAppear { ExcessCreditTip.hasWastedCredits = true }
                    }

                    Section {
                        ForEach(transferable) { course in
                            CourseRow(course: course, style: .transferable)
                        }
                    } header: {
                        HStack(spacing: 6) {
                            Image(systemName: "checkmark.seal.fill").foregroundStyle(TTBrand.mint)
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
                                        .foregroundStyle(TTBrand.skyBlue.opacity(0.7))
                                        .frame(width: 24)
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(course.title)
                                            .font(.system(.subheadline, design: .rounded).weight(.medium))
                                            .lineLimit(1)
                                        Text("\(course.code) · \(course.credits) cr · \(course.grade)")
                                            .font(.caption).foregroundStyle(.secondary).lineLimit(1)
                                    }
                                    Spacer()
                                    Text(course.grade)
                                        .font(.system(.caption, design: .rounded).weight(.bold))
                                        .foregroundStyle(TTBrand.skyBlue)
                                        .padding(.horizontal, 8).padding(.vertical, 3)
                                        .background(TTBrand.skyBlue.opacity(0.1))
                                        .clipShape(Capsule())
                                }
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        withAnimation { modelContext.delete(course) }
                                    } label: { Label("Delete", systemImage: "trash") }
                                }
                                .contextMenu {
                                    Button(role: .destructive) {
                                        withAnimation { modelContext.delete(course) }
                                    } label: { Label("Delete Course", systemImage: "trash") }
                                }
                            }
                            .onDelete { offsets in
                                for i in offsets { modelContext.delete(userAddedCourses[i]) }
                            }
                        } header: {
                            HStack(spacing: 6) {
                                Image(systemName: "plus.circle.fill").foregroundStyle(TTBrand.skyBlue)
                                Text("Your Added Courses")
                                Spacer()
                                Text("\(userAddedCourses.count) courses · \(userAddedTotal) cr")
                                    .font(.caption).foregroundStyle(.secondary)
                            }
                        } footer: {
                            Text("Swipe left on any course to delete it, or long-press for options.")
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
                                            .foregroundStyle(TTBrand.coral.opacity(0.5))
                                            .font(.caption).frame(width: 24)
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(course.name)
                                                .font(.system(.subheadline, design: .rounded).weight(.medium))
                                                .foregroundStyle(.primary)
                                            Text("\(course.code) · \(course.credits) cr · \(course.grade)")
                                                .font(.caption).foregroundStyle(.secondary)
                                        }
                                        Spacer()
                                        Text("$\(course.costIfWasted)")
                                            .font(.system(.caption, design: .rounded).weight(.bold))
                                            .foregroundStyle(TTBrand.coral)
                                        Image(systemName: "chevron.right").font(.caption2).foregroundStyle(.tertiary)
                                    }
                                }
                                .buttonStyle(.plain)
                            }
                        } header: {
                            HStack(spacing: 6) {
                                Image(systemName: "exclamationmark.triangle.fill").foregroundStyle(TTBrand.amber)
                                Text("Wasted Credits")
                                Spacer()
                                Text("$\(wastedCost.formatted()) · \(wastedMonths) mo lost")
                                    .font(.caption).foregroundStyle(TTBrand.coral)
                            }
                        } footer: {
                            Text("Tap any course to see why it won't transfer to \(vm.selectedUni).")
                        }
                        .id("wastedSection")
                    }

                    Section {
                        Button { showAddCourse = true } label: {
                            HStack(spacing: 14) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2).foregroundStyle(TTBrand.mint)
                                    .frame(width: 44, height: 44)
                                    .background(TTBrand.mint.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Add Course Manually")
                                        .font(.system(.subheadline, design: .rounded).weight(.semibold))
                                        .foregroundStyle(.primary)
                                    Text("Type in your course code, title, and grade")
                                        .font(.caption).foregroundStyle(.secondary).lineLimit(2)
                                }
                                Spacer()
                                Image(systemName: "chevron.right").font(.caption.weight(.semibold)).foregroundStyle(.tertiary)
                            }
                            .padding(.vertical, 4)
                        }
                        .buttonStyle(.plain)

                        Button { showScanner = true } label: {
                            HStack(spacing: 14) {
                                Image(systemName: "doc.text.viewfinder")
                                    .font(.title2).foregroundStyle(TTBrand.skyBlue)
                                    .frame(width: 44, height: 44)
                                    .background(TTBrand.skyBlue.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Scan Transcript")
                                        .font(.system(.subheadline, design: .rounded).weight(.semibold))
                                        .foregroundStyle(.primary)
                                    Text("Use your camera to detect course codes automatically")
                                        .font(.caption).foregroundStyle(.secondary).lineLimit(2)
                                }
                                Spacer()
                                Image(systemName: "chevron.right").font(.caption.weight(.semibold)).foregroundStyle(.tertiary)
                            }
                            .padding(.vertical, 4)
                        }
                        .buttonStyle(.plain)
                    } header: { Text("Add Courses") }

                    if courses.isEmpty {
                        ContentUnavailableView("No Transfer Data", systemImage: "graduationcap.fill",
                            description: Text("Select your colleges to see your credit analysis."))
                    }
                }
                .listStyle(.insetGrouped)
                .safeAreaPadding(.bottom, 80)
                .onChange(of: shouldScrollToWasted) { _, newVal in
                    if newVal {
                        withAnimation(.easeInOut(duration: 0.4)) {
                            proxy.scrollTo("wastedSection", anchor: .top)
                        }
                        shouldScrollToWasted = false
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button { showAddCourse = true } label: { Label("Add Manually", systemImage: "plus.circle") }
                        Button { showScanner = true } label: { Label("Scan Transcript", systemImage: "doc.text.viewfinder") }
                    } label: {
                        Image(systemName: "plus.circle.fill").font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showAddCourse) { AddCourseSheet() }
            .sheet(isPresented: $showScanner) {
                TranscriptScannerSheet { code in
                    let title = readableTitleForCode(code)
                    let parts = code.split(separator: " ")
                    let number = parts.count > 1 ? String(parts[1]) : ""
                    let credits = number.hasSuffix("C") ? 4 : 3
                    let newCourse = UserCourse(code: code, title: title, credits: credits, grade: "B", transfers: true, costIfWasted: 0)
                    modelContext.insert(newCourse)
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    checkMilestone()
                }
            }
            .sheet(item: $wastedInfoCourse) { course in
                WastedCourseInfoSheet(course: course, uniName: vm.selectedUni)
            }
            .alert(surchargeTitle, isPresented: $showSurchargeAlert) {
                Button("View Wasted Credits") {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { shouldScrollToWasted = true }
                }
                Button("Got It", role: .cancel) { }
            } message: {
                Text(surchargeMessage)
            }
            .onAppear {
                if !wasted.isEmpty && !hasShownSurchargeAlert {
                    hasShownSurchargeAlert = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) { showSurchargeAlert = true }
                }
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
        case "MAC", "STA", "MTH", "MAT": return "function"
        case "PSY", "SOC": return "brain.head.profile"
        case "ECO", "FIN": return "chart.line.uptrend.xyaxis"
        case "COP", "CIS", "CAP": return "chevron.left.forwardslash.chevron.right"
        case "PHY": return "atom"
        case "BSC", "BIO", "CHM": return "flask.fill"
        case "ARH", "ART": return "paintpalette.fill"
        case "MUH", "MUS": return "music.note"
        case "AMH", "HIS", "WOH", "EUH": return "clock.fill"
        case "SPN", "FRE", "GER", "ASL": return "globe"
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
                            .font(.system(size: 48)).foregroundStyle(.yellow)
                            .symbolEffect(.bounce, options: .repeating.speed(0.5))
                    } else {
                        Image(systemName: "graduationcap.fill")
                            .font(.system(size: 48)).foregroundStyle(.yellow)
                    }
                    Text("60 Credits!")
                        .font(.system(.title, design: .rounded).weight(.black))
                        .foregroundStyle(.white)
                    Text("You've hit the Associate's Degree transfer threshold.")
                        .font(.system(.subheadline, design: .rounded))
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
        let colors: [Color] = [TTBrand.mint, .yellow, TTBrand.skyBlue, TTBrand.amber, TTBrand.violet, .cyan]
        for i in 0..<40 {
            let p = ConfettiParticle(x: CGFloat.random(in: 0...size.width), y: -20,
                size: CGFloat.random(in: 4...10), color: colors[i % colors.count], opacity: 1.0)
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
                .foregroundStyle(style == .transferable ? TTBrand.mint.opacity(0.7) : TTBrand.coral.opacity(0.5))
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(course.name).font(.system(.subheadline, design: .rounded).weight(.medium))
                Text("\(course.code) · \(course.credits) cr · \(course.grade)")
                    .font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
            Text(course.grade)
                .font(.system(.caption, design: .rounded).weight(.bold))
                .foregroundStyle(style == .transferable ? TTBrand.mint : TTBrand.coral)
                .padding(.horizontal, 8).padding(.vertical, 3)
                .background((style == .transferable ? TTBrand.mint : TTBrand.coral).opacity(0.1))
                .clipShape(Capsule())
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
                    Image(systemName: "xmark.circle.fill").foregroundStyle(TTBrand.coral).font(.title2)
                    Text(course.name).font(.system(.title3, design: .rounded).weight(.bold))
                }
                VStack(alignment: .leading, spacing: 8) {
                    Text("Why it doesn't transfer:")
                        .font(.system(.subheadline, design: .rounded).weight(.medium))
                        .foregroundStyle(.secondary)
                    Text(expandedReason).font(.body).fixedSize(horizontal: false, vertical: true)
                }
                Divider()
                HStack {
                    Label("Cost: $\(course.costIfWasted)", systemImage: "dollarsign.circle")
                        .font(.system(.subheadline, design: .rounded).weight(.medium))
                        .foregroundStyle(TTBrand.coral)
                    Spacer()
                    Label("\(course.credits) credits", systemImage: "book.closed")
                        .font(.system(.subheadline, design: .rounded).weight(.medium))
                        .foregroundStyle(.secondary)
                }
                VStack(alignment: .leading, spacing: 6) {
                    Text("What you can do:")
                        .font(.system(.subheadline, design: .rounded).weight(.medium))
                        .foregroundStyle(.secondary)
                    HStack(spacing: 8) {
                        Image(systemName: "doc.text.fill").foregroundStyle(TTBrand.skyBlue).font(.caption)
                        Text("Appeal with syllabus documentation via the Solutions tab")
                            .font(.caption).foregroundStyle(.secondary)
                    }
                }
                Spacer()
            }
            .padding(24)
            .navigationTitle(course.code)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } }
            }
        }
        .presentationDetents([.medium])
    }

    private var expandedReason: String {
        course.reason
            .replacingOccurrences(of: " CC,", with: " community college,")
            .replacingOccurrences(of: " CC ", with: " community college ")
            .replacingOccurrences(of: " CC.", with: " community college.")
            .replacingOccurrences(of: "at CC", with: "at your community college")
            .replacingOccurrences(of: "Fulfills humanities at CC", with: "Fulfills humanities at your community college")
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
                    TextField("Course Title (e.g. English Composition I)", text: $courseTitle)
                        .focused($titleFocused)
                    TextField("Course Code (e.g. ENC 1101)", text: $courseCode)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.characters)
                    HStack {
                        Text("Credits"); Spacer()
                        TextField("3", text: $credits).keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing).frame(width: 60)
                    }
                    Picker("Grade", selection: $grade) {
                        ForEach(grades, id: \.self) { Text($0) }
                    }
                }
                Section {
                    Text("This course will appear in \"Your Added Courses\" and count toward your total credits.")
                        .font(.caption).foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Add Course")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let code = courseCode.isEmpty ? "GEN 1000" : courseCode.uppercased()
                        let title = courseTitle.isEmpty ? readableTitleForCode(code) : courseTitle
                        modelContext.insert(UserCourse(code: code, title: title, credits: Int(credits) ?? 3, grade: grade, transfers: true, costIfWasted: 0))
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(courseTitle.isEmpty && courseCode.isEmpty)
                }
            }
            .onAppear { titleFocused = true }
        }
    }
}
