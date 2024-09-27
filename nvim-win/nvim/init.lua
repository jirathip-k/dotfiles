require("lazy-plugins-manager")
require("setting")
require("keymap")

local os = require("os")

local path_to_desktop = os.getenv("USERPROFILE") .. "\\quant_main"

local vim_enter_group = vim.api.nvim_create_augroup("vim_enter_group", { clear = true })

vim.api.nvim_create_autocmd(
    {"VimEnter"},
    { pattern = "*", command = "cd " .. path_to_desktop, group = vim_enter_group }
)


vim.g.python3_host_prog = "$PYENV_ROOT/shims/python"

if vim.g.neovide then
    -- vim.o.guifont = "JetBrainsMono NF:h12"
    vim.g.neovide_padding_top = 50
    vim.g.neovide_padding_bottom = 50
    vim.g.neovide_padding_right = 50
    vim.g.neovide_padding_left = 50
    vim.g.neovide_transparency = 0.99
    vim.api.nvim_set_hl(0, "Normal", { bg = "#232634" })
end
