-- vars.lua — 共享变量（被主配置与所有子模块引用）
-- 修改常用程序入口只需改这里
return {
    main_mod         = "SUPER",
    terminal         = "kitty",
    file_manager     = "thunar",
    menu             = os.getenv("HOME") .. "/.local/bin/launcher.sh",
    lock_cmd         = "hyprlock",
    wallpaper_cmd    = os.getenv("HOME") .. "/.local/bin/wallpaper.sh",
    screenshot_full  = os.getenv("HOME") .. "/.local/bin/screenshot.sh full",
    screenshot_region = os.getenv("HOME") .. "/.local/bin/screenshot.sh region",
}
