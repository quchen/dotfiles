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

require "./scripts/commands"

# TODO: Add 'refine selections' to e.g. select all words containing "a" in the
#       current selection. Useful for e.g. selecting all common operators for
#       alignment.
# TODO: Remove all but one newline at EOF on save
# TODO: Open containing folder
# TODO: Comment-aware newline script
# TODO: Comment-aware join lines
