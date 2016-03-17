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

cycleSelection = (mode) -> (_this) ->
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

    editor.transact () ->
        for selection, i in selections
            selection.insertText selectedTexts[i], {select: true}

atom.commands.add 'atom-text-editor',
    'rotate-selection:right': cycleSelection "right",
    'rotate-selection:left': cycleSelection "left"
