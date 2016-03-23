prelude = require "./haskellPrelude.coffee"

selectionRow = (selection) -> selection.getBufferRange().start.row
selectionCol = (selection) -> selection.getBufferRange().start.column

groupSortSelections = (selections) ->
    result = prelude.groupGloballyBy selections, selectionRow
    result.map (selectionLine) ->
        selectionLine.sort (s1, s2) ->
            selectionCol(s1) - selectionCol(s2)

selectionsToBeAligned = (selectionsByLine) ->
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
    editor = atom.workspace.getActiveTextEditor()
    selections = editor.getSelections()
    selectionsByLine = groupSortSelections selections
    toAlign = selectionsToBeAligned selectionsByLine
    alignSelections toAlign
