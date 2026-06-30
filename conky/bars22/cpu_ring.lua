
local col0=0x302B2A  -- CPU color
local colbg=0x4A4D4F -- Background ring color

settings_table = {
    {
        name='cpu',
        arg='cpu0',
        max=100,
        bg_colour=colbg,
        bg_alpha=0.7,
        fg_colour=col0,
        fg_alpha=1,
        x=50, y=50,
        radius=30,
        thickness=6,
        start_angle=0,
        end_angle=360,
    }
}

require 'cairo'

function rgb_to_r_g_b(colour,alpha)
    return ((colour / 0x10000) % 0x100) / 255., ((colour / 0x100) % 0x100) / 255., (colour % 0x100) / 255., alpha
end

function draw_ring(cr,t,pt)
    local xc,yc,ring_r,ring_w,sa,ea=pt['x'],pt['y'],pt['radius'],pt['thickness'],pt['start_angle'],pt['end_angle']
    local bgc, bga, fgc, fga=pt['bg_colour'], pt['bg_alpha'], pt['fg_colour'], pt['fg_alpha']

    local angle_0=sa*(2*math.pi/360)-math.pi/2
    local angle_f=ea*(2*math.pi/360)-math.pi/2
    local t_arc=t*(angle_f-angle_0)

    -- Draw background ring
    cairo_arc(cr,xc,yc,ring_r,angle_0,angle_f)
    cairo_set_source_rgba(cr,rgb_to_r_g_b(bgc,bga))
    cairo_set_line_width(cr,ring_w)
    cairo_stroke(cr)
    
    -- Draw indicator ring
    cairo_arc(cr,xc,yc,ring_r,angle_0,angle_0+t_arc)
    cairo_set_source_rgba(cr,rgb_to_r_g_b(fgc,fga))
    cairo_stroke(cr)
end

function conky_ring_stats()
    if conky_window==nil then return end
    local cs=cairo_xlib_surface_create(conky_window.display,conky_window.drawable,conky_window.visual, conky_window.width,conky_window.height)
    local cr=cairo_create(cs)

    local updates=conky_parse('${updates}')
    local update_num=tonumber(updates)

    if update_num>5 then
        for i in pairs(settings_table) do
            local str=string.format('${%s %s}',settings_table[i]['name'],settings_table[i]['arg'])
            local value=tonumber(conky_parse(str)) or 0
            local pct=value/settings_table[i]['max']
            draw_ring(cr,pct,settings_table[i])
        end
    end

    cairo_surface_destroy(cs)
    cairo_destroy(cr)
end

