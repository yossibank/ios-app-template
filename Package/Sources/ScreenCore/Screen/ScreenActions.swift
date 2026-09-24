public struct ScreenActions {
    public let request: @MainActor (FetchOperation) -> Void
    public let refresh: @MainActor () async -> Void
    public let isRunning: @MainActor (FetchOperation) -> Bool
}
