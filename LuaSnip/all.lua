local get_visual = function(args, parent)
  if #parent.snippet.env.LS_SELECT_RAW > 0 then
    return sn(nil, i(1, parent.snippet.env.LS_SELECT_RAW))
  else -- If LS_SELECT_RAW is empty, return a blank insert node
    return sn(nil, i(1))
  end
end
local line_begin = require('luasnip.extras.expand_conditions').line_begin
local in_mathzone = function()
  return vim.fn['vimtex#syntax#in_mathzone']() == 1
end
-- https://ejmastnak.com/tutorials/vim-latex/luasnip/
------------------------------------------

return {
  s({ trig = ';a', snippetType = 'autosnippet' }, {
    t '\\alpha',
  }),
  s({ trig = ';b', snippetType = 'autosnippet' }, {
    t '\\beta',
  }),
  s({ trig = ';g', snippetType = 'autosnippet' }, {
    t '\\gamma',
  }),
  s(
    { trig = 'eq', dscr = 'A LaTeX equation environment' },
    fmt(
      [[
      \begin{equation}
          <>
      \end{equation}
    ]],
      { i(1) },
      { delimiters = '<>' }
    )
  ),

  s('tt', fmta('\\texttt{<>}', { i(1) })),

  s(
    'ff',
    fmt('\\frac{<>}{<>}', {
      i(1),
      i(2),
    }, { delimiters = '<>' })
  ),

  s(
    { trig = 'env', snippetType = 'autosnippet' },
    fmta(
      [[
      \begin{<>}
          <>
      \end{<>}
    ]],
      {
        i(1),
        i(2),
        rep(1),
      }
    )
  ),

  s(
    { trig = '([^%a])mm', wordTrig = false, regTrig = true },
    fmta('<>$<>$', {
      f(function(_, snip)
        return snip.captures[1]
      end),
      d(1, get_visual),
    })
  ),

  s(
    { trig = '([^%a])ee', regTrig = true, wordTrig = false },
    fmta('<>e^{<>}', {
      f(function(_, snip)
        return snip.captures[1]
      end),
      d(1, get_visual),
    })
  ),
  s(
    { trig = '([^%a])ff', regTrig = true, wordTrig = false },
    fmta([[<>\frac{<>}{<>}]], {
      f(function(_, snip)
        return snip.captures[1]
      end),
      i(1),
      i(2),
    })
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
