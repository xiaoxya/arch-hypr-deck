-- ~/.config/hypr/hyprland.lua — arch-hypr-deck 主配置
-- Hyprland 0.56+ Lua 配置（0.55 起官方推荐，hyprlang 已弃用）
-- 结构：主配置只负责装配，各功能拆分到 modules/ 子配置
-- 语法参考：https://wiki.hypr.land/Configuring/Start/

-- 共享变量（程序路径、修饰键等），各子模块通过 require("vars") 获取
require("vars")

-- 子配置：按功能拆分，任一文件出错不影响其他文件加载
require("modules/environment")  -- 环境变量（含 fcitx5 输入法）
require("modules/monitors")     -- 显示器
require("modules/appearance")   -- 外观：间距/边框/圆角/模糊/动画/布局
require("modules/input")        -- 键盘/触摸板/手势
require("modules/autostart")    -- 自动启动
require("modules/keybinds")     -- 键位
require("modules/rules")        -- 窗口/工作区规则
