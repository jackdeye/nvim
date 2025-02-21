local line_begin = require('luasnip.extras.expand_conditions').line_begin
local helpers = require 'luasnip-helper-funcs'
local get_visual = helpers.get_visual
local tex_utils = require 'tex_utils'
local in_mathzone = tex_utils.in_mathzone

return {
  s({ trig = 'tb', desc = 'Text Bold' }, fmta('\\textbf{<>}', { i(1) })),

  s('tu', fmta('\\underline{<>}', { i(1) })),
  s({ trig = 'ti', desc = 'Text Italics' }, fmta('\\textit{<>}', { i(1) })),

  s('tt', fmta('\\text{<>}', { i(1) })),

  s(
    { trig = 'ff', snippetType = 'autosnippet' },
    fmta('\\frac{<>}{<>}', {
      i(1),
      i(2),
    }, { delimiters = '<>' }),
    { condition = in_mathzone }
  ),
  s(
    { trig = 'lr', snippetType = 'autosnippet' },
    fmta('\\left<><> \\right<> <>', {
      i(1),
      i(2),
      f(function(args)
        local delimiters = {
          ['('] = ')',
          ['['] = ']',
          ['{'] = '}',
        }
        local input = args[1][1]
        if input then
          local first_char = input:sub(1, 1)
          return delimiters[first_char] or first_char
        else
          return ''
        end
      end, { 1 }),
      i(0),
    }, { delimiters = '<>' }),
    { condition = in_mathzone }
  ),
}
