local M = {}

function M.setup()
  require('base16-colorscheme').setup({
    base00 = '#131317',
    base01 = '#1f1f23',
    base02 = '#292a2e',
    base03 = '#8f909a',
    base04 = '#c6c5d1',
    base05 = '#e4e1e7',
    base06 = '#e4e1e7',
    base07 = '#e4e1e7',
    base08 = '#ffb4ab',
    base09 = '#f0b3e7',
    base0A = '#c1c5e0',
    base0B = '#b6c4ff',
    base0C = '#f0b3e7',
    base0D = '#b6c4ff',
    base0E = '#c1c5e0',
    base0F = '#93000a',
  })

  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  hi('TelescopeNormal', { fg = '#e4e1e7', bg = '#131317' })
  hi('TelescopeBorder', { fg = '#8f909a', bg = '#131317' })
  hi('TelescopePromptNormal', { fg = '#e4e1e7', bg = '#131317' })
  hi('TelescopePromptBorder', { fg = '#8f909a', bg = '#131317' })
  hi('TelescopePromptPrefix', { fg = '#b6c4ff', bg = '#131317' })
  hi('TelescopePromptCounter', { fg = '#c6c5d1', bg = '#131317' })
  hi('TelescopePromptTitle', { fg = '#131317', bg = '#b6c4ff' })
  hi('TelescopePreviewTitle', { fg = '#131317', bg = '#c1c5e0' })
  hi('TelescopeResultsTitle', { fg = '#131317', bg = '#f0b3e7' })
  hi('TelescopeSelection', { fg = '#e4e1e7', bg = '#292a2e' })
  hi('TelescopeSelectionCaret', { fg = '#b6c4ff', bg = '#292a2e' })
  hi('TelescopeMatching', { fg = '#b6c4ff', bold = true })
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
