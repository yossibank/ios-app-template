# ios-app-template

> iOS アプリの初期テンプレート。画面とロジックはローカル SPM パッケージに分割している。

## 3 リポジトリの関係

```mermaid
flowchart LR
    KMP["kmp-app-template<br/>共通ロジック"]
    AND["android-app-template<br/>Android アプリ"]
    IOS["ios-app-template<br/>← このリポジトリ"]
    KMP -->|"AAR / klib"| AND
    KMP -->|"Shared.xcframework"| IOS
```

[android-app-template](https://github.com/yossibank/android-app-template) ・
[kmp-app-template](https://github.com/yossibank/kmp-app-template)

## モジュール構成

```mermaid
flowchart LR
    SHARED["Shared<br/><i>共通コア</i>"]
    CORE["Core"]
    HOME["FeatureHome"]
    ROOT["AppRoot"]
    APP["AppTemplate.app"]
    SHARED --> CORE --> HOME --> ROOT --> APP
```

| モジュール | 役割 |
| --- | --- |
| `Core` | 共通コアの入口。`Shared` を import してよいのはここだけ |
| `FeatureHome` | 画面 1 つ分。機能ごとに `Feature<名前>` を並べる |
| `AppRoot` | 画面の組み立て |
| アプリターゲット | 起動と Assets のみ |

`Core` 以外から `import Shared` した場合は SwiftLint が error として落とす（`shared_import_outside_core`）。

```
AppTemplate.xcworkspace     # 入口
App/
├── AppTemplate.xcodeproj
└── AppTemplate/           # @main と Assets
Package/
├── Package.swift          # 依存とモジュールの宣言（共通コアのバージョンもここ）
└── Sources/
    ├── ScreenCore/
    ├── SharedCore/
    ├── FeatureHome/
    └── AppRoot/
```

## コマンド

| コマンド | 内容 |
| --- | --- |
| `make verify` | lint + ビルド + ユニットテスト（変更後はこれを通す） |
| `make build` | ビルドのみ |
| `make verify SIMULATOR='iPhone 17'` | シミュレータを指定して実行 |
| `make lint` | SwiftFormat / SwiftLint によるチェック（`make verify` に含まれる） |
| `make format` | SwiftFormat / SwiftLint で自動修正 |

## 環境

| 項目 | バージョン |
| --- | --- |
| Xcode | 26.x |
| Swift 言語モード | 6（アプリターゲット・`Package` とも） |
| Deployment Target | iOS 26.5（`Package.swift` は `.iOS(.v26)`） |
| 認証 | `~/.netrc` に `api.github.com` の資格情報（共通コアの取得に必要） |
