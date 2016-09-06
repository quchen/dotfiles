# Takes a text like
#
# """
# XXXX
#   XXXXXX
# """
#
# and turns the "X" into selection ranges. The above would yield a selection that
# marks the first four characters of the first line, and 6 on the second.
maskToRanges = (text) ->

    markers = []
    row = 0
    column = 0
    selectionOpen = false
    for char in text
        switch char
            when "\n"
                ++row
                column = 0
            when "X"
                if selectionOpen
                    continue
                else # Beginning of selection
                    selectionOpen = true
                    markers.push
                        row:    row
                        column: column
            else
                if selectionOpen
                    markers.push
                        row:    row
                        column: column
                    selectionOpen = False


    if markers.length % 2 != 0
        throw new Error("Uneven number of markers in selection mask")

    ranges = []
    for i in [0 .. markers.length-1] by 2
        ranges.push
            begin: markers[i]
            end:   markers[i+1]

    return ranges
