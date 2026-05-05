-- ~/.config/nvim/lua/inkscape.lua

local M = {}

local watch_job_id = nil
local function get_root()
  local root = vim.b.vimtex and vim.b.vimtex.root
  if not root then
    root = vim.fn.getcwd()
  end
  return root
end

-- Start inkscape-figures watch automatically
local function start_watch()
  if watch_job_id then
    return -- Already running
  end

  local root = get_root()

  watch_job_id = vim.fn.jobstart({ 'inkscape-figures', 'watch' }, {
    cwd = root,
    on_exit = function()
      watch_job_id = nil
    end,
  })

  if watch_job_id > 0 then
    print 'Started inkscape-figures watch'
  else
    print 'Failed to start inkscape-figures watch'
    watch_job_id = nil
  end
end

-- Stop the watch process
local function stop_watch()
  if watch_job_id then
    vim.fn.jobstop(watch_job_id)
    watch_job_id = nil
    print 'Stopped inkscape-figures watch'
  end
end

-- Function to create a new figure
local function create_figure()
  local line = vim.api.nvim_get_current_line()
  local name = vim.trim(line)

  if name == '' then
    print 'Error: Line is empty. Type a figure name first.'
    return
  end

  -- Start watch if not already running
  start_watch()

  local root = get_root()
  local figures_dir = root .. '/figures/'

  if vim.fn.isdirectory(figures_dir) == 0 then
    vim.fn.mkdir(figures_dir, 'p')
  end

  local fig_path = figures_dir .. name .. '.svg'

  if vim.fn.filereadable(fig_path) == 1 then
    print('Figure already exists: ' .. name)
  else
    local cmd = string.format("inkscape-figures create '%s' '%s'", name, figures_dir)
    local result = vim.fn.system(cmd)
    if vim.v.shell_error ~= 0 then
      print('Error creating figure: ' .. result)
      return
    end
    print('Created new figure: ' .. name)
  end

  local latex_cmd = string.format('\\incfig{%s}', name)
  vim.api.nvim_set_current_line(latex_cmd)
  vim.cmd 'w'
end

-- Function to edit existing figures
local function edit_figure()
  -- Start watch if not already running
  start_watch()

  local root = get_root()
  local figures_dir = root .. '/figures/'

  if vim.fn.isdirectory(figures_dir) == 0 then
    print('No figures directory found at: ' .. figures_dir)
    return
  end

  require('telescope.builtin').find_files {
    prompt_title = 'Edit Figure',
    cwd = figures_dir,
    find_command = { 'find', '.', '-name', '*.svg' },
    attach_mappings = function(prompt_bufnr, map)
      local actions = require 'telescope.actions'
      local action_state = require 'telescope.actions.state'

      actions.select_default:replace(function()
        actions.close(prompt_bufnr)
        local selection = action_state.get_selected_entry()
        if selection then
          local fig_path = figures_dir .. selection.value
          -- Actually open Inkscape instead of just touching the file
          local open_cmd = string.format("inkscape '%s' > /dev/null 2>&1 &", fig_path)
          os.execute(open_cmd)
          print('Opening figure: ' .. selection.value)
        end
      end)
      return true
    end,
  }
end

-- Auto-start watch when opening .tex files
vim.api.nvim_create_autocmd('FileType', {
  pattern = 'tex',
  callback = function()
    start_watch()
  end,
})

-- Auto-stop watch when leaving Neovim
vim.api.nvim_create_autocmd('VimLeavePre', {
  callback = function()
    stop_watch()
  end,
})

-- vim.keymap.set('i', '<leader>if', create_figure, { desc = '[I]nkscape [F]igure create' })
-- vim.keymap.set('n', '<leader>if', edit_figure, { desc = '[I]nkscape [F]igure edit' })

-- Optional: Manual control keymaps
-- vim.keymap.set('n', '<leader>iw', start_watch, { desc = '[I]nkscape [W]atch start' })
-- vim.keymap.set('n', '<leader>is', stop_watch, { desc = '[I]nkscape watch [S]top' })

return M
