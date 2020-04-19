local items = require("items")
local constants = require("constants")


local simulation = {}


simulation.create_state = function()
  math.randomseed(os.time())
  return
  {
    request = 'pick_axe',
    request_time_remaining = 60 * 20,
    in_day = false,
    day = 0,
    day_time_remaining = constants.day_length_ticks,
    pee_time_remaining = constants.pee_ticks,
    in_toilet = 0,
    position_str = '',
    money = constants.starting_money,
    money_today = 0,
    dock_today = 0,
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

  if #path == 0 then
    table.insert(names, "bath_room")
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
    state.money_today = state.money_today + constants.item_pay
    simulation.generate_new_request(state)
  else
    simulation._on_error(state)
    state.dock_today = state.dock_today - constants.wrong_item_dock
  end

  state.position_str = ''
end

simulation.keypress = function(state, key)
  if not state.in_day then

    local bankrupt = state.money + state.money_today + state.dock_today - constants.rent < 0

    if bankrupt then
      if key == 'r' then
        local new_state = simulation.create_state()
        for k, _ in pairs(state) do
          state[k] = new_state[k]
        end
      end
    else
      if key == 'b' then
        if state.day ~= 1 then
          state.money = state.money + state.money_today + state.dock_today - constants.rent
          simulation.generate_new_request(state)
        end

        state.in_toilet = 0
        state.pee_time_remaining = constants.pee_ticks
        state.in_day = true
        state.day = state.day + 1
        state.money_today = 0
        state.dock_today = 0
        state.day_time_remaining = constants.day_length_ticks
      end
    end

    return
  end

  local current_item = simulation.get_item(simulation.get_position_path(state.position_str))
  if key == 'd' and current_item then
    simulation._deliver_item(state, current_item)
    return
  end

  if state.in_toilet > 0 then
    return
  end

  if key == 'b' and state.position_str == '' then
    state.pee_time_remaining = constants.pee_ticks
    state.in_toilet = constants.toilet_duration
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
  if not state.in_day then
    return
  end

  state.tick = state.tick + 1

  state.request_time_remaining = state.request_time_remaining - 1
  if state.request_time_remaining == 0 then
    simulation._on_error(state)
    state.dock_today = state.dock_today - constants.missed_item_dock

    simulation.generate_new_request(state)
  end

  if state.in_toilet == 0 then
    state.pee_time_remaining = state.pee_time_remaining - 1
  else
    state.in_toilet = state.in_toilet - 1
  end
  if state.pee_time_remaining == 0 then
    state.in_day = false
    state.dock_today = state.dock_today - constants.pee_dock
  end

  state.day_time_remaining = state.day_time_remaining - 1
  if state.day_time_remaining == 0 then
    state.in_day = false
  end

end

simulation.get_item = function(path)
  if #path == 3 then
    return path[3]
  end

  return nil
end

return simulation