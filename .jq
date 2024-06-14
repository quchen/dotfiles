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

def filter(p): map(select(p));

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
        dayOfWeekName:
            (.[6] as $i
             | ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
             | .[$i-1]),
        dayOfYear: .[7]
    };

def splitOnFirst(separator):
    split(separator) | { before: .[0], after: .[1:] | join(separator) };

# Remove whitspace around input
def ltrim: gsub("^\\s+"; "");
def rtrim: gsub("\\s+$"; "");
def trim: ltrim | rtrim;

# Useful for converting external things to JSON using a simple interchange format,
#
# {
#     "foo/bar": "hello",
#     "foo/qux": "world"
# }
# ===>
# expand_object
# ===>
# {
#     "foo": {
#         "bar": "hello",
#         "qux": "world"
#     }
# }
#
# Does not support arrays, and decodes everything to objects, because of the following ambiguity:
#
# {
#     "foo/0": "hello",
#     "foo/1": "world"
# }
#
# This could either be
#
# { "foo": ["hello", "world"] }
#
# or
#
# {
#     "foo": {
#         "0": "hello",
#         "1": "world"
#     }
# }
def expand_object(sep_path_elements):
    def build_object:
        reduce .[] as $entry ({}; setpath($entry | .path; $entry | .value))
        ;

    .
    | to_entries
    | map(
        { path: .key | split(sep_path_elements)
        , value: .value
        })
    | build_object
    ;
def expand_object: expand_object("/");

# Inverse of expand_object when there are no arrays.
def collapse_object(sep_path_elements):
    . as $input
    | [paths]
    | map(
        { path: join(sep_path_elements), value: (. as $dot | $input | getpath($dot)) }
        | if .value | type | . != "array" and . != "object"
            then .
            else empty
            end
        | { key: .path, value }
        )
    | from_entries
    ;
def collapse_object: collapse_object("/");

# Sorted nub
def snub(by):
    group_by(by) | map(.[0])
    ;

def snub: snub(.);

def shist(by):
    group_by(by) | map({element: .[0], count: length}) | sort_by(.count);

def shist: shist(.);

# Histogram function from the Jq Cookbook
# https://github.com/stedolan/jq/wiki/Cookbook

# bag(stream) uses a two-level dictionary: .[type][tostring]
# So given a bag, $b, to recover a count for an entity, $e, use
# $e | $b[type][tostring]
def bag(stream): reduce stream as $x ({}; .[$x|type][$x|tostring] += 1);

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
    | map( {value: .key, count: .value} ) ;

def histogram: histogram(.[]);

def csv2json:
    def parse_csv(sep):
        split("\n") | map(select(length > 0) | split(sep) | map(trim))
        ;

    parse_csv(",")
    | .[0] as $header
    | .[1:] | map([$header, .] | transpose | map({key: .[0], value: .[1]}) | from_entries)
    ;

# Rip out JSON contained in a string
def subjson:
    capture("(?<jsonCandidate>\\{.+\\})") | .jsonCandidate | fromjson
    ;

def hms:
      (. / 60/60 | floor) as $h
    | (. % (60*60) / 60 | floor) as $m
    | (. % 60 | round) as $s
    | "\($h)h \($m)m \($s)s"
    ;
