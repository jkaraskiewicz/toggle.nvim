local M = {}

M.defaults = {
  prefix = '<leader>t',
  toggles = {
    {
      id = 'relative_line_numbers',
      key = 'r',
      toggle = function(value)
        vim.opt.relativenumber = value
      end,
      desc = 'Relative line numbers',
    },
    {
      id = 'cursor_style',
      key = 'c',
      values = { 'block', 'hor20', 'ver25' },
      toggle = function(value)
        vim.opt.guicursor = 'n-v-c:default,i-ci-ve:ver25,r-cr:hor20,o:hor50'
        if value == 'block' then
          vim.opt.guicursor = 'n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50'
        elseif value == 'hor20' then
          vim.opt.guicursor = 'n-v-c:hor20,i-ci-ve:ver25,r-cr:hor20,o:hor50'
        elseif value == 'ver25' then
          vim.opt.guicursor = 'n-v-c:ver25,i-ci-ve:ver25,r-cr:hor20,o:hor50'
        end
      end,
      desc = 'Cursor style',
    },
  },
}

M.options = {}

M.setup = function(opts)
  M.options = vim.tbl_deep_extend('force', {}, M.defaults, opts or {})
end

return M
