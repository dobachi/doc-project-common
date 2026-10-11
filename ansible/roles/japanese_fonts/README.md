japanese_fonts
==============

OnlyOffice / LibreOffice / Inkscape / ブラウザなど、fontconfig 経由でシステム
フォントを参照するアプリで日本語が綺麗に表示・印刷できるよう、
代表的な日本語フォントを apt から一括インストールするロール。

導入後に `fc-cache -f` をハンドラ経由で実行し、フォント DB を更新する。

Installed fonts
---------------

| パッケージ                   | 用途                                              |
| ---------------------------- | ------------------------------------------------- |
| `fonts-noto-cjk` / `-extra`  | Noto Sans CJK JP / Noto Serif CJK JP (推奨既定)    |
| `fonts-ipafont` (Mincho/Gothic) | 公的書類でよく要求される IPA フォント (JIS X 0208) |
| `fonts-ipaexfont` (Mincho/Gothic) | IPAex (プロポーショナル詰めが改善された改訂版)    |
| `fonts-takao` / `-mincho` / `-gothic` / `-pgothic` | MS Mincho / MS Gothic の代替として扱いやすい      |
| `fonts-vlgothic`             | VLGothic (古くから使われている等幅ゴシック)        |
| `fonts-mplus`                | M+ (ウェイトの豊富なサンセリフ)                    |
| `fonts-hanazono`             | 花園明朝 (CJK 拡張漢字を広くカバー)                |
| `fonts-migmix`               | Migmix (M+ と IPA の合成、UI 用途)                 |

Requirements
------------

- Ansible 2.9 以上
- Debian / Ubuntu 系 (apt が使用可能であること)
- `become: yes` (パッケージインストールと `/etc/fonts/` 更新のため)

Role Variables
--------------

| 変数                       | 既定値        | 説明                                |
| -------------------------- | ------------- | ----------------------------------- |
| `japanese_fonts_packages`  | 上記一覧      | インストールするフォントパッケージ。`-e` で配列上書き可能 |

不要なフォントを除外したい場合の例:

```bash
ansible-playbook doc_authoring.yml -K --tags japanese_fonts \
  -e '{"japanese_fonts_packages": ["fonts-noto-cjk","fonts-ipafont","fonts-takao"]}'
```

Example Playbook
----------------

```yaml
- hosts: localhost
  become: yes
  roles:
    - japanese_fonts
```

OnlyOffice での使用について
---------------------------

OnlyOffice DesktopEditors は起動時に fontconfig 経由でシステムフォントを
走査し、内部キャッシュ (`AllFonts.js` など) を生成する。本ロール適用後の
手順:

1. このロールを実行 (`fc-cache -f` が走り、フォントが OS から見える状態になる)
2. OnlyOffice DesktopEditors を**再起動**する。フォントセレクタに
   "Noto Sans CJK JP" / "IPAex Mincho" / "Takao Gothic" などが現れる
3. それでも認識されないときは、ユーザーフォントキャッシュを削除して再起動:

   ```bash
   rm -rf ~/.config/onlyoffice/DesktopEditors/data/fonts/
   ```

   (DesktopEditors を終了した状態で実行すること)

LibreOffice / Inkscape / Firefox / Chromium などは fontconfig を直接参照する
ため、ロール実行後の `fc-cache -f` だけで反映される (アプリ再起動推奨)。

Tags
----

- `japanese_fonts`: このロールだけを実行するためのタグ

License
-------

Apache-2.0（リポジトリ直下の LICENSE）

Author Information
------------------

dobachi
