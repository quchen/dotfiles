# Comment-aware functions to join lines and insert new ones.

# TODO: When inserting a newline above in an indented block from outside the
# block, the automatically inserted indentation will be selected. This is due
# to the reindentation of moveLineUp.
# TODO: Insert newline above is broken when we're at the end of a file, it
# will simply insert at the bottom.

prelude = require "../lib/haskellPrelude.coffee"
selectionLib = require "../lib/selection.coffee"

# Check whether the current scope is a line comment.
isLineCommentScopeName = (scope) -> scope.match /^comment\.line/

# Check whether the selection starts with(in) a line comment.
startsWithLineCommentScope = (selection) ->
    editor = atom.workspace.getActiveTextEditor()
    selectedRangeStart = selection.getBufferRange().start
    scopeDescriptor = editor.scopeDescriptorForBufferPosition selectedRangeStart
    prelude.any isLineCommentScopeName, scopeDescriptor.scopes

# Insert a newline at the current position, commenting out the new line if the
# old line's scope was a line comment.
commentAwareNewline = (selection) ->
    isLineComment = selectionLib.rangeMasked selection, (s) ->
        selection.selectToFirstCharacterOfLine()
        return startsWithLineCommentScope selection

    selection.insertText "\n", autoIndentNewline: true
    if isLineComment
        selection.toggleLineComments()

# Insert a new line below the current line. Equivalent to hitting END and then
# inserting a newline.
commentAwareNewlineBelow = (selection) ->
    selectionLib.translate selection, "deltaColumn": Infinity
    commentAwareNewline selection

# Insert a new line above the current line. Equivalent to hitting HOME,
# inserting a newline, and moving the cursor up one line.
commentAwareNewlineAbove = (selection) ->
    isLineComment = selectionLib.rangeMasked selection, (s) ->
        selection.selectToFirstCharacterOfLine()
        return startsWithLineCommentScope selection
    selection.selectToFirstCharacterOfLine()
    selectionLib.clearToLeft(selection)
    selection.insertText "\n", autoIndentNewline: true
    selectionLib.translate selection, "deltaLine": -1
    if isLineComment
        selection.toggleLineComments()
        selectionLib.clearToRight(selection)

# Join the current line with the one below, collapsing multiple whitespace to a
# single space character.
joinLinesDown = (selection) ->
    if selection.isEmpty()
        isLineComment = startsWithLineCommentScope selection
        if isLineComment
            selectionLib.rangeMasked selection, (s) ->
                selectionLib.translate s, "deltaLine": 1
                isStillLineComment = startsWithLineCommentScope s
                if isStillLineComment
                    s.toggleLineComments()
    else
        selectionLib.rangeMasked selection, (s) ->
            range = s.getBufferRange()
            for line in prelude.enumFromTo range.start.row+1, range.end.row
                console.log line
                s.setBufferRange [[line, Infinity], [line, Infinity]]
                s.selectToFirstCharacterOfLine()
                s.toggleLineComments() if startsWithLineCommentScope s
    selection.joinLines()

# Join the current line with the one above, collapsing multiple whitespace to a
# single space character.
joinLinesUp = (selection) ->
    return if selection.getBufferRange().start.row <= 0
    selectionLib.translate selection, "deltaLine": -1
    joinLinesDown selection

# Execute an action on a single selection on all selections.
#
# forAllSelections : (Selection -> IO ()) -> () -> IO ()
forAllSelections = (action) -> () ->
    editor = atom.workspace.getActiveTextEditor()
    for selection in editor.getSelections()
        action selection

require("../lib/addCommands.coffee").addCommands
    "comment-aware-newline":         forAllSelections commentAwareNewline
    "comment-aware-newline-above":   forAllSelections commentAwareNewlineAbove
    "comment-aware-newline-below":   forAllSelections commentAwareNewlineBelow
    "comment-aware-join-lines-up":   forAllSelections joinLinesUp
    "comment-aware-join-lines-down": forAllSelections joinLinesDown
