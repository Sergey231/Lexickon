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

    private let resolveLaunchDestination: ResolveLaunchDestinationUseCase

    init(resolveDestination: ResolveLaunchDestinationUseCase) {
        self.resolveLaunchDestination = resolveDestination
    }

    var isLoading: Bool {
        state == .loading
    }

    func resolveDestination() async -> LaunchDestination? {
        guard state != .loading else { return nil }

        state = .loading
        do {
            let destination = try await resolveLaunchDestination()
            state = .resolved(destination)
            return destination
        } catch let appError as AppError {
            state = .error(appError)
            return nil
        } catch {
            state = .error(.unexpected(.invariantViolation))
            return nil
        }
    }
}
