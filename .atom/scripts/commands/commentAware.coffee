# Comment-aware functions to join lines and insert new ones.

# TODO: When inserting a newline above in an indented block from outside the
# block, the automatically inserted indentation will be selected. This is due
# to the reindentation of moveLineUp.
# TODO: Insert newline above is broken when we're at the end of a file, it
# will simply insert at the bottom.

prelude = require "../lib/haskellPrelude.coffee"
selectionLib = require "../lib/selection.coffee"

isLineCommentScopeName = (scope) -> scope.match /^comment\.line/

containsLineCommentScope = ({editor}, selection) ->
    selectedRangeStart = selection.getBufferRange().start
    scopeDescriptor = editor.scopeDescriptorForBufferPosition selectedRangeStart
    prelude.any isLineCommentScopeName, scopeDescriptor.scopes

newline = (context) ->
    for selection in context.selections

        rangeToRestore = selection.getBufferRange()
        selection.selectToFirstCharacterOfLine()
        isLineComment = containsLineCommentScope context, selection
        selection.setBufferRange(rangeToRestore)

        selection.insertText "\n", autoIndentNewline: true
        if isLineComment
            selection.toggleLineComments()

newlineBelow = (context) ->
    for selection in context.selections
        selectionLib.translate selection, [0, Infinity]
    newline context

newlineAbove = (context) ->
    newlineBelow context
    context.editor.moveLineUp() # TODO: Eliminate this internal function

joinLinesDown = (context) ->
    for selection in context.selections
        isLineComment = containsLineCommentScope context, selection
        if isLineComment
            {rangeBefore} = selectionLib.translate selection, [1,0]
            isStillLineComment = containsLineCommentScope context, selection
            if isStillLineComment
                selection.toggleLineComments()
            selection.setBufferRange(rangeBefore)
        selection.joinLines()

joinLinesUp = (context) ->
    for selection in context.selections
        selectionLib.translate selection, [-1, 0]
    joinLinesDown context

commentAware = (action) -> () ->
    editor = atom.workspace.getActiveTextEditor()
    action
        "editor":     editor,
        "selections": editor.getSelections()

require("../lib/addCommands.coffee").addCommands
    "comment-aware-newline":         commentAware newline
    "comment-aware-newline-above":   commentAware newlineAbove
    "comment-aware-newline-below":   commentAware newlineBelow
    "comment-aware-join-lines-up":   commentAware joinLinesUp
    "comment-aware-join-lines-down": commentAware joinLinesDown
