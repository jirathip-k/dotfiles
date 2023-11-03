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
-- Move
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '>-2<CR>gv=gv")

-- New Line
vim.keymap.set("n", "<leader><CR>", "$o<Esc>", { desc = "New Line", silent = true, noremap = true })
vim.keymap.set("n", "\\", "$", { desc = "End of Line", silent = true, noremap = true })
vim.keymap.set("n", "<BS>", "k^", { desc = "Start Prev of Line", silent = true, noremap = true })

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

vim.keymap.set("n", "<leader>[", "<C-w>h", { desc = "Move to Left Split", noremap = true, silent = true })
vim.keymap.set("n", "<leader>]", "<C-w>l", { desc = "Move to Right Split", noremap = true, silent = true })

local telescope_builtin = require("telescope.builtin")

vim.keymap.set("n", "<leader>ff", telescope_builtin.find_files, { desc = "Find Files" })
vim.keymap.set("n", "<leader>fg", telescope_builtin.live_grep, { desc = "Live Grep" })
vim.keymap.set("n", "<leader>u", "<cmd>Telescope undo<cr>", { desc = "Undo Tree" })

-- Open parent dir
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
-- Vertically split the window
vim.keymap.set("n", "<leader>v", ":vsp<CR>", { desc = "Vertical Split" })

-- Open a terminal in the current window
vim.keymap.set("n", "<leader>t", ":terminal<CR>", { desc = "Open Terminal" })

-- Escape from terminal mode and get back to normal mode
vim.keymap.set("t", "<C-d>", "<C-\\><C-n>", { desc = "Escape Terminal" })
