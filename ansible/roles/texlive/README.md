texlive
=========

Debian/Ubuntu 系で英語・日本語論文執筆向けの TeX Live 環境を apt で構築します。
upstream の `install-tl` は使わず、distro 同梱版に統一しています
(Ubuntu 26 同梱の TeX Live 2024 系で実用上十分なため)。

含まれるもの
------------

- 一般 LaTeX: `texlive-latex-recommended`, `texlive-latex-extra`,
  `texlive-fonts-recommended`, `texlive-fonts-extra`
- 論文向け: `texlive-bibtex-extra`, `biber`, `texlive-publishers`
  (IEEE / ACM / Springer 等のクラス), `texlive-science`, `texlive-pictures`
- モダンエンジン: `texlive-luatex`, `texlive-xetex`
- ビルド/補助: `latexmk`, `texlive-extra-utils` (`latexindent`, `pdfcrop`等)
- 日本語 (任意): `texlive-lang-japanese`, `fonts-noto-cjk`,
  `fonts-noto-cjk-extra`, `kanji-config-updmap-sys` でシステム既定フォント設定

Requirements
------------

- Ansible 2.9 以上
- Debian / Ubuntu 系 (apt)
- `become: yes` (apt とフォント設定で root 必須)

Role Variables
--------------

| 変数 | デフォルト | 説明 |
| --- | --- | --- |
| `texlive_base_packages` | (英語フルセット) | 一般 LaTeX パッケージ群 |
| `texlive_install_japanese` | `true` | 日本語パッケージ群を入れるか |
| `texlive_japanese_packages` | (`texlive-lang-japanese` 他) | 日本語パッケージ群 |
| `texlive_configure_japanese_font` | `true` | `kanji-config-updmap-sys` で和文フォント既定値を設定するか |
| `texlive_japanese_font_preset` | `noto-otc` | フォントプリセット (`ipaex` / `noto-otc` / `hiragino-pron` 等) |
| `texlive_japanese_font_variant` | `jis2004` | JIS 規格バリアント (`jis2004` / `jis90`) |
| `texlive_install_user_latexmkrc` | `true` | 実行ユーザのホームに `~/.latexmkrc` を配るか |
| `texlive_target_user` | `SUDO_USER` 自動検出 | 配備先ユーザ (リモート/別ユーザ向け配布時は明示) |
| `texlive_target_home` | `ansible_home` or `/home/<user>` | 配備先ホーム (`register_home` ロールが先に走っていればそちらの値) |

`~/.latexmkrc` は **既存ファイルがあれば上書きしません** (`force: false`)。
内容は `latexmk` を `uplatex -> dvipdfmx` (日本語論文の標準ルート) に
切替えるだけのミニマルなものなので、必要に応じてユーザ側で編集してください。

Dependencies
------------

None. (任意で `ipafont` ロールを併用すると IPA フォントも入るので
`texlive_japanese_font_preset: ipaex` に切替可能)

Example Playbook
----------------

```yaml
- hosts: servers
  become: yes
  roles:
    - texlive
```

英語のみ (日本語不要) で軽く済ませたい場合:

```yaml
- hosts: servers
  become: yes
  roles:
    - role: texlive
      vars:
        texlive_install_japanese: false
```

IPA フォントを既定にしたい場合:

```yaml
- hosts: servers
  become: yes
  roles:
    - role: texlive
      vars:
        texlive_japanese_font_preset: ipaex
```

Tags
----

- `texlive`: Apply this tag to run only this role

License
-------

Apache-2.0（リポジトリ直下の LICENSE）

Author Information
------------------

dobachi
