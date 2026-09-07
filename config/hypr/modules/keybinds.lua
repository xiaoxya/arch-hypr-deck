-- modules/keybinds.lua — 键位
-- 参考：https://wiki.hypr.land/Configuring/Basics/Binds/
-- 第三参 flags：{ mouse = true } / { locked = true, repeating = true }

local vars = require("vars")
local mod  = vars.main_mod

-- 程序启动
hl.bind(mod .. " + Return", hl.dsp.exec_cmd(vars.terminal))
hl.bind(mod .. " + E",      hl.dsp.exec_cmd(vars.file_manager))
hl.bind(mod .. " + D",      hl.dsp.exec_cmd(vars.menu))

-- 窗口操作
hl.bind(mod .. " + Q", hl.dsp.window.close())
hl.bind(mod .. " + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mod .. " + J", hl.dsp.layout("togglesplit")) -- dwindle 专用
hl.bind(mod .. " + M", hl.dsp.exec_cmd("command -v hyprshutdown >/dev/null 2>&1 && hyprshutdown || hyprctl dispatch 'hl.dsp.exit()'"))

-- 锁屏 / 截图
hl.bind(mod .. " + L",       hl.dsp.exec_cmd(vars.lock_cmd))
hl.bind("Print",             hl.dsp.exec_cmd(vars.screenshot_full))
hl.bind("SHIFT + Print",     hl.dsp.exec_cmd(vars.screenshot_region))

-- 焦点移动
hl.bind(mod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- 工作区：mod+数字切换，mod+shift+数字移动窗口（Lua 循环，比 hyprlang 省事）
for i = 1, 10 do
    local key = i % 10 -- 10 映射到 0
    hl.bind(mod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- 滚轮切换工作区
hl.bind(mod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

-- 鼠标拖动移动 / 缩放窗口
hl.bind(mod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- 音量（锁屏也可用 + 长按连发）
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),        { locked = true, repeating = true })
hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),       { locked = true, repeating = true })

-- 媒体控制
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"),   { locked = true })

-- 亮度（长按连发）
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl set 5%-"), { locked = true, repeating = true })

-- Lua 函数 dispatcher 示例（比命令行更灵活）
-- hl.bind(mod .. " + X", function()
--     hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
-- end)
