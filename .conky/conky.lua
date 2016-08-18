require("cairo")
local util = require("util")
local widget = require("widget")

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

	local updates=conky_parse("${updates}")
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

    widget.alignedText(
        cr,
        { text     = "CPU"
        , centerX  = xOffset
        , centerY  = yOffset
        , alignX   = "c"
        , alignY   = "m"
        , colour   = colour
        , alpha    = alpha
        , fontSize = 20 })

    for cpuId = 1, 4 do
        local cpuLoad = conky_parse(string.format("${cpu cpu%d}", cpuId))
        widget.ringGauge(
            cr,
            { colour  = colour
            , alpha   = alpha
            , xOffset = xOffset
            , yOffset = yOffset
            , radius  = util.linearInterpolation(60,90+4, 1,4, cpuId)
            , value   = util.linearInterpolation(0,1, 0,100, cpuLoad)
            , value0  = 0
            , width   = 10 })
    end
end

function graphBoxes(cr)
    local box = function(cr, x, y, w, h)
        cairo_set_source_rgba(cr, util.splitRgba(0xffffff, 0.1))
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
        widget.ringGauge(
            cr,
            { colour  = colour
            , alpha   = alpha
            , xOffset = xOffset
            , yOffset = yOffset
            , radius  = 60
            , value   = util.linearInterpolation(0,1, 0,100, memPercent)
            , value0  = 0
            , width   = 10 })
    end

    do
        local swapPercent = tonumber(conky_parse(string.format("${swapperc}")))
        if not swapPercent then swapPercent = 0 end
        widget.ringGauge(
            cr,
            { colour  = colour
            , alpha   = alpha
            , xOffset = xOffset
            , yOffset = yOffset
            , radius  = 70
            , value   = util.linearInterpolation(0,1, 0,100, swapPercent)
            , value0  = 0
            , width   = 6 })
    end

    widget.alignedText(
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
        gaugeConfig.value = util.linearInterpolation(0,1, 0,100, hddRootUsedPercent)
        widget.ringGauge(cr, gaugeConfig)
    end
    do
        local homeUsedPercent = conky_parse(string.format("${fs_used_perc /home}"))
        gaugeConfig.radius = 70+1
        gaugeConfig.value = util.linearInterpolation(0,1, 0,100, homeUsedPercent)
        widget.ringGauge(cr, gaugeConfig)
    end

    widget.alignedText(
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
