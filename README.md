# doc-project-common

文書プロジェクト（Quarto でレポート・論文・検討資料を書くリポジトリ）が共通で使う
スクリプト置き場。各プロジェクトへは **submodule** として `scripts/common` に取り込む。

同じ内容のスクリプトを各リポジトリにコピーして回ると、いずれ版が分岐する。
実際、既存の共有スクリプト21種のうち11種が2〜4種に分岐していた。
submodule なら**取り込んだコミットが固定される**ので、意図しない分岐が起きない。

## 収録物

| ファイル | 役割 |
|:---|:---|
| `check-env.sh` | 環境チェック。不足を列挙し、終了コードで返す |
| `install-tools.sh` | ツール一式を入れる（Debian / Ubuntu 向け。中身は `ansible/`） |
| `ansible/` | ツール導入の playbook とロール。ほかの OS 向けの一覧も [`ansible/README.md`](ansible/README.md) にある |

## 契約（この3つの名前が揃っていれば、どのプロジェクトでも同じ手順になる）

1. **ツールの導入** — `bash scripts/common/install-tools.sh`（マシンごとに一度。
   Debian / Ubuntu 向け。ほかの OS は [`ansible/README.md`](ansible/README.md) の一覧を見て入れる）
2. **`make check-env`** — 揃ったかを確認する
3. **`scripts/env.conf`** — プロジェクト固有の事情を宣言する（無ければ置かない）

## 取り込み方

```bash
git submodule add https://github.com/dobachi/doc-project-common.git scripts/common
```

`Makefile` に入口を作る。**submodule が未取得でも意味の分かるエラーを出すこと**
（`git clone` に `--recursive` を付け忘れる事故が起きるため）。

```make
.PHONY: check-env
check-env:
	@if [ ! -f scripts/common/check-env.sh ]; then \
	  echo "scripts/common が未取得です。次を実行してください:"; \
	  echo "  git submodule update --init --recursive"; \
	  exit 1; \
	fi
	@bash scripts/common/check-env.sh
```

クローン時:

```bash
git clone --recursive <プロジェクトのURL>
# すでに clone 済みなら
git submodule update --init --recursive
```

更新（取り込み側で明示的に上げる。勝手には上がらない）:

```bash
git submodule update --remote scripts/common
git add scripts/common && git commit -m "scripts/common を更新"
```

## check-env.sh が見るもの

何が必要かは**リポジトリの中身から判定する**ので、通常は設定が要らない。

| 判定 | 根拠 |
|:---|:---|
| TeX とフォントが必須 | `_quarto.yml` が `pdf:` を宣言している（宣言が無く Makefile に pdf 系ターゲットがあるだけなら WARN） |
| mermaid-cli が必須 | `Makefile` に `figures` ターゲットがある（ビルドが実際に呼ぶ）。無くても標準ツールとして常に確認する |
| rsvg-convert が必須 | PDF を出す かつ `images/` に SVG がある |

判定で拾えないものは、**取り込み側の** `scripts/env.conf` に書く。

```sh
TOOLS=("pandoc|required|変換に使う")
ASSETS=("_sources|required|無いと逐語引用の再照合ができない|社外秘・引用不可")
PY_MODULES=("pptx|pptx を読む場合のみ")
```

**社内固有・非公開の事情はここ（このリポジトリ）に書かないこと。** 公開リポジトリなので、
共有ストレージのフォルダ名や資材名は取り込み側の private リポジトリに置く。

## 単体で使う

submodule を使わず任意の場所に置く場合は、プロジェクトの根を渡す。

```bash
PROJECT_ROOT=/path/to/project bash check-env.sh
```

## ライセンス

Apache-2.0
