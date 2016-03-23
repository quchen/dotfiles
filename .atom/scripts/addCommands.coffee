prelude = require("./haskellPrelude.coffee")

exports.addCommands = (commands) ->
    for command, effect of commands
        atom.commands.add "atom-text-editor",
            "quchen:#{command}",
            prelude.atomically effect
