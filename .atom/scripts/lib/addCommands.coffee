# Convenience wrapper to add new functions to Atom.
# Prefixes them with "quchen:" and runs them as a transaction so commands
# only create a single undo entry, instead of one for each invoked sub-edit.

prelude = require "./haskellPrelude.coffee"

addCommands = (commands) ->
    for command, effect of commands
        atom.commands.add "atom-text-editor",
            "quchen:#{command}",
            prelude.atomically effect

exports.addCommands = addCommands
