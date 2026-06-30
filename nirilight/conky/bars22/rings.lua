-- rings.lua
require 'cairo'

-- Colors
local col_cpu = 0xDED9CC  -- CPU ring color (foreground)
local col_ram = 0xDED9CC  -- RAM ring color (foreground)
local col_bg  = 0xDED9CC -- Darker background ring color

-- Ring settings
settings_table = {
    cpu_ring = {
        name='cpu',
        arg='cpu0',
        max=100,
        bg_colour=col_bg,
        bg_alpha=0,
        fg_colour=col_cpu,
        fg_alpha=0.9,
        x=100, y=290,
        radius=23,        -- smaller radius
        thickness=4,      -- thinner ring
        start_angle=0,
        end_angle=360,
    },
    ram_ring = {
        name='memperc',
        arg='',
        max=100,
        bg_colour=col_bg,
        bg_alpha=0,
        fg_colour=col_ram,
        fg_alpha=0.9,
        x=100, y=350,
        radius=23,        -- smaller radius
        thickness=4,      -- thinner ring
        start_angle=0,
        end_angle=360,
    }
}

-- Convert hex to RGBA
function rgb_to_r_g_b(colour,alpha)
    return ((colour / 0x10000) % 0x100) / 255.,
           ((colour / 0x100) % 0x100) / 255.,
           (colour % 0x100) / 255.,
           alpha
end

-- Draw a single ring
function draw_ring(cr, t, pt)
    local xc, yc = pt.x, pt.y
    local ring_r, ring_w = pt.radius, pt.thickness
    local sa, ea = pt.start_angle, pt.end_angle
    local bgc, bga, fgc, fga = pt.bg_colour, pt.bg_alpha, pt.fg_colour, pt.fg_alpha

    local angle_0 = sa*(2*math.pi/360) - math.pi/2
    local angle_f = ea*(2*math.pi/360) - math.pi/2
    local t_arc = t*(angle_f - angle_0)

    -- Background ring
    cairo_arc(cr, xc, yc, ring_r, angle_0, angle_f)
    cairo_set_source_rgba(cr, rgb_to_r_g_b(bgc, bga))
    cairo_set_line_width(cr, ring_w)
    cairo_stroke(cr)

    -- Foreground ring
    cairo_arc(cr, xc, yc, ring_r, angle_0, angle_0 + t_arc)
    cairo_set_source_rgba(cr, rgb_to_r_g_b(fgc, fga))
    cairo_stroke(cr)
end

-- Draw all rings
function conky_ring_stats()
    if conky_window == nil then return end
    local cs = cairo_xlib_surface_create(
        conky_window.display, conky_window.drawable,
        conky_window.visual, conky_window.width, conky_window.height
    )
    local cr = cairo_create(cs)

    local updates = tonumber(conky_parse('${updates}'))
    if updates > 5 then
        for _, ring in pairs(settings_table) do
            local str = string.format('${%s %s}', ring.name, ring.arg)
            local value = tonumber(conky_parse(str)) or 0
            local pct = value / ring.max
            draw_ring(cr, pct, ring)
        end
    end

    cairo_surface_destroy(cs)
    cairo_destroy(cr)
end

-- Individual hooks for Conky
function cpu_ring() conky_ring_stats() end
function ram_ring() conky_ring_stats() end

