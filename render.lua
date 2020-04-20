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

  render.items[200] = love.graphics.newImage("gfx/playerFace_dark.png")

  render.font = love.graphics.newFont("gfx/Kenney Future Narrow.ttf", constants.font_size)
  render.font_big = love.graphics.newFont("gfx/Kenney Future Narrow.ttf", constants.big_font_size)
  love.graphics.setFont(render.font)

  render.bzon_logo = love.graphics.newImage("gfx/bzon_logo.png")
  render.fired = love.graphics.newImage("gfx/fired.png")
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
    [200]=3,
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

  local start_h = 5
  local end_h = 23

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
  love.graphics.print("   Pay: " .. render._cents_to_money_str(state.money_today), left, y)
  y = y + constants.font_size

  y = y + vertical_margin

  love.graphics.setColor(0, 0, 0)
  love.graphics.print("   Dock: " .. render._cents_to_money_str(state.dock_today), left, y)
  y = y + constants.font_size

  y = y + vertical_margin

  love.graphics.setColor(0,0,0)
  love.graphics.print("        DELIVER", left, y)
  y = y + constants.font_size

  y = y + vertical_margin

  local items_lookup = simulation.get_all_items_dict()
  local item_code = items_lookup[state.request].item_code

  love.graphics.setColor(0,0,0)
  if not state.delivered and (state.tick % 60) > 30 then
    love.graphics.setColor(0.4,0.4,0.4)
  end
  love.graphics.rectangle("fill", left + 0.5 * constants.tile_size, y, constants.tile_size, constants.tile_size)

  love.graphics.setColor(1,1,1)
  render._draw_icon(item_code, {left + 0.5 * constants.tile_size, y})
  y = y + constants.tile_size

  y = y + vertical_margin

  love.graphics.setColor(0,0,0)
  love.graphics.print(string.format("        %d s left", math.floor(state.request_time_remaining/60)), left, y)
  y = y + constants.font_size

  y = y + vertical_margin

  local bladder_norm = (constants.pee_ticks - state.pee_time_remaining) / constants.pee_ticks
  local bladder_percentage = math.floor(bladder_norm * 100)

  love.graphics.setColor(0,0,0)
  if bladder_percentage > 50 then
    love.graphics.setColor(1,1,0)
  end
  if bladder_percentage > 80 then
    love.graphics.setColor(1,0,0)
  end
  love.graphics.print(string.format("   Bladder: %d%%", bladder_percentage), left, y)
  y = y + constants.font_size

  y = y + vertical_margin


  love.graphics.setColor(1,1,1)
end

local render_text_in_tile_centre = function(str, option_pos)

  local text = love.graphics.newText(render.font, str)
  local x = option_pos[1] + constants.tile_size/2 - text:getWidth()/2
  local y = option_pos[2] + constants.tile_size/2 - text:getHeight()/2

  love.graphics.draw(text, x, y)
  --love.graphics.print(str, x, y)
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

  local bankrupt = state.money + state.money_today + state.dock_today - simulation.rent(state) < 0
  local notice_str = {}

  local won = state.day == 10 and not bankrupt


  if state.day == 0 then
    local scale = 0.6
    local x = constants.screen_width / 2 - render.bzon_logo:getWidth()*scale/2
    love.graphics.draw(render.bzon_logo, x, 25, 0, scale, scale)

    table.insert(notice_str, {0.97,0.64,0.1})
    table.insert(notice_str,
      "Congratulations Applicant!\n\n" ..
      "Your application has been accepted by the illustrious Bzon corporation of America!\n" ..
      "You will be joining the team as a logistics services operator for our new warehouse\n"..
      "in your region. Please present yourself immediately for labour assignment.\n" ..
      "Fulfil orders from Bzon customers on time by pressing the correct keys.\n" ..
      "Don't be late or your pay will be docked!\n\n"..
      "Keep those shareholder returns alive!\n" ..
      "Geoff Bzon, CEO")
  elseif won then
    local scale = 0.6
    local x = constants.screen_width / 2 - render.bzon_logo:getWidth()*scale/2
    love.graphics.draw(render.bzon_logo, x, 25, 0, scale, scale)


    table.insert(notice_str, {0.97,0.64,0.1})
    table.insert(notice_str,
      "Great news team!\n\n" ..
      "Our engineers in the automation department have been hard at work on an\n" ..
      "innovative new logistics solution.\n" ..
      "We are deploying their new Bzo-bot system in your assigned labour zone.\n" ..
      "Shareholder returns from this move are expected to skyrocket!\n\n" ..
      "Unfortunately however, this does mean that there will\n"..
      "no longer be a need for our valued Bzon logistics team members.\n" ..
      "It's been a wild journey, but our hands are tied.\n\n" ..
      "Best of luck with your future endeavours,\n"..
      "Geoff Bzon, CEO")


    render_option(state, "get back in the bread line", render._tile_to_screen_coord({6,6}))


    local final_money = "you finished with " .. render._cents_to_money_str(state.money + state.money_today + state.dock_today - simulation.rent(state))
    render_text_in_tile_centre(final_money, render._tile_to_screen_coord({6,9}))


    love.graphics.draw(render.fired, 600, 400, 0, 1, 1)

  else
    local money_str = string.format("Day: %s\nBank old: %s\nPay today: %s\nPay docked:%s\nRent: %s\n\nTotal Diff: %s\nBank new: %s",
      state.day,
      render._cents_to_money_str(state.money),
      render._cents_to_money_str(state.money_today),
      render._cents_to_money_str(state.dock_today),
      render._cents_to_money_str(-simulation.rent(state)),
      render._cents_to_money_str(state.money_today + state.dock_today - simulation.rent(state)),
      render._cents_to_money_str(state.money + state.money_today + state.dock_today - simulation.rent(state)))

    render_text_in_tile_centre(money_str, render._tile_to_screen_coord({6,2}))
  end

  if not won then

    if not bankrupt then
      if state.day == 1 then
        table.insert(notice_str, {1,1,1})
        table.insert(notice_str, "Whew, a job at last!\nI got hired just before christmas, so only 9 more days until vacation.\n\n")
      elseif state.day == 2 then
        table.insert(notice_str, {1,1,1})
        table.insert(notice_str, "Ok, this is hard work! Only 8 more days to go before christmas!\n\n")
      elseif state.day == 3 then
        table.insert(notice_str, {1,1,1})
        table.insert(notice_str, "whoo-ee my legs sure get sore after a long shift.\n 7 more days, let's do this!\n\n")
      elseif state.day == 4 then
        table.insert(notice_str, {1,1,1})
        table.insert(notice_str, "Man, I sure get thirsty doing all that sprinting.\nIf I kept hydrated I'd need more bathroom breaks though...\n6 days to to before christmas!\n\n")
      elseif state.day == 5 then
        table.insert(notice_str, {1,1,1})
        table.insert(notice_str, "I heard some o' the guys talking about a union.\nI dunno, I don't want to piss off the boss...\n5 days more and I can have a well earned break!\n\n")
      elseif state.day == 6 then
        table.insert(notice_str, {1,1,1})
        table.insert(notice_str, "My supervisor isn't happy with the amount of\nbathroom breaks I've been taking...\n4 more days until christmas\n\n")
      elseif state.day == 7 then
        table.insert(notice_str, {1,1,1})
        table.insert(notice_str, "Joanne and Toby got fired today. Not a nice atmosphere.\n3 more days\n\n")
      elseif state.day == 8 then
        table.insert(notice_str, {1,1,1})
        table.insert(notice_str, "Some of the guys here are using a lot of meds form the vending machines...\n2 more days\n\n")
      elseif state.day == 9 then
        table.insert(notice_str, {1,1,1})
        table.insert(notice_str, "Christ, this is hard work, but only one more day to go! Christmas here I come baby!\n\n")
      end
    end


    if bankrupt then
      table.insert(notice_str, {1,1,1})
      table.insert(notice_str, "You are bankrupt. Game over.\nBut don't worry, the shareholder returns are just fine!\n\n")
    end

    if state.pee_time_remaining == 0 then
      table.insert(notice_str, {0.97,0.64,0.1})
      table.insert(notice_str,"You soiled yourself on the warehouse floor.\nYour pay was docked and you were sent home.\n\nBZON TOP TIP: Keep an eye on the bladder meter at the right\n")
    end


    if bankrupt then
      render_option(state, "try again", render._tile_to_screen_coord({6,6}))
      render_option(state, "reasons not buy from amazon", render._tile_to_screen_coord({6,7}))
    else
      render_option(state, "walk to work", render._tile_to_screen_coord({6,6}))
    end
  end

 render_text_in_tile_centre(notice_str, render._tile_to_screen_coord({6,4}))
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

  if state.in_toilet > 0 then
    player_pos = render._tile_to_screen_coord(items.label_positions.bath_room.pos)
  end

  --love.graphics.rectangle("line", player_pos[1], player_pos[2], constants.tile_size, constants.tile_size)
  render._draw_icon(200, player_pos)


  if state.in_toilet == 0 then
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
  end

  if state.error_ticks > 0 then
    local alpha = (state.error_ticks / constants.error_display_ticks) / 2

    love.graphics.setColor(1,0,0,alpha)
    love.graphics.rectangle("fill", 0, 0, constants.screen_width, constants.screen_height)

    love.graphics.setColor(1,1,1,alpha*2)

    local text = love.graphics.newText(render.font_big, state.error_text)
    local x = constants.screen_width/2 + - text:getWidth()/2
    local y = constants.screen_height/2 - text:getHeight()/2 - constants.big_font_size / 2
    love.graphics.draw(text, x, y)

    if state.error_dock > 0 then
      text = love.graphics.newText(render.font_big, render._cents_to_money_str(state.error_dock))
      x = constants.screen_width/2 + - text:getWidth()/2
      y = constants.screen_height/2 - text:getHeight()/2 + constants.big_font_size / 2
      love.graphics.draw(text, x, y)
    end

    love.graphics.setColor(1,1,1,1)
  end

end

return render