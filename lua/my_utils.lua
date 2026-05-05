local M = {}

-- Mapping of minted language names to file extensions
local language_to_extension = {
  python = 'py',
  python3 = 'py',
  javascript = 'js',
  typescript = 'ts',
  cpp = 'cpp',
  c = 'c',
  java = 'java',
  rust = 'rs',
  lua = 'lua',
  bash = 'sh',
  shell = 'sh',
  html = 'html',
  css = 'css',
  tex = 'tex',
  latex = 'tex',
  markdown = 'md',
  json = 'json',
  yaml = 'yaml',
  sql = 'sql',
  r = 'r',
  go = 'go',
  ruby = 'rb',
  php = 'php',
  swift = 'swift',
  kotlin = 'kt',
  scala = 'scala',
  vim = 'vim',
  toml = 'toml',
  xml = 'xml',
  haskell = 'hs',
  ocaml = 'ml',
  pascal = 'pas',
  perl = 'pl',
  powershell = 'ps1',
  dockerfile = 'dockerfile',
  makefile = 'makefile',
  cmake = 'cmake',
  assembly = 'asm',
  fortran = 'f90',
  matlab = 'm',
  mathematica = 'nb',
  julia = 'jl',
  nim = 'nim',
  elixir = 'ex',
  erlang = 'erl',
  clojure = 'clj',
  scheme = 'scm',
  lisp = 'lisp',
  prolog = 'pl',
  cobol = 'cob',
  ada = 'ada',
  d = 'd',
  fsharp = 'fs',
  csharp = 'cs',
  vb = 'vb',
  vbnet = 'vb',
  objective = 'm',
  objectivec = 'm',
  dart = 'dart',
  zig = 'zig',
  crystal = 'cr',
  v = 'v',
  -- Add more as needed
}

-- Comment prefixes for various languages
local comment_prefixes = {
  python = '#',
  javascript = '//',
  typescript = '//',
  cpp = '//',
  c = '//',
  java = '//',
  rust = '//',
  lua = '--',
  bash = '#',
  shell = '#',
  tex = '%',
  latex = '%',
  html = '<!-- ',
  css = '/* ',
  sql = '--',
  r = '#',
  ruby = '#',
  go = '//',
  php = '//',
  swift = '//',
  kotlin = '//',
  scala = '//',
  vim = '"',
  yaml = '#',
  toml = '#',
  haskell = '--',
  ocaml = '(*',
  perl = '#',
  powershell = '#',
  dockerfile = '#',
  makefile = '#',
  cmake = '#',
  assembly = ';',
  fortran = '!',
  matlab = '%',
  julia = '#',
  nim = '#',
  elixir = '#',
  erlang = '%',
  clojure = ';',
  scheme = ';',
  lisp = ';',
  prolog = '%',
  ada = '--',
  d = '//',
  fsharp = '//',
  csharp = '//',
  vb = "'",
  vbnet = "'",
  dart = '//',
  zig = '//',
  crystal = '#',
  v = '//',
}

M.create_and_insert_codeblock = function()
  local current_file = vim.fn.expand '%:t'
  if current_file == '' then
    print 'Please save the file before creating a code block.'
    return
  end

  local file_base_name = vim.fn.fnamemodify(current_file, ':r')
  local current_dir = vim.fn.expand '%:p:h'
  local code_dir = current_dir .. '/code'

  -- Create code directory if it doesn't exist
  if vim.fn.isdirectory(code_dir) == 0 then
    vim.fn.mkdir(code_dir, 'p')
  end

  -- Find next available number
  local code_block_num = 0
  local files = vim.fn.readdir(code_dir)
  if files then
    local prefix_pattern = file_base_name .. '_'
    for _, file in ipairs(files) do
      if file:sub(1, #prefix_pattern) == prefix_pattern then
        local num_str = string.match(file, prefix_pattern .. '(%d+)%.')
        if num_str then
          local num = tonumber(num_str)
          if num and num > code_block_num then
            code_block_num = num
          end
        end
      end
    end
  end
  code_block_num = code_block_num + 1
  local language = vim.fn.input 'Enter language (e.g., python, cpp, rust): '
  if language == '' then
    print 'No language provided. Aborting.'
    return
  end
  language = string.lower(language)
  local extension = language_to_extension[language]
  if not extension then
    -- If language not in map, ask for extension
    vim.notify('Unknown language "' .. language .. '". Please provide file extension.', vim.log.levels.WARN)
    extension = vim.fn.input('Enter file extension for ' .. language .. ': ')
    if extension == '' then
      print 'No extension provided. Aborting.'
      return
    end
    -- Remove leading dot if provided
    extension = extension:gsub('^%.', '')
  end
  -- Create file paths
  local new_file_path = string.format('%s/%s_%d.%s', code_dir, file_base_name, code_block_num, extension)
  local relative_path = string.format('code/%s_%d.%s', file_base_name, code_block_num, extension)
  -- Create LaTeX command with explicit language
  local latex_command = string.format([[\codeblockwithLang{%s}{%s}]], language, relative_path)
  -- Insert LaTeX command at cursor
  local lines = { latex_command }
  vim.api.nvim_buf_set_text(0, vim.fn.line '.' - 1, vim.fn.col '.' - 1, vim.fn.line '.' - 1, vim.fn.col '.' - 1, lines)
  -- Open new file for editing
  vim.cmd('edit ' .. new_file_path)
  -- Add a comment header if we know the comment style
  local comment_prefix = comment_prefixes[language]
  if comment_prefix then
    local header
    if comment_prefix:match '[*<]' then
      -- Multi-line comment style
      if language == 'html' then
        header = string.format('<!-- Code block %d for %s -->', code_block_num, file_base_name)
      elseif language == 'css' then
        header = string.format('/* Code block %d for %s */', code_block_num, file_base_name)
      elseif language == 'ocaml' then
        header = string.format('(* Code block %d for %s *)', code_block_num, file_base_name)
      else
        header = string.format('%s Code block %d for %s', comment_prefix, code_block_num, file_base_name)
      end
    else
      -- Single-line comment style
      header = string.format('%s Code block %d for %s', comment_prefix, code_block_num, file_base_name)
    end
    vim.api.nvim_buf_set_lines(0, 0, 0, false, { header, '' })
  end

  -- Save the file
  vim.cmd 'write'
end

-- Helper function to list available languages
M.list_supported_languages = function()
  local langs = {}
  for lang, ext in pairs(language_to_extension) do
    table.insert(langs, string.format('%s -> .%s', lang, ext))
  end
  table.sort(langs)
  print 'Supported languages and their extensions:'
  for _, mapping in ipairs(langs) do
    print('  ' .. mapping)
  end
end

-- Optional: Add completion for languages
M.get_language_completions = function()
  local completions = {}
  for lang, _ in pairs(language_to_extension) do
    table.insert(completions, lang)
  end
  table.sort(completions)
  return completions
end

return M
