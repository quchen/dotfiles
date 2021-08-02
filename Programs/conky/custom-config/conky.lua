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

    local xOffset = 128

    backgroundBox(cr)

    topCpu(cr, 370, 150, 5)
    cpuCircles(cr, xOffset, 140)
    cpuTemperature(cr, 405, 115)

    graphBoxes(cr)

    memoryCircles(cr, xOffset, 340)
    topMem(cr, 250, 340, 5)
    memoryUsage(cr, 405, 305)

    hddCircles(cr, xOffset, 500)
    hddUsage(cr, 24, 440)

    entropyCircles(cr, xOffset, 710)
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



-- For better readability on bright backgrounds
function backgroundBox(cr)
    widget.box(
        cr,
        { xOffset = 0
        , yOffset = 24
        , width   = 512
        , height  = 777
        , colour  = 0x000000
        , alpha   = 0.5
        , fill    = true })
    widget.box(
        cr,
        { xOffset = 1
        , yOffset = 24
        , width   = 426
        , height  = 776
        , colour  = 0xffffff
        , alpha   = 1
        , fill    = false })
end



function graphBoxes(cr)
    local box = function(cr, x, y, w, h)
        cairo_set_source_rgba(cr, util.splitRgba(0xffffff, 0.2))
        cairo_set_line_width(cr, 1)
        cairo_rectangle(cr, x, y, w, h)
        cairo_fill(cr)
    end

    common = {height=32, colour=0xffffff, alpha=0.2, fill=true}

    widget.box(cr, util.merge({ xOffset=22,  yOffset=68,  width=384 }, common)) -- CPU
    widget.box(cr, util.merge({ xOffset=22,  yOffset=254, width=384 }, common)) -- Memory

    widget.box(cr, util.merge({ xOffset=22,  yOffset=486, width=185 }, common)) -- Hard drive read
    widget.box(cr, util.merge({ xOffset=222, yOffset=486, width=185 }, common)) -- Hard drive write

    widget.box(cr, util.merge({ xOffset=22,  yOffset=574, width=185 }, common)) -- Upload
    widget.box(cr, util.merge({ xOffset=222, yOffset=574, width=185 }, common)) -- Download
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

function hddUsage(cr, xOffset, yOffset)

    local colour = 0xffffff
    local alpha = 1
    local fontSize = 16

    labelOffsets = {}
    labelOffsets["Mount"] = 0
    labelOffsets["Used"]  = 130
    labelOffsets["Max"]   = 240
    labelOffsets["%"]     = 380

    do
        local paintLabel = function(labelName, labelXOffset)
            widget.alignedText(
            cr,
            { text     = labelName
            , centerX  = xOffset + labelXOffset
            , centerY  = yOffset
            , alignX   = "l"
            , alignY   = "d"
            , colour   = colour
            , alpha    = alpha
            , fontSize = fontSize })
        end
        paintLabel("Mount", labelOffsets["Mount"])
        paintLabel("Used", labelOffsets["Used"])
        paintLabel("Max", labelOffsets["Max"])

        widget.alignedText(
            cr,
            { text     = "%"
            , centerX  = xOffset + labelOffsets["%"]
            , centerY  = yOffset
            , alignX   = "r"
            , alignY   = "d"
            , colour   = colour
            , alpha    = alpha
            , fontSize = fontSize })
    end

    local hddUsedLine = function(location, label, lineYOffset)

        used = util.spaceBeforeUnits(conky_parse(string.format("${fs_used %s} ", location)))
        size = util.spaceBeforeUnits(conky_parse(string.format("${fs_size %s} ", location)))
        percentUsed = conky_parse(string.format("${fs_used_perc %s}", location))

        local printText = function(text, textXOffset)
            widget.alignedText(
            cr,
            { text     = text
            , centerX  = xOffset + textXOffset
            , centerY  = yOffset + lineYOffset
            , alignX   = "l"
            , alignY   = "d"
            , colour   = colour
            , alpha    = alpha
            , fontSize = fontSize })
        end
        printText(label, labelOffsets["Mount"])
        printText(used, labelOffsets["Used"])
        printText(size, labelOffsets["Max"])

        widget.alignedText(
            cr,
            { text     = percentUsed
            , centerX  = xOffset + labelOffsets["%"]
            , centerY  = yOffset + lineYOffset
            , alignX   = "r"
            , alignY   = "d"
            , colour   = colour
            , alpha    = alpha
            , fontSize = fontSize })
    end

    hddUsedLine("/", "/", 18)
    hddUsedLine("/home", "~", 2*18)

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

function cpuTemperature(cr, xOffset, yOffset)

    local colour = 0xffffff
    local alpha = 1
    local fontSize = 16

    temperature = conky_parse("${hwmon 0 temp 1}")

    widget.alignedText(
        cr,
        { text     = temperature .. " °C"
        , centerX  = xOffset
        , centerY  = yOffset
        , alignX   = "r"
        , alignY   = "d"
        , colour   = colour
        , alpha    = alpha
        , fontSize = fontSize })
end

function memoryUsage(cr, xOffset, yOffset)

    local colour = 0xffffff
    local alpha = 1
    local fontSize = 16

    do
        memoryUsed = util.spaceBeforeUnits(conky_parse("${mem}"))
        memoryMax = util.spaceBeforeUnits(conky_parse("${memMax}"))

        widget.alignedText(
            cr,
            { text     = string.format("%s / %s", memoryUsed, memoryMax)
            , centerX  = xOffset
            , centerY  = yOffset
            , alignX   = "r"
            , alignY   = "d"
            , colour   = colour
            , alpha    = alpha
            , fontSize = fontSize })
    end

    do
        swapUsed = util.spaceBeforeUnits(util.trim(conky_parse("${swap}")))
        swapMax = util.spaceBeforeUnits(util.trim(conky_parse("${swapmax}")))

        widget.alignedText(
            cr,
            { text     = string.format("Swap: %s / %s", swapUsed, swapMax)
            , centerX  = xOffset
            , centerY  = yOffset + 18
            , alignX   = "r"
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
