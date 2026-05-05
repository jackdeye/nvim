local line_begin = require('luasnip.extras.expand_conditions').line_begin
local helpers = require 'luasnip-helper-funcs'
local get_visual = helpers.get_visual
local tex_utils = require 'tex_utils'
local in_mathzone = tex_utils.in_mathzone

return {
  s({ trig = 'tb', desc = 'Text Bold' }, fmta('\\textbf{<>}', { d(1, get_visual) })),
  s({ trig = 'tw', desc = 'Typewritter Text' }, fmta('\\texttt{<>}', { d(1, get_visual) })),
  s('tu', fmta('\\underline{<>}', { d(1, get_visual) })),
  s({ trig = 'abk', snippetType = 'autosnippet' }, fmta('\\langle <>\\rangle', { d(1, get_visual) })),
  s({ trig = 'ti', desc = 'Text Italics' }, fmta('\\textit{<>}', { d(1, get_visual) })),
  s({ trig = 'bx', desc = 'Text Italics' }, fmta('\\boxed{<>}', { d(1, get_visual) })),

  s('tt', fmta('\\text{<>}', { i(1) })),

  s(
    { trig = 'gg', snippetType = 'autosnippet' },
    fmta('\\{<>\\}', {
      i(1),
    }, { delimiters = '<>' }),
    { condition = in_mathzone }
  ),

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
