# Cyclically permute all selections.
#
# lorem ipsum dolor -> dolor lorem ipsum -> ipsum dolor lorem

prelude = require "../lib/haskellPrelude.coffee"

insertTextSelected = (selection, text) ->
    selection.insertText text, {select: true}

# cycleSelection :: ([a] -> [a]) -> IO ()
cycleSelection = (rotate) -> () ->
    editor = atom.workspace.getActiveTextEditor()
    selections = editor.getSelectionsOrderedByBufferPosition()
    selectedTexts = selections.map (item) -> item.getText()
    rotate selectedTexts
    prelude.zipWith insertTextSelected, selections, selectedTexts

# rotateLeft :: [a] -> [a]
rotateRight = (list) -> list.unshift list.pop()

# rotateRight :: [a] -> [a]
rotateLeft = (list) -> list.push list.shift()

exports.commands =
    "rotate-selection-right": cycleSelection rotateRight
    "rotate-selection-left":  cycleSelection rotateLeft
