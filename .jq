def schema:
    if type == "object" then
        map_values(schema)
    elif type == "array" then
        if length == 0 then
            "[]"
        else
            map(schema) | unique
        end
    else
        type
    end
    ;

def filter(p): [ .[] | select(p) ];

def collect_all(f): [.. | f];

def all_keys: [.. | objects | keys | .[]] | unique;

def enumerate: [keys, .] | transpose | map({"index": .[0], "value": .[1]});

def time_object:
    {
        year: .[0],
        month: (.[1] + 1), # month is 0-based here, for whatever reason
        day: .[2],
        hour: .[3],
        minute: .[4],
        second: .[5],
        dayOfWeek: .[6],
        dayOfYear: .[7]
    };

# Useful for converting external things to JSON using a simple interchange format,
#
# foo/bar: hello
# foo/qux: world
#
# ==>
# {
#     "foo": {
#         "bar": "hello",
#         "qux": "world"
#     }
# }
def interpret_flattened_object:
    def splitOnPrefix(separator):
        index(separator) as $i
        | (separator | length) as $sepLength
        | ($i+$sepLength) as $j
        | .[:$i] as $before
        | .[$j:] as $after
        | if ($before | length == 0) or ($after | length == 0) then empty else . end
        | { before: $before, after: $after }
        ;

    def expandPaths(sep):
        (.before | split(sep)) as $path
        | .after as $value
        | {} | setpath($path; $value)
        ;

    def merge_objects:
        reduce .[] as $e ({}; . * $e)
        ;

    split("\n") | map(splitOnPrefix(": ") | expandPaths("/")) | merge_objects
    ;

# Histogram function from the Jq Cookbook
# https://github.com/stedolan/jq/wiki/Cookbook

# bag(stream) uses a two-level dictionary: .[type][tostring]
# So given a bag, $b, to recover a count for an entity, $e, use
# $e | $b[type][tostring]
def bag(stream):
  reduce stream as $x ({}; .[$x|type][$x|tostring] += 1 );

def bag: bag(.[]);

# Produce a stream of the distinct elements in the given stream
def nub(stream):
    bag(stream)
    | to_entries[]
    | .key as $type
    | .value
    | to_entries[]
    | if $type == "string" then .key else .key|fromjson end ;

def nub: nub(.[]);

def bag_to_entries:
    [ to_entries[]
    | .key as $type
    | .value
    | to_entries[]
    | {key: (if $type == "string" then .key else .key|fromjson end), value} ] ;

# Emit an array of [value, frequency] pairs, sorted by frequency
def histogram(stream):
  bag(stream)
  | bag_to_entries
  | sort_by( [.value, .key])
  | map( {value: .key, count: .value} ) ;
