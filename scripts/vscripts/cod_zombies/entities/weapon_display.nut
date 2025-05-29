local weapon_directory =
[
	"weapon_sniper_scout",
	"weapon_smg_silenced"
]

// Variables
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
local isweapon = false;
local currentplayer = null;

// Functions

function CheckWeapon(player)
{
	// check if player's currently held weapon is the same as the wallbuy
	local invtable = {}
	local primary = null

	GetInvTable(player, invtable)

	if ( "slot0" in invtable )
	{
		primary = invtable.slot0
		primary = primary.GetClassname()
		if ( internal_name == primary )
		{
			return true;
		}
		else
		{
			return false;
		}
	}
	else
	{
		return false;
	}
}

// Main code
// Init

if ( name.len() != 2 )
{
	printl("INCORRECTLY SET UP: " name)
	throw "Entity " + name + " does not have correct number of strings"
}

// get internal name of item

internal_name <- "weapon_" + name[0].tolower();
internal_name = ::replace(internal_name, " ", "_");
printl(internal_name);
if ( weapon_directory.find(internal_name) != null )
{
	isweapon = true;
	printl(internal_name + "located weapon at: " + weapon_directory.find(internal_name))
	printl("Is a weapon");
}

// Think script

function think()
{
	local modescript = ::g_ModeScript;
	for ( local i = 0; i < ::survivor_table.len(); i++ )
	{
		currentplayer = Ent(::survivor_table[i].entname)
		if ( self.IsTouching(currentplayer) )
		{
			printl("Is touching " + currentplayer.GetPlayerName());
			if (isweapon && CheckWeapon(currentplayer) )
			{
				::OverrideHUD("Buy ammo for " + (name[1].tointeger() / 2), currentplayer)
				override[i] = true;
			}
			else if (isweapon && !CheckWeapon(currentplayer) )
			{
				::OverrideHUD("Buy " + name[0] + " for " + name[1], currentplayer )
				override[i] = true;
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

	return THINKTIME
}