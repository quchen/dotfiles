# Like Atom's built-in join lines, but join with the previous one instead
# of the next.

exports.joinLinesUp = () ->
    editor = atom.workspace.getActiveTextEditor()
    selections = editor.getSelections()

    for selection in selections
        range = selection.getBufferRange()
        oneLineUp = range.translate([-1,0])
        selection.setBufferRange(oneLineUp)
        selection.joinLines()
