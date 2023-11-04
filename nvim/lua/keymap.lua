-- Yank and copy to system clipboard

vim.keymap.set("n", "yy", '"+yy', { noremap = true, silent = true })
vim.keymap.set("v", "y", '"+y', { noremap = true, silent = true })
vim.keymap.set("n", "y$", '"+y$', { noremap = true, silent = true })
vim.keymap.set("n", "yw", '"+yw', { noremap = true, silent = true })
-- Paste from system clipboard
vim.keymap.set("n", "p", '"+p', { noremap = true, silent = true })
vim.keymap.set("n", "P", '"+P', { noremap = true, silent = true })
vim.keymap.set("v", "p", '"+p', { noremap = true, silent = true })
vim.keymap.set("v", "P", '"+P', { noremap = true, silent = true })
-- Move Line
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '>-2<CR>gv=gv")

-- New Line
vim.keymap.set("n", "<leader><CR>", function()
    vim.cmd('startinsert!')
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<CR>", true, false, true), 'n', true)
end, { desc = "New Line", silent = true, noremap = true })

-- Better navigation between lines
vim.keymap.set("n", "\\", "$a", { desc = "End of Line", silent = true, noremap = true })
vim.keymap.set("n", "<BS>", "k^", { desc = "Start Prev of Line", silent = true, noremap = true })
vim.keymap.set("n", "0", "^", { desc = "Move to Start of indent", silent = true, noremap = true })
vim.keymap.set("i", "<M-0>", '<Esc>/\\s*[(<]<CR>a',
    { desc = "Move to after opening bracket", silent = true, noremap = true })
vim.keymap.set("i", "<M-\\>", '<Esc>l/\\s*[)>]<CR>i',
    { desc = "Move to before closing bracket", silent = true, noremap = true })


-- Search and Replace
vim.keymap.set(
    "n",
    "<leader>s",
    [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
    { desc = "Search and Replace" }
)

-- Insert Text in front
vim.keymap.set("v", "<leader>a", [[:s/^/ /<Left>]], { desc = "Insert Text in front of line" })

-- Remove first few characters from each selected line
vim.keymap.set(
    "v",
    "<leader>d",
    [[:s/^.\{N\}//<Left><Left><Left>]],
    { desc = "Remove first N characters from selected lines" }
)

-- Move between vertical split
vim.keymap.set("n", "<leader>[", "<C-w>h", { desc = "Move to Left Split", noremap = true, silent = true })
vim.keymap.set("n", "<leader>]", "<C-w>l", { desc = "Move to Right Split", noremap = true, silent = true })

-- Telescope
local telescope_builtin = require("telescope.builtin")

vim.keymap.set("n", "<leader>f", telescope_builtin.find_files, { desc = "Find Files" })
vim.keymap.set("n", "<leader>g", telescope_builtin.live_grep, { desc = "Live Grep" })
vim.keymap.set("n", "<leader>u", "<cmd>Telescope undo<cr>", { desc = "Undo Tree" })

-- Open parent dir
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
-- Previous Buffer
vim.keymap.set(
    'n', '=', ":b#<CR>",
    { desc = "Previous buffer", noremap = true, silent = true }
)


-- Vertically split the window
vim.keymap.set("n", "<leader>v", ":vsp<CR>", { desc = "Vertical Split" })

-- Open a terminal in the current window
vim.keymap.set("n", "<leader>t", ":terminal<CR>", { desc = "Open Terminal" })

-- Escape from terminal mode and get back to normal mode
vim.keymap.set("t", "<C-d>", "<C-\\><C-n>", { desc = "Escape Terminal" })



-- Show LSP diagnostics in another buffer
local diagnostics = require('utils.diagnostics')

vim.keymap.set(
    'n', '<leader>b',
    diagnostics.ShowDiagnosticsInBuffer,
    { desc = "Show Diagnostics in Current Buffer", noremap = true, silent = true }
)
