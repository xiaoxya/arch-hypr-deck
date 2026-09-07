-- modules/input.lua — 键盘 / 触摸板 / 手势 / 外设
-- 参考：https://wiki.hypr.land/Configuring/Basics/Variables/ 与 Devices 页

hl.config({
    input = {
        kb_layout    = "us",
        follow_mouse = 1,
        sensitivity  = 0, -- -1.0 ~ 1.0，0 为不修改

        touchpad = {
            natural_scroll = true,
        },
    },
})

hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})

-- 按设备名单独配置（hyprctl devices 查看名称）
-- hl.device({ name = "epic-mouse-v1", sensitivity = -0.5 })
