##############################################################################
##  Keybindings
##############################################################################

# Drop all non-user-configured keybindings so that keymap.cson builds
# on a clean slate.
atom.keymaps.keyBindings = atom.keymaps.keyBindings.filter (binding) ->
    binding.source.match "keymap\\.cson$"


##############################################################################
##  Helper functions
##############################################################################

# Run an action as an atomical transaction. Useful to execute a composed
# action that should be undone in a single step.
#
# atomically :: (() -> IO ()) -> () -> IO ()
atomically = (action) -> () ->
    buffer = atom.workspace.getActiveTextEditor().getBuffer()
    buffer.transact () -> action()

# Collect the unique elements of a list, by comparing their values after
# mapping them to something else.
#
# nubVia ((x) -> even x, [1,3,5,2,3,4,5])
#   ==> [1,2]
#
# nubVia :: Ord b => (a -> b) -> [a] -> [a]
nubVia = (projection, array) ->
    cache = {}
    uniques = []
    for entry in array
        projected = projection entry
        if not (cache.hasOwnProperty projected)
            uniques.push(entry)
            cache[projected] = true
    uniques

# zipWith :: (a -> b -> c) -> [a] -> [b] -> [c]
zipWith = (f, xs, ys) ->
    result = []
    iMax = Math.min(xs.length, ys.length)
    for i in [0 .. iMax - 1]
        result.push(f xs[i], ys[i])
    result






##############################################################################
##  Command: rotate selections
##############################################################################

cycleSelection = (mode) -> () ->
    editor = atom.workspace.getActiveTextEditor()
    selections = editor.getSelectionsOrderedByBufferPosition()
    selectedTexts = selections.map (item) -> item.getText()

    switch mode
        when "right"
            rotateRight = (list) -> list.unshift(list.pop())
            rotateRight selectedTexts
        when "left"
            rotateLeft = (list) -> list.push(list.shift())
            rotateLeft selectedTexts
        else
            atom.notifications.addError "Invalid rotation mode",
                'detail': 'The rotation mode "'+mode+'" is not supported.',
                'dismissable': true

    zipWith ((selection, text) -> selection.insertText text, {select: true}),
        selections,
        selectedTexts

atom.commands.add 'atom-text-editor',
    'quchen:rotate-selection-right': atomically (cycleSelection "right"),
    'quchen:rotate-selection-left': atomically (cycleSelection "left")



##############################################################################
##  Command: join with line above
##############################################################################

joinLinesUp = () ->
    editor = atom.workspace.getActiveTextEditor()
    selections = editor.getSelections()

    for selection in selections
        range = selection.getBufferRange()
        oneLineUp = range.translate([-1,0])
        selection.setBufferRange(oneLineUp)
        selection.joinLines()

atom.commands.add 'atom-text-editor',
    'quchen:join-lines-up': atomically joinLinesUp

##############################################################################
##  Command: delete line, maintaining cursor position
##############################################################################

deleteLine = () ->
    editor = atom.workspace.getActiveTextEditor()
    selections = editor.getSelections()

    for selection in selections
        range = selection.getBufferRange()
        selection.deleteLine()
        selection.setBufferRange([range.start, range.start])

atom.commands.add 'atom-text-editor',
    'quchen:delete-line': atomically deleteLine

##############################################################################
##  Command: align selections
##############################################################################

alignLocations = (locations) ->
    alignmentColumn = 0
    for location in locations
        if location.column > alignmentColumn
            alignmentColumn = location.column

    buffer = atom.workspace.getActiveTextEditor().getBuffer()
    alignmentDeltas = locations.map (location) ->
        delta = alignmentColumn - location.column
        padding = ' '.repeat(delta)
        buffer.insert location, padding
        delta

    'alignmentColumn': alignmentColumn,
    'alignmentDeltas': alignmentDeltas

# TODO: Ensure correct handling when multiple cursors in one line

alignSelections = () ->
    editor = atom.workspace.getActiveTextEditor()
    selections = editor.getSelections()
    multiline = false
    selectionStarts = selections.map (selection) ->
        range = selection.getBufferRange()
        if not range.isSingleLine()
            multiline = true
        range.start

    if multiline
        atom.notifications.addInfo "Alignment",
            'detail': 'Aligning selections over multiple lines is not supported.',
            'dismissable': true
        return false

    selectionRanges = selections.map (selection) ->
        selection.getBufferRange()
    alignmentResult = alignLocations selectionStarts
    # Restore selections, but with offsets according to the alignment
    selectionRangesMoved =
        zipWith ((range, delta) -> range.translate [0, delta]),
        selectionRanges,
        alignmentResult.alignmentDeltas
    editor.setSelectedBufferRanges selectionRangesMoved

atom.commands.add 'atom-text-editor',
    'quchen:align': atomically alignSelections



# TODO: Comment-aware newline script
# TODO: Comment-aware join lines
# TODO: Show whitespace in selected text