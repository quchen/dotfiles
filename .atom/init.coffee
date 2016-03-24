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

addCommands = require("./scripts/addCommands.coffee").addCommands

cycleSelection = require("./scripts/cycleSelection.coffee").cycleSelection
addCommands
    "rotate-selection-right": cycleSelection "right",
    "rotate-selection-left":  cycleSelection "left"

joinLinesUp = require("./scripts/joinLinesUp.coffee").joinLinesUp
addCommands "join-lines-up": joinLinesUp

deleteLine = require("./scripts/deleteLine.coffee").deleteLine
addCommands "delete-line": deleteLine

multiAlign = require("./scripts/multiAlign.coffee").multiAlign
addCommands "align": multiAlign

dateCommand = require("./scripts/shellCommand.coffee").dateCommand
addCommands
    "insert-date":           dateCommand "+%Y-%m-%d"
    "insert-date-and-time":  dateCommand "+%Y-%m-%d %H:%M:%S"
    "insert-date-unix-time": dateCommand "+%s"
    "insert-date-iso-8601":  dateCommand "--iso-8601=ns"
    "insert-date-rfc-3339":  dateCommand "--rfc-3339=ns"

numberStartingWith = require("./scripts/numberStartingWith.coffee").numberStartingWith
addCommands
    "number-from-0": numberStartingWith 0
    "number-from-1": numberStartingWith 1

removeInlineWhitespace = require("./scripts/removeInlineWhitespace.coffee").removeInlineWhitespace
addCommands "remove-inline-whitespace": removeInlineWhitespace

duplicate = require("./scripts/duplicate.coffee").duplicate
addCommands
    "duplicate": duplicate


# TODO: Remove all but one newline at EOF on save
# TODO: Open containing folder
# TODO: Comment-aware newline script
# TODO: Comment-aware join lines
