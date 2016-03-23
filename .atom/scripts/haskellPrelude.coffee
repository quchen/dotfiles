# Run an action as an atomical transaction. Useful to execute a composed
# action that should be undone in a single step.
#
# atomically :: (() -> IO ()) -> () -> IO ()
exports.atomically = (action) -> () ->
    buffer = atom.workspace.getActiveTextEditor().getBuffer()
    buffer.transact () -> action()

# Collect the unique elements of a list, by comparing their values after
# mapping them to something else.
#
# nubVia ((x) -> even x, [1,3,5,2,3,4,5])
#   ==> [1,2]
#
# nubVia :: Ord b => (a -> b) -> [a] -> [a]
exports.nubVia = (projection, array) ->
    cache = {}
    uniques = []
    for entry in array
        projected = projection entry
        if not (cache.hasOwnProperty projected)
            uniques.push entry
            cache[projected] = true
    uniques

# zipWith :: (a -> b -> c) -> [a] -> [b] -> [c]
exports.zipWith = (f, xs, ys) ->
    result = []
    iMax = Math.min(xs.length, ys.length)
    for i in [0 .. iMax - 1]
        result.push(f xs[i], ys[i])
    result

# all :: (a -> Bool, [a]) -> Bool
exports.all = (predicate, list) ->
    for entry in list
        return false if not (predicate entry)
    return true

exports.any = (predicate, list) ->
    for entry in list
        return true if predicate entry
    return false

# allEqual :: Eq a => [a] -> Bool
exports.allEqual = (list) ->
    for element in list
        if element != list[0]
            return false
    return true


# Like groupBy, but groups all elements fitting in a bucket, not just
# consecutive ones.
#
# For `b = Bool`, this is equivalent to `partition`.
#
# >>> groupGloballyBy [1..10] even
# [[1,3,5,7,9], [2,4,6,8,10]
#
# groupGloballyBy :: Ord a => [a] -> (a -> b) -> [[a]]
exports.groupGloballyBy = (list, projection) ->
    grouped = {}
    for item in list
        key = projection item
        grouped[key] ?= []
        grouped[key].push item
    result = []
    for key, value of grouped
        result.push value
    result

# Map and discard nulls afterwards
#
# mapMaybe :: (a -> Maybe b) -> [a] -> [b]
exports.mapMaybe = (f, xs) -> xs.map(f).filter((x) -> x?)
