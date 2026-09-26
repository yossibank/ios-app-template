public enum FetchMore<Value> {
    case more(Value)
    case last(Value)
    case unchanged

    public var value: Value? {
        switch self {
        case let .more(value), let .last(value):
            value

        case .unchanged:
            nil
        }
    }
}
