 local M = {}

function M.setup()
  require('base16-colorscheme').setup({
    base00 = '#101416',
    base01 = '#1c2023',
    base02 = '#272a2d',
    base03 = '#899298',
    base04 = '#bfc8cf',
    base05 = '#e0e3e6',
    base06 = '#e0e3e6',
    base07 = '#e0e3e6',
    base08 = '#ffb4ab',
    base09 = '#e7b5f9',
    base0A = '#afcadd',
    base0B = '#85cffa',
    base0C = '#e7b5f9',
    base0D = '#85cffa',
    base0E = '#afcadd',
    base0F = '#93000a',
  })

  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  hi('TelescopeNormal',         { fg = '#e0e3e6',          bg = '#101416' })
  hi('TelescopeBorder',         { fg = '#899298',             bg = '#101416' })
  hi('TelescopePromptNormal',   { fg = '#e0e3e6',          bg = '#101416' })
  hi('TelescopePromptBorder',   { fg = '#899298',             bg = '#101416' })
  hi('TelescopePromptPrefix',   { fg = '#85cffa',             bg = '#101416' })
  hi('TelescopePromptCounter',  { fg = '#bfc8cf',  bg = '#101416' })
  hi('TelescopePromptTitle',    { fg = '#101416',             bg = '#85cffa' })
  hi('TelescopePreviewTitle',   { fg = '#101416',             bg = '#afcadd' })
  hi('TelescopeResultsTitle',   { fg = '#101416',             bg = '#e7b5f9' })
  hi('TelescopeSelection',      { fg = '#e0e3e6',          bg = '#272a2d' })
  hi('TelescopeSelectionCaret', { fg = '#85cffa',             bg = '#272a2d' })
  hi('TelescopeMatching',       { fg = '#85cffa',             bold = true })
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
