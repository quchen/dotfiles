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

require "./scripts"

# TODO: Refining needs a reload if config (i.e. matching sequences) change
#       right now
