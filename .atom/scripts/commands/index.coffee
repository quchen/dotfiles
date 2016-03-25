readDir = require("fs").readdirSync
basename = require("path").basename

isCoffeescript = (file) -> file.match "\\.coffee$"
isSelf         = (file) -> file.match (basename __filename)
validInclude   = (file) -> isCoffeescript(file) and not isSelf(file)

for file in readDir __dirname
    if validInclude file
        console.log "Auto-loading #{file}"
        require "./#{file}"
