import SwiftUI

struct MainTabView: View {
    @Environment(AppEnvironment.self) private var env
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        TabView(selection: Binding(
            get: { env.selectedMainTab },
            set: { env.selectedMainTab = $0 }
        )) {
            TodayView()
                .tabItem { Label(MainTab.today.title, systemImage: MainTab.today.symbol) }
                .tag(MainTab.today)
                .accessibilityIdentifier("tab.today")

            ReadView()
                .tabItem { Label(MainTab.read.title, systemImage: MainTab.read.symbol) }
                .tag(MainTab.read)
                .accessibilityIdentifier("tab.read")

            TalkView()
                .tabItem { Label(MainTab.talk.title, systemImage: MainTab.talk.symbol) }
                .tag(MainTab.talk)
                .accessibilityIdentifier("tab.talk")

            PrayView()
                .tabItem { Label(MainTab.pray.title, systemImage: MainTab.pray.symbol) }
                .tag(MainTab.pray)
                .accessibilityIdentifier("tab.pray")

            JourneyView()
                .tabItem { Label(MainTab.journey.title, systemImage: MainTab.journey.symbol) }
                .tag(MainTab.journey)
                .accessibilityIdentifier("tab.journey")
        }
        .tint(SelahColors.primaryDeep)
        .toolbarBackground(SelahColors.background, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
        .background(SelahColors.background.ignoresSafeArea())
        .onChange(of: env.selectedMainTab) { _, tab in
            env.qualifyingTracker.setPrayOrTalkActive(tab.isPrayOrTalk)
        }
        .onChange(of: scenePhase) { _, phase in
            env.qualifyingTracker.setForeground(phase == .active)
        }
        .onAppear {
            env.qualifyingTracker.setPrayOrTalkActive(env.selectedMainTab.isPrayOrTalk)
            env.qualifyingTracker.setForeground(scenePhase == .active)
        }
        .task {
            while !Task.isCancelled {
                env.qualifyingTracker.tick()
                try? await Task.sleep(for: .seconds(1))
            }
        }
    }
}
