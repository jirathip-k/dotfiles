local M = {}

function M.ShowDiagnosticsInBuffer()
    local diagnostics = vim.diagnostic.get(0)
    local lines = {}
    for _, diag in ipairs(diagnostics) do
        local message = diag.message:gsub("\n", " ")
        local line_content = vim.api.nvim_buf_get_lines(0, diag.lnum, diag.lnum + 1, false)[1]
        table.insert(lines, string.format("%s: %s - %s", diag.lnum + 1, line_content, message))
    end
    vim.cmd("botright new")
    local bufnr = vim.api.nvim_get_current_buf()
    vim.bo[bufnr].buftype = 'nofile'
    vim.bo[bufnr].bufhidden = 'hide'
    vim.bo[bufnr].swapfile = false
    vim.bo[bufnr].modifiable = true
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
    vim.api.nvim_win_set_height(0, math.min(10, #lines))
end

return M
