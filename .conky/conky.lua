require 'cairo'

function splitRgb(colour)
    return
        ((colour / 0x10000) % 0x100) / 255.,
        ((colour / 0x100) % 0x100) / 255.,
        (colour % 0x100) / 255.
end

function splitRgba(colour, alpha)
    local r, g, b = splitRgb(colour)
    return r, g, b, alpha
end

function joinRgb(r, g, b)
    return r*0xff0000 + g*0x00ff00 + b*0x0000ff
end

function setRgba(cr, colour, alpha)
    cairo_set_source_rgba(cr, splitRgba(colour, alpha))
end

function deg2rad(angle)
    return angle / 360 * (2 * math.pi)
end

-- Interpolate linearly between two values.
--
-- > linearInterpolation(start, end, paramStart, paramEnd, param)
--
-- interpolates from start to end as param moves from paramStart to paramEnd.
--
-- For example, linearInterpolation(0,1, 10,20, 15) will yield 0.5,
-- since 15 is the halfway point between 10 and 20. Therefore, the halfway
-- point between 0 and 1 is chosen, which is 0.5.
function linearInterpolation(startValue, endValue, paramMin, paramMax, parameter)
    return (endValue-startValue) / (paramMax-paramMin) * (parameter-paramMax) + endValue
end

function linearInterpolateColours(startColour, endColour, paramMin, paramMax, parameter)
    local startR, startG, startB = splitRgb(startColour)
    local endR, endG, endB = splitRgb(endColour)
    return joinRgb(
        linearInterpolation(startR, endR, paramMin, paramMax, parameter),
        linearInterpolation(startG, endG, paramMin, paramMax, parameter),
        linearInterpolation(startB, endB, paramMin, paramMax, parameter))
end

function arc(cr, centerX, centerY, radius, startAngle, fillLevel)

    local startAngleRad = deg2rad(startAngle + 180)
    local endAngleRad = startAngleRad + 2*math.pi * fillLevel

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
	end
end

function main(cr)
    centerX = conky_window.width/2
    cpuCircles(cr, centerX, 140)
    graphBoxes(cr)
    memoryCircles(cr, centerX, 340)
    hddCircles(cr, centerX, 500)
end

function cpuCircles(cr, xOffset, yOffset)

    local colour = 0xffffff
    local alpha = 0.5

    alignedText(
        cr,
        { text     = "CPU"
        , centerX  = xOffset
        , centerY  = yOffset
        , alignX   = "c"
        , alignY   = "m"
        , colour   = colour
        , alpha    = alpha
        , fontSize = 20 }
    )

    for cpuId = 1, 4 do
        local cpuLoad = conky_parse(string.format("${cpu cpu%d}", cpuId))
        ringGauge(
            cr,
            { colour  = colour
            , alpha   = alpha
            , xOffset = xOffset
            , yOffset = yOffset
            , radius  = linearInterpolation(60,90+4, 1,4, cpuId)
            , value   = linearInterpolation(0,1, 0,100, cpuLoad)
            , value0  = 0
            , width   = 10 }
        )
    end
end

function graphBoxes(cr)
    local box = function(cr, x, y, w, h)
        cairo_set_source_rgba(cr, splitRgba(0xffffff, 0.1))
        cairo_set_line_width(cr, 1)
        cairo_rectangle(cr, x, y, w, h)
        cairo_fill(cr)
    end

    box(cr, 22, 68, 384, 32) -- CPU
    box(cr, 22, 254, 384, 32) -- Memory

    box(cr, 22, 506, 185, 32) -- Hard drive read
    box(cr, 222, 506, 185, 32) -- Hard drive write

    box(cr, 22, 614, 185, 32) -- Upload
    box(cr, 222, 614, 185, 32) -- Download
end

function memoryCircles(cr, xOffset, yOffset)
    local colour = 0xffffff
    local alpha = 0.5

    do
        local memPercent = conky_parse(string.format("${memperc}"))
        ringGauge(
            cr,
            { colour  = colour
            , alpha   = alpha
            , xOffset = xOffset
            , yOffset = yOffset
            , radius  = 60
            , value   = linearInterpolation(0,1, 0,100, memPercent)
            , value0  = 0
            , width   = 10 }
        )
    end

    do
        local swapPercent = tonumber(conky_parse(string.format("${swapperc}")))
        if not swapPercent then swapPercent = 0 end
        ringGauge(
            cr,
            { colour  = colour
            , alpha   = alpha
            , xOffset = xOffset
            , yOffset = yOffset
            , radius  = 70
            , value   = linearInterpolation(0,1, 0,100, swapPercent)
            , value0  = 0
            , width   = 6 }
        )
    end

    alignedText(
        cr,
        { text     = "Mem"
        , centerX  = xOffset
        , centerY  = yOffset
        , alignX   = "c"
        , alignY   = "m"
        , colour   = colour
        , alpha    = alpha
        , fontSize = 20 }
    )
end

function hddCircles(cr, xOffset, yOffset)
    local colour = 0xffffff
    local alpha = 0.5

    local gaugeConfig =
        { colour  = colour
        , alpha   = alpha
        , xOffset = xOffset
        , yOffset = yOffset
        , radius  = null
        , value   = null
        , value0  = 0
        , width   = 10 }
    do
        local hddRootUsedPercent = conky_parse(string.format("${fs_used_perc /}"))
        gaugeConfig.radius = 60
        gaugeConfig.value = linearInterpolation(0,1, 0,100, hddRootUsedPercent)
        ringGauge(cr, gaugeConfig)
    end
    do
        local homeUsedPercent = conky_parse(string.format("${fs_used_perc /home}"))
        gaugeConfig.radius = 70+1
        gaugeConfig.value = linearInterpolation(0,1, 0,100, homeUsedPercent)
        ringGauge(cr, gaugeConfig)
    end

    alignedText(
        cr,
        { text     = "HDD"
        , centerX  = xOffset
        , centerY  = yOffset
        , alignX   = "c"
        , alignY   = "m"
        , colour   = colour
        , alpha    = alpha
        , fontSize = 20 })
end

function ringGauge(cr, config)
    local value0angle = linearInterpolation(0, 2*math.pi, 0,1, config.value0)
    local angle = function(filledFraction)
        return linearInterpolation(
            -math.pi/2 + value0angle,
             3*math.pi/2 + value0angle,
             0,1,
             filledFraction)
    end

    cairo_set_source_rgba(cr, splitRgba(config.colour, config.alpha))
    cairo_arc(
        cr,
        config.xOffset,
        config.yOffset,
        config.radius,
        angle(0),
        angle(config.value))
    cairo_set_line_width(cr, config.width)
    cairo_stroke(cr)

    cairo_set_source_rgba(cr, splitRgba(config.colour, config.alpha/4))
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

function radialGauge(cr, config)
    cairo_set_source_rgba(cr, splitRgba(config.colour, config.alpha))
    cairo_arc(
        cr,
        config.xOffset,
        config.yOffset,
        linearInterpolation(
            config.minRadius, (config.maxRadius+config.minRadius)/2,
            0, 1,
            config.value),
        config.angleStart,
        config.angleEnd)
    cairo_set_line_width(
        cr,
        linearInterpolation(
            0, config.maxRadius-config.minRadius,
            0, 1,
            config.value))
    cairo_stroke(cr)

    cairo_set_source_rgba(cr, splitRgba(config.colour, config.alpha/4))
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

function alignedText(cr, config)
    cairo_set_source_rgba(cr, splitRgba(config.colour, config.alpha))
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

function polarToCartesian(r, phi)
    return r*math.cos(phi), r*math.sin(phi)
end

-- Draw radial rays from a center point. Useful to create ticks on circles.
function rays(cr, config)
    for i = 1, config.multitude do
        local angle = linearInterpolation(
            config.rotation,2*math.pi + config.rotation,
            1, config.multitude+1,
            i)
        local x,y = polarToCartesian(config.innerRadius, angle)
        cairo_move_to(cr, x+config.centerX, y+config.centerY)
        x,y = polarToCartesian(config.outerRadius, angle)
        cairo_line_to(cr, x+config.centerX, y+config.centerY)
    end
    cairo_set_line_width(cr, config.lineWidth)
    cairo_set_source_rgba(cr, splitRgba(config.colour, config.alpha))
    cairo_stroke(cr)
end
