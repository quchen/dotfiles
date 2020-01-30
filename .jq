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


# Apply f to composite entities recursively, and to atoms
# Taken from https://github.com/stedolan/jq/blob/master/src/builtin.jq
# Will be part of jq 1.6
# Example: delete all email fields: walk(if type == "object" then del(.email) else . end)
def walk(f):
  . as $in
  | if type == "object" then
      reduce keys_unsorted[] as $key
        ( {}; . + { ($key):  ($in[$key] | walk(f)) } ) | f
  elif type == "array" then map( walk(f) ) | f
  else f
  end;

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
