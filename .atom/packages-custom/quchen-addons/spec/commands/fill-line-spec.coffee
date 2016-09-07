{maskToRanges} = require "../utils"

describe "fill line", ->
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

    describe "to length of previous line", ->
        describe "without selection", ->
            it "repeats the the character before the cursor", ->
                editor.setText """
                    Lorem ipsum dolor sit amet
                    -
                """

                editor.setSelectedBufferRanges maskToRanges """
                    Lorem ipsum dolor sit amet
                    -|
                """

                atom.commands.dispatch editorView, "quchen:fill-lines-to-length-of-previous"

                expect(editor.getText()).toEqual """
                    Lorem ipsum dolor sit amet
                    --------------------------
                """
                expect(editor.getSelectedBufferRanges()).toEqual maskToRanges """
                    Lorem ipsum dolor sit amet
                    [------------------------]
                """
        describe "with selection", ->
            it "repeats the the character before the cursor", ->
                editor.setText """
                    Lorem ipsum dolor sit amet
                    .:.:
                """

                editor.setSelectedBufferRanges maskToRanges """
                    Lorem ipsum dolor sit amet
                    .:[]
                """

                atom.commands.dispatch editorView, "quchen:fill-lines-to-length-of-previous"

                expect(editor.getText()).toEqual """
                    Lorem ipsum dolor sit amet
                    .:.:.:.:.:.:.:.:.:.:.:.:.:
                """
                expect(editor.getSelectedBufferRanges()).toEqual maskToRanges """
                    Lorem ipsum dolor sit amet
                    .:[----------------------]
                """
