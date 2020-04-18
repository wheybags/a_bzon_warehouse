local items = require("items")
local constants = require("constants")

local render = {}

render.setup = function()
  render.items = {}

  for i = 1,163 do
    local path = "gfx/items/genericItem_color_" .. string.format("%03d", i) .. ".png"
    render.items[i] = love.graphics.newImage(path)
  end
end

render.draw = function()

  local item_width = 70
  local sprite_scale = 0.4

  local gap = item_width * 1.3

  local x_positions = {0,constants.screen_width - item_width*4}


  -- 1 XXXX
  --
  -- 2 XXXX
  -- 3 XXXX
  --
  -- 4 XXXX

  local y_positions =
  {
    0,
    item_width + gap,
    item_width + gap + item_width,
    item_width + gap + item_width + item_width + gap,
  }


  for category, category_data in pairs(items.items) do
    for sub_category, sub_category_data in pairs(category_data) do
      local x = items.positions[category][sub_category][1]+1
      local y = items.positions[category][sub_category][2]+1

      x = x_positions[x]
      y = y_positions[y]

      for item_key, item_code in pairs(sub_category_data) do
        love.graphics.rectangle("line", x, y, item_width, item_width)
        love.graphics.draw(render.items[item_code], x, y, 0, sprite_scale, sprite_scale)

        x = x + item_width
      end
    end
  end

end

return render