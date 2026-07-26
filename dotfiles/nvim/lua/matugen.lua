 local M = {}

function M.setup()
  require('base16-colorscheme').setup({
    base00 = '#17130d',
    base01 = '#241f19',
    base02 = '#2e2923',
    base03 = '#9c8f7e',
    base04 = '#d4c4b2',
    base05 = '#ebe1d7',
    base06 = '#ebe1d7',
    base07 = '#ebe1d7',
    base08 = '#ffb4ab',
    base09 = '#cbd980',
    base0A = '#e1c298',
    base0B = '#ffc875',
    base0C = '#c0ce76',
    base0D = '#f6bd65',
    base0E = '#e1c298',
    base0F = '#93000a',
  })

  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  hi('TelescopeNormal',         { fg = '#ebe1d7',          bg = '#17130d' })
  hi('TelescopeBorder',         { fg = '#9c8f7e',             bg = '#17130d' })
  hi('TelescopePromptNormal',   { fg = '#ebe1d7',          bg = '#17130d' })
  hi('TelescopePromptBorder',   { fg = '#9c8f7e',             bg = '#17130d' })
  hi('TelescopePromptPrefix',   { fg = '#ffc875',             bg = '#17130d' })
  hi('TelescopePromptCounter',  { fg = '#d4c4b2',  bg = '#17130d' })
  hi('TelescopePromptTitle',    { fg = '#17130d',             bg = '#ffc875' })
  hi('TelescopePreviewTitle',   { fg = '#17130d',             bg = '#e1c298' })
  hi('TelescopeResultsTitle',   { fg = '#17130d',             bg = '#cbd980' })
  hi('TelescopeSelection',      { fg = '#ebe1d7',          bg = '#2e2923' })
  hi('TelescopeSelectionCaret', { fg = '#ffc875',             bg = '#2e2923' })
  hi('TelescopeMatching',       { fg = '#ffc875',             bold = true })
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
