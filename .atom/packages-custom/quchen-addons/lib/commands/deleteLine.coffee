# Like Atom's built-in `delete line`, but will maintain the current row of
# the cursor, if possible.

deleteLine = () ->
    selections = atom.workspace.getActiveTextEditor().getSelections()
    for selection in selections
        range = selection.getBufferRange()
        selection.deleteLine()
        selection.setBufferRange([range.start, range.start])

exports.commands =
    "delete-line": deleteLine
