#!/usr/bin/env bash
#
# arch-hypr-deck — Hyprland 桌面一键部署
# 在已安装的 Arch Linux 上执行：装包 + 写配置 + 启服务，装完即可使用。
#
# 用法:
#   ./install.sh              交互式部署
#   ./install.sh --yes        全部采用默认值，无需确认
#   ./install.sh --check      只做环境体检（不安装任何东西）
#
set -Eeuo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ASSUME_YES=0
CHECK_ONLY=0
NO_AUR=0

for arg in "$@"; do
  case "$arg" in
    --yes|-y)   ASSUME_YES=1 ;;
    --check)    CHECK_ONLY=1 ;;
    --no-aur)   NO_AUR=1 ;;
    -h|--help)  sed -n '2,12p' "$0"; exit 0 ;;
    *) echo "未知参数: $arg" >&2; exit 1 ;;
  esac
done

# ---------- 输出工具 ----------
C_OK=$'\033[32m'; C_WARN=$'\033[33m'; C_ERR=$'\033[31m'; C_INFO=$'\033[36m'; C_OFF=$'\033[0m'
info()  { printf '%s[信息]%s %s\n' "$C_INFO" "$C_OFF" "$1"; }
ok()    { printf '%s[完成]%s %s\n' "$C_OK"   "$C_OFF" "$1"; }
warn()  { printf '%s[警告]%s %s\n' "$C_WARN" "$C_OFF" "$1"; }
error() { printf '%s[错误]%s %s\n' "$C_ERR"  "$C_OFF" "$1" >&2; }
die()   { error "$1"; exit 1; }
step()  { printf '\n%s==> %s%s\n' "$C_INFO" "$C_OFF" "$1"; }

confirm() {
  (( ASSUME_YES )) && return 0
  read -r -p "$1 [y/N] " reply
  [[ "$reply" =~ ^[Yy] ]]
}

# ---------- 1. 预检 ----------
preflight() {
  step "预检"
  [[ "$(id -u)" -ne 0 ]] || die "请不要以 root 运行，脚本会自行调用 sudo。"
  command -v pacman  >/dev/null || die "未检测到 pacman，此脚本仅支持 Arch Linux / Arch 系发行版。"
  grep -q '^ID=arch' /etc/os-release || warn "检测到的不是 Arch Linux，将继续但可能出现依赖差异。"
  sudo -v || die "sudo 权限校验失败。"
  ping -c1 -W2 1.1.1.1 >/dev/null 2>&1 || warn "似乎没有网络，安装包阶段可能失败。"
  ok "预检通过"
}

# ---------- 2. 官方仓库包 ----------
OFFICIAL_PKGS=(
  # ---- 你清单里的部分 ----
  hyprland waybar fastfetch kitty fish btop cava nvim
  fcitx5 fcitx5-rime fcitx5-qt fcitx5-gtk fcitx5-configtool
  sddm
  # ---- 底层运行时（第 1 类）----
  pipewire pipewire-pulse pipewire-jack wireplumber
  networkmanager network-manager-applet
  polkit hyprpolkitagent seatd
  xdg-desktop-portal xdg-desktop-portal-hyprland xdg-desktop-portal-gtk
  upower brightnessctl
  bluez bluez-utils blueman
  efibootmgr os-prober intel-ucode amd-ucode
  # ---- 桌面体验（第 2 类）----
  rofi mako hyprlock hypridle
  wl-clipboard cliphist grim slurp swappy
  qt5-wayland qt6-wayland qt5ct qt6ct
  noto-fonts noto-fonts-cjk noto-fonts-emoji ttf-jetbrains-mono-nerd
  # ---- 日常应用（第 3 类）----
  thunar tumbler gvfs gvfs-mtp file-roller
  firefox imv mpv pavucontrol playerctl
  jq git base-devel
)

install_official() {
  step "安装官方仓库软件包（${#OFFICIAL_PKGS[@]} 个）"
  sudo pacman -S --needed --noconfirm -- "${OFFICIAL_PKGS[@]}"
  ok "官方仓库包安装完成"
}

# ---------- 3. AUR 包（lianwall）----------
AUR_PKGS=(lianwall-bin lianwalld-bin lianwall-gui-bin)

ensure_aur_helper() {
  if command -v paru >/dev/null; then AUR_HELPER=paru; return 0; fi
  if command -v yay  >/dev/null; then AUR_HELPER=yay;  return 0; fi

  step "未检测到 AUR 助手，构建 paru-bin"
  local tmp; tmp="$(mktemp -d)"
  sudo pacman -S --needed --noconfirm -- git
  git clone https://aur.archlinux.org/paru-bin.git "$tmp/paru-bin"
  ( cd "$tmp/paru-bin" && makepkg -si --noconfirm )
  rm -rf "$tmp"
  command -v paru >/dev/null || die "paru 构建失败，请手动安装 paru 或 yay 后重跑。"
  AUR_HELPER=paru
  ok "paru 安装完成"
}

install_aur() {
  (( NO_AUR )) && { warn "已按 --no-aur 跳过 AUR 包（lianwall）"; return 0; }
  step "安装 AUR 包: ${AUR_PKGS[*]}"
  ensure_aur_helper
  "$AUR_HELPER" -S --needed --noconfirm -- "${AUR_PKGS[@]}"
  ok "AUR 包安装完成"
}

# ---------- 4. 部署配置文件 ----------
backup_stamp="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$HOME/.config/backup-$backup_stamp"

backup_if_exists() {
  local p="$1"
  [[ -e "$p" ]] || return 0
  mkdir -p "$BACKUP_DIR/$(dirname "${p#"$HOME"/}")"
  mv "$p" "$BACKUP_DIR/${p#"$HOME"/}"
  BACKED_UP=1
}

deploy_configs() {
  step "部署配置文件（旧配置备份到 $BACKUP_DIR）"
  BACKED_UP=0
  local dest
  for item in "$SCRIPT_DIR"/config/*; do
    dest="$HOME/.config/$(basename "$item")"
    backup_if_exists "$dest"
    mkdir -p "$(dirname "$dest")"
    cp -r "$item" "$dest"
  done
  (( BACKED_UP )) && warn "检测到已有配置，已备份至 $BACKUP_DIR"

  # 壁纸
  mkdir -p "$HOME/Pictures/wallpapers"
  cp -n "$SCRIPT_DIR"/assets/wallpapers/* "$HOME/Pictures/wallpapers/" 2>/dev/null || true

  # 用户脚本
  mkdir -p "$HOME/.local/bin"
  install -m 755 "$SCRIPT_DIR"/scripts/*.sh "$HOME/.local/bin/"
  # 去掉 .sh 后缀别名，方便调用
  for f in "$SCRIPT_DIR"/scripts/*.sh; do
    local name; name="$(basename "$f" .sh)"
    install -m 755 "$f" "$HOME/.local/bin/$name"
  done
  ok "配置部署完成（hyprland / waybar / kitty / fish / fcitx5 / nvim / mako / rofi / matugen …）"
}

# ---------- 5. 系统服务 ----------
enable_services() {
  step "启用系统服务"
  sudo systemctl enable --now NetworkManager
  sudo systemctl enable --now bluetooth 2>/dev/null || warn "bluetooth 服务启用失败（无蓝牙硬件可忽略）"
  sudo systemctl enable sddm
  systemctl --user enable --now pipewire pipewire-pulse wireplumber 2>/dev/null || \
    warn "用户级音频服务启用失败，重新登录后再试"
  ok "服务已启用：NetworkManager / sddm / bluetooth / pipewire"
}

# ---------- 6. 默认 Shell ----------
set_default_shell() {
  [[ "$(getent passwd "$USER" | cut -d: -f7)" == "$(command -v fish)" ]] && { ok "默认 Shell 已是 fish"; return 0; }
  if confirm "是否把默认 Shell 改为 fish？"; then
    chsh -s "$(command -v fish)"
    ok "默认 Shell 已改为 fish（重新登录生效）"
  fi
}

# ---------- 7. GRUB 微码检查 ----------
grub_check() {
  step "GRUB 微码检查"
  if [[ ! -f /boot/grub/grub.cfg ]]; then
    warn "未检测到 /boot/grub/grub.cfg，跳过（若你用 systemd-boot 可忽略）。"
    return 0
  fi
  if grep -qE '(intel-ucode|amd-ucode)\.img' /boot/grub/grub.cfg; then
    ok "GRUB 已加载微码"
  else
    warn "grub.cfg 中未发现微码条目，请执行：sudo grub-mkconfig -o /boot/grub/grub.cfg"
  fi
}

# ---------- 8. 体检 ----------
run_doctor() {
  step "部署体检"
  bash "$SCRIPT_DIR/scripts/doctor.sh" || true
}

# ---------- 主流程 ----------
main() {
  if (( CHECK_ONLY )); then run_doctor; exit 0; fi

  cat <<'BANNER'
  ╔══════════════════════════════════════════╗
  ║   arch-hypr-deck · Hyprland 一键部署     ║
  ║   装包 → 配置 → 服务 → 体检             ║
  ╚══════════════════════════════════════════╝
BANNER
  confirm "即将安装 ${#OFFICIAL_PKGS[@]} 个官方包 + 3 个 AUR 包并覆盖部署配置，继续？" \
    || die "用户取消。"

  preflight
  install_official
  install_aur
  deploy_configs
  enable_services
  set_default_shell
  grub_check
  run_doctor

  cat <<'DONE'

  部署完成！
  ├─ 重启后在 SDDM 登录界面选择 "Hyprland" 会话即可进入桌面
  ├─ 默认键位：Super+Enter 终端 / Super+D 启动器 / Super+L 锁屏 / PrtSc 截图
  └─ 更多说明见 README.md；按 Super+M 可退出会话
DONE
  if confirm "是否现在重启？"; then sudo systemctl reboot; fi
}

main "$@"
