local function render_latex(destination)
  local file = vim.fn.expand('%:p')
  local file_name = vim.fn.expand('%:t:r')
  local compiled_pdf = vim.fn.expand('%:p:h') .. "/" .. file_name .. ".pdf"

  destination = destination or compiled_pdf

  local compile_cmd = "pdflatex -output-directory=" .. vim.fn.expand('%:p:h') .. " " .. file
  vim.fn.system(compile_cmd)

  if compiled_pdf ~= destination then
    vim.fn.system("mv " .. compiled_pdf .. " " .. destination)
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
