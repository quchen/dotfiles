{maskToRanges} = require "./utils"

describe "maskToRanges", ->
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

    it "converts | to a zero-character selection", ->
        actual = maskToRanges " | "
        expected = \
            [
                {
                    start: {row: 0, column: 1},
                    end:   {row: 0, column: 1}
                }
            ]

        expect(actual).toEqual expected

    it "converts \\\# to a single-character selection", ->
        actual = maskToRanges " # "
        expected = \
            [
                {
                    start: {row: 0, column: 1},
                    end:   {row: 0, column: 2}
                }
            ]

        expect(actual).toEqual expected

    it "converts [...] to a multi-character selection", ->
        actual = maskToRanges " [-] "
        expected = \
            [
                {
                    start: {row: 0, column: 1},
                    end:   {row: 0, column: 4}
                }
            ]

        expect(actual).toEqual expected

    it "works for multiple markers", ->
        actual = maskToRanges """
            [--] [--]#
              [----] #
        """
        expected = \
            [
                {
                    start: {row: 0, column: 0},
                    end:   {row: 0, column: 4}
                }, {
                    start: {row: 0, column: 5},
                    end:   {row: 0, column: 9}
                }, {
                    start: {row: 0, column: 9},
                    end:   {row: 0, column: 10}
                }, {
                    start: {row: 1, column: 2},
                    end:   {row: 1, column: 8}
                }, {
                    start: {row: 1, column: 9},
                    end:   {row: 1, column: 10}
                }
            ]

        expect(actual).toEqual expected
