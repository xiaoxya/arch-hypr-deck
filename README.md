# arch-hypr-deck

Arch Linux + Hyprland 桌面一键部署。基于你的软件清单（hyprland、Waybar、fastfetch、fcitx5+rime、GRUB、sddm、kitty、fish、btop、cava、nvim、lianwall、matugen），并补齐了完整桌面所需的全部缺失组件。

## 一键部署

在已安装的 Arch Linux 上（非 root 用户、能 sudo）：

```bash
cd arch-hypr-deck
./install.sh          # 交互式部署
./install.sh --yes    # 全部默认，无需确认
```

部署内容：

1. **官方仓库包** — 70+ 个（见 `install.sh` 中 `OFFICIAL_PKGS`）
2. **AUR 包** — lianwall-bin / lianwalld-bin / lianwall-gui-bin（自动装 paru）
3. **配置文件** — 全套 dotfiles（旧配置自动备份到 `~/.config/backup-<时间戳>`）
4. **系统服务** — NetworkManager / sddm / bluetooth / pipewire
5. **体检** — `scripts/doctor.sh` 验证部署结果

部署完成后**重启即可**：SDDM 登录界面选择 **Hyprland** 会话。

## 清单对照

| 你提供的 | 补齐的缺失 |
|---|---|
| hyprland waybar fastfetch sddm kitty fish btop cava nvim | rofi（启动器）、mako（通知）、hyprlock+hypridle（锁屏/空闲） |
| fcitx5 + rime | fcitx5-qt/gtk/configtool + 环境变量（已写入 hyprland.conf） |
| GRUB | intel/amd 微码 + efibootmgr + os-prober + 检查逻辑 |
| lianwall（AUR） | 自动装 paru → 装 AUR 包；swww 兜底方案 |
| matugen | 模板打通 kitty / waybar / mako 主题自动换色 |

补齐的底层：pipewire 全家桶、NetworkManager+applet、polkit agent、xdg-desktop-portal（Hyprland 版 + GTK）、seatd、剪贴板（wl-clipboard/cliphist）、截图（grim+slurp+swappy）、亮度/音量控制、Qt Wayland 化、中文字体（noto-fonts-cjk）、Thunar 文件管理器、Firefox、mpv 等。

## Hyprland 配置（0.56 Lua 格式）

Hyprland 0.55 起弃用 hyprlang，改用 Lua（`~/.config/hypr/hyprland.lua`）。本项目已完整迁移，并按功能拆分为主配置 + 子配置：

```
~/.config/hypr/
├── hyprland.lua            ← 主配置：只负责 require 装配
├── vars.lua                ← 共享变量（常用程序、修饰键、脚本路径）
└── modules/
    ├── environment.lua     环境变量（fcitx5 输入法、Wayland 优先）
    ├── monitors.lua        显示器
    ├── appearance.lua      外观：间距/边框/圆角/模糊/动画/布局
    ├── input.lua           键盘/触摸板/手势
    ├── autostart.lua       自动启动（waybar/fcitx5/wallpaper 等）
    ├── keybinds.lua        键位（Lua 循环生成工作区键位）
    └── rules.lua           窗口/工作区规则
```

- 每个 `require()` 是独立作用域，单个子配置出错不影响其他文件加载
- 改常用程序只需编辑 `vars.lua`
- 语法基于官方 wiki 与 Hyprland 仓库 example/hyprland.lua

## 默认键位

| 按键 | 功能 |
|---|---|
| `Super+Enter` | kitty 终端 |
| `Super+D` | rofi 启动器 |
| `Super+E` | Thunar 文件管理器 |
| `Super+Q` | 关闭窗口 |
| `Super+L` | 锁屏（hyprlock） |
| `Super+M` | 退出会话 |
| `PrtSc` / `Shift+PrtSc` | 全屏 / 选区截图（自动复制） |
| `Super+1..5`（+Shift） | 切换/移动工作区 |
| `XF86` 音量/亮度键 | 已绑定 |

## 关键脚本（部署到 ~/.local/bin）

- `wallpaper.sh` — 起动 lianwalld → 设壁纸 → matugen 取色 → 热刷新 kitty/waybar/mako 主题
- `screenshot.sh` — grim+slurp 截图，swappy 编辑
- `launcher.sh` — rofi 启动器
- `doctor.sh` — 体检（也可独立运行：`./install.sh --check`）

## 中文输入（fcitx5 + rime）

已预置 profile（首个输入法为 Rime）。进入桌面后用 `Ctrl+Space` 切换输入法；右键 fcitx5 托盘图标 → 配置，可添加更多方案（明月拼音等在 Rime 中按 `F4` 选择）。

## 注意事项

- NVIDIA 显卡需额外装 `nvidia-dkms` 等驱动并配置 hyprland 启动参数，本脚本未自动处理。
- lianwall 的 CLI 参数以 [上游文档](https://github.com/Yueosa/lianwall) 为准，`wallpaper.sh` 中已做 swww 兜底。
- 若 GRUB 中无微码条目，脚本结束时会提示执行 `sudo grub-mkconfig -o /boot/grub/grub.cfg`。
