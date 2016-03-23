##############################################################################
##  Keybindings
##############################################################################

# Drop all non-user-configured keybindings so that keymap.cson builds
# on a clean slate.
atom.keymaps.keyBindings = atom.keymaps.keyBindings.filter (binding) ->
    binding.source.match "keymap\\.cson$"


##############################################################################
##  Helper functions
##############################################################################

addCommands = (commands) ->
    for command, effect of commands
        atom.commands.add "atom-text-editor",
            "quchen:#{command}",
            atomically effect

# Run an action as an atomical transaction. Useful to execute a composed
# action that should be undone in a single step.
#
# atomically :: (() -> IO ()) -> () -> IO ()
atomically = (action) -> () ->
    buffer = atom.workspace.getActiveTextEditor().getBuffer()
    buffer.transact () -> action()

# Collect the unique elements of a list, by comparing their values after
# mapping them to something else.
#
# nubVia ((x) -> even x, [1,3,5,2,3,4,5])
#   ==> [1,2]
#
# nubVia :: Ord b => (a -> b) -> [a] -> [a]
nubVia = (projection, array) ->
    cache = {}
    uniques = []
    for entry in array
        projected = projection entry
        if not (cache.hasOwnProperty projected)
            uniques.push entry
            cache[projected] = true
    uniques

# zipWith :: (a -> b -> c) -> [a] -> [b] -> [c]
zipWith = (f, xs, ys) ->
    result = []
    iMax = Math.min(xs.length, ys.length)
    for i in [0 .. iMax - 1]
        result.push(f xs[i], ys[i])
    result

# all :: (a -> Bool, [a]) -> Bool
all = (predicate, list) ->
    for entry in list
        return false if not (predicate entry)
    return true

any = (predicate, list) ->
    for entry in list
        return true if predicate entry
    return false

# allEqual :: Eq a => [a] -> Bool
allEqual = (list) ->
    for element in list
        if element != list[0]
            return false
    return true


# Like groupBy, but groups all elements fitting in a bucket, not just
# consecutive ones.
#
# For `b = Bool`, this is equivalent to `partition`.
#
# >>> groupGloballyBy [1..10] even
# [[1,3,5,7,9], [2,4,6,8,10]
#
# groupGloballyBy :: Ord a => [a] -> (a -> b) -> [[a]]
groupGloballyBy = (list, projection) ->
    grouped = {}
    for item in list
        key = projection item
        grouped[key] ?= []
        grouped[key].push item
    result = []
    for key, value of grouped
        result.push value
    result

# Map and discard nulls afterwards
#
# mapMaybe :: (a -> Maybe b) -> [a] -> [b]
mapMaybe = (f, xs) -> xs.map(f).filter((x) -> x?)

spawnSync = require("child_process").spawnSync

# Run a shell command, and return its STDOUT.
#
# shellCommand :: String -> IO String
shellCommand = (command, args) ->
    result = spawnSync command, args
    if result.error?
        atom.notifications.addInfo "Shell command failed",
            "detail": "Running #{command} failed. STDERR:\n#{result.stderr}",
            "dismissable": true
        return null
    else
        return result.stdout.toString()



##############################################################################
##  Command: rotate selections
##############################################################################

cycleSelection = (mode) -> () ->
    editor = atom.workspace.getActiveTextEditor()
    selections = editor.getSelectionsOrderedByBufferPosition()
    selectedTexts = selections.map (item) -> item.getText()

    switch mode
        when "right"
            rotateRight = (list) -> list.unshift(list.pop())
            rotateRight selectedTexts
        when "left"
            rotateLeft = (list) -> list.push list.shift()
            rotateLeft selectedTexts
        else
            atom.notifications.addError "Invalid rotation mode",
                "detail": "The rotation mode #{mode} is not supported.",
                "dismissable": true

    zipWith ((selection, text) -> selection.insertText text, {select: true}),
        selections,
        selectedTexts

addCommands
    "rotate-selection-right": cycleSelection "right",
    "rotate-selection-left": cycleSelection "left"



##############################################################################
##  Command: join with line above
##############################################################################

joinLinesUp = () ->
    editor = atom.workspace.getActiveTextEditor()
    selections = editor.getSelections()

    for selection in selections
        range = selection.getBufferRange()
        oneLineUp = range.translate([-1,0])
        selection.setBufferRange(oneLineUp)
        selection.joinLines()

addCommands "join-lines-up": joinLinesUp

##############################################################################
##  Command: delete line, maintaining cursor position
##############################################################################

deleteLine = () ->
    editor = atom.workspace.getActiveTextEditor()
    selections = editor.getSelections()

    for selection in selections
        range = selection.getBufferRange()
        selection.deleteLine()
        selection.setBufferRange([range.start, range.start])

addCommands "delete-line": deleteLine

##############################################################################
##  Command: align selections
##############################################################################

selectionRow = (selection) -> selection.getBufferRange().start.row
selectionCol = (selection) -> selection.getBufferRange().start.column

groupSortSelections = (selections) ->
    result = groupGloballyBy selections, selectionRow
    result.map (selectionLine) ->
        selectionLine.sort (s1, s2) ->
            selectionCol(s1) - selectionCol(s2)

selectionsToBeAligned = (selectionsByLine) ->
    alignmentIndex = 0
    candidates = []
    loop
        candidates = mapMaybe ((list) -> list[alignmentIndex]), selectionsByLine
        if candidates.length <= 0
            break
        else if allEqual (candidates.map selectionCol)
            ++alignmentIndex
        else
            break
    candidates

alignSelections = (selections) ->
    rightmostColumn = 0
    for selection in selections
        rightmostColumn = Math.max rightmostColumn, selectionCol selection
    for selection in selections
        currentContent = selection.getText()
        selectionStart = selection.getBufferRange().start.column
        selection.insertText " ".repeat(rightmostColumn - selectionStart)
        selection.insertText currentContent, 'select': true

multiAlign = () ->
    editor = atom.workspace.getActiveTextEditor()
    selections = editor.getSelections()
    selectionsByLine = groupSortSelections selections
    toAlign = selectionsToBeAligned selectionsByLine
    alignSelections toAlign

addCommands
    "align": multiAlign



##############################################################################
##  Command: Insert current date
##############################################################################

dateCommand = (format) -> () ->
    out = shellCommand "date", [format]
    console.log out
    for selection in atom.workspace.getActiveTextEditor().getSelections()
        selection.insertText out.trim()

# TODO: Atomically doesn"t seem to work here: inserting 3 dates creates 3 undo steps
addCommands
    "insert-date":
        dateCommand "+%Y-%m-%d"
    "insert-date-and-time":
        dateCommand "+%Y-%m-%d %H:%M:%S"
    "insert-date-unix-time":
        dateCommand "+%s"
    "insert-date-iso-8601":
        dateCommand "--iso-8601=ns"
    "insert-date-rfc-3339":
        dateCommand "--rfc-3339=ns"

##############################################################################
##  Command: Number selections
##############################################################################

numberStartingWith = (start) -> () ->
    i = start
    for selection in atom.workspace.getActiveTextEditor().getSelections()
        selection.insertText i.toString()
        ++i

addCommands
    "enumerate-from-0": numberStartingWith 0
    "enumerate-from-1": numberStartingWith 1


# TODO: Remove whitespace around selections
# TODO: Comment-aware newline script
# TODO: Comment-aware join lines
