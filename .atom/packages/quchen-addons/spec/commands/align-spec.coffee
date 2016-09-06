{maskToRanges} = require "../utils"

describe "align", ->
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

    describe "one symbol per row is selected", ->
        describe "left-align", ->
            it "left-aligns them vertically and keeps selections", ->
                editor.setText """
                    aaaaa = 1
                    b = 2
                    ccccccccc = 3
                """

                editor.setSelectedBufferRanges maskToRanges """
                    aaaaa # 1
                    b # 2
                    ccccccccc # 3
                """

                atom.commands.dispatch editorView, "quchen:align-left"

                expect(editor.getText()).toEqual """
                    aaaaa     = 1
                    b         = 2
                    ccccccccc = 3
                """
                expect(editor.getSelectedBufferRanges()).toEqual maskToRanges """
                    aaaaa     # 1
                    b         # 2
                    ccccccccc # 3
                """

        describe "right-align", ->
            it "right-aligns them vertically and collapses selections", ->
                editor.setText """
                    aaaaa: 1
                    b: 2
                    ccccccccc: 3
                """

                editor.setSelectedBufferRanges \
                    [
                        {
                            start: {row: 0, column: 5}
                            end:   {row: 0, column: 5 + ":".length}
                        }, {
                            start: {row: 1, column: 1}
                            end:   {row: 1, column: 1 + ":".length}
                        }, {
                            start: {row: 2, column: 9}
                            end:   {row: 2, column: 9 + ":".length}
                        }
                    ]
                atom.commands.dispatch editorView, "quchen:align-right"

                expect(editor.getText()).toEqual """
                    aaaaa:     1
                    b:         2
                    ccccccccc: 3
                """
                expect(editor.getSelectedBufferRanges()).toEqual \
                    [
                        {
                            start: {row: 0, column: 10}
                            end:   {row: 0, column: 10}
                        }, {
                            start: {row: 1, column: 10}
                            end:   {row: 1, column: 10}
                        }, {
                            start: {row: 2, column: 10}
                            end:   {row: 2, column: 10}
                        }
                    ]

    describe "multiple things are selected", ->
        describe "left-align", ->
            it "left-aligns them vertically and incrementally", ->
                editor.setText """
                    foo = bar
                    loremipsum = dolor != id
                    sitamet = 42 <= 55
                """

                editor.setSelectedBufferRanges \
                    [
                        {
                            start: {row: 0, column: 4}
                            end:   {row: 0, column: 4 + "=".length}
                        }, {
                            start: {row: 1, column: 11}
                            end:   {row: 1, column: 11 + "=".length}
                        }, {
                            start: {row: 1, column: 19}
                            end:   {row: 1, column: 19 + "!=".length}
                        }, {
                            start: {row: 2, column: 8}
                            end:   {row: 2, column: 8 + "=".length}
                        }, {
                            start: {row: 2, column: 13}
                            end:   {row: 2, column: 13 + "=".length}
                        }
                    ]

                atom.commands.dispatch editorView, "quchen:align-left"
                expect(editor.getText()).toEqual """
                    foo        = bar
                    loremipsum = dolor != id
                    sitamet    = 42 <= 55
                """
                expect(editor.getSelectedBufferRanges()).toEqual \
                    [
                        {
                            start: {row: 0, column: 11}
                            end:   {row: 0, column: 11 + "=".length}
                        }, {
                            start: {row: 1, column: 11}
                            end:   {row: 1, column: 11 + "=".length}
                        }, {
                            start: {row: 1, column: 19}
                            end:   {row: 1, column: 19 + "!=".length}
                        }, {
                            start: {row: 2, column: 11}
                            end:   {row: 2, column: 11 + "=".length}
                        }, {
                            start: {row: 2, column: 16}
                            end:   {row: 2, column: 16 + "=".length}
                        }
                    ]

                atom.commands.dispatch editorView, "quchen:align-left"
                expect(editor.getText()).toEqual """
                    foo        = bar
                    loremipsum = dolor != id
                    sitamet    = 42    <= 55
                """
                expect(editor.getSelectedBufferRanges()).toEqual \
                    [
                        {
                            start: {row: 0, column: 11}
                            end:   {row: 0, column: 11 + "=".length}
                        }, {
                            start: {row: 1, column: 11}
                            end:   {row: 1, column: 11 + "=".length}
                        }, {
                            start: {row: 1, column: 19}
                            end:   {row: 1, column: 19 + "!=".length}
                        }, {
                            start: {row: 2, column: 11}
                            end:   {row: 2, column: 11 + "=".length}
                        }, {
                            start: {row: 2, column: 19}
                            end:   {row: 2, column: 19 + "=".length}
                        }
                    ]
