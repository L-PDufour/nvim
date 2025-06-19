vim.api.nvim_create_autocmd("FileType", {
  pattern = "templ",
  callback = function()
    vim.bo.commentstring = "<!-- %s -->"  -- Use HTML-style comments
  end,
})
