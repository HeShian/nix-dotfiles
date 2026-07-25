 local M = {}

function M.setup()
  require('base16-colorscheme').setup({
    base00 = '#12131d',
    base01 = '#1e1f2a',
    base02 = '#282934',
    base03 = '#8f8fa3',
    base04 = '#c5c5da',
    base05 = '#e2e1f0',
    base06 = '#e2e1f0',
    base07 = '#e2e1f0',
    base08 = '#ffb4ab',
    base09 = '#f4aeff',
    base0A = '#bdc2ff',
    base0B = '#bdc2ff',
    base0C = '#f4aeff',
    base0D = '#bdc2ff',
    base0E = '#bdc2ff',
    base0F = '#93000a',
  })

  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  hi('TelescopeNormal',         { fg = '#e2e1f0',          bg = '#12131d' })
  hi('TelescopeBorder',         { fg = '#8f8fa3',             bg = '#12131d' })
  hi('TelescopePromptNormal',   { fg = '#e2e1f0',          bg = '#12131d' })
  hi('TelescopePromptBorder',   { fg = '#8f8fa3',             bg = '#12131d' })
  hi('TelescopePromptPrefix',   { fg = '#bdc2ff',             bg = '#12131d' })
  hi('TelescopePromptCounter',  { fg = '#c5c5da',  bg = '#12131d' })
  hi('TelescopePromptTitle',    { fg = '#12131d',             bg = '#bdc2ff' })
  hi('TelescopePreviewTitle',   { fg = '#12131d',             bg = '#bdc2ff' })
  hi('TelescopeResultsTitle',   { fg = '#12131d',             bg = '#f4aeff' })
  hi('TelescopeSelection',      { fg = '#e2e1f0',          bg = '#282934' })
  hi('TelescopeSelectionCaret', { fg = '#bdc2ff',             bg = '#282934' })
  hi('TelescopeMatching',       { fg = '#bdc2ff',             bold = true })
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
