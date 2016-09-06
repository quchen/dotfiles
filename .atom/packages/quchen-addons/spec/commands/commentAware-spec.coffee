{maskToRanges} = require "../utils"

describe "comment-aware", ->
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

    describe "newline below inserts a line below the current one", ->
        describe "in ordinary text", ->
            it "works on the first line", ->
                editor.setText """
                    Lorem
                    ipsum
                    dolor
                """

                editor.setSelectedBufferRanges maskToRanges """
                    ...|.
                    .....
                    .....
                """

                atom.commands.dispatch editorView, "quchen:comment-aware-newline-below"

                expect(editor.getText()).toEqual """
                    Lorem

                    ipsum
                    dolor
                """
                expect(editor.getSelectedBufferRanges()).toEqual maskToRanges """
                    .....
                    |
                    .....
                    .....
                """

            it "works in the middle of the buffer", ->
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

                atom.commands.dispatch editorView, "quchen:comment-aware-newline-below"

                expect(editor.getText()).toEqual """
                    Lorem
                    ipsum

                    dolor
                """
                expect(editor.getSelectedBufferRanges()).toEqual maskToRanges """
                    .....
                    .....
                    |
                    .....
                """

            it "works at the end of the buffer", ->
                editor.setText """
                    Lorem
                    ipsum
                    dolor
                """

                editor.setSelectedBufferRanges maskToRanges """
                    .....
                    .....
                    ..|..
                """

                atom.commands.dispatch editorView, "quchen:comment-aware-newline-below"

                expect(editor.getText()).toEqual """
                    Lorem
                    ipsum
                    dolor

                """
                expect(editor.getSelectedBufferRanges()).toEqual maskToRanges """
                    .....
                    .....
                    .....
                    |
                """

    describe "newline above inserts a line above the current one", ->
        describe "in ordinary text", ->
            it "works on the first line", ->
                editor.setText """
                    Lorem
                    ipsum
                    dolor
                """

                editor.setSelectedBufferRanges maskToRanges """
                    ...|.
                    .....
                    .....
                """

                atom.commands.dispatch editorView, "quchen:comment-aware-newline-above"

                expect(editor.getText()).toEqual """

                    Lorem
                    ipsum
                    dolor
                """
                expect(editor.getSelectedBufferRanges()).toEqual maskToRanges """
                    |
                    .....
                    .....
                    .....
                """

            it "works in the middle of the buffer", ->
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

                atom.commands.dispatch editorView, "quchen:comment-aware-newline-above"

                expect(editor.getText()).toEqual """
                    Lorem

                    ipsum
                    dolor
                """
                expect(editor.getSelectedBufferRanges()).toEqual maskToRanges """
                    .....
                    |
                    .....
                    .....
                """

            it "works at the end of the buffer", ->
                editor.setText """
                    Lorem
                    ipsum
                    dolor
                """

                editor.setSelectedBufferRanges maskToRanges """
                    .....
                    .....
                    ..|..
                """

                atom.commands.dispatch editorView, "quchen:comment-aware-newline-above"

                expect(editor.getText()).toEqual """
                    Lorem
                    ipsum

                    dolor
                """
                expect(editor.getSelectedBufferRanges()).toEqual maskToRanges """
                    .....
                    .....
                    |
                    .....
                """

    describe "join with line below", ->
        describe "when nothing is selected", ->
            describe "in ordinary text", ->
                it "works on the first line", ->
                    editor.setText """
                        Lorem
                        ipsum
                        dolor
                    """

                    editor.setSelectedBufferRanges maskToRanges """
                        ...|.
                        .....
                        .....
                    """

                    atom.commands.dispatch editorView, "quchen:comment-aware-join-lines-down"

                    expect(editor.getText()).toEqual """
                        Lorem ipsum
                        dolor
                    """
                    expect(editor.getSelectedBufferRanges()).toEqual maskToRanges """
                        Lorem|ipsum
                    """

                it "works in the middle of the buffer", ->
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

                    atom.commands.dispatch editorView, "quchen:comment-aware-join-lines-down"

                    expect(editor.getText()).toEqual """
                        Lorem
                        ipsum dolor
                    """
                    expect(editor.getSelectedBufferRanges()).toEqual maskToRanges """
                        .....
                        ipsum|dolor
                    """

                it "does nothing at the end of the buffer", ->
                    text = """
                        Lorem
                        ipsum
                        dolor
                    """
                    selections = maskToRanges """
                        .....
                        .....
                        ..|..
                    """
                    editor.setText text
                    editor.setSelectedBufferRanges selections

                    atom.commands.dispatch editorView, "quchen:comment-aware-join-lines-down"

                    expect(editor.getText()).toEqual text
                    expect(editor.getSelectedBufferRanges()).toEqual selections

    describe "join with line above", ->
        describe "when nothing is selected", ->
            describe "in ordinary text", ->
                it "does nothing on the first line", ->
                    text = """
                        Lorem
                        ipsum
                        dolor
                    """
                    selections = maskToRanges """
                        ...|.
                        .....
                        .....
                    """
                    editor.setText text
                    editor.setSelectedBufferRanges selections

                    atom.commands.dispatch editorView, "quchen:comment-aware-join-lines-up"

                    expect(editor.getText()).toEqual text
                    expect(editor.getSelectedBufferRanges()).toEqual selections

                it "works in the middle of the buffer", ->
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

                    atom.commands.dispatch editorView, "quchen:comment-aware-join-lines-up"

                    expect(editor.getText()).toEqual """
                        Lorem ipsum
                        dolor
                    """
                    expect(editor.getSelectedBufferRanges()).toEqual maskToRanges """
                        Lorem|ipsum
                        ...
                    """

                it "works on the last line", ->
                    editor.setText """
                        Lorem
                        ipsum
                        dolor
                    """

                    editor.setSelectedBufferRanges maskToRanges """
                        .....
                        .....
                        ..|..
                    """

                    atom.commands.dispatch editorView, "quchen:comment-aware-join-lines-up"

                    expect(editor.getText()).toEqual """
                        Lorem
                        ipsum dolor
                    """
                    expect(editor.getSelectedBufferRanges()).toEqual maskToRanges """
                        .....
                        ipsum|dolor
                    """
