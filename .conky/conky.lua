require 'cairo'

function splitRgb(colour)
    return
        ((colour / 0x10000) % 0x100) / 255.,
        ((colour / 0x100) % 0x100) / 255.,
        (colour % 0x100) / 255.
end

function joinRgb(r, g, b)
    return r * 0xff0000 + g * 0x00ff00 + b * 0x0000ff
end


function setRgba(cr, colour, alpha)
    local r, g, b = splitRgb(colour)
    cairo_set_source_rgba(cr, r, g, b, alpha)
end

function deg2rad(angle)
    return angle / 360 * (2 * math.pi)
end

-- Interpolate linearly between two values. The parameter ranges from 0 to 1.
function linearInterpolate(startValue, endValue, parameter)
    return (endValue - startValue) * parameter + startValue
end

-- Interpolate linearly between two values. The parameter takes values between a
-- minimum and a maximum, and the interpolation is done linearly between those
-- parameter values.
--
-- For example, linearInterpolateInRange(0,1, 10,20, 15) will yield 0.5,
-- since 15 is the halfway point between 10 and 20. Therefore, the halfway
-- point between 0 and 1 is chosen, which is 0.5.
function linearInterpolateInRange(startValue, endValue, paramMin, paramMax, parameter)
    local interpolatedParameter = 1 - (paramMax - parameter) / (paramMax - paramMin)
    return linearInterpolate(startValue, endValue, interpolatedParameter)
end

function linearInterpolateColours(startColour, endColour, paramMin, paramMax, parameter)
    local startR, startG, startB = splitRgb(startColour)
    local endR, endG, endB = splitRgb(endColour)
    return joinRgb(
        linearInterpolateInRange(startR, endR, paramMin, paramMax, parameter),
        linearInterpolateInRange(startG, endG, paramMin, paramMax, parameter),
        linearInterpolateInRange(startB, endB, paramMin, paramMax, parameter))
end

function arc(cr, centerX, centerY, radius, startAngle, fillLevel)

    startAngleRad = deg2rad(startAngle + 180)
    local endAngleRad = startAngleRad + 2 * math.pi * fillLevel

    cairo_arc(cr, centerX, centerY, radius, startAngleRad, endAngleRad)
end

function conky_main()

    if conky_window == nil then
        return
    end

    local cairoSurface = cairo_xlib_surface_create(
        conky_window.display,
        conky_window.drawable,
        conky_window.visual,
        conky_window.width,
        conky_window.height)

    local cr = cairo_create(cairoSurface)

	local updates=conky_parse('${updates}')
	if tonumber(updates) > 5 then
		main(cr)
    else
        loading(cr)
	end
end

function loading(cr)
    cairo_set_source_rgba(cr, 0, 0, 0, 1)
    cairo_set_line_width(cr, 10)
    cairo_select_font_face (cr, "Sans", CAIRO_FONT_SLANT_NORMAL,
                                        CAIRO_FONT_WEIGHT_NORMAL);
    cairo_set_font_size (cr, 50);
    cairo_move_to(cr, 0, 120)
    cairo_show_text (cr, "Loading LUA");
    cairo_stroke(cr)
end

function main(cr)
    cpuCircles(cr, 200, 180)
end

function cpuCircles(cr, xOffset, yOffset)

    local colourLow  = 0x19414a
    local colourHigh = 0x5c291f

    local r1, g1, b1 = splitRgb(colourLow)
    local r2, g2, b2 = splitRgb(colourHigh)

    local cpuLabel = function()
        cairo_set_source_rgba(cr, r1, g1, b1, 1)
        cairo_set_line_width(cr, 10)
        cairo_select_font_face (cr, "Sans", CAIRO_FONT_SLANT_NORMAL,
                                            CAIRO_FONT_WEIGHT_NORMAL);
        cairo_set_font_size (cr, 20);
        cairo_move_to(cr, xOffset-21, yOffset+7)
        cairo_show_text(cr, "CPU")
        cairo_stroke(cr)
    end
    cpuLabel()

    local loadCircleBackground = function(cpuId)
        cairo_set_source_rgba(cr, r1, g1, b1, 0.15)
        arc(
            cr,
            xOffset,
            yOffset,
            linearInterpolateInRange(40, 100, 1, 4, cpuId),
            90,
            1)
        cairo_set_line_width(cr, 18)
        cairo_stroke(cr)
    end
    local loadCircle = function(cpuId)
        local load = conky_parse(string.format("${cpu cpu%d}", cpuId))
        cairo_set_source_rgba(
            cr,
            linearInterpolateInRange(r1,r2, 0,100, load),
            linearInterpolateInRange(g1,g2, 0,100, load),
            linearInterpolateInRange(b1,b2, 0,100, load),
            linearInterpolateInRange(0.8, 0.5, 1, 4, cpuId))
        arc(
            cr,
            xOffset,
            yOffset,
            linearInterpolateInRange(40, 100, 1, 4, cpuId),
            90,
            linearInterpolateInRange(
                0,1,
                0,100,
                load))
        cairo_set_line_width(cr, 18)
        cairo_stroke(cr)
    end
    for cpuId = 1, 4 do
        loadCircle(cpuId)
        loadCircleBackground(cpuId)
    end
end
