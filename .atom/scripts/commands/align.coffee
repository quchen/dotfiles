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
#
# Given a list of selections grouped by line, find the first non-aligned
# selections and return them.
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

removeCommonWhitespacePrefix = (selections) ->
    spacePrefixes = []
    for selection in selections
        selectionLib.rangeMasked selection, (s) ->
            ws = 0
            loop
                selectionLib.clearToLeft selection
                selectionLib.clearToLeft s
                s.selectLeft 1
                break if (s.getBufferRange().start.column == 0 or s.getText() != " ")
                ++ws
            spacePrefixes.push(ws)
    commonSpacePrefix = prelude.foldl Math.min, Infinity, spacePrefixes


    for selection in selections
        currentText = selection.getText()
        range = selection.getBufferRange()
        r1 = range.start.row
        c1 = range.start.column
        rc2 = range.end
        selection.setBufferRange([[r1, c1 - commonSpacePrefix], rc2])
        selection.insertText(" ")
        selection.insertText(currentText, "select": true)

multiAlign = () ->
    selections = atom.workspace.getActiveTextEditor().getSelections()
    lineGroups = selectionLib.lineGroup selections
    selectionsToAlign = extractSelectionsToAlign lineGroups
    alignSelections selectionsToAlign
    removeCommonWhitespacePrefix selectionsToAlign

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
        selectionLib.clearToRight selection
    multiAlign()

require("../lib/addCommands.coffee").addCommands
    "align-multi": multiAlign,
    "align-right": alignRight
