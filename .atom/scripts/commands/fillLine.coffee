prelude = require "../lib/haskellPrelude.coffee"
selectionLib = require "../lib/selection.coffee"

isEmptyLine = (selection) ->
    selection.isEmpty() and selectionLib.column(selection) == 0

fillLine = () ->
    lineWidth = atom.config.get('editor.preferredLineLength')
    selections = atom.workspace.getActiveTextEditor().getSelections()
    for selection in selections
        if isEmptyLine selection
            return
        else if selection.isEmpty()
            selection.selectLeft 1
        currentText = selection.getText()
        charsToFill = lineWidth - selectionLib.column(selection)
        replications = Math.ceil (charsToFill / currentText.length)
        selection.insertText \
            currentText.repeat(replications).substr(0, charsToFill),
            'select': true

require("../lib/addCommands.coffee").addCommands
    "fill-line": fillLine
