local line_begin = require('luasnip.extras.expand_conditions').line_begin
local helpers = require 'luasnip-helper-funcs'
local get_visual = helpers.get_visual
-- https://ejmastnak.com/tutorials/vim-latex/luasnip/
------------------------------------------

return {
  s(
    { trig = '([%a%)%]%}])00', regTrig = true, wordTrig = false, snippetType = 'autosnippet' },
    fmta('<>_{<>}', {
      f(function(_, snip)
        return snip.captures[1]
      end),
      t '0',
    })
  ),
  s(
    { trig = '([%a%(%)%[%]%{%}])([1-9])([1-9])', regTrig = true, wordTrig = false, snippetType = 'autosnippet' },
    fmta('<>^{<>}', {
      f(function(_, snip)
        return snip.captures[1]
      end),
      f(function(_, snip)
        return snip.captures[2]
      end),
    })
  ),
}
