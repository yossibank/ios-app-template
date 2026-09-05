import Observation

/// 画面が持つモデルの形。基底クラスではなくプロトコルで要求する。
///
/// 継承にすると、サブクラスへの `@Observable` の付け忘れで観測が
/// 無警告のまま壊れる。プロトコルなら継承せずに形だけを強制できる。
@MainActor
public protocol ScreenModel: AnyObject, Observable {
    associatedtype Value
    associatedtype Destination: Identifiable

    var phase: Phase<Value> { get }
    var destination: Destination? { get set }

    func load() async
}

/// 遷移を持たない画面が `Destination` に指定する。値を作れないので常に nil。
public enum NoDestination: Identifiable {
    public var id: Never {
        switch self {}
    }
}
