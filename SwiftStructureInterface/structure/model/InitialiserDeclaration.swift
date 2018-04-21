public protocol InitialiserDeclaration: Element {
    var parameters: [Parameter] { get }
    var `throws`: Bool { get }
    var `rethrows`: Bool { get }
    var isFailable: Bool { get }
}
