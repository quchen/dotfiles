prelude = require("./haskellPrelude.coffee")

row = (selection) -> selection.getBufferRange().start.row
exports.row = row

column = (selection) -> selection.getBufferRange().start.column
exports.column = column

# Sort selections by their beginning, and group them by line.
#
# lineGroup :: [Selection] -> [[Selection]]
exports.lineGroup = (selections) ->
    result = prelude.groupGloballyBy selections, row
    result.map (selectionLine) ->
        selectionLine.sort (s1, s2) ->
            column(s1) - column(s2)
