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

- **Feature から直接 `import Shared` しない。** 共通コアは `Core` 経由で使う。
  ビルドシステムでは防げない（依存に宣言していなくても `import Shared` は通ることを確認済み）ため、
  規約として守る。
- 機能を足すときは `Package/Sources/Feature<名前>/` を作り、`Package.swift` に
  target と product を 1 つずつ足す。フォルダは平坦のまま。
- UI は SwiftUI のみ。UIKit を使う場合は必要な箇所に閉じる。
- 共通ロジックは kmp-app-template 側に置く。ここには iOS 固有のものだけ。

## 検証

共通コアは SPM で GitHub Releases から取得する。`~/.netrc` に `api.github.com` の
認証情報が必要。

変更したら必ず通す。通らないものは完了ではない。

```sh
make verify   # lint + ビルド + ユニットテスト
```

シミュレータを変えるときは `make verify SIMULATOR='iPhone 17'`。

## やってはいけない

- `xcuserdata/` をコミットしない（`.gitignore` 済み。`git add -f` で足さない）
- 共通コアのバージョンを `Package.swift` 以外で指定しない（Xcode の GUI から
  リモートパッケージを足すと二重管理になる）
