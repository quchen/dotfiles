# Takes a text like
#
# """
# [---]
#   # [...]
# """
#
# and turns
#
# - "#" into single-character selections
# - "|" into zero-character selections starting to the left of the "|"
# - everything including the [] to multi-character ones

maskToRanges = (text) ->
    selections = []
    row = 0
    column = 0
    pushRowColumn = (row, column) ->
        markers.push
            row:    row
            column: column

    for char in text
        switch char
            when "#"
                selections.push \
                    {
                        start: {row: row, column: column},
                        end:   {row: row, column: column+1}
                    }
                ++column
            when "|"
                selections.push \
                    {
                        start: {row: row, column: column},
                        end:   {row: row, column: column}
                    }
                ++column
            when "\n"
                ++row
                column = 0
            when "["
                selections.push \
                    {
                        start: {row: row, column: column},
                        end:   null
                    }
                ++column
            when "]"
                selections[selections.length-1].end = {row: row, column: column+1}
                ++column
            else
                ++column

    return selections

module.exports =
    maskToRanges: maskToRanges
