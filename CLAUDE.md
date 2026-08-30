# ios-app-template

iOS アプリ。SwiftUI の 1 画面のみの最小構成。

## 検証

clone 直後と kmp-app-template を変更した後は `make bootstrap`（XCFramework の生成）を先に実行する。
共通コアは現在ローカル参照で、`../kmp-app-template` に checkout されている前提。

変更したら必ず通す。通らないものは完了ではない。

```sh
make verify   # ビルド + ユニットテスト
make test-ui  # UI テストも実行する（時間がかかるので必要なときだけ）
```

シミュレータを変えるときは `make verify SIMULATOR='iPhone 17'`。

## 規約

- UI は SwiftUI のみ。UIKit を使う場合は必要な箇所に閉じる。
- 共通ロジックは kmp-app-template 側に置く。ここには iOS 固有のものだけ。

## やってはいけない

- `xcuserdata/` をコミットしない（`.gitignore` 済み。`git add -f` で足さない）
