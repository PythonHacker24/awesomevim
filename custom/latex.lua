local function render_latex(destination)
  local file = vim.fn.expand('%:p')
  local file_name = vim.fn.expand('%:t:r')
  local default_destination = vim.fn.getcwd() .. "/" .. file_name .. ".pdf"

  destination = destination or default_destination

  local compile_cmd = "pdflatex -output-directory=" .. vim.fn.expand('%:p:h') .. " " .. file
  vim.fn.system(compile_cmd)

  if pdf_file ~= destination then
    local move_cmd = "mv " .. pdf_file .. " " .. destination
    vim.fn.system(move_cmd)
    print("PDF moved to: " .. destination)
  else
    print("PDF generated at: " .. destination)
  end
end

vim.api.nvim_create_user_command('Renderlatex', function(opts)
  render_latex(opts.args ~= '' and opts.args or nil)
end, {
  nargs = "?",
  desc = "Compile LaTeX and move the PDF to the specified location"
})
