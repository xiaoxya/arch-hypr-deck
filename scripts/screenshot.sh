#!/usr/bin/env bash
# screenshot.sh — 截图：full 全屏 / region 选区（swappy 编辑）
set -euo pipefail
DIR="$HOME/Pictures/Screenshots"
mkdir -p "$DIR"
FILE="$DIR/screenshot-$(date +%Y%m%d-%H%M%S).png"

case "${1:-region}" in
    full)
        grim "$FILE" && wl-copy < "$FILE" && notify-send " 截图" "已保存并复制：$(basename "$FILE")"
        ;;
    region)
        grim -g "$(slurp)" "$FILE" && wl-copy < "$FILE" \
            && notify-send " 截图" "已保存并复制：$(basename "$FILE")" \
            && (swappy -f "$FILE" >/dev/null 2>&1 &)
        ;;
    *)
        echo "用法: screenshot.sh [full|region]"; exit 1 ;;
esac
