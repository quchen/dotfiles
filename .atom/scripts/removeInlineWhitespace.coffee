exports.removeInlineWhitespace = () ->
    for selection in atom.workspace.getActiveTextEditor().getSelections()
        console.log(selection.getText())
        console.log(selection.getText().replace(/[ \t]+/g, ""))
        selection.insertText selection.getText().replace(/[ \t]+/g, ""),
            "select": true
