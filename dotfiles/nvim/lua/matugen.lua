 local M = {}

function M.setup()
  require('base16-colorscheme').setup({
    base00 = '#101412',
    base01 = '#1c211e',
    base02 = '#272b28',
    base03 = '#88938c',
    base04 = '#bec9c1',
    base05 = '#e0e3df',
    base06 = '#e0e3df',
    base07 = '#e0e3df',
    base08 = '#ffb4ab',
    base09 = '#c4c0ff',
    base0A = '#aecebd',
    base0B = '#86d7b3',
    base0C = '#c4c0ff',
    base0D = '#86d7b3',
    base0E = '#aecebd',
    base0F = '#93000a',
  })

  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  hi('TelescopeNormal',         { fg = '#e0e3df',          bg = '#101412' })
  hi('TelescopeBorder',         { fg = '#88938c',             bg = '#101412' })
  hi('TelescopePromptNormal',   { fg = '#e0e3df',          bg = '#101412' })
  hi('TelescopePromptBorder',   { fg = '#88938c',             bg = '#101412' })
  hi('TelescopePromptPrefix',   { fg = '#86d7b3',             bg = '#101412' })
  hi('TelescopePromptCounter',  { fg = '#bec9c1',  bg = '#101412' })
  hi('TelescopePromptTitle',    { fg = '#101412',             bg = '#86d7b3' })
  hi('TelescopePreviewTitle',   { fg = '#101412',             bg = '#aecebd' })
  hi('TelescopeResultsTitle',   { fg = '#101412',             bg = '#c4c0ff' })
  hi('TelescopeSelection',      { fg = '#e0e3df',          bg = '#272b28' })
  hi('TelescopeSelectionCaret', { fg = '#86d7b3',             bg = '#272b28' })
  hi('TelescopeMatching',       { fg = '#86d7b3',             bold = true })
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
