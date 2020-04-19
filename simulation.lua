local items = require("items")


local simulation = {}

local item_pay = 25
local wrong_item_dock = 50
local missed_item_dock = 50


simulation.create_state = function()
  math.randomseed(os.time())
  return
  {
    request = 'pick_axe',
    request_time_remaining = 60 * 30,
    day = 1,
    position_str = '',
    money = 20000,
    money_today = 0,
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

simulation.get_all_items_dict = function()

  local all_items = {}

  local r
  r = function(entry)
    if entry.item_code then
      all_items[entry.name] = entry
    end

    for _, item in pairs(entry.children) do
      r(item)
    end
  end

  r(items.items_list)

  return all_items
end

simulation.get_all_items_list = function()
  local all_items_dict = simulation.get_all_items_dict()

  local r = {}
  for _, val in pairs(all_items_dict) do
    table.insert(r, val)
  end

  return r
end

simulation.generate_new_request = function(state)
  local all_items = simulation.get_all_items_list()

  state.request = all_items[math.random(#all_items)].name
  state.request_time_remaining = math.floor(math.random(5, 10) * 60)
end

simulation._on_error = function(state)

end

simulation._deliver_item = function(state, item)
  if state.request == item then
    state.money_today = state.money_today + item_pay
    simulation.generate_new_request(state)
  else
    simulation._on_error(state)
    state.money_today = state.money_today - wrong_item_dock
  end

  state.position_str = ''
end

simulation.keypress = function(state, key)
  local current_item = simulation.get_item(simulation.get_position_path(state.position_str))
  if key == 'd' and current_item then
    simulation._deliver_item(state, current_item)
    return
  end


  local new_position = state.position_str .. key

  if string.len(key) ~= 1 then
    new_position = ''
  else
    local path = simulation.get_position_path(new_position)
    if #path == 0 then
      new_position = ''
    end
  end

  if new_position == '' then
    simulation._on_error(state)
  end

  state.position_str = new_position
end

simulation.update = function(state)
  state.tick = state.tick + 1

  state.request_time_remaining = state.request_time_remaining - 1
  if state.request_time_remaining == 0 then
    simulation._on_error(state)
    state.money_today = state.money_today - missed_item_dock

    simulation.generate_new_request(state)
  end
end

simulation.get_item = function(path)
  if #path == 3 then
    return path[3]
  end

  return nil
end

return simulation