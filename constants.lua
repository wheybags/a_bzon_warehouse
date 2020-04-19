local constants = {}

constants.tile_size = 70

constants.screen_w_tiles = 13
constants.screen_h_tiles = 10


constants.screen_width = constants.tile_size * constants.screen_w_tiles
constants.screen_height = constants.tile_size * constants.screen_h_tiles

assert(constants.screen_width <= 1280)
assert(constants.screen_height <= 720)


constants.font_size = 15
constants.day_length_ticks = 60 * 100


return constants