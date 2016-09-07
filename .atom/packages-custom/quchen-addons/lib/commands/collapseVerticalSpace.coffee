# Collapse vertical space to standardized sizes.

prelude = require "../lib/haskellPrelude.coffee"

collapseCallback = ({matchText, replace}) ->
    if matchText.length == 3
        replace "\n\n"
    else if matchText.length > 4
        replace "\n\n\n\n"

collapseVerticalSpace = () ->
    editor = atom.workspace.getActiveTextEditor()
    buffer = editor.getBuffer()
    selections = editor.getSelections()

    anyRangeSelected = prelude.any ((selection) -> not selection.isEmpty()), selections

    if anyRangeSelected
        for selection in selections
            range = selection.getBufferRange()
            buffer.backwardsScanInRange /\n{3,}/g, range, collapseCallback
    else
        buffer.backwardsScan /\n{3,}/g, collapseCallback

exports.commands =
    "collapse-vertical-space": collapseVerticalSpace
