# Hyprland Lua 子配置（modules/）教程

本文是 `~/.config/hypr/modules/` 下各子配置的使用教程 + 可直接抄的实例。语法基于 Hyprland 0.56 官方 wiki 与 `example/hyprland.lua`，改完保存即热重载（也可手动 `hyprctl reload`）。

## 0. 加载机制（先懂这个再动手）

```
hyprland.lua（主配置，只做装配）
  ├─ require("vars")              → hypr/vars.lua
  ├─ require("modules/environment") → hypr/modules/environment.lua
  └─ ... 共 7 个子模块
```

- **路径相对 `hyprland.lua` 所在目录**解析，`/` 和 `.` 都可作分隔符：`require("modules/keybinds")` ≡ `require("modules.keybinds")`
- **每个 `require()` 是独立作用域**：某文件运行出错只弹通知、跳过该文件，其余模块照常加载——所以改单个模块很安全
- 要求模块必须存在，否则抛错并中断当前文件；不确定存在时用 `pcall`：

```lua
local ok, err = pcall(require, "myOptionalModule")
if not ok then print("加载失败: " .. err) end
```

- 支持通配符与绝对路径：`require("./modules/*")`
- 主配置出错时 Hyprland 给紧急键位：`Super+Q` 终端 / `Super+R` 运行 / `Super+M` 退出

## 1. vars.lua — 共享变量

被主配置和所有子模块 `require`（Lua 缓存保证拿到同一张表）。**改常用程序入口只动这个文件**：

```lua
-- vars.lua
return {
    main_mod         = "SUPER",      -- 主修饰键：换成 "ALT" 即全局换修饰键
    terminal         = "kitty",      -- 换成 "foot" / "alacritty" 等
    file_manager     = "thunar",
    menu             = os.getenv("HOME") .. "/.local/bin/launcher.sh",
    lock_cmd         = "hyprlock",
    ...
}
```

加一个自己的变量：

```lua
return {
    ...,
    browser = "firefox",
    editor  = "nvim",
}
```

之后在任何模块里 `local vars = require("vars")` 然后 `vars.browser` 使用。

## 2. environment.lua — 环境变量

一行一个，等号写法换成函数调用：

```lua
hl.env("XCURSOR_SIZE", "24")
hl.env("XMODIFIERS", "@im=fcitx")   -- fcitx5 必需
```

注意：`hl.env` 设置的变量对 Hyprland 之后启动的所有子进程生效（含 autostart 里的程序）。

## 3. monitors.lua — 显示器

默认一条规则自动适配所有屏幕。多屏实例：

```lua
-- 笔记本内屏 125% 缩放，外接屏在其右侧
hl.monitor({ output = "eDP-1", mode = "preferred",     position = "auto",       scale = 1.25 })
hl.monitor({ output = "DP-1",  mode = "2560x1440@144", position = "auto-right", scale = 1 })

-- 禁用某块屏
hl.monitor({ output = "HDMI-A-1", disabled = true })

-- 指定位置：外接屏放内屏上方
hl.monitor({ output = "DP-1", position = "0x-1440" })
```

接口名用 `hyprctl monitors` 查看。改完即时生效，不用重启。

## 4. appearance.lua — 外观与动画

改间距 / 圆角 / 模糊，都在 `hl.config` 对应字段里：

```lua
hl.config({
    general = {
        gaps_in = 3,            -- 窗口间距（原 5）
        gaps_out = 15,          -- 屏幕边缘间距
        border_size = 3,
        col = {                 -- 渐变描边：颜色数组 + 角度
            active_border = { colors = { "rgba(89b4faee)", "rgba(a6e3a1ee)" }, angle = 45 },
        },
    },
    decoration = {
        rounding = 12,          -- 圆角
        blur = {
            enabled = true,
            size = 6,           -- 模糊强度
            passes = 3,         -- 模糊次数，越大越糊越费性能
            vibrancy = 0.2,
        },
    },
})
```

**新增动画曲线**：贝塞尔用 `points`（4 个控制点坐标），弹簧用 `mass/stiffness/damping`：

```lua
hl.curve("myEase",  { type = "bezier", points = { { 0.05, 0.7 }, { 0.1, 1 } } })
hl.curve("mySpring",{ type = "spring", mass = 0.8, stiffness = 180, damping = 20 })

hl.animation({ leaf = "windows", enabled = true, speed = 6, bezier = "myEase" })
```

常用 `leaf`：`global` / `windows` / `windowsIn` / `windowsOut` / `fade` / `workspaces` / `layers`（完整列表见 wiki Animations 页）。

**布局切换**：`general.layout` 改 `"dwindle"` / `"master"` / `"scrolling"`，对应布局参数在同文件 `dwindle = {...}` / `master = {...}` 里调。

**Smart gaps**（只有一个窗口时去间距）示例已在 rules.lua 注释里，取消注释即可：

```lua
hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
```

## 5. input.lua — 输入设备

```lua
hl.config({
    input = {
        kb_layout = "us",                  -- 多布局："us,cn"（需 xkeyboard-config 支持）
        numlock_by_default = true,         -- 可加：默认开小键盘
        touchpad = {
            natural_scroll = true,
            tap_to_click = true,           -- 可加：轻触点击
            scroll_factor = 0.5,           -- 可加：滚动速度
        },
    },
})
```

**外设精调**（名字用 `hyprctl devices` 查），取消注释即用：

```lua
hl.device({ name = "logitech-g502", sensitivity = -0.3 })
```

**手势**：3 指横滑切工作区（已启用）。换 4 指：

```lua
hl.gesture({ fingers = 4, direction = "horizontal", action = "workspace" })
```

## 6. autostart.lua — 自启动

在 `hyprland.start` 回调里加一行即可，**只在启动时执行一次，热重载不会重复拉起**：

```lua
hl.on("hyprland.start", function()
    hl.exec_cmd("waybar")
    hl.exec_cmd("fcitx5 -d --replace")
    -- 示例：延迟启动（避免和壁纸/主题抢启动顺序）
    hl.exec_cmd("sleep 2 && nextcloud-client")
end)
```

也可以用带条件判断的纯 Lua 逻辑（这是 Lua 配置相对旧格式的核心优势）：

```lua
hl.on("hyprland.start", function()
    if os.getenv("LAPTOP") == "1" then
        hl.exec_cmd("powersave-mode")
    end
end)
```

## 7. keybinds.lua — 键位

### 基本格式

```lua
hl.bind("修饰键 + 键", dispatcher [, flags])
```

### 换程序启动键（最常见需求）

```lua
local vars = require("vars")
hl.bind(vars.main_mod .. " + B", hl.dsp.exec_cmd(vars.browser))  -- 记得先在 vars.lua 加 browser
```

### 常用 dispatcher 速查

| 写法 | 作用 |
|---|---|
| `hl.dsp.exec_cmd("命令")` | 执行命令 |
| `hl.dsp.window.close()` | 关闭当前窗口 |
| `hl.dsp.window.float({ action = "toggle" })` | 浮动切换 |
| `hl.dsp.window.move({ workspace = 3 })` | 移动到工作区 3 |
| `hl.dsp.focus({ direction = "left" })` | 方向移动焦点 |
| `hl.dsp.focus({ workspace = 5 })` | 跳到工作区 5 |
| `hl.dsp.layout("togglesplit")` | dwindle 分屏切换 |
| `hl.dsp.workspace.toggle_special("magic")` | scratchpad 临时工作区 |

### flags（第三参）

```lua
-- 长按连发 + 锁屏可用（音量键同款）
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl set 5%+"),
        { locked = true, repeating = true })

-- 鼠标键：mouse:272 左键 / 273 右键，必须加 { mouse = true }
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(),   { mouse = true })
```

### Lua 函数做 dispatcher（进阶）

按键执行一段逻辑而不是单条命令：

```lua
hl.bind("SUPER + X", function()
    -- 例：仅当当前窗口是浮动时才关闭
    hl.dispatch(hl.dsp.window.close())
end)
```

### 工作区键位就是一段循环

```lua
for i = 1, 10 do
    local key = i % 10                       -- 10 映射到数字键 0
    hl.bind(vars.main_mod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(vars.main_mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end
```

想扩到 20 个工作区？改成 `for i = 1, 20` 并自己处理两位数键名即可——这正是 Lua 配置比旧格式省事的地方。

### scratchpad（临时终端）示例

```lua
hl.bind("SUPER + S",         hl.dsp.workspace.toggle_special("magic"))
hl.bind("SUPER + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))
-- 配合 rules.lua 里的窗口规则给 special 工作区窗口设尺寸
```

## 8. rules.lua — 窗口规则

### 格式

```lua
hl.window_rule({
    name  = "规则名（便于调试识别）",
    match = { class = "正则", title = "正则", float = true, workspace = "2", ... },
    -- ↓ 要施加的属性（可多个）
    float = true,
})
```

### match 匹配字段

`class` / `title`（POSIX 正则）、`float`、`fullscreen`、`pin`、`xwayland`、`workspace`、`tag`。取反在正则里做，如 `class = "^(?!kitty)"` 不支持，用规则开关代替。

### 常用属性速查

| 属性 | 示例 | 说明 |
|---|---|---|
| `float` | `float = true` | 浮动 |
| `pin` | `pin = true` | 所有工作区可见（画中画） |
| `opacity` | `opacity = "0.92"` | 透明度 |
| `size` | `size = { 960, 540 }` | 浮动尺寸 |
| `move` | `move = "20 monitor_h-120"` | 指定位置 |
| `no_focus` | `no_focus = true` | 不抢焦点 |
| `border_size` / `rounding` | `rounding = 0` | 覆盖外观设置 |
| `no_anim` / `no_blur` / `no_shadow` | `no_blur = true` | 关特效 |
| `suppress_event` | `suppress_event = "maximize"` | 屏蔽事件 |

### 实例：给微信窗口浮动并去模糊

```lua
hl.window_rule({
    name  = "wechat-float",
    match = { title = "^(微信|WeChat)$" },
    float = true,
    no_blur = true,
})
```

### 规则句柄：运行时开关

`hl.window_rule` 返回句柄，可以禁用/启用（适合调试或做场景切换）：

```lua
local rule = hl.window_rule({ name = "no-maximize", match = { class = ".*" }, suppress_event = "maximize" })
-- rule:set_enabled(false)
```

### 层级（layer-shell）规则

针对 waybar、通知弹层等：

```lua
hl.layer_rule({ match = { namespace = "^my-overlay$" }, no_anim = true })
```

## 9. 新建一个自己的子模块

1. 新建 `hypr/modules/myconf.lua`，随便调 `hl.*`
2. 主配置 `hyprland.lua` 加一行 `require("modules/myconf")`
3. 保存即热重载；写错只影响本文件

模块之间共享状态就用 `vars.lua` 返回表的模式（每个模块 `require("vars")`）。

## 10. 调试技巧

| 需求 | 命令 |
|---|---|
| 手动重载 | `hyprctl reload` |
| 查显示器 | `hyprctl monitors` |
| 查输入设备 | `hyprctl devices` |
| 查窗口 class/title（写规则前先查） | `hyprctl clients` |
| 交互式 Lua 调试 | `hyprctl repl` |
| LSP 补全 | 把 `/usr/share/hypr/stubs/` 加进 `.luarc.json` 的 `workspace.library` |
| 本地语法校验 | `luajit -bl <文件> /dev/null`（无 hl 环境，只查语法） |
