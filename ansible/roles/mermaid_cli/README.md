mermaid_cli
===========

Mermaid 記法の図を SVG/PNG/PDF に変換する CLI (`mmdc`,
https://github.com/mermaid-js/mermaid-cli) を npm global で導入するロール。

Quarto のレポートで、Mermaid のソースを**事前に SVG へ変換**してから
取り込む方式を採る場合に必要になる (PDF ビルドでも図を落とさないため)。

Requirements
------------

- Ansible 2.9 以上
- Debian/Ubuntu
- **node/npm が導入済みであること**。`roles/nodejs` を先に実行する。
  未導入の場合はタスクの冒頭で明示的に失敗する。

Role Variables
--------------

| 変数 | 既定値 | 説明 |
| --- | --- | --- |
| `mermaid_cli_version` | `11.9.0` | 導入する版。空文字にすると最新版 |
| `mermaid_cli_install_chromium_deps` | `true` | Puppeteer 同梱 Chromium の実行時依存を先に入れるか |
| `mermaid_cli_chromium_packages` | 下記参照 | その依存パッケージの一覧 |

### なぜ Chromium の依存を入れるのか

`mmdc` は内部で Puppeteer (ヘッドレス Chromium) を起動して描画する。
**`npm install` は Chromium の共有ライブラリが無くても成功する**ため、
不足は「導入時」ではなく「実行時」に共有ライブラリのエラーとして初めて出る。
それを避けるために先に入れている。

`mermaid_cli_chromium_packages` の既定値は **Ubuntu 22.04 で全パッケージの
解決を確認済み**。Ubuntu 24.04 以降は t64 移行でパッケージ名が変わったものが
あり、`libasound2` のみ分岐させているが**それ以外は未検証**。解決に失敗する
場合はこの変数を上書きすること。

```bash
ansible-playbook ... -e '{"mermaid_cli_chromium_packages": ["libnss3", "..."]}'
```

Dependencies
------------

ロールとしての依存は宣言していない (`dependencies: []`)。
node/npm はプレイブック側で `nodejs` を先に並べて解決する。

Example Playbook
----------------

```yaml
- hosts: localhost
  become: yes
  roles:
    - nodejs
    - mermaid_cli
```

まとめて入れる場合は `ansible/doc_authoring.yml` を使う。

導入後の確認 (実際に変換できるかまで見る):

```bash
printf 'graph LR\n  A[入力] --> B[出力]\n' > /tmp/t.mmd
mmdc -i /tmp/t.mmd -o /tmp/t.svg && grep -q '<text' /tmp/t.svg && echo OK
```

`mmdc --version` が通るだけでは不十分で、上のように**実際に SVG を吐かせて
文字が入っているか**まで見ないと、Chromium 側の不足を見落とす。

### 罠: `mmdc` という名前のコマンドは複数ある

PyPI にも `mermaid_cli` という**別物の Python パッケージ**があり、
`pip install` すると `~/.local/bin/mmdc` ができる。PATH の優先順によっては
このロールが `/usr/local/bin` に入れる本物を**覆い隠す**。
ロール側では利用者の PATH を直せないので、入れた後に確認すること。

```bash
command -v mmdc          # /usr/local/bin/mmdc であること
mmdc --version           # "11.9.0" のように数字だけ出れば本物
                         # "mmdc, version 0.1.2" のように語が混じったら別物
```

Tags
----

- `mermaid_cli`: このロールのみを実行したい場合に使用

License
-------

Apache-2.0（リポジトリ直下の LICENSE）

Author Information
------------------

dobachi
