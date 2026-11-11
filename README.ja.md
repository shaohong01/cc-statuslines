# cc-statuslines

[繁體中文](README.md) | [简体中文](README.zh-CN.md) | [English](README.en.md) | **日本語**

Claude Code 用のカスタム status line スタイル集です。対話式インストーラーがスタイルを一覧表示し、お使いのターミナルでそのままプレビューして、選んだものをインストールします。

```
 Opus  xhigh   412k / 1.0M · 41%   1% · 6d12h 
└─ model + effort ─┘ └─ context 使用量 ─┘ └─ 週間使用量 · リセット ─┘
```

## 必要なもの

- [Claude Code](https://code.claude.com/docs/en/statusline)
- `jq`（macOS：`brew install jq`）
- 24 ビット True Color 対応のターミナル
- Nerd Font（任意。角丸のピル表示に必要で、なければ四角いブロック表示に切り替えられます）

## インストール

```bash
gh repo clone shaohong01/cc-statuslines ~/.cc-statuslines
~/.cc-statuslines/install.sh --lang ja
```

インストーラーがすべてのスタイルを実際の色付きプレビューとともに表示します。番号を入力するとインストールされ、Claude Code のセッションを開き直すと反映されます。

メニューを使わず、スタイルを直接指定することもできます。

```bash
~/.cc-statuslines/install.sh pills-duo
```

## スタイル

| スタイル | 説明 |
|---|---|
| `pills-duo` | ツートーンのピル：model と effort を 1 つにまとめ、context 使用量は別のピル、週間使用量とリセットまでの残り時間は白いピルで表示。effort と context はレベルと使用量に応じて緑・黄・赤に、週間使用量の文字は青・黄・赤に変わります |

## コマンド

| コマンド | 動作 |
|---|---|
| `install.sh` | 対話式メニュー：スタイルの選択、言語の切り替え、削除 |
| `install.sh <スタイル>` | 指定したスタイルをインストール、または切り替え |
| `install.sh --list` | すべてのスタイルとプレビューを表示 |
| `install.sh --preview <スタイル>` | 各状態での表示をプレビュー |
| `install.sh --uninstall` | status line の設定を削除 |
| `install.sh --lang <言語>` | インストーラーの言語を切り替え：`zh-TW`（既定）、`zh-CN`、`en`、`ja` |

## 個人設定

インストール時に `~/.claude/statusline.conf` が作成されます。調整はここに書いておけば、リポジトリを更新しても上書きされません。

| 設定 | 既定値 | 説明 |
|---|---|---|
| `ROUND` | `1` | `1` は角丸のピル（Nerd Font が必要）、`0` は四角いブロック |
| `JOIN` | `round` | model と effort の境目。`round` は丸く重ねる、`flat` はまっすぐ区切る |
| `WARN` | `50` | context 使用量がこの割合に達すると黄色になります |
| `CRIT` | `80` | context 使用量がこの割合に達すると赤になります |
| `WK_WARN` | `70` | 週間使用量がこの割合に達すると文字が黄色になります |
| `WK_CRIT` | `85` | 週間使用量がこの割合に達すると文字が赤になります |

保存すると、status line の次回更新時に反映されます。

## 更新

```bash
git -C ~/.cc-statuslines pull
```

インストールされるのはリポジトリへのリンクなので、pull するだけで最新になります。

## インストーラーが行うこと

- `~/.claude/statusline.sh` を、選んだスタイルへのリンクとして作成します。
- `~/.claude/settings.json` に `statusLine` の設定を書き込みます。ほかの設定はそのまま残ります。
- 初回インストール時は、変更前に `settings.json` を `settings.json.bak-<日時>` としてバックアップします。その後のスタイル切り替えはリンクを付け替えるだけなので、`settings.json` は変更されず、バックアップも増えません。
- 自作の `statusline.sh` がすでにある場合は、`statusline.sh.bak-<日時>` に名前を変えて残します。

削除時に取り除かれるのはリンクと `statusLine` の設定だけです。バックアップと `statusline.conf` は残ります。

## スタイルを追加する

1. `styles/<名前>/statusline.sh` を作成します。Claude Code が stdin に渡す JSON を読み、表示内容を stdout に出力します。
2. `styles/<名前>/style.meta` を作成し、言語ごとに 1 行の説明を書きます（`zh-TW=`、`zh-CN=`、`en=`、`ja=`）。
3. `test/run.sh` を実行し、すべてのサンプルデータで正しく出力されることを確認します。
4. 4 つの README のスタイル表にそれぞれ 1 行追加します。

メニューは `styles/` を自動で読み込むため、`install.sh` の変更は不要です。

## よくある質問

**ピルの両端が四角や「?」で表示される。** ターミナルのフォントに Nerd Font の記号がありません。Nerd Font に変更するか、`statusline.conf` で `ROUND` を `0` にしてください。

**色がおかしい。** ターミナルが 24 ビット True Color に対応していません。対応しているターミナルをお使いください。

**context が 0 と表示される。** 新しいセッションや `/compact` の直後は、まだ使用量のデータがありません。次の応答のあとに表示されます。

**週間使用量のピルが表示されない。** このデータは claude.ai の Pro・Max・Ultra プランでのみ提供され、API キーでは表示されません。新しいセッションでは最初の応答のあとに表示されます。

**effort の部分が表示されない。** 現在のモデルが effort パラメーターに対応していないため、model だけが表示されます。
