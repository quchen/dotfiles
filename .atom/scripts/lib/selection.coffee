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

# Like selection.clear(), but place the cursor at the right end of the former
# selection, instead of the left.
#
# clearRight :: Selection -> IO ()
exports.clearRight = (selection) ->
    range = selection.getBufferRange()
    selection.setBufferRange([range.end, range.end])

# Convenience function to translate a selection. Returns the ranges before and after.
exports.translate = (selection, {deltaLine, deltaColumn}) ->
    deltaLine ?= 0
    deltaColumn ?= 0
    rangeBefore = selection.getBufferRange()
    rangeAfter = selection.getBufferRange().translate([deltaLine, deltaColumn])
    selection.setBufferRange(rangeAfter)
    "rangeBefore": rangeBefore,
    "rangeAfter": rangeAfter

# Do something with the selected range of a selection and restore it afterwards.
# Useful for hypothetical calculations, such as "is there a comment in the
# current line".
exports.rangeMasked = (selection, action) ->
    rangeToRestore = selection.getBufferRange()
    result = action selection
    selection.setBufferRange(rangeToRestore)
    return result
