# ios-app-template

iOS アプリ。画面とロジックは `Package/` のローカル SPM パッケージに置き、
Xcode プロジェクト側はアプリの起動と Assets だけを持つ。

## モジュール構成

| モジュール | 依存 | 置くもの |
| --- | --- | --- |
| `ScreenCore` | なし | 画面の土台。`ViewModel` / `ViewState` / `ScreenViewModel` / `ScreenState` / `ScreenPhase` / `ScreenView` / `PhaseView` / `PhaseViewStyle` / `ScreenReloadAction` / `ObservationCheck` |
| `SharedCore` | `Shared`（共通コア） | 共通コアの再エクスポートと `Sendable` の表明。中身はこれだけ |
| `FeatureHome` | `ScreenCore`, `SharedCore` | 画面 1 つ分。機能を足すときは `Feature<名前>` を並べる |
| `AppRoot` | `FeatureHome` | 画面の組み立て。アプリ本体はこれを表示するだけ |

依存は `*Core` → `Feature*` → `AppRoot` の一方向。逆流させない。
**`ScreenCore` と `SharedCore` は兄弟で、互いに依存しない。** 画面の土台は純粋な
Swift / SwiftUI で書き、共通コアに依存させない。

モジュール名は層を接頭辞に持たせている。名前の変更は全 import に波及するが、
フォルダ構成は `path:` を直すだけで済むため、フォルダは平坦のまま始めている。
モジュールが 10 個を超えたら階層化を見直す。

## 規約

- **`SharedCore` 以外から `import Shared` しない。** 共通コアは `SharedCore` 経由で使う。
  ビルドシステムでは防げない（依存に宣言していなくても `import Shared` は通ることを確認済み）ため、
  SwiftLint の custom rule `shared_import_outside_core` が error として検出する。
  共通コアを直接扱うモジュールを増やすときは、`.swiftlint.yml` の `excluded` に足す。
- 機能を足すときは `Package/Sources/Feature<名前>/` を作り、`Package.swift` に
  target と product を 1 つずつ足す。フォルダは平坦のまま。
- 並行性は型に `@MainActor` を明示する。`Package.swift` の
  `.defaultIsolation(MainActor.self)` は使わない。影響範囲が target 全体に及び、
  `ScreenCore` の非 UI コードまでメインスレッドに寄るため。`ScreenViewModel` と
  その準拠型が `@MainActor`。
- UI は SwiftUI のみ。UIKit を使う場合は必要な箇所に閉じる。
- 共通ロジックは kmp-app-template 側に置く。ここには iOS 固有のものだけ。
- **画面のオブジェクトは `ViewModel` に準拠させる。** 要求は `state`（`ViewState`）・
  `dependency`・`init(dependency:)` の 3 つ。取得がある画面はさらに `ScreenViewModel` に
  準拠し、`screen`（`ScreenState`）と `fetch()` を足す。**取得の有無で入口を分けない。**
  画面固有の状態が無ければ `State` の宣言を省略できる（既定が `EmptyViewState`）。
  ただし既存データを表示したまま更新する画面やページ追加取得は別の状態設計が要る。
- **依存は `Dependency` に 1 つだけ持たせる。** 画面ごとに `struct Dependency` を定義し、
  `init(dependency:)` で注入する。テストとプレビューの差し替え口をここに固定する。
  swift-dependencies のような仕組みは使わない。公式の判断基準どおり、依存が少なく
  明示的な伝播が許容できるうちは素のコンストラクタ注入で足りる。時計や UUID のような
  環境依存が出てきたら再検討する。`PokemonApi()` の生成は 1 個あたり 0.03 ms なので
  遅延生成は要らない（実測で確認済み）。
- **`fetch()` には取得内容と共通コアの結果からの変換だけを書く。** 要求 ID の照合・
  キャンセル判定・`catch` は `ScreenState` が持つので各画面に書かない。表示したい
  失敗メッセージがあるときは `ScreenFailure` を throw する。
- **View から再取得するときは `\.screenReload`。** `ScreenView` が実行経路にだけ実体を流し込み、
  `.snapshot` では何もしない。`load()` / `reload()` / `ScreenState.run` / `requestReload` /
  `reloadID` は `internal` のまま。`load()` を `public` にすると、実装者が `fetch()` と
  取り違えて `load()` を実装でき、しかもジェネリック文脈からは extension 側が呼ばれるため、
  **要求 ID 照合とキャンセル処理が無警告で失われる**（実測で確認済み）。
- **`ScreenSource` から ViewModel を取り出さない。** 親が再評価されるたびに既定引数が
  新しいインスタンスを作るため、`LiveScreen` が `@State` で保持している実体とは
  別物を掴む（親 3 回の再評価でインスタンスが 4 個作られ、画面が使っていたのは
  1 個目であることを実測で確認済み）。View が触れるのは `ScreenView` が渡す
  `State` と `Value`、および `\.screenReload` だけ。
- **`ViewModel` と `ViewState` には無条件で `@Observable` を付ける。**「状態を足すときだけ」に
  しない。付け忘れると View が更新されないまま無言で壊れる（body が初回 1 回しか評価されず
  画面が固着することを実測で確認済み）。**型システムでは強制できない。** `Observable` は
  要求を持たないマーカーなので継承させてもマクロ無しで通り、基底クラスに付けても
  サブクラスの追加プロパティには届かない（いずれも実測で確認済み）。代わりに
  `ObservationCheck` が DEBUG 時に `Mirror` でマクロ生成物の有無を検査し、無ければ型名つきで
  `assert` する。**SwiftLint では守れない**——入れ子の型では「どの宣言に付いた属性か」を
  近接では判定できないため（実際に検出できないことを確認済み）。
- **取得状態は `ScreenPhase` で表す。** `isLoading` と `error` を別々の変数にすると、
  両方が立った状態が型として表現できてしまう。失敗は `any Error` を保つので、
  認証切れとネットワーク断で表示を変える必要が出ても全画面に波及しない。
- **`.idle` は「まだ取得を始めていない」。`ScreenState` の初期値。**
  `.loading` を初期値にすると、取得が始まっていない間も「取得中」を名乗る。
  **見た目は `.loading` と同じにしてある。** live 経路では `.task` が走る前に `.idle` が
  描画されるため（`idle → idle → loading → loaded` の順を実測で確認済み）、別の見た目を
  与えると全画面で読み込み表示の前に挟まる。取得を利用者の操作まで待つ画面が出てきたら、
  そのときに `PhaseViewStyle` へ `idle` を足して分ける。
- **画面の表示は `ScreenView` に渡す。** 実行する `.live` と状態だけの `.snapshot` を UI 側で
  明示的に分ける。`.task(id:)` と再試行の接続は `ScreenView` が持つので画面に書かない。
  `Button` の中で作った `Task` は View が消えても自動では止まらないため、非同期処理を
  画面のライフサイクルから外さないこと。
- **読み込み中と失敗の見た目は `PhaseView` と `PhaseViewStyle`。** 各画面が書くのは成功時だけ。
  変えたい範囲に `.phaseViewStyle(_:)` を付ける。`ButtonStyle` と同じ作法で、差し替えは
  modifier を付けた階層に閉じる。**画面ごとに独自の失敗表示を直接書かない。**
- **`#Preview` は `.snapshot` を渡す。** `.snapshot` 経路には ViewModel も API も取得タスクも
  存在しない（`HomeViewModel.init` が 0 回であることを実測で確認済み）。`State` は
  `ScreenView` が内部で作るので、プレビュー側は状態を渡すだけでよい。固定表示なので
  再試行ボタンと `\.screenReload` は何もしない。動作確認は実行経路で別途行う。
- **Kotlin/Native の型への `Sendable` 表明は `SharedCore.swift` にだけ置く。**
  `@MainActor` の ViewModel が共通コアの型を保持して async メソッドを呼ぶと
  `sending 'self.api' risks causing data races` で弾かれる。表明を各所に散らさない。
- **`State` を struct にまとめない。`@Observable` な class にする。** `@Observable` は
  プロパティ単位で追跡するので、struct にまとめると 1 プロパティ扱いになり無関係な変更で
  View が再評価される。`a` だけ読む View が `b` の変更 4 回すべてで再評価された（body 5 回）。
  class なら 1 回のままであることを実測で確認済み。
- **View 固有の見た目（フォーカス・スクロール位置・アニメーション）は View の
  `@State` に置く。** ViewModel に入れない。

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
