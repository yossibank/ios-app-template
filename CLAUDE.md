# ios-app-template

iOS アプリ。SwiftUI の 1 画面のみの最小構成。

## 検証

共通コアは SPM で GitHub Packages から取得する。`~/.netrc` に maven.pkg.github.com の
認証情報が必要（GitHub Packages は public リポジトリでも読み取りにトークンを要求する）。

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
