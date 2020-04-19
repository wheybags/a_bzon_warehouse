local items = {}


items.items_list =
{
  children=
  {
    {
      name="tools",
      children=
      {
        {
          name="big",
          children =
          {
            {name="pickaxe", children={}, item_code = 21},
            {name="axe", children={}, item_code = 20},
            {name="hammer", children={}, item_code = 23},
            {name="saw", children={}, item_code = 16},
          }
        },

        {
          name="small",
          children =
          {
            {name="wrench", children={}, item_code = 7},
            {name="screwdriver", children={}, item_code = 5},
            {name="pliers", children={}, item_code = 9},
            {name="brush", children={}, item_code = 11},
          }
        },
      },
    },

    {
      name="electronics",
      children=
      {
        {
          name="computer",
          children =
          {
            {name="black", children={}, item_code=54},
            {name="white", children={}, item_code=55},
            {name="laptop", children={}, item_code=50},
            {name="screen", children={}, item_code=53},
          }
        },

        {
          name="phone",
          children =
          {
            {name="retro", children={}, item_code=63},
            {name="flip", children={}, item_code=64},
            {name="smart", children={}, item_code=67},
            {name="tablet", children={}, item_code=69},
          }
        } ,
      }
    },

    {
      name="kitchen",
      children =
      {
        {
          name="utensils",
          children =
          {
            {name="fork", children={}, item_code=129},
            {name="spatula", children={}, item_code=135},
            {name="knife", children={}, item_code=134},
            {name="rolling_pin", children={}, item_code=140},
          }
        },

        {
          name="appliances",
          children =
          {
            {name="kettle", children={}, item_code=125},
            {name="blender", children={}, item_code=137},
            {name="toaster", children={}, item_code=138},
            {name="coffee_machine", children={}, item_code = 139},
          }
        },
      }
    },

    {
      name="medical",
      children =
      {
        {
          name="drugs",
          children =
          {
            {name="red_pill", children={}, item_code=89},
            {name="blue_pill", children={}, item_code=90},
            {name="white_pill", children={}, item_code=96},
            {name="pink_pill", children={}, item_code=97},
          }
        },

        {
          name="equipment",
          children =
          {
            {name="stethoscope", children={}, item_code=110},
            {name="crutch", children={}, item_code=113},
            {name="first_aid_kit", children={}, item_code=102},
            {name="syringe", children={}, item_code=93},
          },
        },
      },
    },
  }
}


-- here be dragons:


local r
r = function(t)

  local ret = {orig = t}
  ret.item_code = t.item_code

  for _, val in pairs(t.children) do
    ret[val.name] = r(val)
  end

  return ret
end

items.items_dict = r(items.items_list)

items.positions =
{
  tools =
  {
    big = {pos={0, 0}},
    small = {pos={0, 3}},
  },
  electronics =
  {
    computer = {pos={7, 0}},
    phone = {pos={7, 3}},
  },
  kitchen =
  {
    utensils = {pos={0, 4}},
    appliances = {pos={0, 7}},
  },
  medical =
  {
    drugs = {pos={7, 4}},
    equipment = {pos={7, 7}},
  },
}

local fix_one = function(row, name, offset)
  row[name] = {pos={row.pos[1]+offset[1], row.pos[2]+offset[2]}}
end

local generate_subcat_items = function(positions, cat, subcat, offset)
  if offset == nil then offset = {0,0} end


  for num, item in pairs(items.items_dict[cat][subcat].orig.children) do
    fix_one(positions[cat][subcat], item.name, {num + offset[1] - 1, offset[2]})
  end
end

local generate_item_positions_from_row_positions = function(positions, offset)

  for _, cat_data in pairs(items.items_dict.orig.children) do
    local cat = cat_data.name

    for _, subcat_data in pairs(items.items_dict[cat].orig.children) do
      local subcat = subcat_data.name
      generate_subcat_items(positions, cat, subcat, offset)
    end
  end
end

generate_item_positions_from_row_positions(items.positions)

--print(serpent.block(items.positions, {comment=false}))

local sd = 1.2 -- distance from shelf

items.player_positions =
{
  pos={5,9},
  tools =
  {
    pos={4,1.5},
    big = {pos={1.5, 0+sd}},
    small = {pos={1.5, 3-sd}},
  },
  electronics =
  {
    pos={6,1.5},
    computer = {pos={8.5, 0+sd}},
    phone = {pos={8.5, 3-sd}},
  },
  kitchen =
  {
    pos={4,5.5},
    utensils = {pos={1.5, 4+sd}},
    appliances = {pos={1.5, 7-sd}},
  },
  medical =
  {
    pos={6,5.5},
    drugs = {pos={8.5, 4+sd}},
    equipment = {pos={8.5, 7-sd}},
  },
}

local generate_player_row = function(cat, subcat, offset_y)

  for num, item in pairs(items.items_dict[cat][subcat].orig.children) do
    items.player_positions[cat][subcat][item.name] = {pos={num-1 + items.positions[cat][subcat].pos[1], items.positions[cat][subcat].pos[2] + offset_y}}
  end
end


generate_player_row("tools", "big", sd)
generate_player_row("tools", "small", -sd)
generate_player_row("electronics", "computer", sd)
generate_player_row("electronics", "phone", -sd)
generate_player_row("kitchen", "utensils", sd)
generate_player_row("kitchen", "appliances", -sd)
generate_player_row("medical", "drugs", sd)
generate_player_row("medical", "equipment", -sd)


print(serpent.block(items.player_positions, {comment=false}))

return items