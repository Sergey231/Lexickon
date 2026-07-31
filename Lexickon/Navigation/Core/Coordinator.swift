@MainActor
protocol Coordinator: AnyObject {
    associatedtype Step: CoordinatorStep

    func handle(_ step: Step)
}

protocol CoordinatorStep: Hashable, Sendable {}

extension Array where Element: CoordinatorStep {
    mutating func pushUnique(_ step: Element) {
        if let existingIndex = firstIndex(of: step) {
            removeSubrange(index(after: existingIndex)..<endIndex)
        } else {
            append(step)
        }
    }
}
