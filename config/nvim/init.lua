-- ~/.config/nvim/init.lua — arch-hypr-deck
-- 轻量纯 Lua 配置，无第三方插件依赖，开箱即用。
-- 需要插件生态时可自行接入 lazy.nvim（见文件末尾注释）。

local o = vim.opt

-- 基础
o.number = true
o.relativenumber = true
o.mouse = "a"
o.clipboard = "unnamedplus"
o.breakindent = true
o.undofile = true
o.ignorecase = true
o.smartcase = true
o.signcolumn = "yes"
o.updatetime = 250
o.timeoutlen = 400
o.completeopt = "menu,preview,noselect"
o.termguicolors = true
o.cursorline = true
o.scrolloff = 8
o.sidescrolloff = 8
o.tabstop = 4
o.shiftwidth = 4
o.expandtab = true
o.smartindent = true
o.splitright = true
o.splitbelow = true

-- 快捷键
local map = vim.keymap.set
map("n", "<C-h>", "<C-w>h", { desc = "窗口左" })
map("n", "<C-j>", "<C-w>j", { desc = "窗口下" })
map("n", "<C-k>", "<C-w>k", { desc = "窗口上" })
map("n", "<C-l>", "<C-w>l", { desc = "窗口右" })
map("n", "<Esc><Esc>", ":nohlsearch<CR>", { desc = "取消高亮" })
map("v", "<", "<gv")
map("v", ">", ">gv")
map("n", "<leader>w", ":w<CR>", { desc = "保存" })
map("n", "<leader>q", ":q<CR>", { desc = "退出" })

-- 主题（跟随 kitty 的 matugen 主题色则由终端透传，这里用内置暗色）
vim.cmd.colorscheme("default")
o.background = "dark"

--[[
-- 可选：接入 lazy.nvim 插件生态（需网络）：
-- local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
-- if not vim.uv.fs_stat(lazypath) then
--   vim.fn.system({ "git", "clone", "--filter=blob:none",
--     "https://github.com/folke/lazy.nvim.git", lazypath })
-- end
-- vim.opt.rtp:prepend(lazypath)
-- require("lazy").setup({ "folke/tokyonight.nvim", "neovim/nvim-lspconfig" })
--]]
