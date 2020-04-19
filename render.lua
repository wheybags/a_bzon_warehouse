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

  love.graphics.rectangle("line", player_pos[1], player_pos[2], constants.tile_size, constants.tile_size)
end

return render