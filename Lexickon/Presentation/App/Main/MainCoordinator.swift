import Observation
import SwiftUI

enum MainStep: CoordinatorStep {
    case frequency
    case profile
    case settings
    case about
    case onboarding
    case selectTab(MainTab)
    case logout
    case sessionExpired
}

enum MainTab: String, Hashable, Sendable {
    case search
    case frequency
    case profile
}

@Observable
@MainActor
final class MainCoordinator: Coordinator {
    var path: [MainStep] = []
    var sheet: MainStep?
    var fullScreenCover: MainStep?
    var selectedTab: MainTab = .search

    private let onStep: @MainActor (AppStep) -> Void

    init(onStep: @escaping @MainActor (AppStep) -> Void) {
        self.onStep = onStep
    }

    func navigate(to step: MainStep) {
        switch step {
        case .frequency, .profile, .settings:
            path.pushUnique(step)
        case .about:
            sheet = .about
        case .onboarding:
            fullScreenCover = .onboarding
        case let .selectTab(tab):
            selectedTab = tab
        case .logout:
            onStep(.logout)
        case .sessionExpired:
            onStep(.sessionExpired)
        }
    }
}
@MainActor
struct MainCoordinatorView: View {
    @Bindable var coordinator: MainCoordinator

    var body: some View {
        NavigationStack(path: $coordinator.path) {
            TabView(selection: $coordinator.selectedTab) {
                searchTab
                    .tabItem {
                        Label("navigation.main.search", systemImage: "magnifyingglass")
                    }
                    .tag(MainTab.search)

                frequencyTab
                    .tabItem {
                        Label("navigation.main.frequency", systemImage: "chart.bar")
                    }
                    .tag(MainTab.frequency)

                profileTab
                    .tabItem {
                        Label("navigation.main.profile", systemImage: "person")
                    }
                    .tag(MainTab.profile)
            }
            .navigationDestination(for: MainStep.self) { step in
                destination(for: step)
            }
        }
        .sheet(item: $coordinator.sheet) { sheet in
            switch sheet {
            case .about:
                NavigationPlaceholderScreen(
                    title: "navigation.main.about.title",
                    subtitle: "navigation.placeholder.subtitle",
                    systemImage: "info.circle",
                    accessibilityIdentifier: "main.about.title"
                ) {
                    Button("navigation.close") {
                        coordinator.sheet = nil
                    }
                }
            case .frequency, .profile, .settings, .onboarding, .selectTab,
                 .logout, .sessionExpired:
                EmptyView()
            }
        }
        .fullScreenCover(item: $coordinator.fullScreenCover) { cover in
            switch cover {
            case .onboarding:
                NavigationPlaceholderScreen(
                    title: "navigation.main.onboarding.title",
                    subtitle: "navigation.placeholder.subtitle",
                    systemImage: "sparkles",
                    accessibilityIdentifier: "main.onboarding.title"
                ) {
                    Button("navigation.close") {
                        coordinator.fullScreenCover = nil
                    }
                }
            case .frequency, .profile, .settings, .about, .selectTab,
                 .logout, .sessionExpired:
                EmptyView()
            }
        }
    }

    private var searchTab: some View {
        NavigationPlaceholderScreen(
            title: "navigation.main.title",
            subtitle: "navigation.placeholder.subtitle",
            systemImage: "character.book.closed",
            accessibilityIdentifier: "main.placeholder"
        ) {
            Button("navigation.main.frequency") {
                coordinator.navigate(to: .selectTab(.frequency))
            }

            Button("navigation.main.logout") {
                coordinator.navigate(to: .logout)
            }
            .accessibilityIdentifier("main.logout")
            .buttonStyle(.bordered)

            Button("navigation.main.sessionExpired") {
                coordinator.navigate(to: .sessionExpired)
            }
            .accessibilityIdentifier("main.sessionExpired")
            .buttonStyle(.bordered)
        }
    }

    private var frequencyTab: some View {
        NavigationPlaceholderScreen(
            title: "navigation.main.frequency.title",
            subtitle: "navigation.placeholder.subtitle",
            systemImage: "chart.bar",
            accessibilityIdentifier: "main.frequency.title"
        ) {
            Button("navigation.main.openFrequency") {
                coordinator.navigate(to: .frequency)
            }
        }
    }

    private var profileTab: some View {
        NavigationPlaceholderScreen(
            title: "navigation.main.profile.title",
            subtitle: "navigation.placeholder.subtitle",
            systemImage: "person.crop.circle",
            accessibilityIdentifier: "main.profile.title"
        ) {
            Button("navigation.main.settings") {
                coordinator.navigate(to: .settings)
            }

            Button("navigation.main.about") {
                coordinator.navigate(to: .about)
            }
            .buttonStyle(.bordered)
        }
    }

    @ViewBuilder
    private func destination(for step: MainStep) -> some View {
        switch step {
        case .frequency:
            NavigationPlaceholderScreen(
                title: "navigation.main.frequency.title",
                subtitle: "navigation.placeholder.subtitle",
                systemImage: "chart.bar",
                accessibilityIdentifier: "main.frequency.destination.title"
            ) { EmptyView() }
        case .profile:
            NavigationPlaceholderScreen(
                title: "navigation.main.profile.title",
                subtitle: "navigation.placeholder.subtitle",
                systemImage: "person.crop.circle",
                accessibilityIdentifier: "main.profile.destination.title"
            ) { EmptyView() }
        case .settings:
            NavigationPlaceholderScreen(
                title: "navigation.main.settings.title",
                subtitle: "navigation.placeholder.subtitle",
                systemImage: "gearshape",
                accessibilityIdentifier: "main.settings.title"
            ) { EmptyView() }
        case .about, .onboarding, .selectTab, .logout, .sessionExpired:
            EmptyView()
        }
    }
}
