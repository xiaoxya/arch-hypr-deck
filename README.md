# arch-hypr-deck

Arch Linux + Hyprland 桌面**一键部署**项目。基于个人软件清单（hyprland、Waybar、fastfetch、fcitx5+rime、GRUB、sddm、kitty、fish、btop、cava、nvim、lianwall、matugen），并补齐了完整桌面所需的全部缺失组件，装完即可日常使用。

- ✅ 一条命令：装包 → 部署配置 → 启服务 → 体检
- ✅ Hyprland 0.56 **Lua 配置**，按功能拆分主/子配置（hyprlang 已被官方弃用）
- ✅ matugen 主题联动：换壁纸 → kitty / waybar / mako 全套自动换色
- ✅ 旧配置自动备份，幂等可重跑，`--check` 独立体检
- ✅ Rime 默认简体中文输出，Electron/Chromium 输入法已配置

## 一键部署

在已安装的 Arch Linux 上（非 root 用户、能 sudo）：

```bash
cd arch-hypr-deck
./install.sh          # 交互式部署
./install.sh --yes    # 全部默认，无需确认
./install.sh --check  # 只体检，不安装
./install.sh --no-aur # 跳过 AUR 包（lianwall）
```

部署完成后**重启**：SDDM 登录界面选择 **Hyprland** 会话即可。

## 软件清单

### 你提供的

`hyprland` `waybar` `fastfetch` `sddm` `kitty` `fish` `btop` `cava` `nvim` `fcitx5+rime` `lianwall`(AUR) `matugen`，GRUB 走系统已有引导。

### 补齐的（共 60+ 官方包 + 3 个 AUR 包）

| 类别 | 补齐内容 |
|---|---|
| 底层运行时 | pipewire / pipewire-pulse / wireplumber（音频，cava 依赖）、NetworkManager + applet、polkit + hyprpolkitagent、seatd、xdg-desktop-portal（Hyprland + GTK 双后端）、upower、brightnessctl、bluez + blueman、微码 + efibootmgr + os-prober |
| 桌面体验 | **rofi**（启动器）、**mako**（通知）、**hyprlock + hypridle**（锁屏/空闲）、wl-clipboard + cliphist、grim + slurp + swappy（截图）、Qt Wayland 化（qt5/6-wayland + qt5/6ct）、中文字体（noto-fonts-cjk）+ Nerd Font |
| 日常应用 | thunar + tumbler + gvfs（文件管理）、firefox、imv、mpv、pavucontrol、playerctl |
| AUR | lianwall-bin / lianwalld-bin / lianwall-gui-bin（自动安装 paru） |

## 配置总览（部署后）

```
~/.config/
├── hypr/                      ← Hyprland 0.56 Lua 配置（见下节）
├── waybar/
│   ├── config.jsonc           模块：工作区/窗口/时钟/托盘/音量/网络/CPU/内存/电池/通知
│   ├── style.css              样式（@import colors.css 实现动态配色）
│   └── colors.css             配色变量（默认值，matugen 自动覆盖，勿手改）
├── kitty/
│   ├── kitty.conf             字体/透明度/滚动等，include colors.conf
│   └── colors.conf            16 色主题（默认值，matugen 自动覆盖）
├── fish/config.fish           别名、EDITOR、fastfetch 欢迎信息
├── fcitx5/profile             Rime 为首个输入法
├── nvim/init.lua              纯 Lua 轻量配置（零插件，开箱即用；lazy.nvim 接入示例见注释）
├── btop/btop.conf             布局/树形进程/主题
├── fastfetch/config.jsonc     显示模块定制
├── mako/config                通知样式（跟随主题色）
├── rofi/config.rasi           启动器主题（drun/run/window）
├── matugen/
│   ├── config.toml            定义 3 个模板：kitty / waybar / mako
│   └── templates/             模板源文件
├── gtk-3.0/ & gtk-4.0/        GTK 暗色主题 + 中文字体
├── electron-flags.conf        Electron 应用（QQ/微信/VS Code）Wayland 输入法
└── chromium-flags.conf        Chromium 浏览器 Wayland 输入法

~/.local/share/fcitx5/rime/
└── default.custom.yaml        Rime 默认简体 + 候选词 7 个

~/Pictures/wallpapers/
└── default.png                项目生成的默认渐变壁纸

~/.local/bin/                  可执行脚本（见"脚本"节）
```

## Hyprland Lua 配置（主 + 子）

依据 [官方 wiki](https://wiki.hypr.land/Configuring/Start/) 与 [官方示例](https://github.com/hyprwm/Hyprland/blob/main/example/hyprland.lua)，主配置只做装配，每个 `require()` 是独立作用域，单文件出错不影响其他模块：

```
~/.config/hypr/
├── hyprland.lua          主配置：require 全部子模块（16 行）
├── vars.lua              共享变量：常用程序 / 修饰键 / 脚本路径
└── modules/
    ├── environment.lua   环境变量：fcitx5 输入法、Wayland 优先
    ├── monitors.lua      显示器（自动适配，多屏示例见注释）
    ├── appearance.lua    间距/边框/渐变描边/圆角/模糊/阴影/动画/布局
    ├── input.lua         键盘/触摸板（自然滚动）/三指手势
    ├── autostart.lua     自启动：waybar、mako、fcitx5、hypridle、
    │                     polkitagent、nm-applet、wallpaper.sh
    ├── keybinds.lua      键位（工作区用 for 循环生成）
    └── rules.lua         窗口规则：小工具浮动、画中画置顶、kitty 半透明、
                          XWayland 修复、屏蔽 maximize
```

**改常用入口只动 `vars.lua`**；每个模块头部都有对应 wiki 链接。

## 主题联动链路（matugen）

```
换壁纸 (wallpaper.sh)
  └─ lianwalld 设壁纸（swww 兜底）
      └─ matugen image <壁纸> 提取 Material You 配色
          ├─ → ~/.config/kitty/colors.conf    终端配色
          ├─ → ~/.config/waybar/colors.css    状态栏配色
          └─ → ~/.config/mako/config          通知配色
              └─ 热重载 waybar / mako / kitty，无需重启
```

## 默认键位

| 按键 | 功能 | 按键 | 功能 |
|---|---|---|---|
| `Super+Enter` | kitty 终端 | `Super+1..9,0` | 工作区切换 |
| `Super+D` | rofi 启动器 | `Super+Shift+1..0` | 移动窗口到工作区 |
| `Super+E` | Thunar 文件管理器 | `Super+←↑↓→` | 焦点移动 |
| `Super+Q` | 关闭窗口 | `Super+拖动` | 移动 / `Super+右键` 调整大小 |
| `Super+L` | 锁屏 hyprlock | `Super+滚轮` | 滚动工作区 |
| `Super+M` | 退出会话 | `Super+V` | 窗口浮动切换 |
| `PrtSc` | 全屏截图（自动复制） | `Shift+PrtSc` | 选区截图 + swappy 编辑 |
| `XF86` 音量键 | wpctl 调节（锁屏可用+长按连发） | `XF86` 亮度键 | brightnessctl |

## 脚本（部署到 ~/.local/bin）

| 脚本 | 说明 |
|---|---|
| `wallpaper.sh` | 起 lianwalld → 设壁纸 → matugen 取色 → 热刷新主题（swww 兜底） |
| `screenshot.sh` | grim 截图 → wl-copy 复制 → 通知，选区模式唤起 swappy |
| `launcher.sh` | rofi 启动器入口 |
| `doctor.sh` | 体检：60+ 命令、配置文件、服务状态逐项核对 |

## 中文输入（fcitx5 + rime）

- 链路：`hl.env` 注入 `GTK_IM_MODULE/QT_IM_MODULE/XMODIFIERS` → autostart 启动 `fcitx5 -d`
- `Ctrl+Space` 中英切换；Rime 内 `F4` 选方案；默认**简体**输出（`default.custom.yaml`）
- Electron 应用与 Chromium 已通过 `*-flags.conf` 启用 Wayland 输入法，无需手动传参
- 排查：`fcitx5-diagnose`

## 体检项（doctor.sh）

- **软件包**：60+ 核心命令逐个检查，lianwall 缺失降级为警告（有 swww 兜底）
- **配置文件**：hyprland.lua、waybar、kitty、fish、fcitx5、rime 简体配置、nvim、mako、rofi、matugen、壁纸
- **服务**：NetworkManager / sddm 启用状态、bluetooth、pipewire 运行状态
- 结果分三色汇总，存在失败项即非零退出

## 注意事项

- **NVIDIA** 显卡需自行安装驱动并配置 Hyprland 启动参数，脚本不自动处理
- **GRUB 微码**：安装后若 `grub.cfg` 无微码条目，脚本会提示执行 `sudo grub-mkconfig -o /boot/grub/grub.cfg`
- **旧配置备份**：覆盖前自动备份到 `~/.config/backup-<时间戳>`
- **重复运行**：幂等设计（`pacman --needed` / `cp -n`），可随时重跑修复
- lianwall 的 CLI 参数以[上游文档](https://github.com/Yueosa/lianwall)为准，`wallpaper.sh` 中 `lianwall set` 如有出入改那一行即可
- 手动改主题色请改 `colors.css` 对应的 **matugen 模板**（`~/.config/matugen/templates/`），直接改 `colors.css` 会被下次换壁纸覆盖

## 项目仓库结构

```
arch-hypr-deck/
├── install.sh        一键部署入口
├── config/           dotfiles（install.sh 负责映射到 ~/.config 等）
├── assets/
│   ├── rime/         Rime 简体配置 → ~/.local/share/fcitx5/rime/
│   └── wallpapers/   默认壁纸 → ~/Pictures/wallpapers/
├── scripts/          部署到 ~/.local/bin + doctor.sh
└── README.md
```
