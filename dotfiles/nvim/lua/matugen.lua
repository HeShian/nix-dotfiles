 local M = {}

function M.setup()
  require('base16-colorscheme').setup({
    base00 = '#13140e',
    base01 = '#20201a',
    base02 = '#2a2a24',
    base03 = '#919282',
    base04 = '#c8c7b6',
    base05 = '#e5e3d9',
    base06 = '#e5e3d9',
    base07 = '#e5e3d9',
    base08 = '#ffb4ab',
    base09 = '#99d4a0',
    base0A = '#c6caa2',
    base0B = '#c2cd7b',
    base0C = '#99d4a0',
    base0D = '#c2cd7b',
    base0E = '#c6caa2',
    base0F = '#93000a',
  })

  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  hi('TelescopeNormal',         { fg = '#e5e3d9',          bg = '#13140e' })
  hi('TelescopeBorder',         { fg = '#919282',             bg = '#13140e' })
  hi('TelescopePromptNormal',   { fg = '#e5e3d9',          bg = '#13140e' })
  hi('TelescopePromptBorder',   { fg = '#919282',             bg = '#13140e' })
  hi('TelescopePromptPrefix',   { fg = '#c2cd7b',             bg = '#13140e' })
  hi('TelescopePromptCounter',  { fg = '#c8c7b6',  bg = '#13140e' })
  hi('TelescopePromptTitle',    { fg = '#13140e',             bg = '#c2cd7b' })
  hi('TelescopePreviewTitle',   { fg = '#13140e',             bg = '#c6caa2' })
  hi('TelescopeResultsTitle',   { fg = '#13140e',             bg = '#99d4a0' })
  hi('TelescopeSelection',      { fg = '#e5e3d9',          bg = '#2a2a24' })
  hi('TelescopeSelectionCaret', { fg = '#c2cd7b',             bg = '#2a2a24' })
  hi('TelescopeMatching',       { fg = '#c2cd7b',             bold = true })
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
