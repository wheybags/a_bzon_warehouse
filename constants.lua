local constants = {}

constants.tile_size = 70

constants.screen_w_tiles = 13
constants.screen_h_tiles = 10


constants.screen_width = constants.tile_size * constants.screen_w_tiles
constants.screen_height = constants.tile_size * constants.screen_h_tiles

assert(constants.screen_width <= 1280)
assert(constants.screen_height <= 720)


constants.font_size = 15
constants.big_font_size = 70

constants.day_length_ticks = 60 * 60 * 1
constants.pee_per_day = 3
constants.pee_ticks = math.floor(constants.day_length_ticks / constants.pee_per_day)
constants.toilet_duration = 60 * 3

local money_scale = 100

constants.starting_money = 100 * 5 * money_scale

constants.item_pay = 25 * money_scale
constants.wrong_item_dock = 50 * money_scale
constants.missed_item_dock = 50 * money_scale
constants.pee_dock = 100 * money_scale

constants.rent = 100 * money_scale
constants.rent_hike_per_day = 20 * money_scale


constants.error_display_ticks = 60 * 2


return constants