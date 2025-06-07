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

// Functions

function handleMysteryBoxState(player, state) {
	local idx = ::GetSurvivorIndex(player)
    switch(state) {
        case "idle":
            ::OverrideHUD("Buy " + name[0] + " for " + name[1], player)
            return true;
        case "rolling":
            ::OverrideHUD(false, player)
            return false;
        case "displaying":
            ::OverrideHUD("Use for Weapon", player)
            return true;
    }
}


// Main code
// init

if ( name.len() != 2 )
{
	printl("INCORRECTLY SET UP: " name)
	throw "Entity " + name + " does not have correct number of strings"
}


// Think script

function think()
{
	for ( local i = 0; i < ::survivor_table.len(); i++ )
	{
		currentplayer = Ent(::survivor_table[i].entname)
		if ( self.IsTouching(currentplayer) )
		{
            override[i] = handleMysteryBoxState(currentplayer, ::box_state[0])
		}
        else
        {
            if (override[i] == true)
            {
                ::OverrideHUD(false, currentplayer)
                override[i] = false
            }
        }
	}

    return THINKTIME
}