import SwiftUI

@available(iOS 17.0, *)
struct TimelineTab: View {
    @Bindable var vm: TransferViewModel

    @State private var hasAppeared = false
    @State private var pulsePhase: CGFloat = 0
    @State private var selectedGuideEvent: TimelineEvent? = nil

    private var events: [TimelineEvent] {
        generateEvents(
            semester: vm.transferSemester,
            cc: vm.selectedCC,
            uni: vm.selectedUni,
            state: vm.selectedState
        )
    }

    private var todayIndex: Int {
        let today = Date()
        for (i, event) in events.enumerated() {
            if event.date > today { return max(0, i - 1) }
        }
        return events.count - 1
    }

    private let rowHeight: CGFloat = 160
    private let nodeWidth: CGFloat = 36
    private let cardGap: CGFloat = 10
    private let outerPad: CGFloat = 20

    var body: some View {
        GeometryReader { outerGeo in
            let usableWidth = outerGeo.size.width - outerPad * 2
            let cardWidth = (usableWidth - nodeWidth - cardGap * 2) / 2

            ScrollViewReader { proxy in
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {

                        VStack(spacing: 8) {
                            Text("Your Transfer Path")
                                .font(.system(.title3, design: .rounded).weight(.bold))
                                .foregroundStyle(.primary)
                            Text("\(vm.selectedCC) → \(vm.selectedUni)")
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundStyle(.secondary)
                        }
                        .padding(.top, 16)
                        .padding(.bottom, 24)

                        ZStack(alignment: .top) {
                            timelineSpine(
                                centerX: usableWidth / 2,
                                totalHeight: CGFloat(events.count) * rowHeight,
                                todayY: CGFloat(todayIndex) * rowHeight + rowHeight / 2
                            )

                            VStack(spacing: 0) {
                                ForEach(Array(events.enumerated()), id: \.element.id) { index, event in
                                    TimelineRow(
                                        event: event,
                                        isPast: index < todayIndex,
                                        isCurrent: index == todayIndex,
                                        isRight: index % 2 == 0,
                                        pulsePhase: pulsePhase,
                                        viabilityScore: vm.viabilityScore,
                                        cardWidth: cardWidth,
                                        nodeWidth: nodeWidth,
                                        cardGap: cardGap,
                                        rowHeight: rowHeight,
                                        onSeeGuide: {
                                            selectedGuideEvent = event
                                        }
                                    )
                                    .id(event.id)
                                    .staggerFade(delay: hasAppeared ? 0 : Double(index) * 0.08, yOffset: 12)
                                }
                            }
                        }

                        VStack(spacing: 8) {
                            Image(systemName: "flag.checkered")
                                .font(.title2)
                                .foregroundStyle(TTBrand.mint)
                            Text("Transfer Complete")
                                .font(.system(.headline, design: .rounded))
                                .foregroundStyle(.primary)
                            Text("First day at \(vm.selectedUni)")
                                .font(.system(.caption, design: .rounded))
                                .foregroundStyle(.secondary)
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 120)
                        .staggerFade(delay: hasAppeared ? 0 : Double(events.count) * 0.08)
                    }
                    .padding(.horizontal, outerPad)
                }
                .onAppear {
                    guard !hasAppeared else { return }
                    hasAppeared = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        withAnimation(.spring(response: 0.6)) {
                            proxy.scrollTo(events[safe: todayIndex]?.id, anchor: .center)
                        }
                    }
                    withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                        pulsePhase = 1.0
                    }
                }
            }
        }
        .safeAreaPadding(.bottom, 80)
        .sheet(item: $selectedGuideEvent) { event in
            TimelineGuideSheet(event: event, uni: vm.selectedUni, cc: vm.selectedCC, state: vm.selectedState)
        }
    }

    @ViewBuilder
    private func timelineSpine(centerX: CGFloat, totalHeight: CGFloat, todayY: CGFloat) -> some View {
        Canvas { context, _ in
            if todayY > 0 {
                let pastPath = Path { p in
                    p.move(to: CGPoint(x: centerX, y: 0))
                    p.addLine(to: CGPoint(x: centerX, y: todayY))
                }
                context.stroke(
                    pastPath,
                    with: .linearGradient(
                        Gradient(colors: TTBrand.gradient(for: vm.viabilityScore)),
                        startPoint: CGPoint(x: centerX, y: 0),
                        endPoint: CGPoint(x: centerX, y: todayY)
                    ),
                    style: StrokeStyle(lineWidth: 3, lineCap: .round)
                )
            }

            let futurePath = Path { p in
                p.move(to: CGPoint(x: centerX, y: todayY))
                p.addLine(to: CGPoint(x: centerX, y: totalHeight))
            }
            context.stroke(
                futurePath,
                with: .color(.secondary.opacity(0.3)),
                style: StrokeStyle(lineWidth: 2, lineCap: .round, dash: [8, 6])
            )
        }
        .frame(height: totalHeight)
        .allowsHitTesting(false)
    }
}

@available(iOS 17.0, *)
struct TimelineRow: View {
    let event: TimelineEvent
    let isPast: Bool
    let isCurrent: Bool
    let isRight: Bool
    let pulsePhase: CGFloat
    let viabilityScore: Int
    let cardWidth: CGFloat
    let nodeWidth: CGFloat
    let cardGap: CGFloat
    let rowHeight: CGFloat
    var onSeeGuide: (() -> Void)? = nil
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        HStack(spacing: 0) {
            if isRight {
                cardContent
                    .frame(width: cardWidth)
                Color.clear
                    .frame(width: cardGap)
                nodeView
                    .frame(width: nodeWidth, height: rowHeight)
                Color.clear
                    .frame(width: cardGap)
                Color.clear
                    .frame(width: cardWidth)
            } else {
                Color.clear
                    .frame(width: cardWidth)
                Color.clear
                    .frame(width: cardGap)
                nodeView
                    .frame(width: nodeWidth, height: rowHeight)
                Color.clear
                    .frame(width: cardGap)
                cardContent
                    .frame(width: cardWidth)
            }
        }
        .frame(height: rowHeight)
        .accessibilityElement(children: .combine)
    }

    @ViewBuilder
    private var nodeView: some View {
        ZStack {
            if isCurrent {
                Circle()
                    .fill(TTBrand.amber.opacity(0.2 + pulsePhase * 0.15))
                    .frame(width: 28 + pulsePhase * 6, height: 28 + pulsePhase * 6)
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [TTBrand.amber, TTBrand.amber.opacity(0.6)],
                            center: .center, startRadius: 0, endRadius: 10
                        )
                    )
                    .frame(width: 14, height: 14)
                    .shadow(color: TTBrand.amber.opacity(0.5), radius: 6)
            } else if isPast {
                ZStack {
                    Circle()
                        .fill(TTBrand.accent(for: viabilityScore))
                        .frame(width: 12, height: 12)
                    Image(systemName: "checkmark")
                        .font(.system(size: 6, weight: .black))
                        .foregroundStyle(.white)
                }
            } else {
                Circle()
                    .fill(Color(uiColor: .systemFill))
                    .frame(width: 10, height: 10)
                    .overlay(
                        Circle()
                            .stroke(Color.secondary.opacity(0.3), lineWidth: 1.5)
                    )
            }
        }
    }

    @ViewBuilder
    private var cardContent: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 3) {
                Image(systemName: event.icon)
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundStyle(isCurrent ? TTBrand.amber : (isPast ? .secondary : .primary))
                Text(event.dateString)
                    .font(.system(size: 9, weight: .bold, design: .rounded))
                    .foregroundStyle(isCurrent ? TTBrand.amber : (isPast ? .secondary : .primary))
                    .textCase(.uppercase)
                    .lineLimit(1)
                if isCurrent {
                    Text("NOW")
                        .font(.system(size: 7, weight: .black, design: .rounded))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 1)
                        .background(TTBrand.amber)
                        .clipShape(Capsule())
                }
            }

            Text(event.title)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
                .foregroundStyle(isPast ? .secondary : .primary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)

            Text(event.detail)
                .font(.system(size: 10, design: .rounded))
                .foregroundStyle(isPast ? .tertiary : .secondary)
                .lineLimit(3)

            if event.isActionable && !isPast {
                Button {
                    onSeeGuide?()
                } label: {
                    HStack(spacing: 3) {
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.system(size: 9))
                        Text("See Guide")
                            .font(.system(size: 10, weight: .semibold, design: .rounded))
                    }
                    .foregroundStyle(TTBrand.skyBlue)
                }
                .accessibilityHint("Double tap to open step-by-step guide")
            }
        }
        .padding(10)
        .frame(width: cardWidth, alignment: .leading)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(isCurrent ? AnyShapeStyle(.thickMaterial) : AnyShapeStyle(.regularMaterial))
        }
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(
                    isCurrent ? TTBrand.amber.opacity(0.4) :
                    (colorScheme == .light
                        ? Color(uiColor: .separator).opacity(0.2)
                        : Color.white.opacity(0.06)),
                    lineWidth: isCurrent ? 1.5 : 0.5
                )
        )
        .shadow(
            color: colorScheme == .light
                ? .black.opacity(isCurrent ? 0.08 : 0.04)
                : .black.opacity(isCurrent ? 0.15 : 0.04),
            radius: isCurrent ? 10 : 4,
            y: 2
        )
        .opacity(isPast ? 0.6 : 1.0)
        .scaleEffect(isCurrent ? 1.02 : 1.0)
    }
}

@available(iOS 17.0, *)
struct TimelineGuideSheet: View {
    let event: TimelineEvent
    let uni: String
    let cc: String
    let state: String
    @Environment(\.dismiss) private var dismiss

    private var steps: [(icon: String, text: String)] {
        let title = event.title.lowercased()

        if title.contains("fafsa") {
            return [
                ("doc.text.fill", "Go to studentaid.gov and log in with your FSA ID"),
                ("magnifyingglass", "Add \(uni)'s federal school code to your FAFSA"),
                ("calendar", "File before June 30 — earlier = more aid available"),
                ("checkmark.circle.fill", "Confirm your Student Aid Report (SAR) looks correct"),
                ("envelope.fill", "Follow up with \(uni) financial aid office within 2 weeks"),
            ]
        }

        if title.contains("directconnect") || title.contains("direct connect") {
            return [
                ("link", "Verify your \(cc) AA degree audit is on track"),
                ("list.clipboard.fill", "Confirm all required gen-ed courses are complete"),
                ("person.fill", "Meet with your \(cc) advisor to sign off on DirectConnect"),
                ("paperplane.fill", "Submit your DirectConnect application to \(uni)"),
                ("checkmark.shield.fill", "Monitor your \(uni) application portal for confirmation"),
            ]
        }

        if title.contains("tag") {
            return [
                ("calendar", "Mark September 1–30 — TAG window is ONE month only"),
                ("doc.text.fill", "Prepare your transcript and GPA verification from \(cc)"),
                ("link", "Submit TAG application through the UC Transfer Admission Planner"),
                ("checkmark.circle.fill", "Verify your TAG-eligible major and GPA requirements"),
                ("bell.fill", "Watch for TAG confirmation email within 4–6 weeks"),
            ]
        }

        if title.contains("cal grant") {
            return [
                ("doc.text.fill", "File your FAFSA first — Cal Grant requires it"),
                ("person.fill", "Ask \(cc) financial aid to send your GPA verification"),
                ("calendar", "Both must be submitted by March 2"),
                ("dollarsign.circle.fill", "Cal Grant covers up to $14K/year at UCs"),
                ("magnifyingglass", "Check your Cal Grant status at webgrants4students.org"),
            ]
        }

        if title.contains("texas core") {
            return [
                ("list.clipboard.fill", "Review your degree audit for the 42-credit Texas Core"),
                ("checkmark.circle.fill", "Complete all core areas: Communication, Math, Life Sciences, etc."),
                ("doc.text.fill", "Request a Texas Core Curriculum completion certificate from \(cc)"),
                ("paperplane.fill", "The completed core transfers as a BLOCK — no individual evaluation"),
                ("exclamationmark.triangle.fill", "Partial core = course-by-course review = lost credits"),
            ]
        }

        if title.contains("gaa") {
            return [
                ("magnifyingglass", "Look up \(uni) GAA GPA cutoff for YOUR specific major"),
                ("exclamationmark.triangle.fill", "Engineering/CS often require 3.4+ — not the general 3.0"),
                ("person.fill", "Meet with \(cc) transfer advisor to confirm GAA eligibility"),
                ("doc.text.fill", "Gather unofficial transcript showing your current GPA"),
                ("checkmark.shield.fill", "Submit GAA verification form when applying to \(uni)"),
            ]
        }

        if title.contains("dta") {
            return [
                ("list.clipboard.fill", "Check your DTA degree progress at \(cc)"),
                ("exclamationmark.triangle.fill", "Without DTA, credits are evaluated one-by-one — you'll lose some"),
                ("person.fill", "Meet with \(cc) advisor to confirm remaining DTA requirements"),
                ("checkmark.circle.fill", "DTA guarantees junior standing at \(uni)"),
                ("calendar", "Complete DTA BEFORE your transfer semester"),
            ]
        }

        if title.contains("caa") {
            return [
                ("link", "Go to cfnc.org and pull up the CAA transfer list"),
                ("list.clipboard.fill", "Cross-reference every \(cc) course against the CAA list"),
                ("exclamationmark.triangle.fill", "Courses NOT on the list won't transfer to \(uni)"),
                ("person.fill", "Ask your advisor about substitute courses if needed"),
                ("doc.text.fill", "Print your verified CAA course map for your records"),
            ]
        }

        if title.contains("nj transfer") {
            return [
                ("link", "Go to njtransfer.org and select \(cc) → \(uni)"),
                ("magnifyingglass", "Run a course-by-course equivalency report"),
                ("exclamationmark.triangle.fill", "Flag any courses showing 'No Equivalent' or 'Free Elective'"),
                ("doc.text.fill", "Save/print your transfer evaluation report"),
                ("person.fill", "Bring the report to your \(cc) advisor for action plan"),
            ]
        }

        if title.contains("scholarship") {
            return [
                ("magnifyingglass", "Search \(uni)'s financial aid page for transfer-specific scholarships"),
                ("doc.text.fill", "Prepare your personal statement (focus on your transfer journey)"),
                ("list.clipboard.fill", "Gather recommendation letters from \(cc) professors"),
                ("calendar", "Most transfer scholarship deadlines are 2–4 months before enrollment"),
                ("dollarsign.circle.fill", "Apply to ALL you qualify for — typical awards: $1K–$3K/year"),
            ]
        }

        if title.contains("appeal") || title.contains("credit") {
            return [
                ("doc.text.fill", "Gather syllabus for each rejected course"),
                ("envelope.fill", "Email the \(uni) department chair for each subject area"),
                ("text.alignleft", "Include: course description, learning outcomes, textbook used"),
                ("clock.fill", "Allow 2–3 weeks for review — follow up if no response"),
                ("checkmark.circle.fill", "Students recover 6–9 credits on average through appeals"),
            ]
        }

        if title.contains("housing") {
            return [
                ("house.fill", "Check \(uni) off-campus housing listings and Facebook groups"),
                ("person.2.fill", "Post in \(uni) roommate-matching groups to split rent"),
                ("dollarsign.circle.fill", "Budget for first + last month + security deposit"),
                ("doc.text.fill", "Bring your acceptance letter — many complexes accept it in lieu of credit"),
                ("calendar", "Best apartments fill 3–4 months early — don't wait"),
            ]
        }

        return [
            ("lightbulb.fill", "Research this step on \(uni)'s official website"),
            ("person.fill", "Contact \(uni) admissions or your \(cc) advisor for guidance"),
            ("calendar", "Add this deadline to your calendar with a 2-week reminder"),
            ("checkmark.circle.fill", "Track your progress in the Solutions tab"),
        ]
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Image(systemName: event.icon)
                                .font(.title2)
                                .foregroundStyle(TTBrand.skyBlue)
                            Text(event.title)
                                .font(.system(.title3, design: .rounded).weight(.bold))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        Text(event.dateString)
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundStyle(.secondary)
                        Text(event.detail)
                            .font(.system(.subheadline, design: .rounded))
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Text("STEP-BY-STEP GUIDE")
                        .font(.system(.caption2, design: .rounded).weight(.bold))
                        .tracking(1.0)
                        .foregroundStyle(.secondary)

                    ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                        HStack(alignment: .top, spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(TTBrand.skyBlue.opacity(0.15))
                                    .frame(width: 36, height: 36)
                                Text("\(index + 1)")
                                    .font(.system(.subheadline, design: .rounded).weight(.bold))
                                    .foregroundStyle(TTBrand.skyBlue)
                            }
                            Text(step.text)
                                .font(.system(.subheadline, design: .rounded))
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.top, 8)
                        }
                        .staggerFade(delay: Double(index) * 0.08)
                    }

                    HStack(spacing: 8) {
                        Image(systemName: "lightbulb.fill")
                            .foregroundStyle(.yellow)
                            .font(.caption)
                        Text("Mark this action complete in the Solutions tab to boost your viability score.")
                            .font(.system(.caption, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                    .padding(12)
                    .background(Color.yellow.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                    Spacer(minLength: 40)
                }
                .padding(24)
            }
            .background(Color(uiColor: .systemBackground))
            .navigationTitle("Guide")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium, .large])
        .presentationBackground(Color(uiColor: .systemBackground))
    }
}

struct TimelineEvent: Identifiable, Equatable {
    let id = UUID()
    let date: Date
    let dateString: String
    let title: String
    let detail: String
    let icon: String
    let isActionable: Bool

    static func == (lhs: TimelineEvent, rhs: TimelineEvent) -> Bool {
        lhs.id == rhs.id
    }
}

func generateEvents(semester: String, cc: String, uni: String, state: String) -> [TimelineEvent] {
    let cal = Calendar.current
    let now = Date()

    let targetDate: Date = {
        let parts = semester.split(separator: " ")
        let year = Int(parts.last ?? "2026") ?? 2026
        let month: Int
        if semester.lowercased().contains("fall") { month = 8 }
        else if semester.lowercased().contains("spring") { month = 1 }
        else { month = 8 }
        return cal.date(from: DateComponents(year: year, month: month, day: 15)) ?? now
    }()

    var events: [TimelineEvent] = []
    let fmt = DateFormatter()
    fmt.dateFormat = "MMM yyyy"

    func makeDate(monthsBack: Int) -> Date {
        cal.date(byAdding: .month, value: -monthsBack, to: targetDate) ?? targetDate
    }

    func fmtDate(_ d: Date) -> String { fmt.string(from: d) }

    let fafsaDate = makeDate(monthsBack: 9)
    events.append(TimelineEvent(date: fafsaDate, dateString: fmtDate(fafsaDate), title: "File FAFSA + Add \(uni) Code", detail: "Pell Grant and state aid require FAFSA on file. Add \(uni)'s school code on studentaid.gov.", icon: "doc.text.fill", isActionable: true))

    switch state {
    case "Florida":
        let dcDate = makeDate(monthsBack: 7)
        events.append(TimelineEvent(date: dcDate, dateString: fmtDate(dcDate), title: "Confirm DirectConnect Eligibility", detail: "Your \(cc) AA guarantees \(uni) admission. Verify your AA degree audit is on track.", icon: "link", isActionable: true))

    case "California":
        let tagDate = cal.date(from: DateComponents(year: cal.component(.year, from: makeDate(monthsBack: 11)), month: 9, day: 1)) ?? makeDate(monthsBack: 11)
        events.append(TimelineEvent(date: tagDate, dateString: fmtDate(tagDate), title: "Submit TAG Application", detail: "Transfer Admission Guarantee window is Sept 1–30 ONLY. Miss it and you're in the regular pool.", icon: "link", isActionable: true))
        let calGrant = makeDate(monthsBack: 6)
        events.append(TimelineEvent(date: calGrant, dateString: fmtDate(calGrant), title: "Cal Grant Deadline (March 2)", detail: "Up to $14K/year at UCs. Requires FAFSA + GPA verification from \(cc).", icon: "star.fill", isActionable: true))

    case "Texas":
        let coreDate = makeDate(monthsBack: 8)
        events.append(TimelineEvent(date: coreDate, dateString: fmtDate(coreDate), title: "Complete Texas Core (42 cr)", detail: "The 42-credit Texas Core transfers as a block to \(uni). Finish it before transferring.", icon: "link", isActionable: true))

    case "Virginia":
        let gaaDate = makeDate(monthsBack: 7)
        events.append(TimelineEvent(date: gaaDate, dateString: fmtDate(gaaDate), title: "Confirm GAA Status", detail: "Check your Guaranteed Admission Agreement GPA cutoff for your specific major at \(uni).", icon: "checkmark.shield.fill", isActionable: true))

    case "Washington":
        let dtaDate = makeDate(monthsBack: 7)
        events.append(TimelineEvent(date: dtaDate, dateString: fmtDate(dtaDate), title: "Finish DTA Degree", detail: "Direct Transfer Agreement from \(cc) guarantees junior standing at \(uni).", icon: "link", isActionable: true))

    case "North Carolina":
        let caaDate = makeDate(monthsBack: 7)
        events.append(TimelineEvent(date: caaDate, dateString: fmtDate(caaDate), title: "Cross-Check CAA Courses", detail: "Verify every remaining course at \(cc) is on the Comprehensive Articulation Agreement list.", icon: "list.clipboard.fill", isActionable: true))

    case "New Jersey":
        let njDate = makeDate(monthsBack: 7)
        events.append(TimelineEvent(date: njDate, dateString: fmtDate(njDate), title: "Run NJ Transfer Evaluation", detail: "Go to njtransfer.org and check which \(cc) credits transfer to \(uni).", icon: "magnifyingglass", isActionable: true))

    default: break
    }

    let appDate = makeDate(monthsBack: 5)
    events.append(TimelineEvent(date: appDate, dateString: fmtDate(appDate), title: "Submit \(uni) Application", detail: "Apply early. Don't wait for deadlines — rolling admissions favor early applicants.", icon: "paperplane.fill", isActionable: false))

    let scholarDate = makeDate(monthsBack: 4)
    events.append(TimelineEvent(date: scholarDate, dateString: fmtDate(scholarDate), title: "Apply for Transfer Scholarships", detail: "Check \(uni)'s transfer-specific awards. Most students skip these. $1K–$3K/year.", icon: "dollarsign.circle.fill", isActionable: true))

    let creditDate = makeDate(monthsBack: 3)
    events.append(TimelineEvent(date: creditDate, dateString: fmtDate(creditDate), title: "Appeal Rejected Credits", detail: "Email department chairs with syllabi for each rejected course. Recover 6–9 credits.", icon: "arrow.uturn.backward", isActionable: true))

    let housingDate = makeDate(monthsBack: 2)
    events.append(TimelineEvent(date: housingDate, dateString: fmtDate(housingDate), title: "Lock Down Housing", detail: "Best student apartments fill early. Tour, apply, and secure a roommate ASAP.", icon: "house.fill", isActionable: true))

    let orientDate = makeDate(monthsBack: 1)
    events.append(TimelineEvent(date: orientDate, dateString: fmtDate(orientDate), title: "Attend \(uni) Orientation", detail: "Register for classes. Meet your advisor. Get your student ID and parking permit.", icon: "person.wave.2.fill", isActionable: false))

    events.append(TimelineEvent(date: targetDate, dateString: fmtDate(targetDate), title: "First Day at \(uni)!", detail: "You made it. All the planning pays off. Go crush it.", icon: "graduationcap.fill", isActionable: false))

    return events.sorted { $0.date < $1.date }
}
