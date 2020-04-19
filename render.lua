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

  render.font = love.graphics.newFont("gfx/Kenney Future Narrow.ttf", 15)
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

render.draw = function(state)

  local sprite_scale = 0.4

  for _, category_data in pairs(items.items_list.children) do
    local category = category_data.name

    for _, sub_category_data in pairs(category_data.children) do
      local sub_category = sub_category_data.name

      for _, item_data in pairs(sub_category_data.children) do
        local pos = render._path_to_screen_coord({category, sub_category, item_data.name}, items.positions)
        local item_code = item_data.item_code

        love.graphics.rectangle("line", pos[1], pos[2], constants.tile_size, constants.tile_size)
        love.graphics.draw(render.items[item_code], pos[1], pos[2], 0, sprite_scale, sprite_scale)

      end
    end
  end

  local player_path = simulation.get_position_path(state.position_str)
  local player_pos = render._path_to_screen_coord(player_path, items.player_positions)


  local next_options = simulation.get_path_next_options(player_path)

  for _, option in pairs(next_options) do
    local option_path = {unpack(player_path)}
    table.insert(option_path, option)

    local option_pos = render._path_to_screen_coord(option_path, items.label_positions)

    --love.graphics.rectangle("line", option_pos[1], option_pos[2], constants.tile_size, constants.tile_size)

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

    --love.graphics.draw(text, x, y)
    --love.graphics.print(option, option_pos[1], option_pos[2])
  end
  --print(serpent.line(simulation.get_path_next_options(player_path), {comment=false}))

  love.graphics.rectangle("line", player_pos[1], player_pos[2], constants.tile_size, constants.tile_size)
end

return render