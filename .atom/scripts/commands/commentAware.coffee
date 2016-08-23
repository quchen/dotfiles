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

# Check whether the selection contains a line comment.
containsLineCommentScope = (selection) ->
    editor = atom.workspace.getActiveTextEditor()
    selectedRangeStart = selection.getBufferRange().start
    scopeDescriptor = editor.scopeDescriptorForBufferPosition selectedRangeStart
    prelude.any isLineCommentScopeName, scopeDescriptor.scopes

# Insert a newline at the current position, commenting out the new line if the
# old line's scope was a line comment.
commentAwareNewline = (selection) ->
    isLineComment = selectionLib.rangeMasked selection, (s) ->
        selection.selectToFirstCharacterOfLine()
        return containsLineCommentScope selection

    selection.insertText "\n", autoIndentNewline: true
    if isLineComment
        selection.toggleLineComments()

# Insert a new line below the current line. Equivalent to hitting END and then
# inserting a newline.
commentAwareNewlineBelow = (selection) ->
    selectionLib.translate selection, [0, Infinity]
    commentAwareNewline selection

# Insert a new line above the current line. Equivalent to hitting HOME,
# inserting a newline, and moving the cursor up one line.
commentAwareNewlineAbove = (selection) ->
    isLineComment = selectionLib.rangeMasked selection, (s) ->
        selection.selectToFirstCharacterOfLine()
        return containsLineCommentScope selection
    selection.selectToFirstCharacterOfLine()
    selection.clear()
    selection.insertText "\n", autoIndentNewline: true
    selectionLib.translate selection, [-1, 0]
    if isLineComment
        selection.toggleLineComments()
        selectionLib.clearRight(selection)

# Join the current line with the one below, collapsing multiple whitespace to a
# single space character.
joinLinesDown = (selection) ->
    isLineComment = containsLineCommentScope selection
    if isLineComment
        {rangeBefore} = selectionLib.translate selection, [1,0]
        isStillLineComment = containsLineCommentScope selection
        if isStillLineComment
            selection.toggleLineComments()
        selection.setBufferRange(rangeBefore)
    selection.joinLines()

# Join the current line with the one above, collapsing multiple whitespace to a
# single space character.
joinLinesUp = (selection) ->
    selectionLib.translate selection, [-1, 0]
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
