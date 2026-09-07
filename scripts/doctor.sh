#!/usr/bin/env bash
# doctor.sh — 部署体检：检查包、配置、服务是否就绪
set -uo pipefail

ok_n=0; warn_n=0; err_n=0
ok()   { printf '  \033[32m✔\033[0m %s\n' "$1"; ok_n=$((ok_n+1)); }
warn() { printf '  \033[33m⚠\033[0m %s\n' "$1"; warn_n=$((warn_n+1)); }
err()  { printf '  \033[31m✘\033[0m %s\n' "$1"; err_n=$((err_n+1)); }

echo "== arch-hypr-deck 体检 =="

# 1. 命令存在性
echo "-- 软件包"
for cmd in Hyprland waybar fastfetch kitty fish btop cava nvim sddm \
           fcitx5 rofi mako hyprlock hypridle \
           pipewire wireplumber nmcli bluetoothctl thunar \
           grim slurp wl-copy cliphist matugen brightnessctl \
           pavucontrol playerctl firefox; do
    if command -v "$cmd" >/dev/null 2>&1 || \
       pacman -Qs "^${cmd}/" >/dev/null 2>&1; then
        ok "$cmd"
    else
        err "$cmd 未安装"
    fi
done

# AUR 包（lianwall）
for cmd in lianwall lianwalld lianwall-gui; do
    if command -v "$cmd" >/dev/null 2>&1; then ok "$cmd (AUR)"; else warn "$cmd (AUR) 未安装 — 壁纸将退回 swww"; fi
done

# 2. 配置文件
echo "-- 配置文件"
declare -A confs=(
    [hyprland.conf]="$HOME/.config/hypr/hyprland.conf"
    [waybar]="$HOME/.config/waybar/config.jsonc"
    [kitty]="$HOME/.config/kitty/kitty.conf"
    [fish]="$HOME/.config/fish/config.fish"
    [fcitx5]="$HOME/.config/fcitx5/profile"
    [nvim]="$HOME/.config/nvim/init.lua"
    [mako]="$HOME/.config/mako/config"
    [rofi]="$HOME/.config/rofi/config.rasi"
    [matugen]="$HOME/.config/matugen/config.toml"
)
for name in "${!confs[@]}"; do
    if [[ -e "${confs[$name]}" ]]; then ok "$name"; else err "$name 缺失 (${confs[$name]})"; fi
done

if [[ -f "$HOME/Pictures/wallpapers/default.png" ]]; then ok "默认壁纸"; else warn "默认壁纸缺失"; fi

# 3. 服务状态
echo "-- 服务"
if systemctl is-enabled NetworkManager >/dev/null 2>&1; then ok "NetworkManager 已启用"; else err "NetworkManager 未启用"; fi
if systemctl is-enabled sddm >/dev/null 2>&1; then ok "sddm 已启用"; else err "sddm 未启用（无法进入图形登录）"; fi
if systemctl is-active NetworkManager >/dev/null 2>&1; then ok "NetworkManager 运行中"; else warn "NetworkManager 未运行"; fi
if command -v bluetoothctl >/dev/null; then
    if systemctl is-enabled bluetooth >/dev/null 2>&1; then ok "bluetooth 已启用"; else warn "bluetooth 未启用（无蓝牙硬件可忽略）"; fi
fi
if systemctl --user is-active pipewire >/dev/null 2>&1; then ok "pipewire 运行中"; else warn "pipewire 未运行（重新登录后生效）"; fi

# 4. 汇总
echo
echo "-- 结果: $ok_n 通过, $warn_n 警告, $err_n 失败"
if (( err_n )); then
    echo "存在失败项，请重新运行 ./install.sh 修复。"
    exit 1
elif (( warn_n )); then
    echo "基本就绪，警告项可视情况忽略或处理。"
    exit 0
else
    echo "全部就绪！重启后在 SDDM 选择 Hyprland 会话即可。"
    exit 0
fi
