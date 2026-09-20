public struct ScreenActions {
    public let reload: @MainActor () -> Void
    public let loadMore: @MainActor () -> Void
    public let isLoadingMore: Bool
}
