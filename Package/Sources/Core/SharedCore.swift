// 共通コア（kmp-app-template）を import してよいのはこの Core モジュールだけ。
// 再エクスポートすることで、Feature / AppRoot は `import Core` だけで
// Kotlin 側の型に触れる（間に変換層は置かない）。
@_exported import Shared
