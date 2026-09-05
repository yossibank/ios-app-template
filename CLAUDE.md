# ios-app-template

iOS アプリ。画面とロジックは `Package/` のローカル SPM パッケージに置き、
Xcode プロジェクト側はアプリの起動と Assets だけを持つ。

## モジュール構成

| モジュール | 依存 | 置くもの |
| --- | --- | --- |
| `Core` | `Shared`（共通コア） | 共通コアの再エクスポート。全機能から使う土台 |
| `FeatureHome` | `Core` | 画面 1 つ分。機能を足すときは `Feature<名前>` を並べる |
| `AppRoot` | `FeatureHome` | 画面の組み立て。アプリ本体はこれを表示するだけ |

依存は `Core` → `Feature*` → `AppRoot` の一方向。逆流させない。

モジュール名は層を接頭辞に持たせている。名前の変更は全 import に波及するが、
フォルダ構成は `path:` を直すだけで済むため、フォルダは平坦のまま始めている。
モジュールが 10 個を超えたら階層化を見直す。

## 規約

- **`Core` 以外から `import Shared` しない。** 共通コアは `Core` 経由で使う。
  ビルドシステムでは防げない（依存に宣言していなくても `import Shared` は通ることを確認済み）ため、
  SwiftLint の custom rule `shared_import_outside_core` が error として検出する。
  共通コアを直接扱うモジュールを増やすときは、`.swiftlint.yml` の `excluded` に足す。
- 機能を足すときは `Package/Sources/Feature<名前>/` を作り、`Package.swift` に
  target と product を 1 つずつ足す。フォルダは平坦のまま。
- 並行性の既定は層で分ける。UI 層（`Feature*` / `AppRoot`）で必要になったら
  `Package.swift` の該当 target に `.defaultIsolation(MainActor.self)` を足す。
  `Core` は nonisolated のままにする（共通コアの async / AsyncSequence を
  既定でメインスレッドに寄せないため）。
- UI は SwiftUI のみ。UIKit を使う場合は必要な箇所に閉じる。
- 共通ロジックは kmp-app-template 側に置く。ここには iOS 固有のものだけ。
- **View にデータ取得を直接書かない。** 取得は `init` で注入し、引数なしの `init` が
  本番の経路を与える。`#Preview` にはスタブを渡す。View の中で呼ぶと、プレビューを
  開くたびに実 API を叩き、ネットワークが無いと描画できなくなる。

## 検証

共通コアは SPM で GitHub Releases から取得する。`~/.netrc` に `api.github.com` の
認証情報が必要。

変更したら必ず通す。通らないものは完了ではない。

```sh
make verify   # lint + ビルド
```

シミュレータを変えるときは `make verify SIMULATOR='iPhone 17'`。

テストターゲットは無い。テストを書くときは Xcode で追加し、`make verify` に
`test` を戻すこと。ターゲットが無い状態で `xcodebuild test` を呼ぶと
`There are no test bundles available to test.` で失敗する。

`Package/` のコードの警告は **Xcode.app では表示されない**。Xcode がパッケージ
ターゲットに `-suppress-warnings` を渡すためで、プロジェクト設定でも `Package.swift`
でも打ち消せない。`make` が `SWIFT_SUPPRESS_WARNINGS=NO` を渡して外しているので、
警告は `make verify` で確認する。Xcode で警告ゼロに見えても根拠にならない。

## やってはいけない

- `xcuserdata/` をコミットしない（`.gitignore` 済み。`git add -f` で足さない）
- 共通コアのバージョンを `Package.swift` 以外で指定しない（Xcode の GUI から
  リモートパッケージを足すと二重管理になる）
