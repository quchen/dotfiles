readDir = require("fs").readdirSync
{basename} = require("path")
{addCommands} = require "./lib/addCommands"
{CompositeDisposable} = require "atom"

isCoffeescript = (file) -> file.match "\\.coffee$"
isSelf         = (file) -> file.match (basename __filename)
validInclude   = (file) -> isCoffeescript(file) and not isSelf(file)

includedFiles = []
subscriptions = new CompositeDisposable
for file in readDir "#{__dirname}/commands"
    if validInclude file
        {commands} = require "./commands/#{file}"
        addCommands subscriptions, commands
        includedFiles.push file

removeExtension = (file) -> file.replace(/\..*$/, "")
includedFiles = includedFiles.map removeExtension
console.log "Auto-loaded scripts: #{__dirname}/{#{includedFiles.join ", "}}"
