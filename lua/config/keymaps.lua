--Remap space as leader key
vim.keymap.set("", "<Space>", "<Nop>")
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

function insertFullPath()
	vim.fn.setreg("+", vim.fn.expand("%:p")) -- write to clippoard
end
vim.keymap.set("n", "<leader>yp", insertFullPath, { noremap = true, silent = true })

-- supermanven
-- vim.keymap.set("n", "<S-l>", ":bnext<CR>")
vim.keymap.set("n", "<S-h>", ":bprevious<CR>")

vim.keymap.set("n", "<leader>pv", ":Ex<CR>")

-- neotest
local opts = { noremap = true, silent = true }
vim.keymap.set("n", "<leader>l", ':lua require("neotest").run.run()<CR>', opts)
vim.keymap.set("n", "<leader>ls", ':lua require("neotest").run.stop()<CR>', opts)
vim.keymap.set("n", "<leader>lk", ':lua require("neotest").run.run(vim.fn.expand("%"))<CR>', opts)
vim.keymap.set("n", "<leader>lo", ':lua require("neotest").output.open()<CR>', opts)
vim.keymap.set("n", "<leader>loo", ':lua require("neotest").output.open({ enter = true })<CR>', opts)
vim.keymap.set("n", "<leader>ls", ':lua require("neotest").summary.toggle()<CR>', opts)

-- remove highlighted words
vim.keymap.set("n", "<leader>//", ":nohls<CR>")

-- oil show parent
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
