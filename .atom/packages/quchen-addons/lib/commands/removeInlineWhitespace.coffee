# Remove all spaces and tabs in the selections, ignoring indentation
# whitespace.

# TODO: Indentation whitespace detection is still not good.

# Ideal feature:
#  - Don't touch indentation whitespace
#  - For empty selections, remove all whitespace around the cursor
#  - For nonempty ones, remove all whitespace inside

prelude = require "../lib/haskellPrelude.coffee"
selectionLib = require "../lib/selection.coffee"

removeInlineWhitespace = () ->
    editor = atom.workspace.getActiveTextEditor()
    buffer = editor.getBuffer()
    selections = editor.getSelections()

    for selection in selections
        range = selection.getBufferRange()
        rangeStartsAtBol = selectionLib.column(selection) == 0
        buffer.backwardsScanInRange /\s+/g, range, ({matchText, replace}) ->
            replace "" unless matchText.match(/\n/) or rangeStartsAtBol

exports.commands =
    "remove-inline-whitespace": removeInlineWhitespace
