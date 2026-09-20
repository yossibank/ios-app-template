# ios-app-template

## プロジェクト概要

iOS アプリの初期テンプレート。ビジネスロジックは Kotlin Multiplatform の共通コアに置き、
このリポジトリには iOS 固有のものだけを置く。

kmp-app-template（共通ロジック）・android-app-template と合わせた 3 リポジトリ構成の 1 つ。

## 技術スタック

| 項目 | 採用 |
| --- | --- |
| UI | SwiftUI |
| 状態管理 | Observation |
| 並行性 | Swift Concurrency（言語モード 6） |
| テスト | Swift Testing |
| 依存管理 | Swift Package Manager |

バージョンの出所は [README.md](README.md) の「環境」。

## プロジェクト構成

```
AppTemplate.xcworkspace     入口。.xcodeproj は直接開かない
App/                        アプリターゲット。@main と Assets のみ
Package/                    画面とロジック。モジュールはここに並べる
```

依存は `*Core` → `Feature*` → `AppRoot` の一方向。
モジュールの役割は [README.md](README.md)。

## 使用ライブラリ

| | |
| --- | --- |
| `Shared`（kmp-app-template） | 共通コア。唯一の依存。`Package.swift` で `exact` 指定 |
| SwiftFormat / SwiftLint | 書式と規約のチェック。版は `Mintfile` で固定し、Mint 経由で呼ぶ |
| Renovate | 依存の更新 PR（毎週月曜） |

## コーディング規約

- コードに無駄なコメントを書かない。
- グローバル関数を作らない。型のメソッドか、対象の型への extension にする。
- 画面に出る文言を Swift のリテラルで書かない。`Localizable.xcstrings` に置き、
  `String(localized:bundle: .module)` で引く。`defaultValue` は渡さない
  （引けていないことをテストで検出できなくなる）。

## 全体ルール

- 変更したら `make verify` を通す。通らないものは完了ではない。
- 共通ロジックは kmp-app-template 側に置く。ここには iOS 固有のものだけ。
- 共通コアのバージョンを `Package.swift` 以外で指定しない。
- lint ツールのバージョンを `Mintfile` 以外で指定しない。素の `swiftlint` /
  `swiftformat` を直接呼ばない（PATH 上の版が何かに依存してしまう）。
- 警告を数えるときは DerivedData を捨てる。増分ビルドでは再コンパイルされず 0 件に見える。
