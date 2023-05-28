local enabled = gui.add_checkbox("Velocity indicator", "lua>tab a")
local color = gui.add_colorpicker("lua>tab a>Velocity indicator", true)
local x_raw, y_raw = render.get_screen_size()
local x = x_raw*0.5-60
local y = y_raw*0.5-300
local photo = render.create_texture("fatality/wheelchair.png")
local font = render.create_font("tahoma.ttf", 16, render.font_flag_outline, render.font_flag_shadow)
local color_loaded_wm = 0
local color_wm = 0

function on_paint()
    if (color_wm < 200 ) and (color_loaded_wm == 0) then
        color_wm = color_wm + 1
        end
        if color_wm >= 200 then
            color_loaded_wm = 1
        end
         if (color_loaded_wm == 1) then
            color_wm = color_wm - 1
        end
         if color_wm == 75 then
            color_loaded_wm = 0
        end

    local lp = entities.get_entity(engine.get_local_player())
    if lp == nil then return end
    if not lp:is_alive() or enabled:get_bool() == false then return end
    local vel=lp:get_prop("m_flVelocityModifier")
    vel=vel*100
    if vel==100 and not gui.is_menu_open() then return end
        render.push_texture(photo)
        render.rect_filled(x-5, y+7, x+23,y+27,render.color(0,0,0,255))
        render.rect_filled(x-4, y+8, x+22,y+28,render.color(color:get_color().r, color:get_color().g, color:get_color().b, color_wm))
        render.pop_texture()
        render.text(font,x+23, y+8,"VELOCITY "..tostring(math.floor(vel)).."%" ,render.color(0,0,0,255))
        render.text(font,x+23, y+8,"VELOCITY "..tostring(math.floor(vel)).."%" ,render.color(color:get_color().r, color:get_color().g, color:get_color().b, color_wm))
        render.rect_filled(x-2, y+28, x+132,y+42,render.color(0, 0, 0, 255))
        render.rect_filled(x, y+30, x+vel+30,y+40,render.color(color:get_color().r, color:get_color().g, color:get_color().b, color_wm))
end