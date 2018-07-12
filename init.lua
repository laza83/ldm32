laser_range = 32

laser = function(pos, node, range, on)
    local laser_pos = vector.new(pos)
    local dir = vector.new(pos)
    local nodelist = {}
    local meta = minetest.get_meta(pos)
    
    for i = 1, range, 1 do
        if node.param2 == 1 then dir.z = laser_pos.z - i end
        if node.param2 == 2 then dir.x = laser_pos.x - i end
        if node.param2 == 3 then dir.z = laser_pos.z + i end
        if node.param2 == 0 then dir.x = laser_pos.x + i end
        
        if on == true then
            if minetest.get_node(dir).name ~= "air" then
                break
            else
                nodelist[i] = dir
                minetest.set_node(nodelist[i], {name="ldm32:laser_beam", param2 = node.param2})
            end
            meta:set_string("infotext","Distance: " .. tostring(#nodelist) .. "m")
        else
            if minetest.get_node(dir).name ~= "ldm32:laser_beam" then
                break
            else
                nodelist[i] = dir
                minetest.set_node(nodelist[i], {name="air"})
            end
            meta:set_string("infotext","Off")
        end
    end
end

minetest.register_node("ldm32:spirit_level", {
    description = "Spirit Level",
    drawtype = "mesh",
    mesh = "ldm32_spirit_level.obj",
    tiles = {"ldm32_casing.png"},
    selection_box = {
        type = "fixed",
        fixed = {{-0.5, -0.5, -0.07, 0.5, -0.25, 0.07},}
    },
    collision_box = {
        type = "fixed",
        fixed = {{-0.5, -0.5, -0.07, 0.5, -0.25, 0.07},}
    },
    is_ground_content = true,
    paramtype2 = "facedir",
    groups = {cracky = 3},

    on_construct = function(pos)
        local meta = minetest.get_meta(pos)
        meta:set_string("infotext","Off")
        meta:set_string("is_punsh", "false")
    end,
    
    after_dig_node = function(pos, oldnode, oldmetadata)
        local meta = minetest.get_meta(pos)
        laser(pos, oldnode, laser_range, false)
    end,

    on_punch = function(pos, node, player, pointed_thing)
        local meta = minetest.get_meta(pos)

        if meta:get_string("is_punsh") == "false" then
            laser(pos, node,laser_range,true)
            meta:set_string("is_punsh", "true")
        else
            laser(pos, node,laser_range,false)
            meta:set_string("is_punsh", "false")
        end
    end,
})

minetest.register_node("ldm32:laser_beam", {
    description = "Laser Beam",
    drawtype = "mesh",
    mesh = "ldm32_laser_beam.obj",
    tiles = {"ldm32_beam.png"},
    paramtype = "light",
    paramtype2 = "facedir",
    use_texture_alpha = true,
    --alpha = 0,
    light_source = 4,
    post_effect_color = {r=128,g=64,b=64, a=128},
    sunlight_propagates = true,
    walkable = false,
    pointable = false,
    diggable = false,
})

minetest.register_craft({
    --type = "sharpless",
    output = "ldm32:spirit_level",
    recipe = {
              {"group:wood","dye:grey","default:mese_crystal"},
              {"default:steel_ingot","default:steel_ingot","default:steel_ingot"}
             }
        })
