##############################################################################
##  Keybindings
##############################################################################

# Drop all non-user-configured keybindings so that keymap.cson builds
# on a clean slate.
atom.keymaps.keyBindings = atom.keymaps.keyBindings.filter (binding) ->
    binding.source.match "keymap\\.cson$"





##############################################################################
##  Command: rotate selections
##############################################################################

cycleSelection = (mode) -> () ->
    editor = atom.workspace.getActiveTextEditor()
    selections = editor.getSelections()
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

    editor.getBuffer().transact () ->
        for selection, i in selections
            selection.insertText selectedTexts[i], {select: true}

atom.commands.add 'atom-text-editor',
    'rotate-selection:right': cycleSelection "right",
    'rotate-selection:left': cycleSelection "left"



##############################################################################
##  Command: join with line above
##############################################################################

joinWithLineAbove = () ->
    atom.notifications.addError "Join with line above",
        'detail': 'TODO: Implement',
        'dismissable': true

atom.commands.add 'atom-text-editor',
    'editor:join-lines-above': joinWithLineAbove

# TODO: Make delete-line maintain current column

##############################################################################
##  Command: align selections
##############################################################################

alignSelections = () ->
    editor = atom.workspace.getActiveTextEditor()
    cursors = editor.getCursors()

    cursorColumns = cursors.map (c) -> c.getBufferColumn()
    maxColumn = Math.max cursorColumns...
    padCursors = for cursor in cursors
        row = cursor.getBufferRow()
        column = cursor.getBufferColumn()
        paddingDelta = maxColumn - column

        'raw': cursor,
        'row': row,
        'column': column,
        'padding': ' '.repeat(paddingDelta)

    buffer = editor.getBuffer()
    buffer.transact () ->
        for cursor in padCursors
            buffer.insert [cursor.row, cursor.column], cursor.padding
            cursor.raw.moveToBeginningOfLine()
            cursor.raw.moveRight(maxColumn)
    # TODO: Ensure correct handling when multiple cursors in one line
    #       (Seems to be correct by accident right now)
    # TODO: When multiple things are selected/marked, align by their left edges
    #       and maintain marked contents when aligning. Useful with ^k^k^k -> align

atom.commands.add 'atom-text-editor',
    'editor:align': alignSelections




# TODO: Comment-aware newline script
