local line_begin = require('luasnip.extras.expand_conditions').line_begin
local helpers = require 'luasnip-helper-funcs'
local get_visual = helpers.get_visual
local tex_utils = require 'tex_utils'
local in_mathzone = tex_utils.in_mathzone

return {
  s({ trig = 'bt', desc = 'Bold text' }, fmta('\\textbf{<>}', { i(1) })),

  s('tt', fmta('\\text{<>}', { i(1) })),

  s(
    { trig = 'ff', snippetType = 'autosnippet' },
    fmta('\\frac{<>}{<>}', {
      i(1),
      i(2),
    }, { delimiters = '<>' }),
    { condition = in_mathzone }
  ),
}