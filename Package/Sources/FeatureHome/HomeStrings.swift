enum HomeStrings {
    static let title = "ポケモン"
    static let searchPrompt = "名前で絞り込む"
    static let emptyTitle = "ポケモンがいません"
    static let emptyDescription = "取得できましたが 1 件もありませんでした"
    static let reload = "再取得"
    static let offline = "接続を確認してください"
    static let unreadable = "データを読み取れませんでした"

    static func serverError(statusCode: Int) -> String {
        "サーバーが応答しませんでした（\(statusCode)）"
    }
}
