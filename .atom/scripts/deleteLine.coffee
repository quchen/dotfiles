exports.deleteLine = () ->
    editor = atom.workspace.getActiveTextEditor()
    selections = editor.getSelections()

    for selection in selections
        range = selection.getBufferRange()
        selection.deleteLine()
        selection.setBufferRange([range.start, range.start])
