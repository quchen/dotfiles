# Fill the line based on the current selection.
#
# The line length is read from the config via `editor.preferredLineLength`.
# If something has been selected, cycle that to the end of the line.
# If the selection is empty, repeat the character before the cursor.

prelude = require "../lib/haskellPrelude.coffee"
selectionLib = require "../lib/selection.coffee"

isAtBol = (selection) -> selectionLib.column(selection) == 0

firstEachLine = (selections) ->
    selections = selectionLib.lineGroup selections
    prelude.mapMaybe prelude.head, selections

fillToLength = (selection, length) ->
    if isAtBol(selection) and selection.isEmpty()
        return
    else if selection.isEmpty()
        selection.selectLeft 1
    currentText = selection.getText()
    charsToFill = length - selectionLib.column selection
    replications = Math.ceil (charsToFill / currentText.length)
    if replications > 0
        selection.insertText \
            currentText.repeat(replications).substr(0, charsToFill),
            'select': true

fillEntireLines = () ->
    lineWidth = atom.config.get 'editor.preferredLineLength'
    selections = atom.workspace.getActiveTextEditor().getSelections()
    for selection in firstEachLine selections
        fillToLength selection, lineWidth

fillToPrevious = () ->
    buffer = atom.workspace.getActiveTextEditor().getBuffer()
    selections = atom.workspace.getActiveTextEditor().getSelections()
    for selection in firstEachLine selections
        startLine = selection.getBufferRange().start.row
        continue if startLine <= 0
        previousLineLength = buffer.lineForRow(startLine - 1).length
        fillToLength selection, previousLineLength

require("../lib/addCommands.coffee").addCommands
    "fill-lines-entirely":              fillEntireLines
    "fill-lines-to-length-of-previous": fillToPrevious
