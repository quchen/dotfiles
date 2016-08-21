require("cairo")
local util = require("util")
local widget = require("widget")



function conky_main()
    if conky_window == nil then
        return
    end

    local cr = cairo_create(
        cairo_xlib_surface_create(
            conky_window.display,
            conky_window.drawable,
            conky_window.visual,
            conky_window.width,
            conky_window.height))

    local xOffset = 100

    topCpu(cr, 370, 160, 5)
    cpuCircles(cr, xOffset, 140)

    graphBoxes(cr)

    memoryCircles(cr, xOffset, 340)
    topMem(cr, 250, 340, 5)

    hddCircles(cr, xOffset, 500)

    entropyCircles(cr, xOffset, 750)
end



function cpuCircles(cr, xOffset, yOffset)

    local colour = 0xffffff
    local alpha = 0.5

    local getCpuLoad = function(cpuId)
        local cpuPat = cpuId and "${cpu cpu%d}" or "${cpu cpu}"
        return conky_parse(string.format(cpuPat, cpuId))
    end

    do
        local labelPadding = 3
        widget.alignedText(
            cr,
            { text     = "CPU"
            , centerX  = xOffset
            , centerY  = yOffset - labelPadding
            , alignX   = "c"
            , alignY   = "d"
            , colour   = colour
            , alpha    = alpha
            , fontSize = 20 })
        widget.alignedText(
            cr,
            { text     = getCpuLoad()
            , centerX  = xOffset
            , centerY  = yOffset + labelPadding
            , alignX   = "c"
            , alignY   = "u"
            , colour   = colour
            , alpha    = alpha
            , fontSize = 20 })
    end

    local cpuLoads = {}
    do
        for cpuId = 1, 4 do
            cpuLoads[cpuId] = getCpuLoad(cpuId)
        end
        local compareLoads = function(x,y)
            return x > y
        end
        table.sort(cpuLoads, compareLoads)
    end
    for cpuId, cpuLoad in pairs(cpuLoads) do
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
        if swapPercent then
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
    end

    do
        local labelPadding = 3
        widget.alignedText(
            cr,
            { text     = "Mem"
            , centerX  = xOffset
            , centerY  = yOffset - labelPadding
            , alignX   = "c"
            , alignY   = "d"
            , colour   = colour
            , alpha    = alpha
            , fontSize = 20 }
        )
        local memPercent = tonumber(conky_parse(string.format("${memperc}")))
        widget.alignedText(
            cr,
            { text     = memPercent
            , centerX  = xOffset
            , centerY  = yOffset + labelPadding
            , alignX   = "c"
            , alignY   = "u"
            , colour   = colour
            , alpha    = alpha
            , fontSize = 20 }
        )
    end
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



function entropyCircles(cr, xOffset, yOffset)
    local colour = 0xffffff
    local alpha = 0.5

    local entropyPoolSize = conky_parse("${entropy_avail}")
    local entropyPoolMax = conky_parse("${entropy_poolsize}")

    widget.ringGauge(
        cr,
        { colour  = colour
        , alpha   = alpha
        , xOffset = xOffset
        , yOffset = yOffset
        , radius  = 60
        , value   = util.linearInterpolation(0,1, 0,entropyPoolMax, entropyPoolSize)
        , value0  = 0
        , width   = 10 })

    do
        local entropyPoolPercent = conky_parse("${entropy_perc}")
        local labelPadding = 3
        widget.alignedText(
            cr,
            { text     = "Entropy"
            , centerX  = xOffset
            , centerY  = yOffset - labelPadding
            , alignX   = "c"
            , alignY   = "d"
            , colour   = colour
            , alpha    = alpha
            , fontSize = 20 })
        widget.alignedText(
            cr,
            { text     = entropyPoolPercent
            , centerX  = xOffset
            , centerY  = yOffset + labelPadding
            , alignX   = "c"
            , alignY   = "u"
            , colour   = colour
            , alpha    = alpha
            , fontSize = 20 })
    end
end

function topCpu(cr, xOffset, yOffset, numTop)

    local colour = 0xffffff
    local alpha = 1
    local fontSize = 16
    local padding = 10 -- Distance between process name and its load

    for i = 1, numTop do
        local name = util.trim(conky_parse(string.format("${top name %d}", i)))
        local cpuLoad = util.trim(conky_parse(string.format("${top cpu %d}", i)))

        widget.alignedText(
            cr,
            { text     = name
            , centerX  = xOffset - padding/2
            , centerY  = yOffset + (i-1) * fontSize
            , alignX   = "r"
            , alignY   = "d"
            , colour   = colour
            , alpha    = alpha
            , fontSize = fontSize })
        widget.alignedText(
            cr,
            { text     = string.format("%.1f", cpuLoad)
            , centerX  = xOffset + padding/2
            , centerY  = yOffset + (i-1) * fontSize
            , alignX   = "l"
            , alignY   = "d"
            , colour   = colour
            , alpha    = alpha
            , fontSize = fontSize })
    end
end


function topMem(cr, xOffset, yOffset, numTop)

    local colour = 0xffffff
    local alpha = 1
    local fontSize = 16

    for i = 1, numTop do
        local name = util.trim(conky_parse(string.format("${top_mem name %d}", i)))
        local memAbsolute = util.trim(conky_parse(string.format("${top_mem mem_res %d}", i)))
        local memPercent = util.trim(conky_parse(string.format("${top_mem mem %d}", i)))

        widget.alignedText(
            cr,
            { text     = name
            , centerX  = xOffset
            , centerY  = yOffset + (i-1) * fontSize
            , alignX   = "r"
            , alignY   = "d"
            , colour   = colour
            , alpha    = alpha
            , fontSize = fontSize })
        widget.alignedText(
            cr,
            { text     = string.format("%.1f%%", memPercent)
            , centerX  = xOffset + 15
            , centerY  = yOffset + (i-1) * fontSize
            , alignX   = "l"
            , alignY   = "d"
            , colour   = colour
            , alpha    = alpha
            , fontSize = fontSize })
        widget.alignedText(
            cr,
            { text     = util.spaceBeforeUnits(memAbsolute)
            , centerX  = xOffset + 80
            , centerY  = yOffset + (i-1) * fontSize
            , alignX   = "l"
            , alignY   = "d"
            , colour   = colour
            , alpha    = alpha
            , fontSize = fontSize })
    end
end
