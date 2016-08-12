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
                console.log char
                parenthesesStack.push(char)
            when char == ")" or char == ">" or char == "}" or char == "]"
                console.log char
                parenthesesStack.pop()

    parenthesesStack

closeAllOpenParens = () ->
    editor       = atom.workspace.getActiveTextEditor()
    cursorPos    = editor.getCursorBufferPosition()
    beforeCursor = editor.getTextInBufferRange([[0, 0], cursorPos])
    afterCursor  = editor.getTextInBufferRange([cursorPos, [Infinity, Infinity]])

    for unbalancedParenthesis in findUnbalancedParentheses(beforeCursor, afterCursor).reverse()
        editor.insertText(matchingParenthesis unbalancedParenthesis)

require("../lib/addCommands.coffee").addCommands
    "close-open-parentheses": closeAllOpenParens
