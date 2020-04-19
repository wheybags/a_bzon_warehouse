local items = require("items")
local constants = require("constants")
local simulation = require("simulation")

local render = {}

render.setup = function()
  render.items = {}

  for i = 1,163 do
    local path = "gfx/items/genericItem_color_" .. string.format("%03d", i) .. ".png"
    render.items[i] = love.graphics.newImage(path)
  end

  render.font = love.graphics.newFont("gfx/Kenney Future Narrow.ttf", constants.font_size)
  love.graphics.setFont(render.font)
end

render._tile_to_screen_coord = function(pos)
  local result = {unpack(pos)}

  result[1] = result[1] * constants.tile_size
  result[2] = result[2] * constants.tile_size

  return result
end

render._path_to_screen_coord = function(path, positions)
  local tmp = positions

  for _, entry in pairs(path) do
    tmp = tmp[entry]
  end

  assert(tmp.pos)
  return render._tile_to_screen_coord(tmp.pos)
end

local sprite_scale = 0.4

render._draw_icon = function(idx, pos)
  local scale_override =
  {
    [96] = 2,
    [97] = 2,
    [89] = 2,
    [90] = 2,
    [93] = 1.5,
    [16] = 0.85,
  }

  local scale = (scale_override[idx] or 1) * sprite_scale

  local left = pos[1]
  local top = pos[2]

  local s = render.items[idx]

  local s_w = s:getWidth() * scale
  local s_h = s:getHeight() * scale

  local x = left + constants.tile_size / 2 - s_w / 2
  local y = top + constants.tile_size / 2 - s_h / 2


  love.graphics.setColor(1,1,1)
  love.graphics.draw(s, x, y, 0, scale, scale)
end

render._cents_to_money_str = function(total_cents)
  local cents_abs = math.abs(total_cents)
  local sign = ""
  if total_cents < 0 then
    sign = "-"
  end
  local dollars = math.floor(cents_abs / 100)
  local cents = cents_abs - (dollars * 100)

  return sign .. "$" .. tostring(dollars) .. "." .. string.format("%02d", cents)
end


render._draw_gui = function(state)
  local left = (constants.screen_w_tiles - 2) * constants.tile_size


  love.graphics.setColor(0.7, 0.7, 0.7)
  love.graphics.rectangle("fill", left, 0, constants.tile_size * 2, constants.screen_height)

  local vertical_margin = 20
  local y = 0

  y = y + vertical_margin

  love.graphics.setColor(0, 0, 0)

  love.graphics.setColor(0, 0, 0)
  love.graphics.print( "   Day: " .. tostring(state.day), left, y)
  y = y + constants.font_size

  y = y + vertical_margin

  local start_h = 7
  local end_h = 22

  local time_norm = (constants.day_length_ticks-state.day_time_remaining) / constants.day_length_ticks
  local decimal_hour_24 = time_norm * (end_h-start_h) + start_h

  local hour_24 = math.floor(decimal_hour_24)
  local normalised_minute = decimal_hour_24 - hour_24

  local minute = math.floor(normalised_minute * 60)
  local hour_12 = hour_24
  if hour_12 > 12 then
    hour_12 = hour_12 - 12
  end

  local am_pm = "AM"
  if decimal_hour_24 > 12 then
    am_pm = "PM"
  end

  love.graphics.print(string.format("   Time: %d:%02d %s", hour_12, minute, am_pm) , left, y)
  y = y + constants.font_size

  y = y + vertical_margin

  love.graphics.setColor(0, 0, 0)
  love.graphics.print( "   Bank: " .. render._cents_to_money_str(state.money), left, y)
  y = y + constants.font_size

  y = y + vertical_margin

  love.graphics.setColor(0, 0, 0)
  love.graphics.print("   Today: " .. render._cents_to_money_str(state.money_today), left, y)
  y = y + constants.font_size

  y = y + vertical_margin

  love.graphics.setColor(0,0,0)
  love.graphics.print("        DELIVER", left, y)
  y = y + constants.font_size

  y = y + vertical_margin

  local items_lookup = simulation.get_all_items_dict()
  local item_code = items_lookup[state.request].item_code
  love.graphics.rectangle("fill", left + 0.5 * constants.tile_size, y, constants.tile_size, constants.tile_size)

  render._draw_icon(item_code, {left + 0.5 * constants.tile_size, y})
  y = y + constants.tile_size

  y = y + vertical_margin

  love.graphics.setColor(0,0,0)
  love.graphics.print(string.format("        %d s left", math.floor(state.request_time_remaining/60)), left, y)
  y = y + constants.font_size

  y = y + vertical_margin


  love.graphics.setColor(1,1,1)
end

local render_text_in_tile_centre = function(str, option_pos)
  local text = love.graphics.newText(render.font, str)
  local x = option_pos[1] + constants.tile_size/2 - text:getWidth()/2
  local y = option_pos[2] + constants.tile_size/2 - text:getHeight()/2

  love.graphics.print(str, x, y)
end

local render_option = function(state, option, option_pos)
  local human_name = option:gsub("_", "\n")

  local text = love.graphics.newText(render.font, human_name)
  local x = option_pos[1] + constants.tile_size/2 - text:getWidth()/2
  local y = option_pos[2] + constants.tile_size/2 - text:getHeight()/2

  local hotkey = human_name:sub(1,1)
  local rest = human_name:sub(2,string.len(human_name))

  local hotkey_color = {1,1,1}
  if (state.tick % 60) < 30 then
    hotkey_color = {1,0,0}
  end

  love.graphics.print({hotkey_color, hotkey, {1,1,1}, rest}, x, y)
end

render._draw_inter_day = function(state)

  local bankrupt = state.money + state.money_today < 0

  local money_str = string.format("Bank old: %s\nPay today: %s\nBank new: %s",
    render._cents_to_money_str(state.money),
    render._cents_to_money_str(state.money_today),
    render._cents_to_money_str(state.money + state.money_today))

  render_text_in_tile_centre(money_str, render._tile_to_screen_coord({6,2}))

  local notice_str = ""

  if bankrupt then
    notice_str = "You are bankrupt"
  end

  render_text_in_tile_centre(notice_str, render._tile_to_screen_coord({6,3}))

  if bankrupt then
    render_option(state, "restart", render._tile_to_screen_coord({6,4}))
  else
    render_option(state, "start", render._tile_to_screen_coord({6,4}))
  end
end

render.draw = function(state)
  if not state.in_day then
    render._draw_inter_day(state)
    return
  end

  love.graphics.clear(0.2,0.2,0.2)

  render._draw_gui(state)


  for _, category_data in pairs(items.items_list.children) do
    local category = category_data.name

    for _, sub_category_data in pairs(category_data.children) do
      local sub_category = sub_category_data.name

      for _, item_data in pairs(sub_category_data.children) do
        local pos = render._path_to_screen_coord({category, sub_category, item_data.name}, items.positions)
        local item_code = item_data.item_code

        love.graphics.rectangle("line", pos[1], pos[2], constants.tile_size, constants.tile_size)
        render._draw_icon(item_code, pos)

      end
    end
  end

  local player_path = simulation.get_position_path(state.position_str)
  local player_pos = render._path_to_screen_coord(player_path, items.player_positions)


  local next_options = simulation.get_path_next_options(player_path)


  if simulation.get_item(player_path) then
    render_option(state, "deliver", render._tile_to_screen_coord({5,9}))
  else
    for _, option in pairs(next_options) do
      local option_path = {unpack(player_path)}
      table.insert(option_path, option)

      local option_pos = render._path_to_screen_coord(option_path, items.label_positions)
      render_option(state, option, option_pos)
    end
  end

  love.graphics.rectangle("line", player_pos[1], player_pos[2], constants.tile_size, constants.tile_size)
end

return render