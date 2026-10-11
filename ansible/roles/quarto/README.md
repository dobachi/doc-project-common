quarto
======

Quarto (https://quarto.org/) を Debian/Ubuntu に導入するロール。
upstream の GitHub Releases から .deb を取得して `apt` でインストールする
(distro 同梱版は古い/存在しないため)。

Requirements
------------

- Ansible 2.9 以上
- Debian/Ubuntu (amd64 / arm64)

Role Variables
--------------

| 変数 | 既定値 | 説明 |
| --- | --- | --- |
| `quarto_version` | `1.9.37` | 導入する Quarto のバージョン (タグから `v` を除いた値) |
| `quarto_deb_arch` | 自動判定 (`amd64` / `arm64`) | Quarto 配布物のアーキ表記 |
| `quarto_release_base_url` | `https://github.com/quarto-dev/quarto-cli/releases/download` | ダウンロード元 |
| `quarto_deb_download_dir` | `/tmp` | .deb の一時保存先 |

既にインストール済みかつ `quarto --version` が `quarto_version` と一致する
場合はダウンロード / 再インストールをスキップする (べき等性のため)。

Dependencies
------------

なし。

Example Playbook
----------------

```yaml
- hosts: localhost
  become: yes
  roles:
    - quarto
```

別バージョンを入れたい場合:

```bash
ansible-playbook doc_authoring.yml -K --tags quarto \
  -e quarto_version=1.10.3
```

Tags
----

- `quarto`: このロールのみを実行したい場合に使用

License
-------

Apache-2.0（リポジトリ直下の LICENSE）

Author Information
------------------

dobachi
