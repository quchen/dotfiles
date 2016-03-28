prelude = require("./haskellPrelude.coffee")

row = (selection) -> selection.getBufferRange().start.row
exports.row = row

column = (selection) -> selection.getBufferRange().start.column
exports.column = column

# sortSelectionsBy
#     :: [Selection]
#     -> (Selection -> Selection -> Int)
#     -> [Selection]
sortSelectionsBy = (selections, comparing) ->
    selections.sort (s1, s2) ->
        comparing(s1) - comparing(s2)

# Sort selections by their beginning, and group them by line.
#
# lineGroup :: [Selection] -> [[Selection]]
exports.lineGroup = (selections) ->
    result = prelude.partition selections, row
    result.map (selectionLine) ->
        sortSelectionsBy selectionLine, column
