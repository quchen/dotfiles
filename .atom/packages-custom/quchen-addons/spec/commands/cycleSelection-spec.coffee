{maskToRanges} = require "../utils"

describe "cycle selection", ->
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

    describe "rotate right", ->
        it "swaps two elements back and forth", ->
            inputText      = "(AAA, BBBBB)"
            inputSelection = "([-], [---])"

            editor.setText inputText
            editor.setSelectedBufferRanges maskToRanges inputSelection

            atom.commands.dispatch editorView, "quchen:rotate-selection-right"

            expect(editor.getText()).toEqual "(BBBBB, AAA)"
            expect(editor.getSelectedBufferRanges()).toEqual maskToRanges "([---], [-])"

            atom.commands.dispatch editorView, "quchen:rotate-selection-right"

            expect(editor.getText()).toEqual inputText
            expect(editor.getSelectedBufferRanges()).toEqual maskToRanges inputSelection

        it "cycles 4 elements", ->
            inputText      = "(AAA, BBBBB, CCCCCCC, DDDDDDDDD)"
            inputSelection = "([-], [---], [-----], [-------])"

            editor.setText inputText
            editor.setSelectedBufferRanges maskToRanges inputSelection

            atom.commands.dispatch editorView, "quchen:rotate-selection-right"
            expect(editor.getText()).toEqual "(DDDDDDDDD, AAA, BBBBB, CCCCCCC)"
            expect(editor.getSelectedBufferRanges()).toEqual maskToRanges \
                                             "([-------], [-], [---], [-----])"

            atom.commands.dispatch editorView, "quchen:rotate-selection-right"
            expect(editor.getText()).toEqual "(CCCCCCC, DDDDDDDDD, AAA, BBBBB)"
            expect(editor.getSelectedBufferRanges()).toEqual maskToRanges \
                                             "([-----], [-------], [-], [---])"

            atom.commands.dispatch editorView, "quchen:rotate-selection-right"
            expect(editor.getText()).toEqual "(BBBBB, CCCCCCC, DDDDDDDDD, AAA)"
            expect(editor.getSelectedBufferRanges()).toEqual maskToRanges \
                                             "([---], [-----], [-------], [-])"

            atom.commands.dispatch editorView, "quchen:rotate-selection-right"
            expect(editor.getText()).toEqual inputText
            expect(editor.getSelectedBufferRanges()).toEqual maskToRanges inputSelection

    describe "rotate left", ->
        it "swaps two elements back and forth", ->
            inputText      = "(AAA, BBBBB)"
            inputSelection = "([-], [---])"

            editor.setText inputText
            editor.setSelectedBufferRanges maskToRanges inputSelection

            atom.commands.dispatch editorView, "quchen:rotate-selection-left"

            expect(editor.getText()).toEqual "(BBBBB, AAA)"
            expect(editor.getSelectedBufferRanges()).toEqual maskToRanges "([---], [-])"

            atom.commands.dispatch editorView, "quchen:rotate-selection-left"

            expect(editor.getText()).toEqual inputText
            expect(editor.getSelectedBufferRanges()).toEqual maskToRanges inputSelection

        it "cycles 4 elements", ->
            inputText      = "(AAA, BBBBB, CCCCCCC, DDDDDDDDD)"
            inputSelection = "([-], [---], [-----], [-------])"

            editor.setText inputText
            editor.setSelectedBufferRanges maskToRanges inputSelection

            atom.commands.dispatch editorView, "quchen:rotate-selection-left"
            expect(editor.getText()).toEqual "(BBBBB, CCCCCCC, DDDDDDDDD, AAA)"
            expect(editor.getSelectedBufferRanges()).toEqual maskToRanges \
                                             "([---], [-----], [-------], [-])"

            atom.commands.dispatch editorView, "quchen:rotate-selection-left"
            expect(editor.getText()).toEqual "(CCCCCCC, DDDDDDDDD, AAA, BBBBB)"
            expect(editor.getSelectedBufferRanges()).toEqual maskToRanges \
                                             "([-----], [-------], [-], [---])"

            atom.commands.dispatch editorView, "quchen:rotate-selection-left"
            expect(editor.getText()).toEqual "(DDDDDDDDD, AAA, BBBBB, CCCCCCC)"
            expect(editor.getSelectedBufferRanges()).toEqual maskToRanges \
                                             "([-------], [-], [---], [-----])"

            atom.commands.dispatch editorView, "quchen:rotate-selection-left"
            expect(editor.getText()).toEqual inputText
            expect(editor.getSelectedBufferRanges()).toEqual maskToRanges inputSelection
