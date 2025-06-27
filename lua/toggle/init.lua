local M = {}
local H = {}

local utils = require('utils')

local data_dir = vim.fn.stdpath('data')
local plugin_data_dir = data_dir .. '/toggle'
local filepath = plugin_data_dir .. '/state'

H.clues = {}

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
    -- Handle empty file case
    if json_string == '' then return {} end
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

H.get_description = function(desc, value)
  return string.format('%s (current: %s)', desc, value)
end

H.sync_stored_state = function(opts)
  local state = H.read_state_as_json()
  local opts_toggles = opts.toggles

  -- Remove stale entries from the stored state file
  local in_config = function(id, _)
    return utils.tables.contains(opts_toggles, function(config_id, _) return id == config_id end)
  end

  local leftovers = utils.tables.filter_not(state, in_config)
  for k, _ in pairs(leftovers) do
    state[k] = nil
  end

  -- Add/update toggles based on config
  for id, value in pairs(opts_toggles) do
    local values = value.values or { false, true }
    local key = value.key
    local toggle_fn = value.toggle
    local desc = value.desc
    local enabled = value.enabled

    -- Skip disabled toggles
    if not enabled then goto continue end

    -- Initialize state to 1 (first value) if not present
    state[id] = state[id] or 1
    local current_value = values[state[id]]

    -- The keymap callback that cycles through the values
    local callback
    callback = function()
      local current_index = H.read_state_for_id(id) or 1
      local next_index = current_index % #values + 1

      H.write_state_for_id(id, next_index)

      local new_value = values[next_index]
      toggle_fn(new_value)

      -- Adjust description for the keymap reflecting the new value
      vim.keymap.set('n', opts.prefix .. key, callback,
        { noremap = true, silent = true, desc = H.get_description(desc, new_value) })
    end

    -- Add clues for mini.clue
    table.insert(H.clues, { mode = 'n', keys = opts.prefix .. key, postkeys = opts.prefix })

    -- Setup keymaps for toggles
    vim.keymap.set('n', opts.prefix .. key, callback,
      { noremap = true, silent = true, desc = H.get_description(desc, current_value) })

    -- Apply the initial state when setup is called
    toggle_fn(current_value)

    ::continue::
  end

  H.write_state_as_json(state)
end

M.clues = function()
  return H.clues
end

return M
