spawnSync = require("child_process").spawnSync

# Run a shell command, and return its STDOUT.
#
# shellCommand :: String -> IO String
shellCommand = (command, args) ->
    result = spawnSync command, args
    if result.error?
        atom.notifications.addInfo "Shell command failed",
            "detail": "Running #{command} failed. STDERR:\n#{result.stderr}",
            "dismissable": true
        return null
    else
        return result.stdout.toString()

exports.dateCommand = (format) -> () ->
    out = shellCommand "date", [format]
    console.log out
    for selection in atom.workspace.getActiveTextEditor().getSelections()
        selection.insertText out.trim()
