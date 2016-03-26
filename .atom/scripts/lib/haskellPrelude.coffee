# Run an action as an atomical transaction. Useful to execute a composed
# action that should be undone in a single step.
#
# atomically :: (() -> IO ()) -> () -> IO ()
atomically = (action) -> () ->
    buffer = atom.workspace.getActiveTextEditor().getBuffer()
    buffer.transact () -> action()

# Collect the unique elements of a list, by comparing their values after
# mapping them to something else.
#
# nubVia ((x) -> even x, [1,3,5,2,3,4,5])
#   ==> [1,2]
#
# nubVia :: Ord b => (a -> b) -> [a] -> [a]
nubVia = (projection, array) ->
    cache = {}
    uniques = []
    for entry in array
        projected = projection entry
        if not (cache.hasOwnProperty projected)
            uniques.push entry
            cache[projected] = true
    uniques

# head :: [a] -> Maybe a
head = (xs) -> xs[0]

# reverse :: [a] -> [a]
reverse = (xs) ->
    reversed = []
    for x in xs
        reversed.unshift x
    reversed

# zipWith :: (a -> b -> c) -> [a] -> [b] -> [c]
zipWith = (f, xs, ys) ->
    result = []
    iMax = Math.min(xs.length, ys.length)
    for i in [0 .. iMax - 1]
        result.push(f xs[i], ys[i])
    result

# all :: (a -> Bool, [a]) -> Bool
all = (predicate, list) ->
    for entry in list
        return false if not (predicate entry)
    return true

any = (predicate, list) ->
    for entry in list
        return true if predicate entry
    return false

# Like groupBy, but groups all elements fitting in a bucket, not just
# consecutive ones.
#
# For `b = Bool`, this is equivalent to `partition`.
#
# >>> groupGloballyBy [1..10] even
# [[1,3,5,7,9], [2,4,6,8,10]
#
# groupGloballyBy :: Ord a => [a] -> (a -> b) -> [[a]]
groupGloballyBy = (list, projection) ->
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
mapMaybe = (f, xs) -> xs.map(f).filter((x) -> x?)

# compose [f,g,h] x = f (g (h x))
# Like `foldr (.) id` in Haskell, but the functions don't have to be
# `a -> a -> a -> a` but can be `a -> b -> c -> d` due to JS' weak typing.
compose = (fs) -> (x) ->
    for f in reverse fs
        x = f x
    x

# foldl :: (b -> a -> b) -> b -> [a] -> b
foldl = (f, z, xs) ->
    for x in xs
        z = f z, x
    z

exports.atomically      = atomically
exports.nubVia          = nubVia
exports.head            = head
exports.reverse         = reverse
exports.zipWith         = zipWith
exports.all             = all
exports.any             = any
exports.groupGloballyBy = groupGloballyBy
exports.mapMaybe        = mapMaybe
exports.compose         = compose
exports.foldl           = foldl
