{maskToRanges} = require "../utils"

describe "close open parentheses", ->
    editor = null
    editorView = null

    beforeEach ->
        waitsForPromise ->
            Promise.all [
                atom.packages.activatePackage "quchen-addons"
                atom.workspace.open().then (e) ->
                    editor = e
                    editorView = atom.views.getView e
            ]

    describe "something is selected", ->
        it "closes all left open selected parentheses and selects the insertion", ->
            editor.setText                              "  (( ([][{()<( "
            editor.setSelectedBufferRanges maskToRanges "  .. [------] "

            atom.commands.dispatch editorView, "quchen:close-open-parentheses"

            expect(editor.getText()).toEqual \
                "  (( ([][{()<>}])( "
            expect(editor.getSelectedBufferRanges()).toEqual maskToRanges \
                "  .. ........[--]. "
