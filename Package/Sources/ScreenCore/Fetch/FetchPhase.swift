public enum FetchPhase<Value> {
    case idle
    case loading
    case loaded(Value)
    case failed(any Error)
}
