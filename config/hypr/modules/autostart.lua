-- modules/autostart.lua — 自动启动
-- 参考：https://wiki.hypr.land/Configuring/Basics/Autostart/
-- 注意：hyprland.start 只在启动时执行一次，配置热重载不会重复启动

hl.on("hyprland.start", function()
    hl.exec_cmd("waybar")                                   -- 状态栏
    hl.exec_cmd("mako")                                     -- 通知守护进程
    hl.exec_cmd("fcitx5 -d --replace")                      -- 输入法
    hl.exec_cmd("hypridle")                                 -- 空闲管理
    hl.exec_cmd("nm-applet --indicator")                    -- 网络托盘
    hl.exec_cmd("systemctl --user start hyprpolkitagent.service 2>/dev/null || true")
    hl.exec_cmd("~/.local/bin/wallpaper.sh")                -- lianwall 壁纸 + matugen 主题
end)
