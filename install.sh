#!/bin/bash
# cc-statuslines 安裝程式
#
#   install.sh                 互動式選單：列出樣式、預覽、選擇後安裝
#   install.sh <樣式>          直接安裝（或切換到）指定樣式
#   install.sh --list          列出所有樣式
#   install.sh --preview [樣式] 用模擬資料預覽
#   install.sh --uninstall     移除 status line 設定
#   install.sh --lang <語言>   切換介面語言：zh-TW（預設）、zh-CN、en、ja
#
# 相容 macOS 內建的 bash 3.2。

set -u

REPO_DIR="$(cd "$(dirname "$0")" && pwd)"
STYLES_DIR="$REPO_DIR/styles"
FIXTURE="$REPO_DIR/test/fixtures/normal.json"
CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
LINK="$CLAUDE_DIR/statusline.sh"
SETTINGS="$CLAUDE_DIR/settings.json"
CONF="$CLAUDE_DIR/statusline.conf"
LANG_FILE="$CLAUDE_DIR/cc-statuslines.lang"

# ---------- 語言 ----------

normalize_lang() {
  case "$1" in
    zh-TW|zh_TW|zh-tw|tw|zh-Hant) echo "zh-TW" ;;
    zh-CN|zh_CN|zh-cn|cn|zh-Hans) echo "zh-CN" ;;
    en|en-US|en_US|EN)            echo "en" ;;
    ja|ja-JP|ja_JP|jp)            echo "ja" ;;
    *) return 1 ;;
  esac
}

load_messages() {
  case "$UI_LANG" in
    zh-CN)
      M_TITLE="cc-statuslines 安装程序"
      M_CHOOSE="请选择要安装的样式："
      M_ACTIVE="使用中"
      M_OPT_LANG="切换语言"
      M_OPT_UNINSTALL="移除 status line"
      M_OPT_CANCEL="取消"
      M_PROMPT="请输入编号"
      M_INVALID="无效的选项：%s"
      M_CANCELLED="已取消，没有做任何更改。"
      M_NO_JQ="找不到 jq。请先安装（macOS：brew install jq），然后重新运行。"
      M_NO_STYLES="styles/ 里没有任何样式。"
      M_NO_STYLE="找不到样式：%s"
      M_BAD_JSON="%s 不是有效的 JSON，为避免损坏已中止。请先修正这个文件。"
      M_BACKUP="已备份 %s"
      M_MOVED="原有的 statusline.sh 已改名为 %s"
      M_CONF_CREATED="已创建个人设置文件 %s"
      M_INSTALLED="已安装样式 %s"
      M_RESTART="重新打开 Claude Code session 后生效。"
      M_HINT="如果上面的预览颜色不对，或两端出现方框，请在 %s 里把 ROUND 改成 0。"
      M_UNINSTALLED="已移除 status line 设置。"
      M_NOT_INSTALLED="目前没有通过 cc-statuslines 安装的 status line。"
      M_KEPT_OTHER="settings.json 里的 statusLine 不是 cc-statuslines 设置的，保持不动。"
      M_LANG_CHOOSE="请选择语言："
      M_LANG_SET="界面语言已切换为 %s"
      M_LANG_BAD="不支持的语言：%s（可用：zh-TW、zh-CN、en、ja）"
      M_USAGE="用法：
  install.sh                  交互式菜单
  install.sh <样式>           直接安装或切换样式
  install.sh --list           列出所有样式
  install.sh --preview [样式] 用模拟数据预览
  install.sh --uninstall      移除 status line 设置
  install.sh --lang <语言>    切换界面语言：zh-TW、zh-CN、en、ja"
      ;;
    en)
      M_TITLE="cc-statuslines installer"
      M_CHOOSE="Choose a style to install:"
      M_ACTIVE="active"
      M_OPT_LANG="Change language"
      M_OPT_UNINSTALL="Remove the status line"
      M_OPT_CANCEL="Cancel"
      M_PROMPT="Enter a number"
      M_INVALID="Invalid choice: %s"
      M_CANCELLED="Cancelled. Nothing was changed."
      M_NO_JQ="jq not found. Install it first (macOS: brew install jq), then run this again."
      M_NO_STYLES="No styles found in styles/."
      M_NO_STYLE="Style not found: %s"
      M_BAD_JSON="%s is not valid JSON. Stopped to avoid damaging it; fix the file first."
      M_BACKUP="Backed up %s"
      M_MOVED="Your existing statusline.sh was renamed to %s"
      M_CONF_CREATED="Created your config file %s"
      M_INSTALLED="Installed style %s"
      M_RESTART="Open a new Claude Code session to see it."
      M_HINT="If the preview colors look wrong or the ends show boxes, set ROUND=0 in %s."
      M_UNINSTALLED="Status line settings removed."
      M_NOT_INSTALLED="No status line installed by cc-statuslines."
      M_KEPT_OTHER="The statusLine in settings.json was not set by cc-statuslines; left untouched."
      M_LANG_CHOOSE="Choose a language:"
      M_LANG_SET="Language set to %s"
      M_LANG_BAD="Unsupported language: %s (available: zh-TW, zh-CN, en, ja)"
      M_USAGE="Usage:
  install.sh                   interactive menu
  install.sh <style>           install or switch to a style
  install.sh --list            list all styles
  install.sh --preview [style] preview with sample data
  install.sh --uninstall       remove the status line settings
  install.sh --lang <lang>     set the language: zh-TW, zh-CN, en, ja"
      ;;
    ja)
      M_TITLE="cc-statuslines インストーラー"
      M_CHOOSE="インストールするスタイルを選んでください："
      M_ACTIVE="使用中"
      M_OPT_LANG="言語を切り替える"
      M_OPT_UNINSTALL="status line を削除する"
      M_OPT_CANCEL="キャンセル"
      M_PROMPT="番号を入力"
      M_INVALID="無効な選択です：%s"
      M_CANCELLED="キャンセルしました。変更はありません。"
      M_NO_JQ="jq が見つかりません。先にインストールしてから（macOS：brew install jq）、もう一度実行してください。"
      M_NO_STYLES="styles/ にスタイルがありません。"
      M_NO_STYLE="スタイルが見つかりません：%s"
      M_BAD_JSON="%s は有効な JSON ではありません。破損を避けるため中止しました。先にファイルを修正してください。"
      M_BACKUP="%s をバックアップしました"
      M_MOVED="既存の statusline.sh を %s に名前変更しました"
      M_CONF_CREATED="個人設定ファイル %s を作成しました"
      M_INSTALLED="スタイル %s をインストールしました"
      M_RESTART="Claude Code のセッションを開き直すと反映されます。"
      M_HINT="上のプレビューの色がおかしい、または両端が四角で表示される場合は、%s で ROUND を 0 にしてください。"
      M_UNINSTALLED="status line の設定を削除しました。"
      M_NOT_INSTALLED="cc-statuslines でインストールした status line はありません。"
      M_KEPT_OTHER="settings.json の statusLine は cc-statuslines が設定したものではないため、そのままにしました。"
      M_LANG_CHOOSE="言語を選んでください："
      M_LANG_SET="表示言語を %s に切り替えました"
      M_LANG_BAD="未対応の言語です：%s（利用可能：zh-TW、zh-CN、en、ja）"
      M_USAGE="使い方：
  install.sh                     対話式メニュー
  install.sh <スタイル>          スタイルをインストール／切り替え
  install.sh --list              スタイル一覧
  install.sh --preview [スタイル] サンプルデータでプレビュー
  install.sh --uninstall         status line の設定を削除
  install.sh --lang <言語>       表示言語の切り替え：zh-TW、zh-CN、en、ja"
      ;;
    *)
      M_TITLE="cc-statuslines 安裝程式"
      M_CHOOSE="請選擇要安裝的樣式："
      M_ACTIVE="使用中"
      M_OPT_LANG="切換語言"
      M_OPT_UNINSTALL="移除 status line"
      M_OPT_CANCEL="取消"
      M_PROMPT="請輸入編號"
      M_INVALID="無效的選項：%s"
      M_CANCELLED="已取消，沒有做任何變更。"
      M_NO_JQ="找不到 jq。請先安裝（macOS：brew install jq），再重新執行。"
      M_NO_STYLES="styles/ 裡沒有任何樣式。"
      M_NO_STYLE="找不到樣式：%s"
      M_BAD_JSON="%s 不是有效的 JSON，為避免弄壞已中止。請先修正這個檔案。"
      M_BACKUP="已備份 %s"
      M_MOVED="原有的 statusline.sh 已改名為 %s"
      M_CONF_CREATED="已建立個人設定檔 %s"
      M_INSTALLED="已安裝樣式 %s"
      M_RESTART="重新開啟 Claude Code session 後生效。"
      M_HINT="如果上面的預覽顏色不對，或兩端出現方框，請在 %s 把 ROUND 改成 0。"
      M_UNINSTALLED="已移除 status line 設定。"
      M_NOT_INSTALLED="目前沒有透過 cc-statuslines 安裝的 status line。"
      M_KEPT_OTHER="settings.json 裡的 statusLine 不是 cc-statuslines 設定的，維持不動。"
      M_LANG_CHOOSE="請選擇語言："
      M_LANG_SET="介面語言已切換為 %s"
      M_LANG_BAD="不支援的語言：%s（可用：zh-TW、zh-CN、en、ja）"
      M_USAGE="用法：
  install.sh                  互動式選單
  install.sh <樣式>           直接安裝或切換樣式
  install.sh --list           列出所有樣式
  install.sh --preview [樣式] 用模擬資料預覽
  install.sh --uninstall      移除 status line 設定
  install.sh --lang <語言>    切換介面語言：zh-TW、zh-CN、en、ja"
      ;;
  esac
}

set_lang() {  # set_lang <語言> [persist]
  local n
  if ! n=$(normalize_lang "$1"); then
    printf "$M_LANG_BAD\n" "$1" >&2
    return 1
  fi
  UI_LANG="$n"
  load_messages
  if [ "${2:-}" = persist ]; then
    mkdir -p "$CLAUDE_DIR" && echo "$UI_LANG" > "$LANG_FILE"
  fi
}

# 語言優先序：環境變數 > 上次的選擇 > 繁體中文
UI_LANG="zh-TW"
if [ -n "${CC_STATUSLINES_LANG:-}" ]; then
  UI_LANG=$(normalize_lang "$CC_STATUSLINES_LANG" || echo "zh-TW")
elif [ -f "$LANG_FILE" ]; then
  UI_LANG=$(normalize_lang "$(head -n 1 "$LANG_FILE")" || echo "zh-TW")
fi
load_messages

# ---------- 小工具 ----------

ok()   { printf '\033[32m✓\033[0m %s\n' "$1"; }
err()  { printf '\033[31m✗\033[0m %s\n' "$1" >&2; }
note() { printf '  %s\n' "$1"; }

list_styles() {
  local d
  for d in "$STYLES_DIR"/*/; do
    [ -f "${d}statusline.sh" ] && basename "$d"
  done
}

style_desc() {  # style_desc <樣式>：依介面語言取說明，沒有就退回英文
  local f="$STYLES_DIR/$1/style.meta" line=""
  [ -f "$f" ] || return 0
  line=$(grep "^$UI_LANG=" "$f" | head -n 1)
  [ -z "$line" ] && line=$(grep "^en=" "$f" | head -n 1)
  echo "${line#*=}"
}

current_style() {  # 目前連結指向 repo 內哪個樣式；不是我們裝的就輸出空字串
  local target
  [ -L "$LINK" ] || return 0
  target=$(readlink "$LINK")
  case "$target" in
    "$STYLES_DIR"/*/statusline.sh) basename "$(dirname "$target")" ;;
  esac
}

fixture() {  # fixture <檔案>：把 rate_limits.*.resets_at 的「距離現在幾秒」換成真正的 epoch
  jq -c --argjson now "$(date +%s)" \
    'if .rate_limits then .rate_limits |= map_values(if .resets_at then .resets_at += $now else . end) else . end' "$1" 2>/dev/null \
    || cat "$1"
}

preview_style() {  # preview_style <樣式>
  fixture "$FIXTURE" | CC_STATUSLINE_CONF="$CONF" bash "$STYLES_DIR/$1/statusline.sh"
}

backup_file() {  # backup_file <檔案>：複製成 .bak-時間戳，不覆蓋既有備份；輸出備份檔名
  local base n=1 dest
  base="$1.bak-$(date +%Y%m%d-%H%M%S)"
  dest="$base"
  while [ -e "$dest" ]; do n=$((n + 1)); dest="$base-$n"; done
  cp "$1" "$dest" && basename "$dest"
}

need_jq() {
  command -v jq >/dev/null 2>&1 && return 0
  err "$M_NO_JQ"
  exit 1
}

# ---------- 安裝／移除 ----------

do_install() {  # do_install <樣式>
  local name="$1" src ts tmp cur_cmd need_write=1
  src="$STYLES_DIR/$name/statusline.sh"
  if [ ! -f "$src" ]; then
    err "$(printf "$M_NO_STYLE" "$name")"
    exit 1
  fi
  need_jq
  mkdir -p "$CLAUDE_DIR"
  ts=$(date +%Y%m%d-%H%M%S)

  # 先確認 settings.json 可以安全修改，再動任何東西
  if [ -f "$SETTINGS" ]; then
    if ! jq empty "$SETTINGS" >/dev/null 2>&1; then
      err "$(printf "$M_BAD_JSON" "$SETTINGS")"
      exit 1
    fi
    # 已經指向我們的連結（切換樣式）就不必再動 settings.json，也不再備份
    cur_cmd=$(jq -r '.statusLine | "\(.type // "")|\(.command // "")"' "$SETTINGS" 2>/dev/null)
    if [ "$cur_cmd" = "command|$LINK" ]; then
      need_write=0
    else
      ok "$(printf "$M_BACKUP" "$SETTINGS → $(backup_file "$SETTINGS")")"
    fi
  else
    echo '{}' > "$SETTINGS"
  fi

  # 使用者原本自己寫的 statusline.sh（不是連結）先改名保留
  if [ -e "$LINK" ] && [ ! -L "$LINK" ]; then
    mv "$LINK" "$LINK.bak-$ts"
    ok "$(printf "$M_MOVED" "$(basename "$LINK").bak-$ts")"
  fi

  chmod +x "$src"
  rm -f "$LINK"
  ln -s "$src" "$LINK"

  # 只合併 statusLine 的 type 與 command，其餘設定原樣保留
  if [ "$need_write" = 1 ]; then
    tmp=$(mktemp)
    if jq --arg cmd "$LINK" '.statusLine = ((.statusLine // {}) + {type: "command", command: $cmd})' "$SETTINGS" > "$tmp"; then
      cat "$tmp" > "$SETTINGS"
    fi
    rm -f "$tmp"
  fi

  if [ ! -f "$CONF" ] && [ -f "$REPO_DIR/statusline.conf.example" ]; then
    cp "$REPO_DIR/statusline.conf.example" "$CONF"
    ok "$(printf "$M_CONF_CREATED" "$CONF")"
  fi

  ok "$(printf "$M_INSTALLED" "$name")"
  echo
  printf '  '; preview_style "$name"
  echo
  note "$(printf "$M_HINT" "$CONF")"
  note "$M_RESTART"
}

do_uninstall() {
  local cur tmp cmd
  cur=$(current_style)
  if [ -z "$cur" ]; then
    note "$M_NOT_INSTALLED"
    return 0
  fi
  rm -f "$LINK"
  if [ -f "$SETTINGS" ] && command -v jq >/dev/null 2>&1 && jq empty "$SETTINGS" >/dev/null 2>&1; then
    cmd=$(jq -r '.statusLine.command // ""' "$SETTINGS")
    if [ "$cmd" = "$LINK" ]; then
      ok "$(printf "$M_BACKUP" "$SETTINGS → $(backup_file "$SETTINGS")")"
      tmp=$(mktemp)
      if jq 'del(.statusLine)' "$SETTINGS" > "$tmp"; then cat "$tmp" > "$SETTINGS"; fi
      rm -f "$tmp"
    elif [ -n "$cmd" ]; then
      note "$M_KEPT_OTHER"
    fi
  fi
  ok "$M_UNINSTALLED"
}

# ---------- 列表／選單 ----------

print_styles() {  # print_styles [numbered]
  local i=0 name cur mark
  cur=$(current_style)
  for name in $(list_styles); do
    i=$((i + 1))
    mark=""
    [ "$name" = "$cur" ] && mark=" [$M_ACTIVE]"
    if [ "${1:-}" = numbered ]; then
      printf '  \033[1m%d) %s\033[0m%s\n' "$i" "$name" "$mark"
    else
      printf '  \033[1m%s\033[0m%s\n' "$name" "$mark"
    fi
    printf '     %s\n' "$(style_desc "$name")"
    printf '     '; preview_style "$name"
    echo
  done
}

lang_menu() {
  local c
  echo
  echo "$M_LANG_CHOOSE"
  echo "  1) 繁體中文"
  echo "  2) 简体中文"
  echo "  3) English"
  echo "  4) 日本語"
  printf '%s: ' "$M_PROMPT"
  read -r c || return 0
  case "$c" in
    1) set_lang zh-TW persist ;;
    2) set_lang zh-CN persist ;;
    3) set_lang en persist ;;
    4) set_lang ja persist ;;
    *) return 0 ;;
  esac
  ok "$(printf "$M_LANG_SET" "$UI_LANG")"
}

menu() {
  local styles count cur def choice i name
  styles=$(list_styles)
  if [ -z "$styles" ]; then
    err "$M_NO_STYLES"
    exit 1
  fi
  count=$(echo "$styles" | wc -l | tr -d ' ')

  while :; do
    cur=$(current_style)
    def=1; i=0
    for name in $styles; do
      i=$((i + 1))
      [ "$name" = "$cur" ] && def=$i
    done

    echo
    printf '\033[1m%s\033[0m\n\n' "$M_TITLE"
    echo "$M_CHOOSE"
    echo
    print_styles numbered
    printf '  L) %s\n' "$M_OPT_LANG"
    [ -n "$cur" ] && printf '  U) %s\n' "$M_OPT_UNINSTALL"
    printf '  0) %s\n\n' "$M_OPT_CANCEL"
    printf '%s [%s]: ' "$M_PROMPT" "$def"
    if ! read -r choice; then
      echo
      note "$M_CANCELLED"
      return 0
    fi
    [ -z "$choice" ] && choice=$def

    case "$choice" in
      0|q|Q) note "$M_CANCELLED"; return 0 ;;
      l|L)   lang_menu; continue ;;
      u|U)   echo; do_uninstall; return 0 ;;
      *[!0-9]*) err "$(printf "$M_INVALID" "$choice")"; continue ;;
    esac
    if [ "$choice" -lt 1 ] || [ "$choice" -gt "$count" ]; then
      err "$(printf "$M_INVALID" "$choice")"
      continue
    fi
    name=$(echo "$styles" | sed -n "${choice}p")
    echo
    do_install "$name"
    return 0
  done
}

# ---------- 參數 ----------

CMD=""
ARG=""
while [ $# -gt 0 ]; do
  case "$1" in
    --lang)
      [ $# -ge 2 ] || { echo "$M_USAGE"; exit 1; }
      set_lang "$2" persist || exit 1
      [ -z "$CMD" ] && CMD="lang"
      shift 2 ;;
    --lang=*)
      set_lang "${1#--lang=}" persist || exit 1
      [ -z "$CMD" ] && CMD="lang"
      shift ;;
    -l|--list)      CMD="list"; shift ;;
    -p|--preview)   CMD="preview"; shift
                    if [ $# -gt 0 ] && [ "${1#-}" = "$1" ]; then ARG="$1"; shift; fi ;;
    -u|--uninstall) CMD="uninstall"; shift ;;
    -h|--help)      CMD="help"; shift ;;
    -*)             echo "$M_USAGE"; exit 1 ;;
    *)              CMD="install"; ARG="$1"; shift ;;
  esac
done

case "$CMD" in
  "")        menu ;;
  lang)      ok "$(printf "$M_LANG_SET" "$UI_LANG")" ;;
  help)      echo "$M_USAGE" ;;
  list)      echo; print_styles ;;
  uninstall) do_uninstall ;;
  install)   do_install "$ARG" ;;
  preview)
    if [ -n "$ARG" ]; then
      if [ ! -f "$STYLES_DIR/$ARG/statusline.sh" ]; then
        err "$(printf "$M_NO_STYLE" "$ARG")"
        exit 1
      fi
      for fx in "$REPO_DIR"/test/fixtures/*.json; do
        printf '  %-10s ' "$(basename "$fx" .json)"
        fixture "$fx" | CC_STATUSLINE_CONF="$CONF" bash "$STYLES_DIR/$ARG/statusline.sh"
      done
    else
      echo; print_styles
    fi ;;
esac
