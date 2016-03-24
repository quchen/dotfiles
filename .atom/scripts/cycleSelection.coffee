# Cyclically permute all selections.
#
# lorem ipsum dolor -> dolor lorem ipsum -> ipsum dolor lorem

prelude = require "./haskellPrelude.coffee"

exports.cycleSelection = (mode) -> () ->
    editor = atom.workspace.getActiveTextEditor()
    selections = editor.getSelectionsOrderedByBufferPosition()
    selectedTexts = selections.map (item) -> item.getText()

    switch mode
        when "right"
            rotateRight = (list) -> list.unshift(list.pop())
            rotateRight selectedTexts
        when "left"
            rotateLeft = (list) -> list.push list.shift()
            rotateLeft selectedTexts
        else
            atom.notifications.addError "Invalid rotation mode",
                "detail": "The rotation mode #{mode} is not supported.",
                "dismissable": true

    prelude.zipWith ((selection, text) -> selection.insertText text, {select: true}),
        selections,
        selectedTexts
