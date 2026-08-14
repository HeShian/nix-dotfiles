 local M = {}

function M.setup()
  require('base16-colorscheme').setup({
    base00 = '#141312',
    base01 = '#211f1e',
    base02 = '#2b2a28',
    base03 = '#979085',
    base04 = '#cec5ba',
    base05 = '#e7e1de',
    base06 = '#e7e1de',
    base07 = '#e7e1de',
    base08 = '#ffb4ab',
    base09 = '#eff2dd',
    base0A = '#cec5ba',
    base0B = '#feeed5',
    base0C = '#c5c9b4',
    base0D = '#d3c5ad',
    base0E = '#cec5ba',
    base0F = '#93000a',
  })

  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  hi('TelescopeNormal',         { fg = '#e7e1de',          bg = '#141312' })
  hi('TelescopeBorder',         { fg = '#979085',             bg = '#141312' })
  hi('TelescopePromptNormal',   { fg = '#e7e1de',          bg = '#141312' })
  hi('TelescopePromptBorder',   { fg = '#979085',             bg = '#141312' })
  hi('TelescopePromptPrefix',   { fg = '#feeed5',             bg = '#141312' })
  hi('TelescopePromptCounter',  { fg = '#cec5ba',  bg = '#141312' })
  hi('TelescopePromptTitle',    { fg = '#141312',             bg = '#feeed5' })
  hi('TelescopePreviewTitle',   { fg = '#141312',             bg = '#cec5ba' })
  hi('TelescopeResultsTitle',   { fg = '#141312',             bg = '#eff2dd' })
  hi('TelescopeSelection',      { fg = '#e7e1de',          bg = '#2b2a28' })
  hi('TelescopeSelectionCaret', { fg = '#feeed5',             bg = '#2b2a28' })
  hi('TelescopeMatching',       { fg = '#feeed5',             bold = true })
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
