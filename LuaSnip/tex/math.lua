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

-- https://ejmastnak.com/tutorials/vim-latex/luasnip/
------------------------------------------
return {
  s(
    { trig = '([^%a])ee', snippetType = 'autosnippet', regTrig = true, wordTrig = false },
    fmta('<>e^{<>}', {
      f(function(_, snip)
        return snip.captures[1]
      end),
      d(1, get_visual),
    })
  ),

  --Greek characters
  s({ trig = ';a', snippetType = 'autosnippet' }, {
    t '\\alpha',
  }),
  s({ trig = ';b', snippetType = 'autosnippet' }, {
    t '\\beta',
  }),
  s({ trig = ';g', snippetType = 'autosnippet' }, {
    t '\\gamma',
  }),
  s({ trig = ';d', snippetType = 'autosnippet' }, {
    t '\\delta',
  }),
  s({ trig = ';e', snippetType = 'autosnippet' }, {
    t '\\epsilon',
  }),
  s({ trig = ';t', snippetType = 'autosnippet' }, {
    t '\\theta',
  }),
  s({ trig = ';l', snippetType = 'autosnippet' }, {
    t '\\lambda',
  }),
  s({ trig = ';x', snippetType = 'autosnippet' }, {
    t '\\xi',
  }),
  s({ trig = ';p', snippetType = 'autosnippet' }, {
    t '\\pi',
  }),
  s({ trig = '([^%a])ii', snippetType = 'autosnippet', regTrig = true, wordTrig = false }, {
    t '\\infty',
  }),
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

  s(
    { trig = 'sum', snippetType = 'autosnippet' },
    fmta('\\sum_{<>}^{<>}', {
      i(1, 'i=1'),
      i(2, '\\infty'),
    }, { delimiters = '<>' }),
    { condition = in_mathzone }
  ),
  s(
    { trig = 'int', snippetType = 'autosnippet' },
    fmta('\\int_{<>}^{<>}', {
      i(1),
      i(2),
    }, { delimiters = '<>' }),
    { condition = in_mathzone }
  ),
  s(
    { trig = 'lim', snippetType = 'autosnippet' },
    fmta('\\lim_{<> \\to <>}', {
      i(1, 'x'),
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
  s({
    trig = 'cd',
    snippetType = 'autosnippet',
  }, { t '\\cdot ' }, { condition = in_mathzone }),

  -----------------------------------
  --- Set Notation and logical Operators
  s({
    trig = 'jj',
    snippetType = 'autosnippet',
  }, { t '\\in' }, { condition = in_mathzone }),
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
      trig = '([%a])^',
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
