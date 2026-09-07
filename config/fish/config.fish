# ~/.config/fish/config.fish — arch-hypr-deck

if status is-interactive
    # 命令打错自动建议纠正
    fish_default_key_bindings

    # 常用别名
    alias ll 'ls -lah --color=auto'
    alias grep 'grep --color=auto'
    alias clip 'wl-copy'
    alias paste 'wl-paste'

    # 用 kitty 打开时设置终端标题
    function set_title --on-event fish_prompt
        echo -ne "\033]0;(pwd | basename)\007"
    end

    # 登录显示系统信息
    type -q fastfetch; and fastfetch
end

set -gx EDITOR nvim
set -gx VISUAL nvim
fish_add_path -g $HOME/.local/bin
