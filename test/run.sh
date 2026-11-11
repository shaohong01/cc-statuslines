#!/bin/bash
# 煙霧測試：每個樣式 × 每份模擬資料都要能正常輸出。
# 用法：test/run.sh        （順便可以肉眼檢查各種狀態的樣子）
REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
fail=0
for conf in "ROUND=1 JOIN=round" "ROUND=1 JOIN=flat" "ROUND=0"; do
  tmp=$(mktemp); for kv in $conf; do echo "$kv" >> "$tmp"; done
  echo "== $conf"
  for style in "$REPO_DIR"/styles/*/statusline.sh; do
    name=$(basename "$(dirname "$style")")
    for fx in "$REPO_DIR"/test/fixtures/*.json; do
      out=$(CC_STATUSLINE_CONF="$tmp" bash "$style" < "$fx"); rc=$?
      if [ $rc -ne 0 ] || [ -z "$out" ] || [ "${out#statusline:}" != "$out" ]; then
        echo "FAIL  $name  $(basename "$fx")  (exit $rc) $out"; fail=1
      else
        printf '%-10s %-14s %s\n' "$name" "$(basename "$fx" .json)" "$out"
      fi
    done
  done
  rm -f "$tmp"
done
[ $fail -eq 0 ] && echo "ALL PASS" || { echo "SOME FAILED"; exit 1; }
