# Close all open parentheses at the cursor location.

prelude = require "../lib/haskellPrelude.coffee"
selectionLib = require "../lib/selection.coffee"

matchingParenthesis = (parenthesis) ->
    switch parenthesis
        when "(" then ")"
        when "<" then ">"
        when "{" then "}"
        when "[" then "]"

isOpeningParenthesis = (char) -> prelude.elem char, "(<{["
isClosingParenthesis = (char) -> prelude.elem char, ")>}]"

# Like pop, but does not remove the element from the array.
peek = (array) -> array[array.length-1]

findUnbalancedParentheses = (beforeCursor, afterCursor) ->
    parenthesesStack = []
    for char in beforeCursor
        switch
            when isOpeningParenthesis char
                parenthesesStack.push char
            when isClosingParenthesis char
                # Ignore unopened closing parentheses, so that e.g. arrows
                # like -> do not mess up closing the rest of the parentheses
                if char == matchingParenthesis (peek parenthesesStack)
                    parenthesesStack.pop()

    afterCursor.split("").reverse().join("") # Reverse string. WTF Javascript

    for char in afterCursor
        switch
            when isOpeningParenthesis then parenthesesStack.unshift char
            when isClosingParenthesis then parenthesesStack.shift()

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
