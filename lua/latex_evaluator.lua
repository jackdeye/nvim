local M = {}

-- Function to evaluate LaTeX expression using Python and sympy with Lark backend
function M.evaluate_latex()
  -- Get visual selection
  local start_line, start_col = vim.fn.getpos("'<")[2], vim.fn.getpos("'<")[3]
  local end_line, end_col = vim.fn.getpos("'>")[2], vim.fn.getpos("'>")[3]

  -- Adjust for multibyte characters
  start_col = vim.fn.byteidx(vim.fn.getline(start_line), start_col - 1) + 1
  end_col = vim.fn.byteidx(vim.fn.getline(end_line), end_col - 1) + 1

  -- Get selected text
  local lines = vim.fn.getline(start_line, end_line)
  if #lines == 0 then
    print 'No text selected'
    return
  end

  -- Ensure lines is treated as a table
  if type(lines) == 'string' then
    lines = { lines }
  end

  -- Modify first and last line to respect column bounds
  if #lines == 1 then
    lines[1] = string.sub(lines[1], start_col, end_col)
  else
    lines[1] = string.sub(lines[1], start_col)
    lines[#lines] = string.sub(lines[#lines], 1, end_col)
  end

  -- Join lines into a single string
  local latex_expr = table.concat(lines, ' ')

  -- Create a temporary Python script to evaluate the expression
  local tmp_file = vim.fn.tempname() .. '.py'
  local file = io.open(tmp_file, 'w')
  if not file then
    print 'Failed to create temporary file'
    return
  end

  -- Write Python code to parse and evaluate the LaTeX expression using Lark directly
  file:write([[
import sys
from sympy import *
from sympy.parsing.latex import parse_latex

try:
    # Initialize symbols that might be used in the LaTeX
    x, y, z = symbols('x y z')
    a, b, c = symbols('a b c')
    latex_expr = r"""]] .. latex_expr .. [["""
    expr = parse_latex(latex_expr, backend="lark")
    result = expr
    
    # If expression can be evaluated to a numerical value, do so
    try:
        if not expr.free_symbols:
            result = float(expr.evalf())
            # Format integers nicely
            if result.is_integer():
                result = int(result)
    except:
        pass
    
    print(f"LaTeX: {latex_expr}")
    print(f"SymPy: {expr}")
    print(f"Result: {result}")
    
except Exception as e:
    print(f"Error: {str(e)}")
    # Print more detailed traceback for debugging
    import traceback
    traceback.print_exc()
]])
  file:close()
  -- Execute the Python script
  vim.fn.jobstart('python3 ' .. tmp_file, {
    on_stdout = function(_, data)
      if data then
        for _, line in ipairs(data) do
          if line ~= '' then
            print(line)
          end
        end
      end
    end,
    on_stderr = function(_, data)
      if data then
        for _, line in ipairs(data) do
          if line ~= '' then
            print('Error: ' .. line)
          end
        end
      end
    end,
    on_exit = function()
      -- Clean up temporary file
      vim.fn.delete(tmp_file)
    end,
    stdout_buffered = true,
    stderr_buffered = true,
  })
end

-- Set up keybinding for visual mode
vim.api.nvim_set_keymap(
  'v',
  '<leader>le',
  [[<ESC>:lua require('latex_evaluator').evaluate_latex()<CR>]],
  { noremap = true, silent = true, desc = 'Evaluate LaTeX expression' }
)

return M
