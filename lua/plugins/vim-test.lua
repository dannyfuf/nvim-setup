return {
  "vim-test/vim-test",
  dependencies = {
    "preservim/vimux"
  },
  config = function()
    vim.keymap.set("n", "<leader>t", ":TestNearest<CR>", {})
    vim.keymap.set("n", "<leader>T", ":TestFile<CR>", {})
    vim.keymap.set("n", "<leader>l", ":TestLast<CR>", {})
    vim.cmd("let test#strategy = 'vimux'")
    vim.cmd("let test#ruby#rspec#executable = 'doppler run -- bundle exec rspec --color'")
  end,
}
