require("cairo")
local util = require("util")


local function ringGauge(cr, config)
    local value0angle = util.linearInterpolation(0, 2*math.pi, 0,1, config.value0)
    local angle = function(filledFraction)
        return util.linearInterpolation(
            -math.pi/2 + value0angle,
             3*math.pi/2 + value0angle,
             0,1,
             filledFraction)
    end

    cairo_set_source_rgba(cr, util.splitRgba(config.colour, config.alpha))
    cairo_arc(
        cr,
        config.xOffset,
        config.yOffset,
        config.radius,
        angle(0),
        angle(config.value))
    cairo_set_line_width(cr, config.width)
    cairo_stroke(cr)

    cairo_set_source_rgba(cr, util.splitRgba(config.colour, config.alpha/4))
    cairo_arc(
        cr,
        config.xOffset,
        config.yOffset,
        config.radius,
        angle(config.value),
        angle(1))
    cairo_set_line_width(cr, config.width)
    cairo_stroke(cr)
end

local function radialGauge(cr, config)
    cairo_set_source_rgba(cr, util.splitRgba(config.colour, config.alpha))
    cairo_arc(
        cr,
        config.xOffset,
        config.yOffset,
        util.linearInterpolation(
            config.minRadius, (config.maxRadius+config.minRadius)/2,
            0, 1,
            config.value),
        config.angleStart,
        config.angleEnd)
    cairo_set_line_width(
        cr,
        util.linearInterpolation(
            0, config.maxRadius-config.minRadius,
            0, 1,
            config.value))
    cairo_stroke(cr)

    cairo_set_source_rgba(cr, util.splitRgba(config.colour, config.alpha/4))
    cairo_arc(
        cr,
        config.xOffset,
        config.yOffset,
        (config.maxRadius+config.minRadius)/2,
        config.angleStart,
        config.angleEnd)
    cairo_set_line_width(cr, config.maxRadius - config.minRadius)
    cairo_stroke(cr)
end

local function alignedText(cr, config)
    cairo_set_source_rgba(cr, util.splitRgba(config.colour, config.alpha))
    cairo_select_font_face(
        cr,
        "Monospace",
        CAIRO_FONT_SLANT_NORMAL,
        CAIRO_FONT_WEIGHT_NORMAL)
    cairo_set_font_size (cr, config.fontSize)

    do
        local te = cairo_text_extents_t:create()
        cairo_text_extents(cr, config.text, te)

        local doAlignX = function(footpoint)
            if config.alignX == "l" then
                return footpoint
            elseif config.alignX == "c" then
                return footpoint - te.width/2
            elseif config.alignX == "r" then
                return footpoint + te.width
            else
                error(string.format("Allowed x alignments: l, c, r, given: %s", config.alignX))
            end
        end
        local doAlignY = function(footpoint)
            if config.alignY == "u" then
                return footpoint + te.height
            elseif config.alignY == "m" then
                return footpoint + te.height/2
            elseif config.alignY == "d" then
                return footpoint
            else
                error(string.format("Allowed y alignments: u, m, d, given: %s", config.alignY))
            end
        end
        cairo_move_to(cr, doAlignX(config.centerX), doAlignY(config.centerY))
    end

    cairo_show_text(cr, config.text)
    cairo_stroke(cr)
end

local function polarToCartesian(r, phi)
    return r*math.cos(phi), r*math.sin(phi)
end

-- Draw radial rays from a center point. Useful to create ticks on circles.
local function rays(cr, config)
    for i = 1, config.multitude do
        local angle = util.linearInterpolation(
            config.rotation,2*math.pi + config.rotation,
            1, config.multitude+1,
            i)
        local x,y = polarToCartesian(config.innerRadius, angle)
        cairo_move_to(cr, x+config.centerX, y+config.centerY)
        x,y = polarToCartesian(config.outerRadius, angle)
        cairo_line_to(cr, x+config.centerX, y+config.centerY)
    end
    cairo_set_line_width(cr, config.lineWidth)
    cairo_set_source_rgba(cr, util.splitRgba(config.colour, config.alpha))
    cairo_stroke(cr)
end

return
    { ringGauge   = ringGauge
    , radialGauge = radialGauge
    , alignedText = alignedText
    , rays        = rays }
