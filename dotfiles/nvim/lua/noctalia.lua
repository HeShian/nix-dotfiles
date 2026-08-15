-- 配色由 Noctalia 主题模板生成（模板源：dotfiles/noctalia/templates/neovim.lua），
-- 生成文件缺失时回退内置 Catppuccin Mocha。
local M = {}

local colors_path = vim.fn.stdpath('data') .. '/noctalia/colors.lua'

-- 兜底配色（Catppuccin Mocha）
local fallback = {
  base00 = '#1e1e2e',
  base01 = '#313244',
  base02 = '#3a3b50',
  base03 = '#646789',
  base04 = '#a3b4eb',
  base05 = '#cdd6f4',
  base06 = '#cdd6f4',
  base07 = '#cdd6f4',
  base08 = '#f38ba8',
  base09 = '#94e2d5',
  base0A = '#fab387',
  base0B = '#cba6f7',
  base0C = '#96e9db',
  base0D = '#bb8af4',
  base0E = '#fab185',
  base0F = '#c8043a',
}

local function load_colors()
  local ok, colors = pcall(dofile, colors_path)
  if ok and type(colors) == 'table' and colors.base00 then
    return colors
  end
  return fallback
end

function M.setup()
  local c = load_colors()
  require('base16-colorscheme').setup(c)

  local hi = function(group, opts)
    vim.api.nvim_set_hl(0, group, opts)
  end

  hi('TelescopeNormal', { fg = c.base05, bg = c.base00 })
  hi('TelescopeBorder', { fg = c.base03, bg = c.base00 })
  hi('TelescopePromptNormal', { fg = c.base05, bg = c.base00 })
  hi('TelescopePromptBorder', { fg = c.base03, bg = c.base00 })
  hi('TelescopePromptPrefix', { fg = c.base0D, bg = c.base00 })
  hi('TelescopePromptCounter', { fg = c.base04, bg = c.base00 })
  hi('TelescopePromptTitle', { fg = c.base00, bg = c.base0D })
  hi('TelescopePreviewTitle', { fg = c.base00, bg = c.base0A })
  hi('TelescopeResultsTitle', { fg = c.base00, bg = c.base0B })
  hi('TelescopeSelection', { fg = c.base05, bg = c.base02 })
  hi('TelescopeSelectionCaret', { fg = c.base0D, bg = c.base02 })
  hi('TelescopeMatching', { fg = c.base0D, bold = true })
end

-- SIGUSR1 热重载（Noctalia post_hook 里 pkill -USR1 nvim）：只重跑 M.setup()，
-- 不能重新 require 本模块——那会重复注册 signal 且旧句柄永不 close（泄漏）
local signal = vim.uv.new_signal()
signal:start(
  'sigusr1',
  vim.schedule_wrap(function()
    M.setup()
  end)
)

return M
