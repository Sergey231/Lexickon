import Observation
import SwiftUI

enum MainStep: CoordinatorStep {
    case frequency
    case profile
    case settings
    case about
    case onboarding
    case aboutDismissed
    case onboardingDismissed
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
        case .aboutDismissed:
            sheet = nil
        case .onboardingDismissed:
            fullScreenCover = nil
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
    private let logout: LogoutUseCase

    init(coordinator: MainCoordinator, logout: LogoutUseCase) {
        self.coordinator = coordinator
        self.logout = logout
    }

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
                MainAboutView { step in
                    coordinator.navigate(to: step)
                }
            case .frequency, .profile, .settings, .onboarding,
                 .aboutDismissed, .onboardingDismissed, .selectTab, .logout,
                 .sessionExpired:
                EmptyView()
            }
        }
        .fullScreenCover(item: $coordinator.fullScreenCover) { cover in
            switch cover {
            case .onboarding:
                MainOnboardingView { step in
                    coordinator.navigate(to: step)
                }
            case .frequency, .profile, .settings, .about, .aboutDismissed,
                 .onboardingDismissed, .selectTab, .logout, .sessionExpired:
                EmptyView()
            }
        }
    }

    private var searchTab: some View {
        MainSearchView(logout: logout) { step in
            coordinator.navigate(to: step)
        }
    }

    private var frequencyTab: some View {
        MainFrequencyView { step in
            coordinator.navigate(to: step)
        }
    }

    private var profileTab: some View {
        MainProfileView { step in
            coordinator.navigate(to: step)
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
        case .about, .onboarding, .aboutDismissed, .onboardingDismissed,
             .selectTab, .logout, .sessionExpired:
            EmptyView()
        }
    }
}
