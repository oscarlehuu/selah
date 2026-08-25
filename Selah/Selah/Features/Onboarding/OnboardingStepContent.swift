import SwiftUI

struct OnboardingStepContent: View {
    let step: OnboardingStep
    @Binding var distance: OnboardingDistance?
    @Binding var desire: OnboardingDesire?
    @Binding var habit: OnboardingHabit?
    @Binding var mood: OnboardingMood?
    let demoResult: String
    let isGenerating: Bool
    let buildProgress: Double

    var body: some View {
        switch step {
        case .welcome: welcome
        case .hook: prose(OnboardingCopy.hookTitle, OnboardingCopy.hookBody)
        case .stat: stat
        case .quizDistance: distanceQuiz
        case .quizDesire: desireQuiz
        case .quizHabit: habitQuiz
        case .mirror: mirror
        case .commitment: prose(OnboardingCopy.commitmentTitle, OnboardingCopy.commitmentBody)
        case .privacy: privacy
        case .demoMood: moodPicker
        case .demoResult: demo
        case .building: building
        case .planReveal: PlanRevealView(desire: desire)
        case .social: social
        case .widget: EmptyView()
        }
    }

    private var welcome: some View {
        List {
            Section {
                Label(OnboardingCopy.welcomeSubtitle, systemImage: "sunrise.fill")
                    .font(SelahFont.ui(.subheadline, weight: .semibold))
                    .foregroundStyle(SelahColors.accent)
                Text(OnboardingCopy.welcomeTitle)
                    .font(SelahFont.display(.largeTitle))
                Text("“\(OnboardingCopy.welcomeVerse)”")
                    .font(SelahFont.verse(.title3))
                Text(OnboardingCopy.welcomeVerseRef)
                    .font(SelahFont.ui(.caption, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
            Section {
                Text(OnboardingCopy.welcomeMeaning)
                Text(OnboardingCopy.welcomeDurationHint)
                    .foregroundStyle(.secondary)
            }
        }
        .listStyle(.insetGrouped)
    }

    private func prose(_ title: String, _ body: String) -> some View {
        List {
            Section {
                Text(title).font(SelahFont.display(.title2))
                Text(body).font(SelahFont.ui(.body)).foregroundStyle(.secondary)
            }
        }
        .listStyle(.insetGrouped)
    }

    private var stat: some View {
        List {
            Section("The gap") {
                Text("1 in 5")
                    .font(SelahFont.display(.largeTitle))
                    .foregroundStyle(SelahColors.primaryDeep)
                Text("Most Christians want to read the Bible daily. Few build the habit.")
            }
            Section {
                LabeledContent("Want to read daily", value: "86%")
                LabeledContent("Actually do", value: "19%")
            } footer: {
                Text("Illustrative figures for this prototype. Replace with a cited source before ship.")
            }
        }
        .listStyle(.insetGrouped)
    }

    private var distanceQuiz: some View {
        List {
            Section {
                Text("What keeps you furthest from God right now?")
                    .font(SelahFont.display(.title3))
            }
            Section {
                ForEach(OnboardingDistance.allCases) { option in
                    quizRow(option.title, option.subtitle, option.symbol, selected: distance == option) {
                        distance = option
                    }
                    .accessibilityIdentifier(option.accessibilityID)
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    private var desireQuiz: some View {
        List {
            Section {
                Text("What do you want most?")
                    .font(SelahFont.display(.title3))
            }
            Section {
                ForEach(OnboardingDesire.allCases) { option in
                    quizRow(option.title, nil, option.symbol, selected: desire == option) {
                        desire = option
                    }
                    .accessibilityIdentifier(option.accessibilityID)
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    private var habitQuiz: some View {
        List {
            Section {
                Text("How often do you read the Bible now?")
                    .font(SelahFont.display(.title3))
                Text("Be honest. This only shapes your plan. Nobody sees it.")
                    .foregroundStyle(.secondary)
            }
            Section {
                ForEach(OnboardingHabit.allCases) { option in
                    quizRow(option.title, option.subtitle, "book", selected: habit == option) {
                        habit = option
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    private var mirror: some View {
        List {
            if let desire, let distance {
                Section {
                    Text(OnboardingCopy.mirrorText(desire: desire, distance: distance))
                        .font(SelahFont.display(.title3))
                    Text("That honesty is already a prayer. Most people never say it out loud.")
                        .foregroundStyle(.secondary)
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    private var privacy: some View {
        List {
            Section {
                Label(OnboardingCopy.privacyTitle, systemImage: "lock.fill")
                    .font(SelahFont.display(.title3))
                Text(OnboardingCopy.privacySubtitle)
                    .foregroundStyle(.secondary)
            }
            Section("On this iPhone") {
                Label("Nothing is uploaded. The companion runs on your device.", systemImage: "icloud.slash")
                Label("Journal is encrypted on this iPhone, locked with Face ID.", systemImage: "faceid")
                Label("Auto-delete a session when you close it, if you prefer.", systemImage: "trash")
            }
        }
        .listStyle(.insetGrouped)
    }

    private var moodPicker: some View {
        List {
            Section {
                Text("How is your heart right now?")
                    .font(SelahFont.display(.title3))
                Text("Pick one. Selah will pray with you — not at you.")
                    .foregroundStyle(.secondary)
            }
            Section {
                ForEach(OnboardingMood.allCases) { option in
                    quizRow(option.title, nil, option.symbol, selected: mood == option) {
                        mood = option
                    }
                }
            }
            if !CompanionTextService.isOnDeviceCompanionAvailable {
                Section {
                    Text(CompanionTextService.unavailableMessage)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    private var demo: some View {
        List {
            Section {
                Text("Feeling \(mood?.title.lowercased() ?? "heavy") · generated on your iPhone")
                    .font(SelahFont.ui(.caption, weight: .semibold))
                    .foregroundStyle(.secondary)
                if isGenerating {
                    ProgressView("Preparing a prayer")
                } else {
                    Text(demoResult.isEmpty ? CompanionTextService.unavailableMessage : demoResult)
                        .font(SelahFont.verse(.body))
                }
            } footer: {
                Text(OnboardingCopy.companionDisclaimer)
            }
        }
        .listStyle(.insetGrouped)
    }

    private var building: some View {
        List {
            Section {
                ProgressView(value: buildProgress)
                Text("Creating your 7-day journey…")
                    .font(SelahFont.display(.title3))
            }
            Section("Preparing") {
                Label("Reading your answers", systemImage: buildProgress >= 0.25 ? "checkmark.circle.fill" : "circle")
                Label("Choosing passages", systemImage: buildProgress >= 0.5 ? "checkmark.circle.fill" : "circle")
                Label("Setting a 5-minute rhythm", systemImage: buildProgress >= 0.75 ? "checkmark.circle.fill" : "circle")
                Label("Preparing your private space", systemImage: buildProgress >= 1 ? "checkmark.circle.fill" : "circle")
            }
        }
        .listStyle(.insetGrouped)
    }

    private var social: some View {
        List {
            Section {
                Text(OnboardingCopy.socialTitle)
                    .font(SelahFont.display(.title3))
            }
            Section("From people who felt far away") {
                ForEach(OnboardingCopy.socialQuotes, id: \.self) { quote in
                    Text("“\(quote)”")
                        .font(SelahFont.verse(.body))
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    private func quizRow(_ title: String, _ subtitle: String?, _ symbol: String, selected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Label {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(title).foregroundStyle(.primary)
                        if let subtitle {
                            Text(subtitle).font(SelahFont.ui(.footnote)).foregroundStyle(.secondary)
                        }
                    }
                } icon: {
                    Image(systemName: symbol)
                }
                Spacer()
                if selected {
                    Image(systemName: "checkmark")
                        .foregroundStyle(SelahColors.primaryDeep)
                }
            }
        }
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}

private struct PlanRevealView: View {
    @Environment(AppEnvironment.self) private var env
    let desire: OnboardingDesire?

    var body: some View {
        let theme = env.planRepository.theme(from: desire ?? .peace)
        List {
            Section {
                Text("7 days toward \(theme?.label.lowercased() ?? "peace")")
                    .font(SelahFont.display(.title3))
                Text("Five minutes a day. One passage, one prayer, one honest moment.")
                    .foregroundStyle(.secondary)
            }
            Section("This week") {
                ForEach(theme?.weekDays(week: 1) ?? []) { day in
                    LabeledContent(day.label, value: "\(day.book) \(day.chapter)")
                }
            }
        }
        .listStyle(.insetGrouped)
    }
}
