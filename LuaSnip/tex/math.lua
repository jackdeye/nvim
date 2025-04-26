local helpers = require 'luasnip-helper-funcs'
local get_visual = helpers.get_visual
local tex_utils = require 'tex_utils'
local in_mathzone = tex_utils.in_mathzone
-- The following is totally unnecessary, I just included it to stop unnecessary lsp warnings
local ls = require 'luasnip'
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local fmta = require('luasnip.extras.fmt').fmta
local punct = '-+?{}[]()$*|<>,.^'
-- https://ejmastnak.com/tutorials/vim-latex/luasnip/
local greek_letters = {
  a = '\\alpha',
  A = '\\Alpha',
  b = '\\beta',
  B = '\\Beta',
  d = '\\delta',
  D = '\\Delta',
  e = '\\epsilon',
  E = '\\Epsilon',
  g = '\\gamma',
  G = '\\Gamma',
  l = '\\lambda',
  L = '\\Lambda',
  m = '\\mu',
  M = '\\Mu',
  n = '\\nabla',
  N = '\\Nabla',
  o = '\\omega',
  O = '\\Omega',
  p = '\\pi',
  P = '\\Pi',
  s = '\\sigma',
  S = '\\Sigma',
  t = '\\theta',
  T = '\\Theta',
  x = '\\xi',
  X = '\\Xi',
}

------------------------------------------
local snippets = {
  s(
    { trig = '([^%a])ee', snippetType = 'autosnippet', regTrig = true, wordTrig = false },
    fmta('<>e^{<>}', {
      f(function(_, snip)
        return snip.captures[1]
      end),
      d(1, get_visual),
    }),
    { condition = in_mathzone }
  ),

  s(
    { trig = '([%a%)])([0-9])', regTrig = true, wordTrig = false, snippetType = 'autosnippet' },
    fmta('<>_{<>}', {
      f(function(_, snip)
        return snip.captures[1]
      end),
      f(function(_, snip)
        return snip.captures[2]
      end),
    }),
    { condition = in_mathzone }
  ),
  -- This autosnippet has both saved me the most time and has beenthe most difficult for me to get, I am constantly tweaking it.
  -- In general, I want "an"->"a_{n}", however, say for "\align" -/->"\alig_{n}". The reason why I have the following "gaps" in my regex are because:
  -- Int -/-> I_{n}t, instead
  s(
    { trig = '([^\\%a])([a-hk-zA-HJ-Z)])([nkj])', regTrig = true, wordTrig = false, snippetType = 'autosnippet' },
    fmta('<>_{<>}<>', {
      f(function(_, snip)
        if snip.captures[1] == '' then
          return snip.captures[2]
        else
          return snip.captures[1] .. snip.captures[2]
        end
      end),
      f(function(_, snip)
        return snip.captures[3]
      end),
      i(0),
    }),
    { condition = in_mathzone }
  ),
  -- Uses back references!
  s(
    { trig = '([^\\%a])([a-hk-zA-KM-Z)])([i])', regTrig = true, wordTrig = false, snippetType = 'autosnippet' },
    fmta('<>_{<>}<>', {
      f(function(_, snip)
        if snip.captures[1] == '' then
          return snip.captures[2]
        else
          return snip.captures[1] .. snip.captures[2]
        end
      end),
      f(function(_, snip)
        return snip.captures[3]
      end),
      i(0),
    }),
    { condition = in_mathzone },
    { priority = 1 }
  ),
  s(
    { trig = '([%a%)])_%{([0-9nk])%}(%2)', regTrig = true, wordTrig = false, snippetType = 'autosnippet' },
    fmta('<>^{<>} ', {
      f(function(_, snip)
        return snip.captures[1]
      end),
      f(function(_, snip)
        return snip.captures[2]
      end),
    }),
    { condition = in_mathzone }
  ),
  s(
    { trig = 'bb(%a)', regTrig = true, wordTrig = false, snippetType = 'autosnippet' },
    fmta('\\bb<>', {
      f(function(_, snip)
        return snip.captures[1]
      end),
    }),
    { condition = in_mathzone }
  ),

  s({ trig = 'ii', regTrig = true, wordTrig = false, snippetType = 'autosnippet' }, {
    t '\\infty',
  }, { condition = in_mathzone }, { priority = 10 }),
  s({ trig = '...', snippetType = 'autosnippet' }, {
    t '\\dots',
  }),

  s(
    { trig = 'pd', snippetType = 'autosnippet', condition = in_mathzone }, --Partial Derivatives
    fmta('\\frac{\\partial <>}{\\partial <>}', {
      i(1),
      i(2),
    }, { delimiters = '<>' })
  ),
  s({ trig = 'st', snippetType = 'autosnippet' }, t '\\text{ s.t. }', { condition = in_mathzone }),
  s({ trig = 'sm', snippetType = 'autosnippet' }, t '\\setminus', { condition = in_mathzone }),
  s({ trig = 'tm', snippetType = 'autosnippet' }, t '\\times', { condition = in_mathzone }),
  s({ trig = 'mt', snippetType = 'autosnippet' }, t '\\mapsto', { condition = in_mathzone }),
  s({ trig = 'em', snippetType = 'autosnippet' }, t '\\emptyset', { condition = in_mathzone }),
  s({ trig = 'sum', snippetType = 'autosnippet' }, t '\\sum', { condition = in_mathzone }),
  s({ trig = 'lim', snippetType = 'autosnippet' }, t '\\lim', { condition = in_mathzone }),
  s({ trig = 'int', snippetType = 'autosnippet' }, t '\\int', { condition = in_mathzone }),
  s(
    { trig = 'Sum', snippetType = 'autosnippet' },
    fmta('\\sum_{<>}^{<>}', {
      i(1, 'i=1'),
      i(2, '\\infty'),
    }, { delimiters = '<>' }),
    { condition = in_mathzone }
  ),
  s(
    { trig = 'Int', snippetType = 'autosnippet' },
    fmta('\\int_{<>}^{<>}', {
      i(1),
      i(2),
    }, { delimiters = '<>' }),
    { condition = in_mathzone }
  ),
  s(
    { trig = 'Lim', snippetType = 'autosnippet' },
    fmta('\\lim_{<> \\to <>}', {
      i(1, 'n'),
      i(2, '\\infty'),
    }, { delimiters = '<>' }),
    { condition = in_mathzone }
  ),
  s(
    { trig = 'sq', snippetType = 'autosnippet' },
    fmta('\\sqrt{<>} ', {
      i(1),
    }, { delimiters = '<>' }),
    { condition = in_mathzone }
  ),
  s(
    { trig = 'ba', snippetType = 'autosnippet' },
    fmta('\\B_{<>,<>}(<>,<>) ', {
      i(1, 'X'),
      i(2, 'd|_{X}'),
      i(3),
      i(4),
    }, { delimiters = '<>' }),
    { condition = in_mathzone }
  ),
  s(
    { trig = 'fd', snippetType = 'autosnippet' },
    fmta('f:<> \\to <>', {
      i(1),
      i(2),
    }, { delimiters = '<>' }),
    { condition = in_mathzone }
  ),
  s(
    { trig = 'cr', snippetType = 'autosnippet' },
    fmta('\\sqrt[<>]{<>} ', {
      i(1, '3'),
      i(2),
    }, { delimiters = '<>' }),
    { condition = in_mathzone }
  ),
  s({ trig = 'cd', snippetType = 'autosnippet' }, { t '\\cdot ' }, { condition = in_mathzone }),
  s({ trig = 'le', snippetType = 'autosnippet' }, { t '\\leq ' }, { condition = in_mathzone }),
  s({ trig = 'ge', snippetType = 'autosnippet' }, { t '\\geq ' }, { condition = in_mathzone }),

  s(
    { trig = 'bi', snippetType = 'autosnippet' },
    fmta('\\bigcap_{<>} ', {
      i(1),
    }, { delimiters = '<>' }),
    { condition = in_mathzone }
  ),
  s(
    { trig = 'bu', snippetType = 'autosnippet' },
    fmta('\\bigcup_{<>} ', {
      i(1),
    }, { delimiters = '<>' }),
    { condition = in_mathzone }
  ),
  -----------------------------------
  --- Set Notation and logical Operators
  s({
    trig = 'dd',
    snippetType = 'autosnippet',
  }, { t '\\in ' }, { condition = in_mathzone }),
  s({
    trig = 'sse',
    snippetType = 'autosnippet',
  }, { t '\\subseteq' }, { condition = in_mathzone }),
  s({
    trig = 'ssn',
    snippetType = 'autosnippet',
  }, { t '\\subsetneq' }, { condition = in_mathzone }),
  s({
    trig = 'ex',
    snippetType = 'autosnippet',
  }, { t '\\exists ' }, { condition = in_mathzone }),
  s({
    trig = 'fa',
    snippetType = 'autosnippet',
  }, { t '\\forall ' }, { condition = in_mathzone }),
  s({
    trig = 'im',
    snippetType = 'autosnippet',
  }, { t '\\implies' }, { condition = in_mathzone }),

  ------------------------------------
  --- Delimiters
  s({
    trig = '[',
    snippetType = 'autosnippet',
  }, fmta('[<>]', { i(1) }, { delimiters = '<>' }), { condition = in_mathzone }),
  s({
    trig = '(',
    snippetType = 'autosnippet',
  }, fmta('(<>)', { i(1) }, { delimiters = '<>' }), { condition = in_mathzone }),
  s({
    trig = '|',
    snippetType = 'autosnippet',
  }, fmta('|<>|', { i(1) }, { delimiters = '<>' }), { condition = in_mathzone }),
  s({
    trig = '{',
    snippetType = 'autosnippet',
  }, fmta('{<>}', { i(1) }, { delimiters = '<>' }), { condition = in_mathzone }),
  s(
    {
      trig = '([%a])_',
      snippetType = 'autosnippet',
      regTrig = true,
      wordtrig = false,
    },
    fmta('<>_{<>}', {
      f(function(_, snip)
        return snip.captures[1]
      end),
      d(1, get_visual),
    }),
    { condition = in_mathzone }
  ),
  s(
    {
      trig = '([%a0-9])^',
      snippetType = 'autosnippet',
      regTrig = true,
      wordtrig = false,
    },
    fmta('<>^{<>}', {
      f(function(_, snip)
        return snip.captures[1]
      end),
      d(1, get_visual),
    }),
    { condition = in_mathzone }
  ),
  s(
    {
      trig = '([%a])%(',
      snippetType = 'autosnippet',
      regTrig = true,
      wordtrig = false,
    },
    fmta('<>(<>) ', {
      f(function(_, snip)
        return snip.captures[1]
      end),
      d(1, get_visual),
    }),
    { condition = in_mathzone }
  ),
}
--Greek characters
for trigger, letter in pairs(greek_letters) do
  table.insert(
    snippets,
    s({ trig = ';' .. trigger, snippetType = 'autosnippet' }, {
      t(letter),
    })
  )
end

return snippets
