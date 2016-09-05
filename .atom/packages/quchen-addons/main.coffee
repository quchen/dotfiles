readDir = require("fs").readdirSync
{basename} = require("path")
{addCommands} = require "./lib/lib/addCommands"
{CompositeDisposable} = require "atom"

isCoffeescript  = (file) -> file.match "\\.coffee$"
isSelf          = (file) -> file.match (basename __filename)
validInclude    = (file) -> isCoffeescript(file) and not isSelf(file)
removeExtension = (file) -> file.replace(/\..*$/, "")

module.exports =
    subscriptions: null

    activate: ->
        console.log "Auto-loading quchen scripts"
        @subscriptions = new CompositeDisposable
        for file in readDir "#{__dirname}/lib/commands"
            if validInclude file
                {commands} = require "./lib/commands/#{file}"
                addCommands @subscriptions, commands
                console.log "    #{removeExtension file}"

    deactivate: ->
        @subscriptions.dispose()
