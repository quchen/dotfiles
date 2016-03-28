readDir = require("fs").readdirSync
basename = require("path").basename

isCoffeescript = (file) -> file.match "\\.coffee$"
isSelf         = (file) -> file.match (basename __filename)
validInclude   = (file) -> isCoffeescript(file) and not isSelf(file)

includedFiles = []
for file in readDir __dirname
    require "./#{file}" if validInclude file
    includedFiles.push file

removeExtension = (file) -> file.replace(/\..*$/, "")
includedFiles = includedFiles.map removeExtension
console.log "Auto-loaded scripts: #{__dirname}/{#{includedFiles.join ", "}}"
