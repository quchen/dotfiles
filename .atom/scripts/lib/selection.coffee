prelude = require("./haskellPrelude.coffee")

row = (selection) -> selection.getBufferRange().start.row

column = (selection) -> selection.getBufferRange().start.column

# sortSelectionsBy
#     :: [Selection]
#     -> (Selection -> Int)
#     -> [Selection]
sortSelectionsBy = (selections, comparing) ->
    selections.sort (s1, s2) ->
        comparing s1 - comparing s2

# Sort selections by their beginning, and group them by line.
#
# lineGroup :: [Selection] -> [[Selection]]
lineGroup = (selections) ->
    result = prelude.partition selections, row
    result.map (selectionLine) ->
        sortSelectionsBy selectionLine, column

# Clear a selection by putting the cursor to its beginning.
#
# clearToLeft :: Selection -> IO ()
clearToLeft = (selection) ->
    range = selection.getBufferRange()
    selection.setBufferRange([range.start, range.start])

# Clear a selection by putting the cursor to its end.
#
# clearToRight :: Selection -> IO ()
clearToRight = (selection) ->
    range = selection.getBufferRange()
    selection.setBufferRange([range.end, range.end])

# Convenience function to translate a selection. Returns the new selected range.
translate = (selection, {deltaLine, deltaColumn}) ->
    deltaLine ?= 0
    deltaColumn ?= 0
    rangeBefore = selection.getBufferRange()
    rangeAfter = selection.getBufferRange().translate([deltaLine, deltaColumn])
    selection.setBufferRange rangeAfter
    rangeAfter

# Do something with the selected range of a selection and restore it afterwards.
# Useful for hypothetical calculations, such as "is there a comment in the
# current line".
rangeMasked = (selection, action) ->
    rangeToRestore = selection.getBufferRange()
    result = action selection
    selection.setBufferRange rangeToRestore
    return result

reverseSelection = (selection) ->
    [a,b] = selection.getBufferRange()
    selection.setBufferRange [b,a]

# Make sure the beginning of the selection is before its end
canonicalize = (selection) ->
    if selection.isReversed()
        reverseSelection selection

exports.row              = row
exports.column           = column
exports.lineGroup        = lineGroup
exports.clearToLeft      = clearToLeft
exports.clearToRight     = clearToRight
exports.translate        = translate
exports.rangeMasked      = rangeMasked
exports.reverseSelection = reverseSelection
exports.canonicalize     = canonicalize
