local M = {}
local H = {}

local data_dir = vim.fn.stdpath('data')
local plugin_data_dir = data_dir .. '/toggle'
local filepath = plugin_data_dir .. '/state'

local utils = require('toggle.utils')

M.setup = function(opts)
  local config = require('toggle.config')
  config.setup(opts)

  pcall(vim.fn.mkdir, plugin_data_dir, 'p')

  H.sync_stored_state(config.options)
end


H.read_state_for_id = function(id)
  local state = H.read_state_as_json()
  return state[id]
end

H.write_state_for_id = function(id, value)
  local state = H.read_state_as_json()
  state[id] = value
  H.write_state_as_json(state)
end

H.read_state_as_json = function()
  local file = io.open(filepath, 'r')
  if file then
    local json_string = file:read('*a')
    file:close()
    return vim.json.decode(json_string)
  else
    return {}
  end
end

H.write_state_as_json = function(data)
  local file = io.open(filepath, 'w')
  if file then
    file:write(vim.json.encode(data))
    file:close()
  else
    vim.notify('Failed to open file for writing: ' .. filepath, vim.log.levels.ERROR)
  end
end

H.sync_stored_state = function(opts)
  local state = H.read_state_as_json()
  local opts_toggles = opts.toggles

  -- Remove stale entries from the stored state file
  local in_config = function(id, _)
    return utils.tables.contains(opts_toggles, function(_, value) return id == value.id end)
  end

  local leftovers = utils.tables.filter_not(state, in_config)
  for k, _ in pairs(leftovers) do
    state[k] = nil
  end

  -- Add new entries from the opts to the stored state file
  for _, value in ipairs(opts_toggles) do
    local id = value.id
    local values = value.values or { false, true }
    local key = value.key
    local toggle_fn = value.toggle
    local desc = value.desc

    state[id] = state[id] or 0
    local value_to_set = values[state[id]]

    vim.keymap.set('n', opts.prefix .. key, function() end, { noremap = true, silent = true, desc = desc })

    toggle_fn(value_to_set)
  end

  H.write_state_as_json(state)
end

return M
