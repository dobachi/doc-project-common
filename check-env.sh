#!/usr/bin/env bash
# 環境チェック。不足しているものを列挙し、終了コードで返す。
# 使い方: make check-env   （または bash scripts/check-env.sh）
#
# ---------------------------------------------------------------------------
# このファイルは共通リポジトリ doc-project-common の一部で、各プロジェクトへは
# submodule として scripts/common に取り込まれる。
#   正本: https://github.com/dobachi/doc-project-common
#   更新: git submodule update --remote scripts/common
# 取り込み先で編集しても上流には戻らない。直すときは正本を直すこと。
# プロジェクト固有の事情は scripts/env.conf に書く（下記）。
# ---------------------------------------------------------------------------
#
# 何を必須とするかはリポジトリの中身から判定するので、通常は設定不要:
#   - _quarto.yml が pdf を宣言していれば TeX とフォントを必須にする
#     （宣言が無くても Makefile に pdf 系ターゲットがあれば WARN で知らせる）
#   - mermaid-cli は常に見る（標準ツール）。Makefile に figures ターゲットが
#     あればビルドが実際に呼ぶので必須へ、無ければ WARN に留める
#   - images/ に SVG があり PDF を出すなら rsvg-convert を必須にする
#
# 判定で拾えないものは scripts/env.conf に宣言する（無ければ置かなくてよい）:
#
#   # 追加で要るコマンド
#   TOOLS=(
#     "pandoc|required|変換に使う"
#     "typst|optional|試験的に併用"
#   )
#   # git 管理外で人手で配置する資材
#   ASSETS=(
#     "_sources|required|無いと何ができないか|（任意）在るときの注記"
#   )
#   # python モジュール
#   PY_MODULES=("pptx|pptx を読む場合のみ")
#
# env.conf は各プロジェクトのリポジトリに置く。社内固有・非公開の事情は
# ここではなく env.conf 側に書くこと（このファイルは公開テンプレートに載る）。
set -uo pipefail
# submodule として scripts/common に置かれる前提で、プロジェクトの根へ移動する。
# 単体で置く場合は PROJECT_ROOT を渡して上書きできる。
cd "${PROJECT_ROOT:-$(dirname "$0")/../..}"

ng=0
ok()   { printf "  \033[32mOK\033[0m   %-26s %s\n" "$1" "${2:-}"; }
warn() { printf "  \033[33mWARN\033[0m %-26s %s\n" "$1" "${2:-}"; }
bad()  { printf "  \033[31mNG\033[0m   %-26s %s\n" "$1" "${2:-}"; ng=$((ng+1)); }

# ツールの導入はマシン単位で ansible に寄せてある（このリポジトリの ansible/）。
#   bash scripts/common/install-tools.sh        Debian / Ubuntu
# ほかの OS は ansible/README.md の「手で入れる場合」を見て入れる。
FIX="bash scripts/common/install-tools.sh で入る（Debian / Ubuntu 以外は scripts/common/ansible/README.md の一覧）"

# --- 何が必要かを判定する ---------------------------------------------------
uses_mmdc=no
grep -qE '^figures:' Makefile 2>/dev/null && uses_mmdc=yes

have_svg=no
[ -n "$(find images -name '*.svg' -print -quit 2>/dev/null)" ] && have_svg=yes

pdf_declared=no
grep -qE '^[[:space:]]+pdf:' _quarto.yml 2>/dev/null && pdf_declared=yes

pdf_target=no
grep -qE '^[a-z-]*pdf:' Makefile 2>/dev/null && pdf_target=yes

# PDF を宣言していれば必須、Makefile にターゲットがあるだけなら注意喚起に留める
pdf_ng() { if [ "$pdf_declared" = yes ]; then bad "$@"; else warn "$@"; fi; }

# プロジェクト固有の宣言（任意）
TOOLS=(); ASSETS=(); PY_MODULES=()
# shellcheck disable=SC1091
[ -f scripts/env.conf ] && . scripts/env.conf

# --- mmdc は同名の別物が存在する -------------------------------------------
# PyPI の mermaid_cli（Python 版、別プロジェクト）を pip で入れると
# ~/.local/bin/mmdc ができ、PATH の優先順によっては
# @mermaid-js/mermaid-cli（Node 版、こちらが正）を覆い隠す。
# 存在確認では見抜けないので版の表記で見分ける。
#   正   : "11.9.0"              数字のみ
#   別物 : "mmdc, version 0.1.2"  語を含む
check_mermaid() {
  local sev="$1" raw num major
  if ! command -v mmdc >/dev/null; then
    "$sev" mermaid-cli "$FIX"
    return
  fi
  raw="$(mmdc --version 2>/dev/null | head -1)"
  num="${raw##* }"
  major="${num%%.*}"
  case "$raw" in
    *[!0-9.]*)
      "$sev" mermaid-cli "$(command -v mmdc) は @mermaid-js/mermaid-cli ではない（\"$raw\"）。PATH の優先順を確認。$FIX"
      return ;;
  esac
  case "$major" in
    ''|*[!0-9]*) "$sev" mermaid-cli "版を判定できない（\"$raw\"）"; return ;;
  esac
  if [ "$major" -ge 10 ]; then
    ok mermaid-cli "$num"
  else
    "$sev" mermaid-cli "版が古い（$num）。11 系を想定している。$FIX"
  fi
}

echo "== 必須（HTML ビルド） =="
command -v quarto >/dev/null && ok quarto "$(quarto --version)" || bad quarto "$FIX"
command -v make   >/dev/null && ok make || bad make
command -v git    >/dev/null && ok git  || bad git

# mermaid-cli は doc_authoring.yml に含まれる標準ツールなので常に見る。
# ビルドが実際に呼ぶ（figures ターゲットがある）場合だけ必須に格上げする。
if [ "$uses_mmdc" = yes ]; then
  command -v node >/dev/null && ok node "$(node --version)" || bad node "mermaid-cli に必要。$FIX"
  check_mermaid bad
else
  check_mermaid warn
fi

if [ "$pdf_declared" = yes ] || [ "$pdf_target" = yes ]; then
  echo
  if [ "$pdf_declared" = yes ]; then
    echo "== 必須（PDF ビルド。_quarto.yml が pdf を宣言している） =="
  else
    echo "== 任意（_quarto.yml に pdf の宣言は無い。PDF を出す場合のみ） =="
  fi
  command -v lualatex >/dev/null && ok lualatex "$(lualatex --version 2>/dev/null | head -1)" \
    || pdf_ng lualatex "$FIX（quarto install tinytex は併用しないこと）"
  if [ "$have_svg" = yes ]; then
    command -v rsvg-convert >/dev/null && ok rsvg-convert "$(rsvg-convert --version 2>/dev/null)" \
      || pdf_ng rsvg-convert "SVG 図の PDF 変換に必須。$FIX"
  fi
  if command -v fc-list >/dev/null; then
    n=$(fc-list 2>/dev/null | grep -ci "Noto Sans CJK JP" || true)
    if [ "${n:-0}" -gt 0 ]; then ok "Noto Sans CJK JP" "${n} faces"; else pdf_ng "Noto Sans CJK JP" "$FIX"; fi
  else
    warn fc-list "フォント確認をスキップ"
  fi
fi

# --- env.conf の宣言 --------------------------------------------------------
if [ ${#TOOLS[@]} -gt 0 ]; then
  echo
  echo "== このプロジェクト固有のツール（scripts/env.conf） =="
  for spec in "${TOOLS[@]}"; do
    IFS='|' read -r cmd sev note <<<"$spec"
    if command -v "$cmd" >/dev/null; then
      ok "$cmd" "$note"
    elif [ "$sev" = required ]; then
      bad "$cmd" "$note"
    else
      warn "$cmd" "$note"
    fi
  done
fi

if [ ${#ASSETS[@]} -gt 0 ]; then
  echo
  echo "== 資材（git 管理外。人手で配置する。SETUP.md 参照） =="
  for spec in "${ASSETS[@]}"; do
    IFS='|' read -r path sev impact note <<<"$spec"
    if [ -e "$path" ]; then
      ok "$path" "$(find "$path" -type f 2>/dev/null | wc -l) ファイル${note:+ （$note）}"
    elif [ "$sev" = required ]; then
      bad "$path" "$impact"
    else
      warn "$path" "$impact"
    fi
  done
  echo
  command -v pdftotext >/dev/null && ok pdftotext "逐語照合に使う" \
    || warn pdftotext "逐語照合に使う。$FIX"
fi

if [ ${#PY_MODULES[@]} -gt 0 ]; then
  echo
  echo "== python モジュール（scripts/env.conf） =="
  for spec in "${PY_MODULES[@]}"; do
    IFS='|' read -r mod note <<<"$spec"
    python3 -c "import $mod" 2>/dev/null && ok "python:$mod" "$note" \
      || warn "python:$mod" "pip install $mod（$note）"
  done
fi

echo
if [ "$ng" -eq 0 ]; then
  echo "必須の不足なし。ビルドを実行できる。"
else
  echo "必須が ${ng} 件不足している。上の NG を解消すること。"
fi
exit "$ng"
