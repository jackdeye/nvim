local line_begin = require('luasnip.extras.expand_conditions').line_begin
local helpers = require 'luasnip-helper-funcs'
local tex_utils = require 'tex_utils'
local get_visual = helpers.get_visual
local in_mathzone = tex_utils.in_mathzone
local in_enumerate = tex_utils.in_enumerate
local in_itemize = tex_utils.in_itemize

-- generating function
local mat = function(args, snip)
  local rows = tonumber(snip.captures[2])
  local cols = tonumber(snip.captures[3])
  local nodes = {}
  local ins_indx = 1
  for j = 1, rows do
    table.insert(nodes, r(ins_indx, tostring(j) .. 'x1', i(1)))
    ins_indx = ins_indx + 1
    for k = 2, cols do
      table.insert(nodes, t ' & ')
      table.insert(nodes, r(ins_indx, tostring(j) .. 'x' .. tostring(k), i(1)))
      ins_indx = ins_indx + 1
    end
    table.insert(nodes, t { ' \\\\', '' })
  end
  -- fix last node.
  nodes[#nodes] = t ' \\\\'
  return sn(nil, nodes)
end

return {
  s(
    { trig = '([^%a])mm', wordTrig = false, regTrig = true, snippetType = 'autosnippet' },
    fmta('<>$<>$', {
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
    { trig = 'ale', snippetType = 'autosnippet', dscr = 'A LaTeX align environment' },
    fmta(
      [[
      \begin{align}
          <>
      \end{align}
    ]],
      { i(1) }
    ),
    { condition = line_begin }
  ),
  s(
    { trig = 'als', snippetType = 'autosnippet', dscr = 'A LaTeX align-star environment' },
    fmta(
      [[
      \begin{align*}
          <>
      \end{align*}
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
    { trig = 'ibeg ', snippetType = 'autosnippet' },
    fmta('\\begin{<>} <> \\end{<>}', {
      i(1),
      i(2),
      rep(1),
    }),
    { condition = in_mathzone() }
  ),

  s(
    { trig = '([bBpvV])mat(%d+)(%d+)', regTrig = true, name = 'matrix', dscr = 'matrix trigger lets go', hidden = true },
    fmt(
      [[
    \begin{<>}
    <>
    \end{<>}]],
      {
        f(function(_, snip)
          return snip.captures[1] .. 'matrix' -- captures matrix type
        end),
        d(1, mat),
        f(function(_, snip)
          return snip.captures[1] .. 'matrix' -- i think i could probably use a repeat node but whatever
        end),
      },
      { delimiters = '<>' }
    ),
    { condition = in_mathzone(), show_condition = in_mathzone() }
  ), --s({ trig = 'as', snippetType = 'autosnippet' }, t 'align*', { condition = in_environment_name }),
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

  ----------------------------------------
  --- Here are all of the math specific stuff
  ----------------------------------------
  s(
    { trig = 'thm' },
    fmta(
      [[
    \begin{thm}{<>}
      <>
    \end{thm}
    <>
    ]],
      {
        i(1),
        i(2),
        i(0),
      },
      { delimiters = '<>' }
    ),
    { condition = line_begin }
  ),
  s(
    { trig = 'thmc' },
    fmta(
      [[
    \begin{thmc}{<>}
      <>
    \end{thmc}
    <>
    ]],
      {
        i(1),
        i(2),
        i(0),
      },
      { delimiters = '<>' }
    ),
    { condition = line_begin }
  ),
  s(
    { trig = 'cor' },
    fmta(
      [[
    \begin{cor}{<>}
      <>
    \end{cor}
    <>
    ]],
      {
        i(1),
        i(2),
        i(0),
      },
      { delimiters = '<>' }
    ),
    { condition = line_begin }
  ),

  s(
    { trig = 'corc' },
    fmta(
      [[
    \begin{corc}{<>}
      <>
    \end{corc}
    <>
    ]],
      {
        i(1),
        i(2),
        i(0),
      },
      { delimiters = '<>' }
    ),
    { condition = line_begin }
  ),

  s(
    { trig = 'clm' },
    fmta(
      [[
    \begin{clm}{<>}
      <>
    \end{clm}
    <>
    ]],
      {
        i(1),
        i(2),
        i(0),
      },
      { delimiters = '<>' }
    ),
    { condition = line_begin }
  ),

  s(
    { trig = 'wc' },
    fmta(
      [[
    \begin{wc}{<>}
      <>
    \end{wc}
    <>
    ]],
      {
        i(1),
        i(2),
        i(0),
      },
      { delimiters = '<>' }
    ),
    { condition = line_begin }
  ),

  s(
    { trig = 'thmcon' },
    fmta(
      [[
    \begin{thmcon}{<>}
      <>
    \end{thmcon}
    <>
    ]],
      {
        i(1),
        i(2),
        i(0),
      },
      { delimiters = '<>' }
    ),
    { condition = line_begin }
  ),

  s(
    { trig = 'ex' },
    fmta(
      [[
    \begin{ex}{<>}
      <>
    \end{ex}
    <>
    ]],
      {
        i(1),
        i(2),
        i(0),
      },
      { delimiters = '<>' }
    ),
    { condition = line_begin }
  ),

  s(
    { trig = 'exc' },
    fmta(
      [[
    \begin{exc}{<>}
      <>
    \end{exc}
    <>
    ]],
      {
        i(1),
        i(2),
        i(0),
      },
      { delimiters = '<>' }
    ),
    { condition = line_begin }
  ),

  s(
    { trig = 'dfn' },
    fmta(
      [[
    \begin{dfn}{<>}
      <>
    \end{dfn}
    <>
    ]],
      {
        i(1),
        i(2),
        i(0),
      },
      { delimiters = '<>' }
    ),
    { condition = line_begin }
  ),

  s(
    { trig = 'dfnc' },
    fmta(
      [[
    \begin{dfnc}{<>}
      <>
    \end{dfnc}
    <>
    ]],
      {
        i(1),
        i(2),
        i(0),
      },
      { delimiters = '<>' }
    ),
    { condition = line_begin }
  ),

  s(
    { trig = 'opn' },
    fmta(
      [[
    \begin{opn}{<>}
      <>
    \end{opn}
    <>
    ]],
      {
        i(1),
        i(2),
        i(0),
      },
      { delimiters = '<>' }
    ),
    { condition = line_begin }
  ),

  s(
    { trig = 'opnc' },
    fmta(
      [[
    \begin{opnc}{<>}
      <>
    \end{opnc}
    <>
    ]],
      {
        i(1),
        i(2),
        i(0),
      },
      { delimiters = '<>' }
    ),
    { condition = line_begin }
  ),

  s(
    { trig = 'qs' },
    fmta(
      [[
    \begin{qs}{<>}
      <>
    \end{qs}
    <>
    ]],
      {
        i(1),
        i(2),
        i(0),
      },
      { delimiters = '<>' }
    ),
    { condition = line_begin }
  ),

  s(
    { trig = 'pf' },
    fmta(
      [[
    \begin{pf}[<>]
      <>
    \end{pf}
    <>
    ]],
      {
        i(1),
        i(2),
        i(0),
      },
      { delimiters = '<>' }
    ),
    { condition = line_begin }
  ),

  s(
    { trig = 'nt' },
    fmta(
      [[
    \begin{nt}
      <>
    \end{nt}
    <>
]],
      {
        i(1),
        i(0),
      },
      { delimiters = '<>' }
    ),
    { condition = line_begin }
  ),
}
