public enum FetchMore<Value> {
    case more(Value)
    case last(Value)
}

public extension FetchMore {
    var value: Value {
        switch self {
        case let .more(value), let .last(value):
            value
        }
    }
}
