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

                editor.setSelectedBufferRanges maskToRanges """
                    aaaaa# 1
                    b# 2
                    ccccccccc# 3
                """
                atom.commands.dispatch editorView, "quchen:align-right"

                expect(editor.getText()).toEqual """
                    aaaaa:     1
                    b:         2
                    ccccccccc: 3
                """
                expect(editor.getSelectedBufferRanges()).toEqual maskToRanges """
                    aaaaa:    |1
                    b:        |2
                    ccccccccc:|3
                """

    describe "multiple things are selected", ->
        describe "left-align", ->
            it "left-aligns them vertically and incrementally", ->
                editor.setText """
                    foo = bar
                    loremipsum = dolor != id
                    sitamet = 42 <= 55
                """

                editor.setSelectedBufferRanges maskToRanges """
                    foo # bar
                    loremipsum # dolor [] id
                    sitamet # 42 [] 55
                """

                atom.commands.dispatch editorView, "quchen:align-left"
                expect(editor.getText()).toEqual """
                    foo        = bar
                    loremipsum = dolor != id
                    sitamet    = 42 <= 55
                """
                expect(editor.getSelectedBufferRanges()).toEqual maskToRanges """
                    foo        # bar
                    loremipsum # dolor [] id
                    sitamet    # 42 [] 55
                """

                atom.commands.dispatch editorView, "quchen:align-left"
                expect(editor.getText()).toEqual """
                    foo        = bar
                    loremipsum = dolor != id
                    sitamet    = 42    <= 55
                """
                expect(editor.getSelectedBufferRanges()).toEqual maskToRanges """
                    foo        # bar
                    loremipsum # dolor [] id
                    sitamet    # 42    [] 55
                """
        describe "combining left-align and right-align", ->
            it "works", ->
                editor.setText """
                    ..aaa: b: ..c
                    ...bb: eeee: ...f
                    ....ccc: hh: ....i
                """

                editor.setSelectedBufferRanges maskToRanges """
                    ..|aa# b# ..#
                    ...|b# eeee# ...#
                    ....|cc# hh# ....#
                """

                atom.commands.dispatch editorView, "quchen:align-left"
                atom.commands.dispatch editorView, "quchen:align-right"
                atom.commands.dispatch editorView, "quchen:align-right"
                atom.commands.dispatch editorView, "quchen:align-left"

                expect(editor.getText()).toEqual """
                    ..  aaa: b:    ..  c
                    ... bb:  eeee: ... f
                    ....ccc: hh:   ....i
                """
                expect(editor.getSelectedBufferRanges()).toEqual maskToRanges """
                    ..  |aa:|b:   |..  #
                    ... |b: |eeee:|... #
                    ....|cc:|hh:  |....#
                """
