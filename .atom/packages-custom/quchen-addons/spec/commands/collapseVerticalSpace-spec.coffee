describe "collapse vertical space", ->
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

    it "works", ->
        editor.setText """
            XXXXXXXXXXXXX

            XXXXXXXXXXXXX


            XXXXXXXXXXXXX



            XXXXXXXXXXXXX




            XXXXXXXXXXXXX





            XXXXXXXXXXXXX
        """

        atom.commands.dispatch editorView, "quchen:collapse-vertical-space"

        expect(editor.getText()).toEqual """
            XXXXXXXXXXXXX

            XXXXXXXXXXXXX

            XXXXXXXXXXXXX



            XXXXXXXXXXXXX



            XXXXXXXXXXXXX



            XXXXXXXXXXXXX
        """
