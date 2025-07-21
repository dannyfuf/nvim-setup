vim.keymap.set("", "<Space>", "<Nop>")
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

local function insertFullPath()
  vim.fn.setreg("+", vim.fn.expand("%:p"))
end
vim.keymap.set("n", "<leader>yp", insertFullPath, { noremap = true, silent = true })

-- supermanven
vim.keymap.set("n", "<S-h>", ":bprevious<CR>")

vim.keymap.set("n", "<leader>pv", ":Ex<CR>")

-- Move between blank lines (similar to { and })
vim.api.nvim_create_augroup("FModeGroup", { clear = true })
vim.api.nvim_create_autocmd("ModeChanged", {
  group = "FModeGroup",
  pattern = "*:n",
  callback = function()
    vim.b.f_mode_active = false
  end,
})

vim.keymap.set("n", "f", function()
  vim.b.f_mode_active = true
  -- Wait for next key
  local ok, char = pcall(function()
    return vim.fn.getcharstr()
  end)

  if ok then
    if char == "j" then
      vim.cmd("normal! }")
    elseif char == "k" then
      vim.cmd("normal! {")
    else
      -- Pass through the f command with the character
      vim.cmd("normal! f" .. char)
      vim.b.f_mode_active = false
    end
  else
    vim.b.f_mode_active = false
  end
end, { noremap = true, silent = true, desc = "f-mode (fj/fk for paragraph navigation)" })

vim.keymap.set("n", "j", function()
  if vim.b.f_mode_active then
    vim.cmd("normal! }")
  else
    vim.cmd("normal! j")
  end
end, { noremap = true, silent = true })

vim.keymap.set("n", "k", function()
  if vim.b.f_mode_active then
    vim.cmd("normal! {")
  else
    vim.cmd("normal! k")
  end
end, { noremap = true, silent = true })

-- remove highlighted words
vim.keymap.set("n", "<leader>//", ":nohls<CR>")

-- oil show parent
vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })

