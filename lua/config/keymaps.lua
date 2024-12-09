--Remap space as leader key
vim.keymap.set("", "<Space>", "<Nop>")
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

function insertFullPath()
  vim.fn.setreg('+', vim.fn.expand('%:p')) -- write to clippoard
end
vim.keymap.set('n', '<leader>yp', insertFullPath, { noremap = true, silent = true })

-- function runRspec()
--   local filepath = vim.fn.expand('%:p')  -- using %:p for absolute path
--   local cmd = 'doppler run -- bundle exec rspec --color ' .. vim.fn.shellescape(filepath)

--   vim.cmd('split')
--   vim.cmd('terminal ' .. cmd)
-- end
-- vim.keymap.set('n', '<leader>tf', runRspec, { noremap = true, silent = true })


-- neotest
local opts = { noremap = true, silent = true }
vim.keymap.set('n', '<leader>l', ':lua require("neotest").run.run()<CR>', opts)
vim.keymap.set('n', '<leader>ls', ':lua require("neotest").run.stop()<CR>', opts)
vim.keymap.set('n', '<leader>lk', ':lua require("neotest").run.run(vim.fn.expand("%"))<CR>', opts)
vim.keymap.set('n', '<leader>lo', ':lua require("neotest").output.open()<CR>', opts)
vim.keymap.set('n', '<leader>loo', ':lua require("neotest").output.open({ enter = true })<CR>', opts)
vim.keymap.set('n', '<leader>ls', ':lua require("neotest").summary.toggle()<CR>', opts)
