#!/usr/bin/env bash
# 文書プロジェクトに要るツール一式を、このマシンに入れる（Debian / Ubuntu 向け）。
#
#   bash install-tools.sh                 一式を入れる（sudo のパスワードを尋ねる）
#   bash install-tools.sh --tags quarto   一部だけ入れ直す
#   bash install-tools.sh --check         何が変わるかだけ見る
#
# 引数はそのまま ansible-playbook に渡す。入るものは ansible/doc_authoring.yml を参照。
# ほかの OS では使えない。ansible/README.md の「手で入れる場合」を見ること。
set -u

here="$(cd "$(dirname "$0")" && pwd)"

if [ ! -f /etc/debian_version ]; then
  echo "Debian / Ubuntu ではないため、このスクリプトでは入れられない。" >&2
  echo "必要なツールの一覧: $here/ansible/README.md" >&2
  exit 1
fi
if ! command -v ansible-playbook >/dev/null 2>&1; then
  echo "ansible-playbook が無い。先に入れること:" >&2
  echo "  sudo apt install ansible" >&2
  exit 1
fi

cd "$here/ansible" && exec ansible-playbook doc_authoring.yml -K "$@"
