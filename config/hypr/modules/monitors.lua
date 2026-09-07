-- modules/monitors.lua — 显示器配置
-- 参考：https://wiki.hypr.land/Configuring/Basics/Monitors/
-- 默认自动适配所有显示器；多显示器用户可按接口名（如 eDP-1、DP-1）逐个配置

hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})

-- 示例：笔记本内屏 + 外接显示器
-- hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto",  scale = 1.25 })
-- hl.monitor({ output = "DP-1",  mode = "2560x1440@144", position = "auto-right", scale = 1 })
-- hl.monitor({ output = "HDMI-A-1", disabled = true })
