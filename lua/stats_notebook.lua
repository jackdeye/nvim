local M = {}

-- CONFIG: Paths
local cache_file = vim.fn.stdpath 'cache' .. '/nvim_stats_data.json'
local python_path = vim.fn.getcwd() .. '/stats_env/bin/python'

-- HELPER: Run Python safely by writing to a temp file first
local function run_python_safely(python_code)
  local tmp_name = vim.fn.tempname() .. '.py'
  local f = io.open(tmp_name, 'w')
  if f then
    f:write(python_code)
    f:close()
  else
    print 'Error: Could not write temp python file.'
    return ''
  end

  -- Run the file using the specific VENV python
  local output = vim.fn.system { python_path, tmp_name }

  -- Cleanup
  os.remove(tmp_name)
  return output
end

-- 1. Ingest and Cache Data
function M.load_dataset()
  -- standard visual selection extraction
  local start_pos = vim.fn.getpos "'<"
  local end_pos = vim.fn.getpos "'>"
  local lines = vim.fn.getline(start_pos[2], end_pos[2])

  if #lines == 0 then
    return
  end
  if type(lines) == 'string' then
    lines = { lines }
  end

  -- Handle partial line selection
  local start_col = start_pos[3]
  local end_col = end_pos[3]
  if #lines == 1 then
    lines[1] = string.sub(lines[1], start_col, end_col)
  else
    lines[1] = string.sub(lines[1], start_col)
    lines[#lines] = string.sub(lines[#lines], 1, end_col)
  end

  local raw_text = table.concat(lines, '\n')
  local safe_text = raw_text:gsub('\\', '\\\\'):gsub('"""', '\\"\\"\\"')

  -- Python script to clean and cache the data
  local script = string.format(
    [[
import json
import re
import sys

raw = r"""%s"""

# Replace common LaTeX commands and braces
text = re.sub(r'\\[a-zA-Z]+\*?', ' ', raw)
text = re.sub(r'[{}[\] ]', ' ', text)
text = text.replace(',', ' ').replace('\\', ' ').replace('&', ' ')

data = []
for t in text.split():
    try:
        data.append(float(t))
    except ValueError:
        pass

if not data:
    print("No valid numbers found.")
    sys.exit(1)

with open(r'%s', 'w') as f:
    json.dump(data, f)

print(f"Loaded {len(data)} data points.")
]],
    safe_text,
    cache_file
  )

  local output = run_python_safely(script)
  print(output)

  if string.find(output, 'Loaded') then
    M.open_notebook()
  end
end

-- 2. Open the "Notebook" Buffer
function M.open_notebook()
  vim.cmd 'vsplit'
  vim.cmd 'enew'
  local buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_set_option(buf, 'buftype', 'nofile')
  vim.api.nvim_buf_set_option(buf, 'bufhidden', 'hide')
  vim.api.nvim_buf_set_option(buf, 'swapfile', false)
  vim.api.nvim_buf_set_option(buf, 'filetype', 'python')
  local starter_code = {
    '# Stats Notebook',
    "# 'df' is your DataFrame.",
    '# Press <Leader><C-r> to run the current line.',
    '# Press <Leader><C-a> to run the entire file.',
    '',
    'df.describe()',
    '',
    '# df.hist()',
  }
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, starter_code)
  -- Execute Keymaps
  local opts = { noremap = true, silent = true }
  vim.api.nvim_buf_set_keymap(buf, 'n', '<leader><C-r>', [[<cmd>lua require('stats_notebook').run_line()<CR>]], opts)
  vim.api.nvim_buf_set_keymap(buf, 'n', '<leader><C-a>', [[<cmd>lua require('stats_notebook').run_file()<CR>]], opts)
end

-- 3. Run Query Helper
local function execute_python(code)
  local safe_code = code:gsub('"""', '\\"\\"\\"')
  -- Python Wrapper Script
  local script = string.format(
    [[
import pandas as pd
import numpy as np
import json
import matplotlib.pyplot as plt
import sys
# Load Data
try:
    with open(r'%s', 'r') as f:
        data = json.load(f)
    df = pd.DataFrame(data, columns=['x'])
except:
    pass 
# Execution
try:
    code = r"""%s"""
    
    if 'plot' in code or 'hist' in code or 'box' in code:
        exec(code)
        plt.show()
    else:
        # Eval/Print Logic
        lines = code.strip().split('\n')
        last_line = lines[-1]
        exec('\n'.join(lines[:-1])) 
        try:
            print(eval(last_line)) 
        except:
            exec(last_line) 
            
except Exception as e:
    print(f"Error: {e}")
]],
    cache_file,
    safe_code
  )
  -- Reuse the safe runner defined at top
  return run_python_safely(script)
end

-- Run current line
function M.run_line()
  local code = vim.api.nvim_get_current_line()
  local output = execute_python(code)
  print(output)
end

-- Run entire file
function M.run_file()
  local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
  local code = table.concat(lines, '\n')
  local output = execute_python(code)
  print(output)
end

vim.api.nvim_set_keymap(
  'v',
  '<leader>ld',
  [[<ESC>:lua require('stats_notebook').load_dataset()<CR>]],
  { noremap = true, silent = true, desc = 'Load Stats Data' }
)

return M
