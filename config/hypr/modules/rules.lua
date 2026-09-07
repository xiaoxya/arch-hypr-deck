-- modules/rules.lua — 窗口规则 / 工作区规则
-- 参考：https://wiki.hypr.land/Configuring/Basics/Window-Rules/
-- match 字段：class / title / float / fullscreen / pin / workspace / tag ...
-- 属性：float / pin / move / size / opacity / border_size / rounding / no_focus / suppress_event ...

-- 常用小工具默认浮动
hl.window_rule({
    name  = "float-pavucontrol",
    match = { class = "^(pavucontrol)$" },
    float = true,
})
hl.window_rule({
    name  = "float-blueman",
    match = { class = "^(blueman-manager)$" },
    float = true,
})
hl.window_rule({
    name  = "float-nm-editor",
    match = { class = "^(nm-connection-editor)$" },
    float = true,
})

-- 画中画：浮动 + 置顶
hl.window_rule({
    name  = "pip",
    match = { title = "^(Picture-in-Picture)$" },
    float = true,
    pin   = true,
    size  = { 960, 540 },
})

-- kitty 半透明（matugen 主题下更好看）
hl.window_rule({
    name    = "kitty-translucent",
    match   = { class = "^(kitty)$" },
    opacity = "0.92",
})

-- 修复 XWayland 拖动问题（官方推荐）
hl.window_rule({
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})

-- 屏蔽所有窗口的 maximize 请求（官方推荐，体验更一致）
hl.window_rule({
    name           = "suppress-maximize-events",
    match          = { class = ".*" },
    suppress_event = "maximize",
})

-- 工作区规则示例（"smart gaps"：仅一个窗口时去间距，需要时取消注释）
-- hl.workspace_rule({ workspace = "w[tv1]", gaps_out = 0, gaps_in = 0 })
-- hl.workspace_rule({ workspace = "f[1]",   gaps_out = 0, gaps_in = 0 })
