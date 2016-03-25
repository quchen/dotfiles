prelude = require("./haskellPrelude.coffee")

exports.row = (selection) -> selection.getBufferRange().start.row
exports.column = (selection) -> selection.getBufferRange().start.column

# Sort selections by their beginning, and group them by line.
#
# lineGroup :: [Selection] -> [[Selection]]
exports.lineGroup = (selections) ->
    result = prelude.groupGloballyBy selections, selectionRow
    result.map (selectionLine) ->
        selectionLine.sort (s1, s2) ->
            selectionCol(s1) - selectionCol(s2)
