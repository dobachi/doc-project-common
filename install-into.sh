#!/usr/bin/env bash
# doc-project-common を既存の文書プロジェクトへ取り込む。
#
#   bash install-into.sh --dry-run <プロジェクト...>   何をするかだけ出す（既定）
#   bash install-into.sh --apply   <プロジェクト...>   実際に取り込む（コミットはしない）
#   bash install-into.sh --apply --commit <...>        取り込んでコミットまでする
#
# push はしない。各リポジトリの内容を確認してから自分で push すること。
#
# やること:
#   1. submodule scripts/common を追加（既にあれば飛ばす）
#   2. Makefile に check-env ターゲットを追記（既にあれば飛ばす）
#   3. 既に同梱の scripts/check-env.sh があれば git rm する
# 未コミットの変更があるリポジトリは既定で飛ばす（--force で無視）。
set -uo pipefail

URL="https://github.com/dobachi/doc-project-common.git"
MODE=dry; DO_COMMIT=no; FORCE=no; targets=()
for a in "$@"; do
  case "$a" in
    --dry-run) MODE=dry ;;
    --apply)   MODE=apply ;;
    --commit)  DO_COMMIT=yes ;;
    --force)   FORCE=yes ;;
    -*) echo "不明なオプション: $a" >&2; exit 2 ;;
    *) targets+=("$a") ;;
  esac
done
[ ${#targets[@]} -gt 0 ] || { echo "取り込み先を指定してください" >&2; exit 2; }

MAKE_BLOCK='
# 環境チェック。不足しているツールを列挙し、終了コードで返す。
# 実体は共通リポジトリ doc-project-common（submodule: scripts/common）。
# clone に --recursive を付け忘れると未取得になるため、その場合は理由を出す。
.PHONY: check-env
check-env:
	@if [ ! -f scripts/common/check-env.sh ]; then \
	  echo "scripts/common が未取得です。次を実行してください:"; \
	  echo "  git submodule update --init --recursive"; \
	  exit 1; \
	fi
	@bash scripts/common/check-env.sh
'

say() { printf "    %s\n" "$1"; }

for d in "${targets[@]}"; do
  d="${d%/}"
  echo "== $d"
  if [ ! -d "$d/.git" ]; then say "飛ばす: git リポジトリではない"; continue; fi
  if [ ! -f "$d/Makefile" ]; then say "飛ばす: Makefile が無い"; continue; fi

  dirty="$(git -C "$d" status --porcelain | wc -l)"
  if [ "$dirty" -gt 0 ] && [ "$FORCE" = no ]; then
    say "飛ばす: 未コミットの変更が ${dirty} 件（--force で無視できる）"
    continue
  fi

  has_sub=no;  grep -q 'path = scripts/common' "$d/.gitmodules" 2>/dev/null && has_sub=yes
  has_tgt=no;  grep -qE '^check-env:' "$d/Makefile" && has_tgt=yes
  has_old=no;  [ -f "$d/scripts/check-env.sh" ] && has_old=yes

  [ "$has_sub" = yes ] && say "submodule: 既にある" || say "submodule: 追加する（scripts/common）"
  [ "$has_tgt" = yes ] && say "Makefile : check-env は既にある" || say "Makefile : check-env を追記する"
  [ "$has_old" = yes ] && say "同梱の scripts/check-env.sh: 削除する"

  # 旧い同梱スクリプトを消すのに Makefile が既にそれを指している場合、
  # ターゲットを書き換えないと「消したファイルを呼ぶ」壊れた状態になる。
  # 自動では直さず、手当てが要ることを明示して飛ばす。
  if [ "$has_old" = yes ] && [ "$has_tgt" = yes ] && \
     grep -qE '^\s+@?bash scripts/check-env\.sh' "$d/Makefile"; then
    say "飛ばす: Makefile の check-env が同梱スクリプトを指している。"
    say "        scripts/common/check-env.sh を指すよう直してから再実行すること"
    continue
  fi

  if [ "$MODE" = dry ]; then continue; fi

  ( cd "$d" || exit 1
    if [ "$has_old" = yes ]; then git rm -q scripts/check-env.sh || exit 1; fi
    if [ "$has_sub" = no ]; then git submodule add -q "$URL" scripts/common || exit 1; fi
    if [ "$has_tgt" = no ]; then
      [ -n "$(tail -c1 Makefile)" ] && printf '\n' >> Makefile
      printf '%s' "$MAKE_BLOCK" >> Makefile
    fi
    if [ "$DO_COMMIT" = yes ]; then
      git add .gitmodules scripts/common Makefile 2>/dev/null
      git commit -q -m "環境チェックを共通リポジトリの submodule で取り込む

make check-env で必要なツールが揃っているかを確認できる。実体は
doc-project-common（scripts/common）。clone に --recursive を付け忘れた場合は
理由の分かるエラーを出す。" || exit 1
    fi
  ) && say "完了" || say "失敗（手で確認すること）"
done

echo
[ "$MODE" = dry ] && echo "空実行。実際に取り込むには --apply を付ける。" \
                  || echo "取り込み済み。push は各リポジトリで内容を確認してから。"
