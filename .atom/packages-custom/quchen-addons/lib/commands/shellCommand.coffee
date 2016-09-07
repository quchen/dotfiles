# Run a shell command, and return its STDOUT.

spawnSync = require("child_process").spawnSync

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

dateCommand = (format) -> () ->
    out = shellCommand "date", [format]
    for selection in atom.workspace.getActiveTextEditor().getSelections()
        selection.insertText out.trim()

exports.commands =
    "insert-date":                  dateCommand "+%Y-%m-%d"
    "insert-date-and-time":         dateCommand "+%Y-%m-%d %H:%M:%S"
    "insert-date-unix-time":        dateCommand "+%s"
    "insert-date-iso-8601-with-ns": dateCommand "--iso-8601=ns"
    "insert-date-rfc-3339-with-ns": dateCommand "--rfc-3339=ns"
