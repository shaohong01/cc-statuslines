#!/bin/bash
# cc-statuslines · pills-duo
# model + effort 合成一顆雙色膠囊，context 用量獨立一顆。
# 個人設定請寫在 ~/.claude/statusline.conf，不要直接改這個檔案。

input=$(cat)

# ---- 預設值（可在 statusline.conf 覆寫）----
ROUND=1      # 1 = 圓角膠囊（需要 Nerd Font）；0 = 方角色塊
JOIN=round   # model 與 effort 的交界：round = 圓弧疊合；flat = 直切分色
WARN=50      # context 用量達到這個百分比轉黃
CRIT=80      # context 用量達到這個百分比轉紅

CONF="${CC_STATUSLINE_CONF:-${CLAUDE_CONFIG_DIR:-$HOME/.claude}/statusline.conf}"
[ -f "$CONF" ] && . "$CONF"
case "$WARN" in ''|*[!0-9]*) WARN=50 ;; esac
case "$CRIT" in ''|*[!0-9]*) CRIT=80 ;; esac

if ! command -v jq >/dev/null 2>&1; then
  echo "statusline: jq not found"
  exit 0
fi

IFS=$'\t' read -r MODEL EFFORT USED SIZE PCT <<EOF
$(echo "$input" | jq -r '[
  (.model.display_name // "?"),
  (.effort.level // "-"),
  ((.context_window.current_usage // {}) | (.input_tokens//0)+(.cache_creation_input_tokens//0)+(.cache_read_input_tokens//0)),
  (.context_window.context_window_size // 200000),
  ((.context_window.used_percentage // 0) | floor)
] | @tsv' 2>/dev/null)
EOF
[ -z "${MODEL:-}" ] && { echo "statusline: no data"; exit 0; }

fmt() { awk -v n="$1" 'BEGIN{ if(n>=1e6) printf "%.1fM", n/1e6; else if(n>=1e3) printf "%.0fk", n/1e3; else printf "%d", n }'; }

# ---- 顏色（r;g;b，24-bit 真彩色）----
BLUE='66;133;244'; RED='234;67;53'; YELLOW='251;188;5'; GREEN='52;168;83'; GRAY='154;160;166'
WHITE='255;255;255'; DARK='32;33;36'

L=$'\xee\x82\xb6'; R=$'\xee\x82\xb4'   # Nerd Font 的左右半圓（U+E0B6、U+E0B4）

pill() {  # pill <背景> <文字色> <文字>
  if [ "$ROUND" = 1 ]; then
    printf '\033[38;2;%sm%s\033[48;2;%s;38;2;%sm%s\033[0;38;2;%sm%s\033[0m' "$1" "$L" "$1" "$2" "$3" "$1" "$R"
  else
    printf '\033[48;2;%s;38;2;%sm %s \033[0m' "$1" "$2" "$3"
  fi
}

duo() {  # duo <背景1> <文字色1> <文字1> <背景2> <文字色2> <文字2>：一顆膠囊、兩段顏色
  if [ "$ROUND" != 1 ]; then
    printf '\033[48;2;%s;38;2;%sm %s \033[48;2;%s;38;2;%sm %s \033[0m' "$1" "$2" "$3" "$4" "$5" "$6"
  elif [ "$JOIN" = round ]; then
    printf '\033[38;2;%sm%s\033[48;2;%s;38;2;%sm%s\033[48;2;%s;38;2;%sm%s\033[38;2;%sm %s\033[0;38;2;%sm%s\033[0m' \
      "$1" "$L" "$1" "$2" "$3" "$4" "$1" "$R" "$5" "$6" "$4" "$R"
  else
    printf '\033[38;2;%sm%s\033[48;2;%s;38;2;%sm%s \033[48;2;%s;38;2;%sm %s\033[0;38;2;%sm%s\033[0m' \
      "$1" "$L" "$1" "$2" "$3" "$4" "$5" "$6" "$4" "$R"
  fi
}

# effort：灰 → 綠 → 黃 → 紅
case "$EFFORT" in
  low)       EB=$GRAY;   EF=$DARK  ;;
  medium)    EB=$GREEN;  EF=$WHITE ;;
  high)      EB=$YELLOW; EF=$DARK  ;;
  xhigh|max) EB=$RED;    EF=$WHITE ;;
  *)         EB=$GRAY;   EF=$DARK  ;;
esac

# context：低於 WARN 綠、低於 CRIT 黃、其餘紅
if   [ "$PCT" -lt "$WARN" ]; then CB=$GREEN;  CF=$WHITE
elif [ "$PCT" -lt "$CRIT" ]; then CB=$YELLOW; CF=$DARK
else                              CB=$RED;    CF=$WHITE; fi

if [ "$EFFORT" != "-" ]; then duo "$BLUE" "$WHITE" "$MODEL" "$EB" "$EF" "$EFFORT"
else pill "$BLUE" "$WHITE" "$MODEL"; fi
printf ' '; pill "$CB" "$CF" "$(fmt "$USED") / $(fmt "$SIZE") · ${PCT}%"
echo
