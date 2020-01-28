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
