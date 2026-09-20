# ios-app-template

> iOS アプリの初期テンプレート。画面とロジックはローカル SPM パッケージに分割している。

書き方の規約は [CLAUDE.md](CLAUDE.md)。

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
    SHAREDCORE["SharedCore"]
    SCREENCORE["ScreenCore"]
    HOME["FeatureHome"]
    ROOT["AppRoot"]
    APP["AppTemplate.app"]
    SHARED --> SHAREDCORE --> HOME
    SCREENCORE --> HOME
    HOME --> ROOT --> APP
```

| モジュール | 役割 |
| --- | --- |
| `ScreenCore` | 画面の土台。共通コアに依存しない |
| `SharedCore` | 共通コアの入口。`Shared` を import してよいのはここだけ |
| `FeatureHome` | 画面 1 つ分。機能ごとに `Feature<名前>` を並べる |
| `AppRoot` | 画面の組み立て |
| アプリターゲット | 起動と Assets のみ |

## ディレクトリ

```
AppTemplate.xcworkspace     # 入口
App/
├── AppTemplate.xcodeproj
└── AppTemplate/           # @main と Assets
Package/
├── Package.swift          # 依存とモジュールの宣言（共通コアのバージョンもここ）
├── Sources/
│   ├── ScreenCore/        # ViewModel/ Fetch/ Screen/ Resources/
│   ├── SharedCore/
│   ├── FeatureHome/       # 画面と Resources/
│   └── AppRoot/
└── Tests/
    ├── ScreenCoreTests/
    └── FeatureHomeTests/
```

**入口は `.xcodeproj` ではなく `.xcworkspace`。**

## コマンド

| コマンド | 内容 |
| --- | --- |
| `make open` | Xcode で `AppTemplate.xcworkspace` を開く |
| `make bootstrap` | `Mintfile` の版で SwiftFormat / SwiftLint を用意する |
| `make verify` | lint + ユニットテスト + ビルド（変更後はこれを通す） |
| `make verify SIMULATOR='iPhone 17'` | シミュレータを指定して実行 |
| `make build` | ビルドのみ |
| `make test` | ユニットテストのみ |
| `make lint` | SwiftFormat / SwiftLint によるチェック（`make verify` に含まれる） |
| `make format` | SwiftFormat / SwiftLint で自動修正 |

## 環境

バージョンはここに書き写さない。写した値は必ず古くなる。

| 項目 | 出所 |
| --- | --- |
| Swift 言語モード・Deployment Target | [project.pbxproj](App/AppTemplate.xcodeproj/project.pbxproj) の `SWIFT_VERSION` / `IPHONEOS_DEPLOYMENT_TARGET` |
| Package の対象 OS・共通コア | [Package/Package.swift](Package/Package.swift) |
| SwiftFormat / SwiftLint | [Mintfile](Mintfile) |
| Xcode | リポジトリでは固定していない。CI は [verify.yml](.github/workflows/verify.yml) のランナー任せ |
| 認証 | `~/.netrc` に `api.github.com` の資格情報（共通コアの取得に必要） |
