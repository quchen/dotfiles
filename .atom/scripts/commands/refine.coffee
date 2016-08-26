# Refine large selections into multiple small selections. Pairs well with
# alignment scripts.

# Escape a string so it can be used to match its own literal
# in a regex.
escapeRegex = (string) ->
    string.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&")



# Given a scope, generate a regex that matches all the things
# that the selection should be refined to.
#
# configuredRefinementRegex :: Refinements -> Scope -> Maybe RegExp
configuredRefinementRegex = (refinements, scopes) ->
    refinementRegexPieces = []
    for scope in scopes
        lookupRefinement = refinements[scope]
        if lookupRefinement?
            refinementRegexPieces = refinementRegexPieces.concat lookupRefinement
    rawRegex = refinementRegexPieces.map escapeRegex
    if rawRegex.length > 0
        new RegExp(rawRegex.join("|"), "g")



# Refine the current selections into sub-selections matching a given regex.
#
# For example, refining
#
# lorem ipsum dolor sit amet
# ^------------------------^
#
# with (ipsum|amet) yields
#
# lorem ipsum dolor sit amet
#       ^---^           ^--^
refine = (refinementRegex) ->
    editor = atom.workspace.getActiveTextEditor()
    buffer = editor.getBuffer()
    selections = editor.getSelections()

    refinedRanges = []
    for selection in selections
        selectedRange = selection.getBufferRange()
        buffer.scanInRange refinementRegex, selectedRange, ({range}) ->
            refinedRanges.push range

    if refinedRanges.length > 0
        editor.setSelectedBufferRanges refinedRanges

refineByConfig = () ->
    editor = atom.workspace.getActiveTextEditor()
    buffer = editor.getBuffer()
    selections = editor.getSelections()

    refinementConfig = atom.config.get("quchen.refinements")
    for selection in selections
        selectedRange = selection.getBufferRange()
        scopeDescriptor = editor.scopeDescriptorForBufferPosition selectedRange.start
        refinementRegex = configuredRefinementRegex refinementConfig, scopeDescriptor.scopes
        if refinementRegex?
            refine refinementRegex if refinementRegex?

refineByFirstWord = () ->
    selections = atom.workspace.getActiveTextEditor().getSelections()

    firstWord = null
    for selection in selections
        firstWord = selection.getText().match(/[^\s]+/)[0]
        break if firstWord?

    rawRegex = escapeRegex firstWord
    refinementRegex = new RegExp(rawRegex, "g")
    refine refinementRegex



require("../lib/addCommands.coffee").addCommands
    "refine-by-config":     refineByConfig
    "refine-by-first-word": refineByFirstWord
