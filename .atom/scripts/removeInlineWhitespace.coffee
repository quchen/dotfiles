# Remove all spaces and tabs in the selections.

removeInlineWhitespace = () ->
    for selection in atom.workspace.getActiveTextEditor().getSelections()
        console.log(selection.getText())
        console.log(selection.getText().replace(/[ \t]+/g, ""))
        selection.insertText selection.getText().replace(/[ \t]+/g, ""),
            "select": true


require("./addCommands.coffee").addCommands
    "remove-inline-whitespace": removeInlineWhitespace
