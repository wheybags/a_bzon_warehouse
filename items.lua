local items = {}

items.items =
{
  tools =
  {
    big =
    {
      pickaxe = 21,
      axe = 20,
      hammer = 23,
      saw = 16
    },

    small =
    {
      wrench = 7,
      screwdriver = 5,
      pliers = 9,
      brush = 11,
    },
  },

  electronics =
  {
    computer =
    {
      black = 54,
      white = 55,
      laptop = 50,
      screen = 53,
    },

    phone =
    {
      retro = 63,
      flip = 64,
      smart = 67,
      tablet = 69,
    },
  },

  kitchen =
  {
    utensils =
    {
      fork = 129,
      spatula = 135,
      knife = 134,
      rolling_pin = 140,
    },

    appliances =
    {
      kettle = 125,
      blender = 137,
      toaster = 138,
      coffee_machine = 139
    },
  },

  medical =
  {
    drugs =
    {
      red_pill = 89,
      blue_pill = 90,
      white_pill = 96,
      pink_pill = 97,
    },

    equipment =
    {
      stethoscope = 110,
      crutch = 113,
      first_aid_kit = 102,
      syringe = 93,
    },
  }
}

items.positions =
{
  tools = {big = {0, 0}, small = {0, 1}},
  electronics = {computer = {1, 0}, phone = {1, 1}},
  kitchen = {utensils = {0, 2}, appliances = {0, 3}},
  medical = {drugs = {1, 2}, equipment = {1, 3}},
}

return items