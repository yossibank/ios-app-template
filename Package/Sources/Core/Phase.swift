/// 非同期取得の状態。全画面がこの型を使う。
///
/// `isLoading` と `error` を別々の変数で持つと、両方が立った状態が型として
/// 表現できてしまう。enum にすることで存在し得なくなる。
public enum Phase<Value> {
    case loading
    case loaded(Value)
    case failed(String)
}
