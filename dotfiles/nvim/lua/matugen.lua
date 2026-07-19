 local M = {}

function M.setup()
  require('base16-colorscheme').setup({
    base00 = '#121315',
    base01 = '#1e2021',
    base02 = '#292a2b',
    base03 = '#8c9196',
    base04 = '#c2c7cc',
    base05 = '#e3e2e4',
    base06 = '#e3e2e4',
    base07 = '#e3e2e4',
    base08 = '#ffb4ab',
    base09 = '#dabdde',
    base0A = '#bdc8d1',
    base0B = '#aecae0',
    base0C = '#dabdde',
    base0D = '#aecae0',
    base0E = '#bdc8d1',
    base0F = '#93000a',
  })

  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  hi('TelescopeNormal',         { fg = '#e3e2e4',          bg = '#121315' })
  hi('TelescopeBorder',         { fg = '#8c9196',             bg = '#121315' })
  hi('TelescopePromptNormal',   { fg = '#e3e2e4',          bg = '#121315' })
  hi('TelescopePromptBorder',   { fg = '#8c9196',             bg = '#121315' })
  hi('TelescopePromptPrefix',   { fg = '#aecae0',             bg = '#121315' })
  hi('TelescopePromptCounter',  { fg = '#c2c7cc',  bg = '#121315' })
  hi('TelescopePromptTitle',    { fg = '#121315',             bg = '#aecae0' })
  hi('TelescopePreviewTitle',   { fg = '#121315',             bg = '#bdc8d1' })
  hi('TelescopeResultsTitle',   { fg = '#121315',             bg = '#dabdde' })
  hi('TelescopeSelection',      { fg = '#e3e2e4',          bg = '#292a2b' })
  hi('TelescopeSelectionCaret', { fg = '#aecae0',             bg = '#292a2b' })
  hi('TelescopeMatching',       { fg = '#aecae0',             bold = true })
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
