// 共通コア（kmp-app-template）を import してよいのはこの Core モジュールだけ。
// 再エクスポートすることで、Feature / AppRoot は `import Core` だけで
// Kotlin 側の型に触れる（間に変換層は置かない）。
@_exported import Shared

/// Kotlin/Native から生成される型は Sendable として宣言されない。そのため
/// `@MainActor` の ViewModel が保持したまま async メソッドを呼ぶと
/// `sending 'self.api' risks causing data races` で弾かれる。
///
/// Kotlin の新メモリマネージャはスレッド間の共有を許し、Ktor の HttpClient も
/// スレッドセーフなので、ここで表明する。**表明はこのファイルにだけ置く。**
extension PokemonApi: @retroactive @unchecked Sendable {}
