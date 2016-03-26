# Fill the line based on the current selection.
#
# The line length is read from the config via `editor.preferredLineLength`.
# If something has been selected, cycle that to the end of the line.
# If the selection is empty, repeat the character before the cursor.

prelude = require "../lib/haskellPrelude.coffee"
selectionLib = require "../lib/selection.coffee"

isAtBol = (selection) -> selectionLib.column(selection) == 0

firstEachLine = prelude.compose \
    [ ((xs) -> prelude.mapMaybe(prelude.head, xs)) \
    , selectionLib.lineGroup ]

fillLine = () ->
    lineWidth = atom.config.get('editor.preferredLineLength')
    selections = atom.workspace.getActiveTextEditor().getSelections()
    for selection in firstEachLine selections
        if isAtBol(selection) and selection.isEmpty()
            continue
        else if selection.isEmpty()
            selection.selectLeft 1
        currentText = selection.getText()
        charsToFill = lineWidth - selectionLib.column(selection)
        replications = Math.ceil (charsToFill / currentText.length)
        if replications > 0
            selection.insertText \
                currentText.repeat(replications).substr(0, charsToFill),
                'select': true

require("../lib/addCommands.coffee").addCommands
    "fill-line": fillLine
