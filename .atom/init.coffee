##############################################################################
##  Keybindings
##############################################################################

# Drop all non-user-configured keybindings so that keymap.cson builds
# on a clean slate.
atom.keymaps.keyBindings = atom.keymaps.keyBindings.filter (binding) ->
    binding.source.match "keymap\\.cson$"


##############################################################################
##  Commands
##############################################################################


require "./scripts/align.coffee"
require "./scripts/cycleSelection.coffee"
require "./scripts/deleteLine.coffee"
require "./scripts/joinLinesUp.coffee"
require "./scripts/numberStartingWith.coffee"
require "./scripts/removeInlineWhitespace.coffee"
require "./scripts/shellCommand.coffee"




# TODO: Remove all but one newline at EOF on save
# TODO: Pad on the right, not on the left
# TODO: Open containing folder
# TODO: Comment-aware newline script
# TODO: Comment-aware join lines
