 local M = {}

function M.setup()
  require('base16-colorscheme').setup({
    base00 = '#10131b',
    base01 = '#1d1f27',
    base02 = '#272a32',
    base03 = '#8c90a0',
    base04 = '#c2c6d7',
    base05 = '#e1e2ed',
    base06 = '#e1e2ed',
    base07 = '#e1e2ed',
    base08 = '#ffb4ab',
    base09 = '#eeb1ff',
    base0A = '#b0c6ff',
    base0B = '#b0c6ff',
    base0C = '#eeb1ff',
    base0D = '#b0c6ff',
    base0E = '#b0c6ff',
    base0F = '#93000a',
  })

  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  hi('TelescopeNormal',         { fg = '#e1e2ed',          bg = '#10131b' })
  hi('TelescopeBorder',         { fg = '#8c90a0',             bg = '#10131b' })
  hi('TelescopePromptNormal',   { fg = '#e1e2ed',          bg = '#10131b' })
  hi('TelescopePromptBorder',   { fg = '#8c90a0',             bg = '#10131b' })
  hi('TelescopePromptPrefix',   { fg = '#b0c6ff',             bg = '#10131b' })
  hi('TelescopePromptCounter',  { fg = '#c2c6d7',  bg = '#10131b' })
  hi('TelescopePromptTitle',    { fg = '#10131b',             bg = '#b0c6ff' })
  hi('TelescopePreviewTitle',   { fg = '#10131b',             bg = '#b0c6ff' })
  hi('TelescopeResultsTitle',   { fg = '#10131b',             bg = '#eeb1ff' })
  hi('TelescopeSelection',      { fg = '#e1e2ed',          bg = '#272a32' })
  hi('TelescopeSelectionCaret', { fg = '#b0c6ff',             bg = '#272a32' })
  hi('TelescopeMatching',       { fg = '#b0c6ff',             bold = true })
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
