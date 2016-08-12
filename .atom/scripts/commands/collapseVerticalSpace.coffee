# Collapse vertical space to standardized sizes.

prelude = require "../lib/haskellPrelude.coffee"

collapseVerticalSpace = () ->
    editor = atom.workspace.getActiveTextEditor()
    buffer = editor.getBuffer()
    selections = editor.getSelections()

    anyRangeSelected = prelude.any ((selection) -> not selection.isEmpty()), selections

    if anyRangeSelected
        for selection in selections
            range = selection.getBufferRange()
            buffer.backwardsScanInRange /\n{3}/g, range, ({replace}) -> replace "\n\n"
            buffer.backwardsScanInRange /\n{5,}/g, range, ({replace}) -> replace "\n\n\n\n"
    else
        buffer.backwardsScan /\n{3}/g, ({replace}) -> replace "\n\n"
        buffer.backwardsScan /\n{5,}/g, ({replace}) -> replace "\n\n\n\n"

require("../lib/addCommands.coffee").addCommands
    "collapse-vertical-space": collapseVerticalSpace
