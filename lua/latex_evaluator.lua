local M = {}

function M.evaluate_latex()
  local start_line, start_col = vim.fn.getpos("'<")[2], vim.fn.getpos("'<")[3]
  local end_line, end_col = vim.fn.getpos("'>")[2], vim.fn.getpos("'>")[3]

  start_col = vim.fn.byteidx(vim.fn.getline(start_line), start_col - 1) + 1
  end_col = vim.fn.byteidx(vim.fn.getline(end_line), end_col - 1) + 1

  local lines = vim.fn.getline(start_line, end_line)
  if #lines == 0 then
    print 'No text selected'
    return
  end

  if type(lines) == 'string' then
    lines = { lines }
  end

  if #lines == 1 then
    lines[1] = string.sub(lines[1], start_col, end_col)
  else
    lines[1] = string.sub(lines[1], start_col)
    lines[#lines] = string.sub(lines[#lines], 1, end_col)
  end

  local latex_expr = table.concat(lines, ' ')

  local tmp_file = vim.fn.tempname() .. '.py'
  local file = io.open(tmp_file, 'w')
  if not file then
    print 'Failed to create temporary file'
    return
  end

  file:write([[
import sys
from sympy import *
from sympy.parsing.latex import parse_latex

try:
    x, y, z = symbols('x y z')
    a, b, c = symbols('a b c')
    latex_expr = r"""]] .. latex_expr .. [["""
    expr = parse_latex(latex_expr, backend="lark")
    result = expr
    
    try:
        if not expr.free_symbols:
            result = float(expr.evalf())
            if result.is_integer():
                result = int(result)
    except:
        pass
    
    # We prefix this so the Lua script can identify the final answer
    print(f"RESULT_VALUE:{result}")
    
    # Keep the logs for the console
    print(f"LaTeX: {latex_expr}")
    print(f"SymPy: {expr}")
    print(f"Result: {result}")
    
except Exception as e:
    print(f"Error: {str(e)}")
]])
  file:close()

  -- Execute the Python script synchronously
  local output = vim.fn.system('python3 ' .. tmp_file)

  -- Clean up temporary file immediately
  vim.fn.delete(tmp_file)

  -- Process the output
  if vim.v.shell_error ~= 0 then
    print('Error running Python: ' .. output)
    return
  end

  -- Find the result in the output string
  for line in string.gmatch(output, '[^\r\n]+') do
    if line:match '^RESULT_VALUE:' then
      local final_val = line:gsub('RESULT_VALUE:', '')
      vim.fn.setreg('+', final_val)
      -- Optional: print to verify it's working during the macro
      print('Copied: ' .. final_val)
    end
  end
end

vim.api.nvim_set_keymap(
  'v',
  '<leader>le',
  [[<ESC>:lua require('latex_evaluator').evaluate_latex()<CR>]],
  { noremap = true, silent = true, desc = 'Evaluate LaTeX and Copy' }
)

return M
