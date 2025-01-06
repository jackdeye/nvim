local line_begin = require('luasnip.extras.expand_conditions').line_begin
local helpers = require 'luasnip-helper-funcs'
local get_visual = helpers.get_visual
-- https://ejmastnak.com/tutorials/vim-latex/luasnip/
------------------------------------------

return {
  s(
    { trig = '([^%a])ee', regTrig = true, wordTrig = false },
    fmta('<>e^{<>}', {
      f(function(_, snip)
        return snip.captures[1]
      end),
      d(1, get_visual),
    }),
    { condition = line_begin }
  ),
  s(
    { trig = '([%a%)%]%}])00', regTrig = true, wordTrig = false, snippetType = 'autosnippet' },
    fmta('<>_{<>}', {
      f(function(_, snip)
        return snip.captures[1]
      end),
      t '0',
    })
  ),
}
