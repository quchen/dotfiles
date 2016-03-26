# Remove all spaces and tabs in the selections.

removeInlineWhitespace = () ->
    for selection in atom.workspace.getActiveTextEditor().getSelections()
        selection.insertText selection.getText().replace(/[ \t]+/g, ""),
            "select": true


require("../lib/addCommands.coffee").addCommands
    "remove-inline-whitespace": removeInlineWhitespace
