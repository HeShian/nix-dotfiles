 local M = {}

function M.setup()
  require('base16-colorscheme').setup({
    base00 = '#121317',
    base01 = '#1e1f23',
    base02 = '#292a2e',
    base03 = '#8e909a',
    base04 = '#c4c6d0',
    base05 = '#e3e2e7',
    base06 = '#e3e2e7',
    base07 = '#e3e2e7',
    base08 = '#ffb4ab',
    base09 = '#edb4ea',
    base0A = '#bdc6e0',
    base0B = '#adc6ff',
    base0C = '#edb4ea',
    base0D = '#adc6ff',
    base0E = '#bdc6e0',
    base0F = '#93000a',
  })

  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  hi('TelescopeNormal',         { fg = '#e3e2e7',          bg = '#121317' })
  hi('TelescopeBorder',         { fg = '#8e909a',             bg = '#121317' })
  hi('TelescopePromptNormal',   { fg = '#e3e2e7',          bg = '#121317' })
  hi('TelescopePromptBorder',   { fg = '#8e909a',             bg = '#121317' })
  hi('TelescopePromptPrefix',   { fg = '#adc6ff',             bg = '#121317' })
  hi('TelescopePromptCounter',  { fg = '#c4c6d0',  bg = '#121317' })
  hi('TelescopePromptTitle',    { fg = '#121317',             bg = '#adc6ff' })
  hi('TelescopePreviewTitle',   { fg = '#121317',             bg = '#bdc6e0' })
  hi('TelescopeResultsTitle',   { fg = '#121317',             bg = '#edb4ea' })
  hi('TelescopeSelection',      { fg = '#e3e2e7',          bg = '#292a2e' })
  hi('TelescopeSelectionCaret', { fg = '#adc6ff',             bg = '#292a2e' })
  hi('TelescopeMatching',       { fg = '#adc6ff',             bold = true })
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
