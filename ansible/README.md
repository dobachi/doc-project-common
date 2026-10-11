# ツールの導入（ansible）

文書プロジェクトのビルドに要るツール一式を入れる playbook とロール。
**Debian / Ubuntu 向け**である。ほかの OS では、下の「手で入れる場合」を見て入れる。

## 入れ方

リポジトリ直下の `install-tools.sh` が入口になる。sudo のパスワードを尋ねる。

```bash
sudo apt install ansible        # ansible が無ければ先に入れる
bash install-tools.sh           # 一式を入れる
bash install-tools.sh --tags mermaid_cli          # 一部だけ入れ直す
bash install-tools.sh -e quarto_version=1.10.3    # Quarto の版を変える
bash install-tools.sh --check   # 何が変わるかだけ見る
```

引数はそのまま `ansible-playbook` に渡る。直接呼ぶ場合は、このディレクトリで実行する
（`ansible.cfg` と `inventory` を読むため）。

```bash
cd ansible && ansible-playbook doc_authoring.yml -K
```

取り込み側のプロジェクトでは、submodule の位置から呼ぶ。

```bash
bash scripts/common/install-tools.sh
```

入れたあとは `check-env.sh` で確かめる。**コマンドがあるかどうかではなく、
そのプロジェクトのビルドに足りているか**を見る。

## 入るもの

| ロール | 入るもの | 用途 |
|:---|:---|:---|
| `quarto` | Quarto 本体（upstream の .deb） | ビルド全般 |
| `texlive` | TeX Live と日本語（luatex-ja） | PDF |
| `japanese_fonts` | 日本語フォント（Noto CJK ほか） | PDF |
| `nodejs` | Node.js と npm（`n` で最新安定版） | mermaid-cli の前提 |
| `mermaid_cli` | `@mermaid-js/mermaid-cli`（`mmdc`）と、Chromium の実行に要るライブラリ | Mermaid → SVG |
| `svg_pdf_tools` | `rsvg-convert`、poppler-utils | SVG → PDF、PDF → テキスト |

順序に意味がある。`mermaid_cli` は npm を使うので、`nodejs` の後に置く。
各ロールの変数は、それぞれの `README.md` と `defaults/main.yml` にある。

## 注意

- **`quarto install tinytex` を併用しないこと。** TeX の導入経路が二重になり、
  パッケージ探索とフォント解決が食い違う。「このマシンでは通るが別マシンで落ちる」の元になる。
- `nodejs` ロールは版を固定していない。mermaid-cli は node の版に敏感なので、
  動かなくなったらまずここを疑う。
- `nodejs` ロールは、apt の nodejs を入れてから `n` で入れ直し、apt のものを外す。
  apt の nodejs を別の用途で使っているマシンでは、`--skip-tags nodejs` を付けて自分で入れる。

## 手で入れる場合（Debian / Ubuntu 以外、または ansible を使わない場合）

次のものが PATH にあればよい。版は固定していない。入れたら `check-env.sh` で確かめる。

| 要るもの | 確かめ方 | 入手先 |
|:---|:---|:---|
| Quarto | `quarto --version` | <https://quarto.org/docs/get-started/> |
| Node.js と npm | `node --version` | <https://nodejs.org/> |
| mermaid-cli | `mmdc --version` | `npm install -g @mermaid-js/mermaid-cli` |
| LuaLaTeX と luatex-ja（PDF を出す場合） | `lualatex --version` | TeX Live <https://tug.org/texlive/>（macOS は MacTeX） |
| Noto Sans CJK JP / Noto Serif CJK JP（PDF を出す場合） | `fc-list \| grep "Noto Sans CJK JP"` | <https://fonts.google.com/noto> |
| rsvg-convert（PDF に SVG を入れる場合） | `rsvg-convert --version` | librsvg（macOS は `brew install librsvg`） |
| pdftotext（任意。逐語照合に使う） | `pdftotext -v` | poppler（macOS は `brew install poppler`） |

HTML だけを出すなら、上の三つ（Quarto、Node.js、mermaid-cli）で足りる。

## ライセンス

Apache-2.0（リポジトリ直下の `LICENSE`）。
