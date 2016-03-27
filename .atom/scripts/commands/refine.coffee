# Escape a string so it can be used to match its own literal
# in a regex.
escapeRegex = (string) ->
    string.replace(/[\-\[\]\/\{\}\(\)\*\+\?\.\\\^\$\|]/g, "\\$&")

# Given a scope, generate a regex that matches all the things
# that the selection should be refined to.
#
# aggregateRefinementRegex :: Refinements -> Scope -> Maybe RegExp
aggregateRefinementRegex = (refinements, scopes) ->
    refinementRegexPieces = []
    for scope in scopes
        lookupRefinement = refinements[scope]
        if lookupRefinement?
            refinementRegexPieces = refinementRegexPieces.concat lookupRefinement
    rawRegex = refinementRegexPieces.map escapeRegex
    if rawRegex.length > 0
        new RegExp(rawRegex.join("|"), "g")
    else
        null

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
refine = () ->
    editor = atom.workspace.getActiveTextEditor()
    buffer = editor.getBuffer()
    selections = editor.getSelections()

    refinements = atom.config.get("quchen.refinements")
    refinedRanges = []
    for selection in selections
        selectedRange = selection.getBufferRange()
        scopeDescriptor = editor.scopeDescriptorForBufferPosition selectedRange.start
        refinementRegex = aggregateRefinementRegex refinements, scopeDescriptor.scopes
        if refinementRegex?
            buffer.scanInRange refinementRegex, selectedRange, ({range}) ->
                refinedRanges.push range
    refinedRanges

    if refinedRanges.length > 0
        editor.setSelectedBufferRanges refinedRanges

require("../lib/addCommands.coffee").addCommands
    "refine-selection": refine
