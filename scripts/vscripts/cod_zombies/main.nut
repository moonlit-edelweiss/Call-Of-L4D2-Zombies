printl("---- MAP MAIN INIT ----")
printl(::survivor_table);


::replace <- function(str, old_sub, new_sub)
{
    // Why doesn't Squirrel have a built-in string replace?
    local result = "";
    local index = 0;
    local old_len = old_sub.len();

    while (index < str.len()) {
        local found = str.find(old_sub, index);

        // Result if found, otherwise find returns null.
        if (found != null) {
            result += str.slice(index, found) + new_sub;
            index = found + old_len;
        } else {
            // append rest of string if no more instances are found
            result += str.slice(index);
            break;
        }
    }
    return result;
}