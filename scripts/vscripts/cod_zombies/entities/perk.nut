local override =
[
	false,
	false,
	false,
	false
]

const THINKTIME = 0.5
local NAMESTRING = self.GetName()
local name = split(NAMESTRING, ".")
local currentplayer = null;

internal_name <- "";

// Functions

// redeclared here because of errors
// redundancy?
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

function CheckPerks(player)
{
	if ( player.perks.find(internal_name) != null )
	{
		return true;
	}
	else
	{
		return false;
	}
}

// Main code
// init

if ( name.len() != 2 )
{
	printl("INCORRECTLY SET UP: " name)
	throw "Entity " + name + " does not have correct number of strings"
}

internal_name <- name[0]


function think()
{
	local modescript = ::g_ModeScript;
	for ( local i = 0; i < ::survivor_table.len(); i++ )
	{
		currentplayer = Ent(::survivor_table[i].entname)
		if ( self.IsTouching(currentplayer) )
		{
			if ( !CheckPerks(::survivor_table[i]) )
			{
				::OverrideHUD("Buy " + name[0] + " for " + name[1], currentplayer)
				override[i] = true;
			}
			else
			{
				::OverrideHUD(false, currentplayer)
				override[i] = false;
			}
		}
		else
		{
			if ( override[i] == true )
			{
				::OverrideHUD(false, currentplayer);
				override[i] = false;
			}
		}
	}

	return THINKTIME;
}