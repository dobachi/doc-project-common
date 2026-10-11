svg_pdf_tools
=============

SVG/PDF を扱うコマンドライン変換ユーティリティを apt で導入するロール。
Quarto でドキュメントをビルドするときに、図と PDF まわりで必要になる。

| コマンド | パッケージ | 用途 |
| --- | --- | --- |
| `rsvg-convert` | `librsvg2-bin` | SVG → PDF/PNG。**Quarto の PDF ビルドで SVG 図を取り込むのに必須。無いと図が欠落する** |
| `pdftotext` / `pdftoppm` / `pdfinfo` | `poppler-utils` | PDF からテキスト・画像を取り出す。引用元 PDF との逐語照合、生成 PDF の目視確認 |

Requirements
------------

- Ansible 2.9 以上
- Debian/Ubuntu

Role Variables
--------------

| 変数 | 既定値 | 説明 |
| --- | --- | --- |
| `svg_pdf_tools_packages` | `[librsvg2-bin, poppler-utils]` | 導入するパッケージ |

Dependencies
------------

なし。

Example Playbook
----------------

```yaml
- hosts: localhost
  become: yes
  roles:
    - svg_pdf_tools
```

まとめて入れる場合は `ansible/doc_authoring.yml` を使う。

### 注意: Mermaid の図を PDF に載せる場合

`rsvg-convert` は SVG 内の `<foreignObject>` を描画できない。Mermaid が
既定で出力する HTML ラベル (`htmlLabels: true`) はこれを使うため、
**PDF ビルドで図中の文字が丸ごと消える**。Mermaid 側の設定で
`htmlLabels: false` にしておくこと。ツールをまたぐ制約なので、
どちらの README を読んでも気づけない部類の罠にあたる。

Tags
----

- `svg_pdf_tools`: このロールのみを実行したい場合に使用

License
-------

Apache-2.0（リポジトリ直下の LICENSE）

Author Information
------------------

dobachi
