local line_begin = require('luasnip.extras.expand_conditions').line_begin
local helpers = require 'luasnip-helper-funcs'
local tex_utils = require 'tex_utils'
local get_visual = helpers.get_visual
local in_mathzone = tex_utils.in_mathzone

return {
  s(
    { trig = '([^%a])mm', wordTrig = false, regTrig = true, snippetType = 'autosnippet' },
    fmta('<>$<>$ ', {
      f(function(_, snip)
        return snip.captures[1]
      end),
      d(1, get_visual),
    })
  ),
  s(
    { trig = 'nn', snippetType = 'autosnippet', dscr = 'A LaTeX equation environment' },
    fmta(
      [[
      \begin{equation}
          <>
      \end{equation}
    ]],
      { i(1) }
    ),
    { condition = line_begin }
  ),
  s(
    { trig = 'beg', snippetType = 'autosnippet' },
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
    ),
    { condition = line_begin }
  ),
  s(
    { trig = 'hwt' },
    fmta(
      [[
      \documentclass{article}
      \usepackage{../latex-style/mystyle}
      \usepackage{bookmark}
      \newtheorem{theorem}{Theorem}[section]
      \newtheorem{corollary}{Corollary}[theorem]
      \newtheorem{lemma}[theorem]{Lemma}
      \begin{document}
      \begin{center}
      \Large <> \\
      \normalsize \today \\
      Jack Deye (ID 706-210-753)
      \end{center}

      <>

      \end{document}
    ]],
      {
        i(1, 'Title'),
        i(2),
      }
    )
  ),
  s(
    { trig = 'enum' },
    fmta(
      [[
      \begin{enumerate}
        \item <>
      \end{enumerate}
      ]],
      {
        i(1),
      },
      { delimiters = '<>' }
    )
  ),
}
