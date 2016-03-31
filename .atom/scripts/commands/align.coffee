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
#     loremipsum = dolor != id
#     sitamet = 42 <= 55
#
# a single multialign will align the first "=" in each line.
#
#     foo        = bar
#     loremipsum = dolor != id
#     sitamet    = 42 <= 55
#
# Aligning again, since the first "=" are all already aligned, will align the
# second ones.
#
#     foo        = bar
#     loremipsum = dolor != id
#     sitamet    = 42 <   = 55



prelude = require "../lib/haskellPrelude.coffee"
selectionLib = require "../lib/selection.coffee"

# allEqual :: Eq a => [a] -> Bool
allEqual = (list) ->
    for element in list
        if element != list[0]
            return false
    return true

# extractSelectionsToAlign :: [[Selection]] -> [Selection]
extractSelectionsToAlign = (selectionsByLine) ->
    alignmentIndex = 0
    candidates = []
    loop
        candidates = prelude.mapMaybe ((list) -> list[alignmentIndex]), selectionsByLine
        if candidates.length <= 0
            break
        else if allEqual (candidates.map selectionLib.column)
            ++alignmentIndex
        else
            break
    candidates

# alignSelections :: [Selection] -> IO ()
alignSelections = (selections) ->
    rightmostColumn = prelude.foldl \
        ((acc, x) -> Math.max acc, selectionLib.column x),
        0,
        selections
    for selection in selections
        currentContent = selection.getText()
        selectionStart = selection.getBufferRange().start.column
        selection.insertText " ".repeat(rightmostColumn - selectionStart)
        selection.insertText currentContent, 'select': true

multiAlign = () ->
    selections = atom.workspace.getActiveTextEditor().getSelections()
    align = prelude.compose [ alignSelections,
                              extractSelectionsToAlign,
                              selectionLib.lineGroup ]
    align selections

keepOnlyFirstSelectionPerLine = () ->
    editor = atom.workspace.getActiveTextEditor()
    selections = editor.getSelections()
    selections = selectionLib.lineGroup selections
    firstRangeEachLine = prelude.mapMaybe \
        ((sels) -> sels[0].getBufferRange()),
        selections
    editor.setSelectedBufferRanges firstRangeEachLine

alignRight = () ->
    keepOnlyFirstSelectionPerLine()
    selections = atom.workspace.getActiveTextEditor().getSelections()
    for selection in selections
        selectionLib.clearRight selection
    multiAlign()

require("../lib/addCommands.coffee").addCommands
    "align-multi": multiAlign,
    "align-right": alignRight
