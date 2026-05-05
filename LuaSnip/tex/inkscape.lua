-- ~/.config/nvim/LuaSnip/tex/inkscape.lua
local ls = require 'luasnip'
local s = ls.snippet
local i = ls.insert_node
local fmt = require('luasnip.extras.fmt').fmt

return {
  s(
    'incfig',
    fmt(
      [[
    \begin{figure}[ht]
        \centering
        \incfig{<>}
        \caption{<>}
        \label{fig:<>}
    \end{figure}
    ]],
      {
        i(1, 'name'),
        i(2, 'caption'),
        i(3, 'label'),
      },
      { delimiters = '<>' }
    )
  ),
}
