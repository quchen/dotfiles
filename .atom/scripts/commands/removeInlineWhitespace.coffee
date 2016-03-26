# Remove all spaces and tabs in the selections.

removeInlineWhitespace = () ->
    selections = atom.workspace.getActiveTextEditor().getSelections()
    for selection in selections
        selection.insertText selection.getText().replace(/[ \t]+/g, ""),
            "select": true

require("../lib/addCommands.coffee").addCommands
    "remove-inline-whitespace": removeInlineWhitespace
