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
| SwiftFormat / SwiftLint | 書式と規約のチェック。版は `Mintfile` で固定。手元は Mint 経由、CI は同じ版の配布バイナリ |
| Renovate | 依存の更新 PR（毎週月曜） |

## コーディング規約

- コメントを書かない。コード、設定、スクリプト、CI のいずれにも書かない。
- コメントが要ると判断したときは、書かずに提案する。
- グローバル関数を作らない。型のメソッドか、対象の型への extension にする。
- 画面に出る文言を Swift のリテラルで書かない。`Localizable.xcstrings` に置き、
  `*Strings.Key` に足してから引く。`defaultValue` は渡さない
  （引けていないことをテストで検出できなくなる）。キーは `Key` に並べる。
  並べないと全数解決のテストの対象から外れる。
- `#Preview` の中だけはリテラルでよい。出荷する文言ではないため、カタログに入れない。

## 全体ルール

- 変更したら `make verify` を通す。通らないものは完了ではない。
- 共通ロジックは kmp-app-template 側に置く。ここには iOS 固有のものだけ。
- 失敗画面と絞り込み 0 件の見せ方は各 OS の作法に寄せる。揃えるのは文言の語彙まで。
- テストターゲットを増やしたら `AppTemplate.xctestplan` に追加する。足さないと走らないまま緑になる。
- 共通コア（`Shared`）を import してよいのは `SharedCore` とそのテストだけ。
  `FeatureHome` に渡すのは `SharedCore` が公開する Swift の型。KMP の型を素通しにしない。
- 共通コアのバージョンを `Package.swift` 以外で指定しない。
- lint ツールのバージョンを `Mintfile` 以外で指定しない。CI も Mintfile から読む。
- Makefile は `$(SWIFTFORMAT)` / `$(SWIFTLINT)` 経由で呼ぶ。実体名を直接書かない
  （手元は Mint、CI は配布バイナリ、と入口を差し替えているため）。
- 警告を数えるときは DerivedData を捨てる。増分ビルドでは再コンパイルされず 0 件に見える。
