public enum FetchPhase<Value> {
    case idle
    case loading
    case loaded(Value)
    case loadingMore(Value)
    case failed(any Error)
}

extension FetchPhase {
    var isLoadingMore: Bool {
        guard case .loadingMore = self else {
            return false
        }

        return true
    }
}
