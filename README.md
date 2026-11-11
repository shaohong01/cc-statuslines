# cc-statuslines

**繁體中文** | [简体中文](README.zh-CN.md) | [English](README.en.md) | [日本語](README.ja.md)

Claude Code 的自訂 status line 樣式集。用一個互動式安裝程式列出所有樣式，在你的終端機裡直接預覽，選好就裝。

```
 Opus  xhigh   412k / 1.0M · 41%
└─ model + effort ─┘ └─ context 用量 ─┘
```

## 需求

- [Claude Code](https://code.claude.com/docs/en/statusline)
- `jq`（macOS：`brew install jq`）
- 支援 24-bit 真彩色的終端機
- Nerd Font（選用，圓角膠囊需要；沒有的話可改用方角）

## 安裝

```bash
gh repo clone shaohong01/cc-statuslines ~/.cc-statuslines
~/.cc-statuslines/install.sh
```

安裝程式會列出所有樣式和實際的彩色預覽，輸入編號就完成安裝。重新開啟 Claude Code session 後生效。

也可以不經選單，直接指定樣式：

```bash
~/.cc-statuslines/install.sh pills-duo
```

## 樣式

| 樣式 | 說明 |
|---|---|
| `pills-duo` | 雙色膠囊：model 與 effort 合併成一顆，context 用量獨立一顆。effort 與 context 依等級和用量在綠、黃、紅之間變色 |

## 指令

| 指令 | 作用 |
|---|---|
| `install.sh` | 互動式選單：選擇樣式、切換語言、移除 |
| `install.sh <樣式>` | 直接安裝或切換到指定樣式 |
| `install.sh --list` | 列出所有樣式與預覽 |
| `install.sh --preview <樣式>` | 預覽該樣式在各種狀態下的樣子 |
| `install.sh --uninstall` | 移除 status line 設定 |
| `install.sh --lang <語言>` | 切換安裝程式的語言：`zh-TW`（預設）、`zh-CN`、`en`、`ja` |

## 個人設定

安裝時會建立 `~/.claude/statusline.conf`。調整都寫在這裡，更新 repo 時不會被蓋掉。

| 設定 | 預設 | 說明 |
|---|---|---|
| `ROUND` | `1` | `1` 是圓角膠囊（需要 Nerd Font）；`0` 是方角色塊 |
| `JOIN` | `round` | model 與 effort 的交界。`round` 是圓弧疊合；`flat` 是直切分色 |
| `WARN` | `50` | context 用量達到這個百分比時轉黃 |
| `CRIT` | `80` | context 用量達到這個百分比時轉紅 |

改完存檔，status line 下次更新時就會套用。

## 更新

```bash
git -C ~/.cc-statuslines pull
```

安裝的是指向 repo 的連結，所以 pull 完就是最新版，不必重新安裝。

## 安裝程式做了什麼

- 把 `~/.claude/statusline.sh` 建成連結，指向你選的樣式。
- 在 `~/.claude/settings.json` 寫入 `statusLine` 設定，其他設定原樣保留。
- 第一次安裝時，修改前先把 `settings.json` 備份成 `settings.json.bak-<時間>`。之後切換樣式只會換連結，不再修改 `settings.json`，也不會再產生備份。
- 如果你原本有自己的 `statusline.sh`，會改名成 `statusline.sh.bak-<時間>` 保留下來。

移除時只會拿掉連結和 `statusLine` 設定，備份檔與 `statusline.conf` 都會留著。

## 新增樣式

1. 建立 `styles/<名稱>/statusline.sh`。腳本從 stdin 讀 Claude Code 傳入的 JSON，把要顯示的內容印到 stdout。
2. 建立 `styles/<名稱>/style.meta`，每種語言一行說明（`zh-TW=`、`zh-CN=`、`en=`、`ja=`）。
3. 執行 `test/run.sh`，確認在每份模擬資料下都能正常輸出。
4. 在四份 README 的樣式表各加一列。

安裝選單會自動掃描 `styles/`，不需要修改 `install.sh`。

## 常見問題

**膠囊兩端出現方框或問號。** 終端機的字型沒有 Nerd Font 符號。換成 Nerd Font，或在 `statusline.conf` 把 `ROUND` 設成 `0`。

**顏色不對。** 終端機不支援 24-bit 真彩色。請換用支援的終端機。

**context 顯示 0。** 新 session 或剛執行完 `/compact` 時還沒有用量資料，下一次回應後就會出現。

**沒有 effort 那一段。** 目前的模型不支援 effort 參數，這時只會顯示 model。
