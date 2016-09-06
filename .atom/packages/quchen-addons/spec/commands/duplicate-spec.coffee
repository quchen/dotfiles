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

            editor.setCursorBufferPosition
                row: 1
                column: 3
            atom.commands.dispatch editorView, "quchen:duplicate"

            expect(editor.getText()).toEqual """
                Lorem
                ipsum
                ipsum
                dolor
            """
            expect(editor.getCursorBufferPosition()).toEqual
                row: 2
                column: 3

    describe "when something is selected", ->
        it "duplicates the selection", ->
            editor.setText "Lorem ipsum dolor"

            editor.setSelectedBufferRanges \
                [
                    start: {row: 0, column: 6}
                    end:   {row: 0, column: 6 + "ipsum".length}
                ]

            expect(editor.getSelectedText()).toEqual "ipsum"
            atom.commands.dispatch editorView, "quchen:duplicate"

            expect(editor.getText()).toEqual "Lorem ipsumipsum dolor"
            expect(editor.getSelectedText()).toEqual "ipsum"
            expect(editor.getSelectedScreenRange()).toEqual
                start: {row: 0, column: 11}
                end:   {row: 0, column: 11 + "ipsum".length}

    describe "when there are multiple selections", ->
        it "works for all of them individually", ->
            editor.setText """
                Lorem1 lorem2 lorem3
                ipsum1 ipsum2 ipsum3
                dolor1 dolor2 dolor3
            """

            editor.setSelectedBufferRanges \
                [
                    {
                        start: {row: 0, column: 7}
                        end:   {row: 0, column: 7 + "lorem2".length},
                    }, {
                        start: {row: 1, column: 2}
                        end:   {row: 1, column: 2},
                    }, {
                        start: {row: 2, column: 14}
                        end:   {row: 2, column: 14 + "dolor3".length},
                    }
                ]
            atom.commands.dispatch editorView, "quchen:duplicate"

            expect(editor.getText()).toEqual """
                Lorem1 lorem2lorem2 lorem3
                ipsum1 ipsum2 ipsum3
                ipsum1 ipsum2 ipsum3
                dolor1 dolor2 dolor3dolor3
            """
