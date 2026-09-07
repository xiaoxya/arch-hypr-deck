-- modules/appearance.lua — 外观：间距 / 边框 / 圆角 / 模糊 / 阴影 / 动画 / 布局
-- 参考：https://wiki.hypr.land/Configuring/Basics/Variables/

hl.config({
    general = {
        gaps_in     = 5,
        gaps_out    = 10,
        border_size = 2,

        col = {
            active_border   = { colors = { "rgba(a78bfaee)", "rgba(60a5faee)" }, angle = 45 },
            inactive_border = "rgba(45475a99)",
        },

        resize_on_border = true,
        allow_tearing    = false,
        layout           = "dwindle",
    },

    decoration = {
        rounding         = 8,
        rounding_power   = 2,
        active_opacity   = 1.0,
        inactive_opacity = 0.96,

        shadow = {
            enabled      = true,
            range        = 12,
            render_power = 3,
            color        = 0xee1a1a1a,
        },

        blur = {
        enabled           = true,
        size              = 5,
        passes            = 2,
        new_optimizations = true,
        },
    },

    animations = {
        enabled = true,
    },

    misc = {
        force_default_wallpaper = -1,
        disable_hyprland_logo   = false,
    },

    dwindle = {
        pseudotile     = true,
        preserve_split = true,
    },

    master = {
        new_status = "master",
    },
})

-- 缓动曲线（官方默认 + 平滑曲线）
hl.curve("smooth",         { type = "bezier", points = { { 0.25, 0.1 }, { 0.25, 1 } } })
hl.curve("easeOutQuint",   { type = "bezier", points = { { 0.23, 1 },   { 0.32, 1 } } })
hl.curve("almostLinear",   { type = "bezier", points = { { 0.5, 0.5 },  { 0.75, 1 } } })
hl.curve("quick",          { type = "bezier", points = { { 0.15, 0 },   { 0.1, 1 } } })
hl.curve("easy",           { type = "spring", mass = 1, stiffness = 238.1191, damping = 24.21279333 })

-- 动画（叶子节点见 wiki Animations 页）
hl.animation({ leaf = "global",     enabled = true, speed = 6,  bezier = "smooth" })
hl.animation({ leaf = "windows",    enabled = true, speed = 5,  spring = "easy" })
hl.animation({ leaf = "windowsIn",  enabled = true, speed = 4,  spring = "easy",   style = "popin 80%" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 2,  bezier = "smooth", style = "popin 80%" })
hl.animation({ leaf = "fade",       enabled = true, speed = 4,  bezier = "quick" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 4,  bezier = "smooth", style = "slide" })
