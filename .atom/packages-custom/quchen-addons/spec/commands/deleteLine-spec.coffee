{maskToRanges} = require "../utils"

describe "delete line", ->
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

    it "deletes the line and maintains the cursor", ->
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

        atom.commands.dispatch editorView, "quchen:delete-line"

        expect(editor.getText()).toEqual """
            Lorem
            dolor
        """
        expect(editor.getSelectedBufferRanges()).toEqual maskToRanges """
            .....
            ..|..
        """

    it "collapses selections to the left", ->
        editor.setText """
            Lorem
            ipsum
            dolor
        """
        editor.setSelectedBufferRanges maskToRanges """
            .....
            ..[-]
            .....
        """

        atom.commands.dispatch editorView, "quchen:delete-line"

        expect(editor.getText()).toEqual """
            Lorem
            dolor
        """
        expect(editor.getSelectedBufferRanges()).toEqual maskToRanges """
            .....
            ..|..
        """

    it "deletes one line for each cursor", ->
        editor.setText """
            Lorem
            ipsum
            dolor
            sit
            amet
        """
        editor.setSelectedBufferRanges maskToRanges """
            |....
            #.[-]
            .....
        """

        atom.commands.dispatch editorView, "quchen:delete-line"

        expect(editor.getText()).toEqual """
            sit
            amet
        """
