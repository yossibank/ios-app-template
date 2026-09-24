# ios-app-template

## 作業の進め方

- 変更したら `make verify` を通す。
- 警告を数えるときは **DerivedData を捨てる**。増分ビルドでは再コンパイルされず 0 件に見える。
- Makefile では `$(SWIFTFORMAT)` / `$(SWIFTLINT)` を使い、実体名を直接書かない。
- バージョンの置き場所を増やさない。
  - 共通コア → `Package.swift`
  - lint ツール → `Mintfile`

## コードの書き方

- **コメントを書かない。** コード、設定、スクリプト、CI のいずれにも書かない。要ると判断したら、書かずに提案する。
- 画面に出る文言は `Localizable.xcstrings` に置き、`*Strings.Key` 経由で引く。
  - `defaultValue` は**渡さない**。
  - 例外：`#Preview` の中だけはリテラルでよい。

## 3 リポジトリの取り決め

- 共通ロジックは kmp-app-template に置く。ここには iOS 固有のものだけを置く。
- 失敗画面と絞り込み 0 件は、見せ方を**各 OS の作法に寄せる**。揃えるのは**文言の語彙まで**。
