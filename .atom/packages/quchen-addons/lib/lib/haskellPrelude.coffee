# Run an action as an atomical transaction. Useful to execute a composed
# action that should be undone in a single step.
#
# atomically :: (() -> IO ()) -> () -> IO ()
atomically = (action) -> () ->
    buffer = atom.workspace.getActiveTextEditor().getBuffer()
    buffer.transact () -> action()

# maybe :: b -> (a -> b) -> Maybe a -> b
maybe = (nothing, just, value) ->
    if value?
        just value
    else
        nothing

# even, odd :: Integer -> Bool
even = (i) -> i % 2 != 0
odd  = (i) -> i % 2 == 0

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

# any :: (a -> Bool, [a]) -> Bool
any = (predicate, list) ->
    for entry in list
        return true if predicate entry
    return false

# elem :: (a -> Bool) -> [a] -> Bool
elem = (needle, haystack) ->
    for x in haystack
        return true if x == needle
    return false

# Like groupBy, but groups all elements fitting in a bucket, not just
# consecutive ones.
#
# For `b = Bool`, this is equivalent to `Haskell's partition`.
#
# >>> partition [1..10] even
# [[1,3,5,7,9], [2,4,6,8,10]
#
# partition :: Ord a => [a] -> (a -> b) -> [[a]]
partition = (list, projection) ->
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
mapMaybe = (f, xs) -> catMaybes xs.map(f)

# Concatenate all Justs (i.e. non-null values)
#
# catMaybes :: [Maybe a] -> [a]
catMaybes = (xs) -> xs.filter((x) -> x?)

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

# flip :: (a -> b -> c) -> (b -> a -> c)
flip = (f, x, y) -> f y, x

enumFromTo = (from, to) ->
    if from > to
        return []
    else
        return [from..to]

module.exports =
    atomically: atomically
    nubVia:     nubVia
    head:       head
    reverse:    reverse
    zipWith:    zipWith
    all:        all
    any:        any
    elem:       elem
    partition:  partition
    mapMaybe:   mapMaybe
    catMaybes:  catMaybes
    compose:    compose
    foldl:      foldl
    enumFromTo: enumFromTo
