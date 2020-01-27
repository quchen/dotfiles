def schema:
    if type == "object" then
        map_values(schema)
    elif type == "array" then
        if length == 0 then
            "[]"
        else
            map(schema) | unifier
        end
    else
        type
    end
    ;
