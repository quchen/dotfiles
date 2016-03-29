# Atom's built-in duplication function ("editor:duplicate-lines") duplicates
# each selected line/block. This command mimics Sublime's duplicate command:
# it duplicates lines if the selection has width 0, and otherwise duplicates
# the selection only.

duplicateLine = (editor, range, selection) ->
    buffer = editor.getBuffer()
    row = range.start.row
    currentText = buffer.lineForRow row
    buffer.insert([row+1, 0], currentText + "\n")
    selection.setBufferRange(range.translate([1, 0]))

duplicateSelection = (range, selection) ->
    currentText = selection.getText()
    selection.setBufferRange([range.end, range.end])
    selection.insertText currentText, "select": true

duplicate = () ->
    editor = atom.workspace.getActiveTextEditor()
    selections = editor.getSelections()
    for selection in selections
        range = selection.getBufferRange()
        if range.isEmpty()
            duplicateLine editor, range, selection
        else
            duplicateSelection range, selection

require("../lib/addCommands.coffee").addCommands
    "duplicate": duplicate
