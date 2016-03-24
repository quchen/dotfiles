# Places a running number at each selection.
#
# For example, selecting the first column in each line in
#
#     lorem
#     ipsum
#     dolor
#     sit
#     amet
#
# will result in
#
#     1lorem
#     2ipsum
#     3dolor
#     4sit
#     5amet

exports.numberStartingWith = (start) -> () ->
    i = start
    for selection in atom.workspace.getActiveTextEditor().getSelections()
        selection.insertText i.toString()
        ++i
