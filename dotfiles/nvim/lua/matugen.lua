 local M = {}

function M.setup()
  require('base16-colorscheme').setup({
    base00 = '#111318',
    base01 = '#1d2024',
    base02 = '#282a2f',
    base03 = '#8c919b',
    base04 = '#c2c6d2',
    base05 = '#e1e2e8',
    base06 = '#e1e2e8',
    base07 = '#e1e2e8',
    base08 = '#ffb4ab',
    base09 = '#eeb1ff',
    base0A = '#b5c8e7',
    base0B = '#a3c9ff',
    base0C = '#eeb1ff',
    base0D = '#a3c9ff',
    base0E = '#b5c8e7',
    base0F = '#93000a',
  })

  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  hi('TelescopeNormal',         { fg = '#e1e2e8',          bg = '#111318' })
  hi('TelescopeBorder',         { fg = '#8c919b',             bg = '#111318' })
  hi('TelescopePromptNormal',   { fg = '#e1e2e8',          bg = '#111318' })
  hi('TelescopePromptBorder',   { fg = '#8c919b',             bg = '#111318' })
  hi('TelescopePromptPrefix',   { fg = '#a3c9ff',             bg = '#111318' })
  hi('TelescopePromptCounter',  { fg = '#c2c6d2',  bg = '#111318' })
  hi('TelescopePromptTitle',    { fg = '#111318',             bg = '#a3c9ff' })
  hi('TelescopePreviewTitle',   { fg = '#111318',             bg = '#b5c8e7' })
  hi('TelescopeResultsTitle',   { fg = '#111318',             bg = '#eeb1ff' })
  hi('TelescopeSelection',      { fg = '#e1e2e8',          bg = '#282a2f' })
  hi('TelescopeSelectionCaret', { fg = '#a3c9ff',             bg = '#282a2f' })
  hi('TelescopeMatching',       { fg = '#a3c9ff',             bold = true })
end

 -- Register a signal handler for SIGUSR1 (matugen updates)
 local signal = vim.uv.new_signal()
 signal:start(
   'sigusr1',
   vim.schedule_wrap(function()
     package.loaded['matugen'] = nil
     require('matugen').setup()
   end)
 )

 return M
