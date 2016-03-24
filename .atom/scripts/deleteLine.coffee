# Like Atom's built-in `delete line`, but will maintain the current row of
# the cursor, if possible.

exports.deleteLine = () ->
    selections = atom.workspace.getActiveTextEditor().getSelections()
    for selection in selections
        range = selection.getBufferRange()
        selection.deleteLine()
        selection.setBufferRange([range.start, range.start])
