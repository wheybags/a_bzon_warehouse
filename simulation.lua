local items = require("items")


local simulation = {}

simulation.create_state = function()
  return
  {
    request = 'pickaxe',
    position_str = '',
    tick = 1,
  }
end

simulation.get_path_next_options = function(path)
  local current = items.items_dict
  for _, point in pairs(path) do
    current = current[point]
  end

  local names = {}
  for _, item in pairs (current.orig.children) do
    table.insert(names, item.name)
  end

  return names
end

simulation.get_position_path = function(position_str)
  local path = {}

  local current = items.items_list

  for c in position_str:gmatch(".") do
    if #current.children == 0 then
      return {}
    end

    local found = false

    for _, data in pairs(current.children) do
      if data.name:sub(1,1) == c then
        found = true
        table.insert(path, data.name)
        current = data
        break
      end
    end

    if not found then
      return {}
    end
  end

  return path
end


simulation.keypress = function(state, key)
  local new_position = state.position_str .. key

  if string.len(key) ~= 1 then
    new_position = ''
  else
    local path = simulation.get_position_path(new_position)
    print("AAA", #path)

    if #path == 0 then
      new_position = ''
    end
  end

  state.position_str = new_position

  print(state.position_str)
end

simulation.update = function(state)
  state.tick = state.tick + 1
end

return simulation