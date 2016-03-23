exports.numberStartingWith = (start) -> () ->
    i = start
    for selection in atom.workspace.getActiveTextEditor().getSelections()
        selection.insertText i.toString()
        ++i
