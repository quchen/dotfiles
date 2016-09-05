# Convenience wrapper to add new functions to Atom.
# Prefixes them with "quchen:" and runs them as a transaction so commands
# only create a single undo entry, instead of one for each invoked sub-edit.

prelude = require "./haskellPrelude.coffee"

exports.addCommands = (subscriptions, commands) ->
    for command, effect of commands
        subscriptions.add atom.commands.add "atom-text-editor",
            "quchen:#{command}", prelude.atomically effect
