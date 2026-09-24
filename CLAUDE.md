# ios-app-template

## 作業の進め方

- 変更したら `make verify` を通す。
- 警告を数えるときは DerivedData を捨てる。増分ビルドでは再コンパイルされず 0 件に見える。
- Makefile では `$(SWIFTFORMAT)` / `$(SWIFTLINT)` を使い、実体名を直接書かない。
- 共通コアのバージョンは `Package.swift`、lint ツールのバージョンは `Mintfile` 以外で指定しない。

## コードの書き方

- コメントを書かない。コード、設定、スクリプト、CI のいずれにも書かない。要ると判断したら、書かずに提案する。
- 画面に出る文言は `Localizable.xcstrings` に置き、`*Strings.Key` 経由で引く。`defaultValue` は渡さない。
  `#Preview` の中だけはリテラルでよい。

## 3 リポジトリの取り決め

- 共通ロジックは kmp-app-template に置く。ここには iOS 固有のものだけを置く。
- 失敗画面と絞り込み 0 件の見せ方は各 OS の作法に寄せる。揃えるのは文言の語彙まで。
