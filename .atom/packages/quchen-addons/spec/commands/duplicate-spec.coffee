describe "duplicate", ->
    editor = null
    editorView = null

    beforeEach ->
        @editorView = atom.views.getView atom.workspace
        waitsForPromise ->
            Promise.all [
                atom.packages.activatePackage "quchen-addons"
                atom.workspace.open().then (e) ->
                    editor = e
            ]

    describe "when nothing is selected", ->
        it "duplicates the current line", ->
            editor.setText """
                Lorem
                ipsum
                dolor
            """

            editor.setCursorBufferPosition
                row: 1
                column: 3

            runs ->
                atom.commands.dispatch @editorView, "quchen:duplicate"
                expect(editor.getText()).toBe """
                    Lorem
                    ipsum
                    ipsum
                    dolor
                """
                expect(editor.getCursorBufferPosition()).toBe
                    row: 2
                    column: 3

    describe "when something is selected", ->
        it "duplicates the selection", ->
            editor.setText "Lorem ipsum dolor"

            editor.addSelectionForBufferRange
                start:
                    row: 0
                    column: 6
                end:
                    row: 0
                    column: 6 + "ipsum".length
            expect(editor.getSelectedText()).toBe "ipsum"

            runs ->
                atom.commands.dispatch @editorView, "quchen:duplicate"
                expect(editor.getText()).toBe "Lorem ipsumipsum dolor"
                expect(editor.getSelectedText()).toBe "ipsum"
                expect(editor.getSelectedScreenRange()).toBe
                    start:
                        row: 0
                        column: 11
                    end:
                        row: 0
                        column: 11 + "ipsum".length
