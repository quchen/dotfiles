# Multi-align is a function to align selections vertically.
#
# It differs from other alignment functions and packages by not being crap.
#     - It is not "smart".
#     - Its outcome is always predictable.
#     - It handles a variety of different use cases, and does exactly the right
#       thing in each of them.
#
# Multialign works like this:
#     1. Group all selections by line.
#     2. Find the first non-aligned selection of all lines.
#     3. Align that group.
#
# For example, having the following code and selecting all the "=",
#
#     foo = bar
#     loremipsum = dolor >>= id
#     sitamet = 42 <= 55
#
# a single multialign will align the first "=" in each line.
#
#     foo        = bar
#     loremipsum = dolor >>= id
#     sitamet    = 42 <= 55
#
# Aligning again, since the first "=" are all already aligned, will align the
# second ones.
#
#     foo        = bar
#     loremipsum = dolor >>= id
#     sitamet    = 42 <    = 55



prelude = require "./haskellPrelude.coffee"

selectionRow = (selection) -> selection.getBufferRange().start.row
selectionCol = (selection) -> selection.getBufferRange().start.column

# groupSortSelections :: [Selection] -> [[Selection]]
groupSortSelections = (selections) ->
    result = prelude.groupGloballyBy selections, selectionRow
    result.map (selectionLine) ->
        selectionLine.sort (s1, s2) ->
            selectionCol(s1) - selectionCol(s2)

# extractSelectionsToAlign :: [[Selection]] -> [Selection]
extractSelectionsToAlign = (selectionsByLine) ->
    alignmentIndex = 0
    candidates = []
    loop
        candidates = prelude.mapMaybe ((list) -> list[alignmentIndex]), selectionsByLine
        if candidates.length <= 0
            break
        else if prelude.allEqual (candidates.map selectionCol)
            ++alignmentIndex
        else
            break
    candidates

# alignSelections :: [Selection] -> IO ()
alignSelections = (selections) ->
    rightmostColumn = 0
    for selection in selections
        rightmostColumn = Math.max rightmostColumn, selectionCol selection
    for selection in selections
        currentContent = selection.getText()
        selectionStart = selection.getBufferRange().start.column
        selection.insertText " ".repeat(rightmostColumn - selectionStart)
        selection.insertText currentContent, 'select': true

exports.multiAlign = () ->
    selections = atom.workspace.getActiveTextEditor().getSelections()
    align = prelude.compose [ alignSelections,
                              extractSelectionsToAlign,
                              groupSortSelections ]
    align selections
