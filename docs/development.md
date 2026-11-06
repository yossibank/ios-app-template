# 開発の手順

> [!NOTE]
> 初めて動かす順のコマンドを書く。
> 共通コアを取得する資格情報と、手元の共通コアへの差し替えも書く。
> 実行環境の版は [README](../README.md#-実行環境) にある。

## 🚀 動かし方

最初に、次の順にコマンドを実行する。

| 順 | コマンド | 内容 |
| --- | --- | --- |
| 1 | `make bootstrap` | SwiftFormat / SwiftLint と、コミット前に整形と lint を検査するフックを用意する |
| 2 | `make open` | `AppTemplate.xcworkspace` を開く |
| 3 | `make verify` | 変更したら通す |

## 🔧 共通コア

kmp-app-template が非公開なら、`~/.netrc` に `api.github.com` の資格情報が要る。[組み込みの手順](https://github.com/yossibank/kmp-app-template/blob/main/docs/integration.md#ios)を見る。

手元のものへの差し替えと、テンプレートから作ったときの置き換えは、README の[入れ方](../README.md#-入れ方)にある。
