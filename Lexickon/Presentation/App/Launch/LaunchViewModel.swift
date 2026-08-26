import Observation

enum LaunchState: Equatable, Sendable {
    case idle
    case loading
    case resolved(LaunchDestination)
    case error(AppError)
}

@Observable
@MainActor
final class LaunchViewModel {
    private(set) var state: LaunchState = .idle

    private let resolveLaunchDestinationUseCase: ResolveLaunchDestinationUseCase
    @ObservationIgnored private let navigate: @MainActor (AppStep) -> Void

    init(
        resolveLaunchDestinationUseCase: ResolveLaunchDestinationUseCase,
        navigate: @escaping @MainActor (AppStep) -> Void
    ) {
        self.resolveLaunchDestinationUseCase = resolveLaunchDestinationUseCase
        self.navigate = navigate
    }

    var isLoading: Bool {
        state == .loading
    }

    func resolveDestination() async {
        guard state != .loading else { return }

        state = .loading
        do {
            let destination = try await resolveLaunchDestinationUseCase()
            state = .resolved(destination)
            navigate(.launchCompleted(destination))
        } catch let appError as AppError {
            state = .error(appError)
        } catch {
            state = .error(.unexpected(.invariantViolation))
        }
    }

    func loginTapped() {
        navigate(.launchCompleted(.login))
    }
}
