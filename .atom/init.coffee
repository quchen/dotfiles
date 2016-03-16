##############################################################################
##  Keybindings
##############################################################################

# Drop all keybindings matching a predicate.
dropBindings = (predicate) ->
    atom.keymaps.keyBindings = atom.keymaps.keyBindings.filter (binding) ->
        not (predicate binding)

boundInConfigCson = (binding) -> binding.source.match "keymap\\.cson$"
keystrokeMatches = (binding, keystrokeRegex) -> binding.keystrokes.match keystrokeRegex


# Drop standard keybindings.
# This is helpful to get rid of keybindings hardcoded in Atom (wat), or
# set by shitty modules that think they're number one priority.
dropBindings (binding) ->
    return false if boundInConfigCson binding

    bindingMatchesOneOf = (regexes) ->
        for regex in regexes
            return true if keystrokeMatches binding, regex
        return false
    return bindingMatchesOneOf ["cmd-", "^ctrl-k", "^ctrl-d$", "^ctrl-shift-D$"]
