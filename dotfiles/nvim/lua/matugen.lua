 local M = {}

function M.setup()
  require('base16-colorscheme').setup({
    base00 = '#141310',
    base01 = '#211f1c',
    base02 = '#2b2a26',
    base03 = '#959083',
    base04 = '#ccc6b7',
    base05 = '#e7e2db',
    base06 = '#e7e2db',
    base07 = '#e7e2db',
    base08 = '#ffb4ab',
    base09 = '#bfd6ae',
    base0A = '#cec6ad',
    base0B = '#dbd09a',
    base0C = '#b7cda6',
    base0D = '#d2c792',
    base0E = '#cec6ad',
    base0F = '#93000a',
  })

  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  hi('TelescopeNormal',         { fg = '#e7e2db',          bg = '#141310' })
  hi('TelescopeBorder',         { fg = '#959083',             bg = '#141310' })
  hi('TelescopePromptNormal',   { fg = '#e7e2db',          bg = '#141310' })
  hi('TelescopePromptBorder',   { fg = '#959083',             bg = '#141310' })
  hi('TelescopePromptPrefix',   { fg = '#dbd09a',             bg = '#141310' })
  hi('TelescopePromptCounter',  { fg = '#ccc6b7',  bg = '#141310' })
  hi('TelescopePromptTitle',    { fg = '#141310',             bg = '#dbd09a' })
  hi('TelescopePreviewTitle',   { fg = '#141310',             bg = '#cec6ad' })
  hi('TelescopeResultsTitle',   { fg = '#141310',             bg = '#bfd6ae' })
  hi('TelescopeSelection',      { fg = '#e7e2db',          bg = '#2b2a26' })
  hi('TelescopeSelectionCaret', { fg = '#dbd09a',             bg = '#2b2a26' })
  hi('TelescopeMatching',       { fg = '#dbd09a',             bold = true })
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
