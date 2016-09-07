{maskToRanges} = require "../utils"

describe "number starting with", ->
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

    for startNumber in [0,1]
        describe "#{startNumber}, #{startNumber+1}, ...", ->
            it "inserts numbers if nothing is selected", ->
                editor.setText """
                    Lorem
                    ipsum
                    dolor
                    sit
                    amet
                """

                editor.setSelectedBufferRanges maskToRanges """
                    |orem
                    |psum
                    |olor
                    |it
                    |amet
                """

                atom.commands.dispatch editorView, "quchen:number-from-#{startNumber}"

                expect(editor.getText()).toEqual """
                    #{startNumber+0}Lorem
                    #{startNumber+1}ipsum
                    #{startNumber+2}dolor
                    #{startNumber+3}sit
                    #{startNumber+4}amet
                """

            it "overrides selections", ->
                editor.setText """
                    Lorem
                    ipsum
                    dolor
                    sit
                    amet
                """

                editor.setSelectedBufferRanges maskToRanges """
                    #orem
                    #psum
                    #olor
                    #it
                    #amet
                """

                atom.commands.dispatch editorView, "quchen:number-from-#{startNumber}"

                expect(editor.getText()).toEqual """
                    #{startNumber+0}orem
                    #{startNumber+1}psum
                    #{startNumber+2}olor
                    #{startNumber+3}it
                    #{startNumber+4}met
                """

    describe "first selection", ->
        it "reads the first selection and numbers from it", ->
            editor.setText """
                3. Lorem
                4. ipsum
                6. dolor
                5. sit
                2. amet
            """

            editor.setSelectedBufferRanges maskToRanges """
                #. Lorem
                #. ipsum
                #. dolor
                #. sit
                #. amet
            """

            atom.commands.dispatch editorView, "quchen:number-from-first-selection"

            expect(editor.getText()).toEqual """
                3. Lorem
                4. ipsum
                5. dolor
                6. sit
                7. amet
            """
