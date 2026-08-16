@MainActor
protocol Coordinator: AnyObject {
    associatedtype Step: CoordinatorStep

    func navigate(to step: Step)
}

protocol CoordinatorStep: Hashable, Identifiable, Sendable {}

extension CoordinatorStep {
    var id: Self { self }
}

extension Array where Element: CoordinatorStep {
    mutating func pushUnique(_ step: Element) {
        if let existingIndex = firstIndex(of: step) {
            removeSubrange(index(after: existingIndex)..<endIndex)
        } else {
            append(step)
        }
    }
}
