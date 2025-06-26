local M = {}

M.defaults = {
  prefix = '<leader>t',
  toggles = {
    {
      id = 'relative_line_numbers',
      key = 'r',
      toggle = function(value)
        print('Toggling relative line numbers')
      end,
      desc = 'Relative line numbers',
    },
  },
}

M.options = {}

M.setup = function(opts)
  M.options = vim.tbl_deep_extend('force', {}, M.defaults, opts or {})
end

return M
