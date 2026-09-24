# ios-app-template

iOS アプリのテンプレート。共通ロジックは [kmp-app-template](https://github.com/yossibank/kmp-app-template) から取得する。
Android 版は [android-app-template](https://github.com/yossibank/android-app-template)。

## 準備

- `~/.netrc` に `api.github.com` の資格情報を置く（共通コアの取得に必要）
- `make bootstrap` で SwiftFormat / SwiftLint を用意する

## 使い方

- `make open` で `AppTemplate.xcworkspace` を開く
- 変更したら `make verify`
