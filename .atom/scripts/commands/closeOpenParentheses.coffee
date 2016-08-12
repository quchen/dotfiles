# Close all open parentheses at the cursor location.

prelude = require "../lib/haskellPrelude.coffee"
selectionLib = require "../lib/selection.coffee"

matchingParenthesis = (parenthesis) ->
    switch parenthesis
        when "(" then ")"
        when "<" then ">"
        when "{" then "}"
        when "[" then "]"

findUnbalancedParentheses = (beforeCursor, afterCursor) ->
    parenthesesStack = []
    for char in beforeCursor
        switch
            when char == "(" or char == "<" or char == "{" or char == "["
                parenthesesStack.push(char)
            when char == ")" or char == ">" or char == "}" or char == "]"
                parenthesesStack.pop()

    afterCursor.split("").reverse().join("") # WTF Javascript
    for char in afterCursor
        switch
            when char == "(" or char == "<" or char == "{" or char == "["
                parenthesesStack.unshift(char)
            when char == ")" or char == ">" or char == "}" or char == "]"
                parenthesesStack.shift()

    parenthesesStack

closeAllOpenParens = () ->
    editor    = atom.workspace.getActiveTextEditor()
    selection = editor.getLastSelection()

    if selection.isEmpty()
        cursorPos    = editor.getCursorBufferPosition()
        beforeCursor = editor.getTextInBufferRange([[0, 0], cursorPos])
        afterCursor  = editor.getTextInBufferRange([cursorPos, [Infinity, Infinity]])
    else
        beforeCursor = selection.getText()
        afterCursor = ""

    missingParentheses = []
    for parenthesis in findUnbalancedParentheses beforeCursor, afterCursor
        missingParentheses.unshift(matchingParenthesis parenthesis)
    selectionLib.clearRight selection
    selection.insertText missingParentheses.join(""), {select: true}


require("../lib/addCommands.coffee").addCommands
    "close-open-parentheses": closeAllOpenParens
