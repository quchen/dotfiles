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
            when prelude.elem char, "(<{[" then parenthesesStack.push(char)
            when prelude.elem char, ")>}]" then parenthesesStack.pop()

    afterCursor.split("").reverse().join("") # Reverse string. WTF Javascript

    for char in afterCursor
        switch
            when prelude.elem char, "(<{[" then parenthesesStack.unshift(char)
            when prelude.elem char, ")>}]" then parenthesesStack.shift()

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

    selectionLib.clearToRight selection
    selection.insertText missingParentheses.join(""), {select: true}

require("../lib/addCommands.coffee").addCommands
    "close-open-parentheses": closeAllOpenParens
