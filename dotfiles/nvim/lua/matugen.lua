 local M = {}

function M.setup()
  require('base16-colorscheme').setup({
    base00 = '#12131b',
    base01 = '#1e1f28',
    base02 = '#292932',
    base03 = '#8f8fa1',
    base04 = '#c5c5d7',
    base05 = '#e3e1ed',
    base06 = '#e3e1ed',
    base07 = '#e3e1ed',
    base08 = '#ffb4ab',
    base09 = '#f3aeff',
    base0A = '#bcc2ff',
    base0B = '#bcc2ff',
    base0C = '#f3aeff',
    base0D = '#bcc2ff',
    base0E = '#bcc2ff',
    base0F = '#93000a',
  })

  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  hi('TelescopeNormal',         { fg = '#e3e1ed',          bg = '#12131b' })
  hi('TelescopeBorder',         { fg = '#8f8fa1',             bg = '#12131b' })
  hi('TelescopePromptNormal',   { fg = '#e3e1ed',          bg = '#12131b' })
  hi('TelescopePromptBorder',   { fg = '#8f8fa1',             bg = '#12131b' })
  hi('TelescopePromptPrefix',   { fg = '#bcc2ff',             bg = '#12131b' })
  hi('TelescopePromptCounter',  { fg = '#c5c5d7',  bg = '#12131b' })
  hi('TelescopePromptTitle',    { fg = '#12131b',             bg = '#bcc2ff' })
  hi('TelescopePreviewTitle',   { fg = '#12131b',             bg = '#bcc2ff' })
  hi('TelescopeResultsTitle',   { fg = '#12131b',             bg = '#f3aeff' })
  hi('TelescopeSelection',      { fg = '#e3e1ed',          bg = '#292932' })
  hi('TelescopeSelectionCaret', { fg = '#bcc2ff',             bg = '#292932' })
  hi('TelescopeMatching',       { fg = '#bcc2ff',             bold = true })
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
