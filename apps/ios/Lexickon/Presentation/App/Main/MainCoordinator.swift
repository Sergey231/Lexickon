import Observation
import SwiftUI

enum MainStep: CoordinatorStep {
    case root
    case frequency
    case profile
    case settings
    case about
    case onboarding
    case selectTab(MainTab)
    case authentication
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
    private let onAuthenticationRequested: @MainActor () -> Void

    init(onAuthenticationRequested: @escaping @MainActor () -> Void) {
        self.onAuthenticationRequested = onAuthenticationRequested
    }

    func navigate(to step: MainStep) {
        switch step {
        case .root:
            path = []
            sheet = nil
            fullScreenCover = nil
        case .frequency, .profile, .settings:
            path.pushUnique(step)
        case .about:
            sheet = .about
        case .onboarding:
            fullScreenCover = .onboarding
        case let .selectTab(tab):
            selectedTab = tab
        case .authentication:
            onAuthenticationRequested()
        }
    }
}

@MainActor
struct MainCoordinatorView: View {
    @State private var coordinator: MainCoordinator
    @Environment(\.useCases) private var useCases

    init(onAuthenticationRequested: @escaping @MainActor () -> Void) {
        _coordinator = State(
            initialValue: MainCoordinator(
                onAuthenticationRequested: onAuthenticationRequested
            )
        )
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
                MainAboutView(
                    viewModel: MainAboutViewModel { step in
                        coordinator.navigate(to: step)
                    }
                )
            case .root, .frequency, .profile, .settings, .onboarding,
                 .selectTab, .authentication:
                EmptyView()
            }
        }
        .fullScreenCover(item: $coordinator.fullScreenCover) { cover in
            switch cover {
            case .onboarding:
                MainOnboardingView(
                    viewModel: MainOnboardingViewModel { step in
                        coordinator.navigate(to: step)
                    }
                )
            case .root, .frequency, .profile, .settings, .about,
                 .selectTab, .authentication:
                EmptyView()
            }
        }
    }

    private var searchTab: some View {
        MainSearchView(
            viewModel: MainSearchViewModel(
                logoutUseCase: useCases.logoutUseCase,
                navigate: { step in
                    coordinator.navigate(to: step)
                }
            )
        )
    }

    private var frequencyTab: some View {
        MainFrequencyView(
            viewModel: MainFrequencyViewModel { step in
                coordinator.navigate(to: step)
            }
        )
    }

    private var profileTab: some View {
        MainProfileView(
            viewModel: MainProfileViewModel { step in
                coordinator.navigate(to: step)
            }
        )
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
        case .root, .about, .onboarding, .selectTab, .authentication:
            EmptyView()
        }
    }
}
