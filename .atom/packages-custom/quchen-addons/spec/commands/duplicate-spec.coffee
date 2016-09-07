{maskToRanges} = require "../utils"

describe "duplicate", ->
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

    describe "when nothing is selected", ->
        it "duplicates the current line", ->
            editor.setText """
                Lorem
                ipsum
                dolor
            """

            editor.setSelectedBufferRanges maskToRanges """
                .....
                ..|..
                .....
            """

            atom.commands.dispatch editorView, "quchen:duplicate"

            expect(editor.getText()).toEqual """
                Lorem
                ipsum
                ipsum
                dolor
            """
            expect(editor.getSelectedBufferRanges()).toEqual maskToRanges """
                .....
                .....
                ..|..
                .....
            """

    describe "when something is selected", ->
        it "duplicates the selection", ->
            editor.setText "Lorem ipsum dolor"
            editor.setSelectedBufferRanges maskToRanges \
                           "Lorem [---] dolor"

            expect(editor.getSelectedText()).toEqual "ipsum"

            atom.commands.dispatch editorView, "quchen:duplicate"
            expect(editor.getText()).toEqual "Lorem ipsumipsum dolor"
            expect(editor.getSelectedText()).toEqual "ipsum"
            expect(editor.getSelectedBufferRanges()).toEqual maskToRanges \
                                             "Lorem ipsum[---] dolor"

            atom.commands.dispatch editorView, "quchen:duplicate"
            atom.commands.dispatch editorView, "quchen:duplicate"
            expect(editor.getText()).toEqual "Lorem ipsumipsumipsumipsum dolor"
            expect(editor.getSelectedText()).toEqual "ipsum"
            expect(editor.getSelectedBufferRanges()).toEqual maskToRanges \
                                             "Lorem ipsumipsumipsum[---] dolor"

    describe "when there are multiple selections", ->
        it "works for all of them individually", ->
            editor.setText """
                Lorem1 lorem2 lorem3
                ipsum1 ipsum2 ipsum3
                dolor1 dolor2 dolor3
            """
            editor.setSelectedBufferRanges maskToRanges """
                Lorem1 [----] lorem3
                ip|um1 ipsum2 ipsum3
                dolor1 dolor2 [----]
            """

            atom.commands.dispatch editorView, "quchen:duplicate"

            expect(editor.getText()).toEqual """
                Lorem1 lorem2lorem2 lorem3
                ipsum1 ipsum2 ipsum3
                ipsum1 ipsum2 ipsum3
                dolor1 dolor2 dolor3dolor3
            """
