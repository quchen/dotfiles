require("cairo")

local function splitRgb(colour)
    return
        ((colour / 0x10000) % 0x100) / 255.,
        ((colour / 0x100) % 0x100) / 255.,
        (colour % 0x100) / 255.
end

local function splitRgba(colour, alpha)
    local r, g, b = splitRgb(colour)
    return r, g, b, alpha
end

local function joinRgb(r, g, b)
    return r*0xff0000 + g*0x00ff00 + b*0x0000ff
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
local function linearInterpolation(startValue, endValue, paramMin, paramMax, parameter)
    return (endValue-startValue) / (paramMax-paramMin) * (parameter-paramMax) + endValue
end

local function linearInterpolateColours(startColour, endColour, paramMin, paramMax, parameter)
    local startR, startG, startB = splitRgb(startColour)
    local endR, endG, endB = splitRgb(endColour)
    return joinRgb(
        linearInterpolation(startR, endR, paramMin, paramMax, parameter),
        linearInterpolation(startG, endG, paramMin, paramMax, parameter),
        linearInterpolation(startB, endB, paramMin, paramMax, parameter))
end

local trim = function(str)
    return string.gsub(str, "^%s*(.-)%s*$", "%1")
end

local spaceBeforeUnits = function(str)
    return string.gsub(str, "^(.-)(%a+)$", "%1 %2")
end

-- Left-biased union of tables
local function merge(a, b)
    result = {}
    for k, v in pairs(b) do result[k] = v end
    for k, v in pairs(a) do result[k] = v end
    return result
end

return
    { splitRgb                 = splitRgb
    , splitRgba                = splitRgba
    , linearInterpolation      = linearInterpolation
    , linearInterpolateColours = linearInterpolateColours
    , trim                     = trim
    , spaceBeforeUnits         = spaceBeforeUnits
    , merge                    = merge
    }
