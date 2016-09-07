{maskToRanges} = require "../utils"

describe "refine selection", ->
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

    describe "by config", ->
        it "selects all configured tokens", ->
            editor.setText """
                case v of
                    Nothing -> 0
                    Just r -> r
            """

            refinementConfig = {}
            rootScope = editor.getRootScopeDescriptor().scopes[0]
            refinementConfig[rootScope] = [
                "="
                "->"
                "<-"
            ]
            editor.config.set "quchen.refinements", refinementConfig

            editor.selectAll()
            atom.commands.dispatch editorView, "quchen:refine-by-config"

            expect(editor.getSelectedBufferRanges()).toEqual maskToRanges """
                case v of
                    Nothing [] 0
                    Just v [] v
            """

    describe "by first word", ->
        it "selects all occurrences of the first word", ->
            editor.setText """
                Lorem ipsum dolor sit amet
                ..AAA ..AAA .... .... ....
                ..... .....AAA.. AAA. ....
                AAA.. ..... AAA AAA AAA...
                Lorem ipsum dolor sit AAAt
            """

            editor.setSelectedBufferRanges maskToRanges """
                Lorem ipsum dolor sit amet
                ..[-----------------------
                --------------------------
                --------------------------
                -------------------------]
            """

            atom.commands.dispatch editorView, "quchen:refine-by-first-word"

            expect(editor.getSelectedBufferRanges()).toEqual maskToRanges """
                Lorem ipsum dolor sit amet
                ..[-] ..[-] .... .... ....
                ..... .....[-].. [-]. ....
                [-].. ..... [-] [-] [-]...
                Lorem ipsum dolor sit [-]t
            """
