import FactoryKit

/// Composition root output. SwiftUI receives only use cases through Environment.
@MainActor
final class AppContainer {
    let useCases: UseCases

    init() {
        self.useCases = Container.shared.useCases()
    }

    /// Test constructor with custom container context.
    init(useCases: UseCases) {
        self.useCases = useCases
    }
}
