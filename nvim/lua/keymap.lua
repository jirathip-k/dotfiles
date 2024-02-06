-- Move Line
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '>-2<CR>gv=gv")

-- Better navigation between lines
vim.keymap.set("n", "\\", "$a", { desc = "End of Line", silent = true, noremap = true })
vim.keymap.set("n", "0", "^", { desc = "Move to Start of indent", silent = true, noremap = true })

-- Move screen
vim.keymap.set("n", "J", "<C-d>zz", { desc = "Move down screen", silent = true, noremap = true })
vim.keymap.set("n", "K", "<C-u>zz", { desc = "Move up screen", silent = true, noremap = true })
vim.keymap.set("n", "n", "nzz", { desc = "Next in search term", silent = true, noremap = true })
vim.keymap.set("n", "N", "Nzz", { desc = "Prev in search term", silent = true, noremap = true })

-- Search and Replace
vim.keymap.set(
    "n",
    "<leader>s",
    [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
    { desc = "Search and Replace" }
)

-- Move between vertical split
vim.keymap.set("n", "<leader>[", "<C-w>h", { desc = "Move to Left Split", noremap = true, silent = true })
vim.keymap.set("n", "<leader>]", "<C-w>l", { desc = "Move to Right Split", noremap = true, silent = true })
-- Move between horizontal split
vim.keymap.set("n", "<leader>j", "<C-w>j", { desc = "Move to Lower Split", noremap = true, silent = true })
vim.keymap.set("n", "<leader>k", "<C-w>k", { desc = "Move to Upper Split", noremap = true, silent = true })
-- Telescope
local telescope_builtin = require("telescope.builtin")

vim.keymap.set("n", "<leader>f", telescope_builtin.find_files, { desc = "Find Files" })
vim.keymap.set("n", "<leader>g", telescope_builtin.live_grep, { desc = "Live Grep" })
vim.keymap.set("n", "<leader>u", "<cmd>Telescope undo<cr>", { desc = "Undo Tree" })

-- Open parent dir
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
-- Previous Buffer
vim.keymap.set("n", "=", ":b#<CR>", { desc = "Previous buffer", noremap = true, silent = true })

-- Vertically split the window
vim.keymap.set("n", "<leader>v", ":vsp<CR>", { desc = "Vertical Split" })

-- Show LSP diagnostics in another buffer
local diagnostics = require("utils.diagnostics")

vim.keymap.set(
    "n",
    "<leader>b",
    diagnostics.ShowDiagnosticsInBuffer,
    { desc = "Show Diagnostics in Current Buffer", noremap = true, silent = true }
)

vim.keymap.set("n", "<leader>h", function()
    vim.lsp.inlay_hint(0, nil)
end, { desc = "Toggle Inlay Hints", noremap = true, silent = true })
