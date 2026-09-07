#!/usr/bin/env bash
# wallpaper.sh — 开机启动：起 lianwalld → 设置壁纸 → matugen 取色刷新主题
# fallback: lianwall 不可用时退回 swww
set -euo pipefail

WALL_DIR="$HOME/Pictures/wallpapers"
WALL="${1:-$WALL_DIR/default.png}"
[[ -f "$WALL" ]] || WALL="$(find "$WALL_DIR" -maxdepth 1 -type f | head -1)"
[[ -n "${WALL:-}" && -f "$WALL" ]] || exit 0

if command -v lianwalld >/dev/null 2>&1; then
    # lianwall：daemon + CLI（具体命令见其 CLI-JSON 文档）
    pidof lianwalld >/dev/null || (lianwalld >/dev/null 2>&1 &)
    sleep 1
    lianwall set "$WALL" 2>/dev/null || swww img "$WALL" 2>/dev/null || true
else
    # 纯 swww 兜底
    command -v swww >/dev/null 2>&1 || exit 0
    pidof swww-daemon >/dev/null || (swww-daemon >/dev/null 2>&1 &)
    sleep 0.5
    swww img "$WALL" --transition-type grow 2>/dev/null || true
fi

# matugen 取色：刷新 kitty / waybar / mako 主题
if command -v matugen >/dev/null 2>&1; then
    matugen image "$WALL" >/dev/null 2>&1 || true
    sleep 0.5
    pidof waybar >/dev/null && pkill -SIGUSR2 waybar 2>/dev/null || true
    pidof mako >/dev/null && makoctl reload 2>/dev/null || true
    pidof kitty >/dev/null && kill -SIGUSR1 $(pgrep kitty) 2>/dev/null || true
fi
