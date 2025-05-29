printl(" ----- COD ZOMBIES MODE INIT ----- ")

::power <- true; // defaults to true for Nacht Der Untoten
::is_singleplayer <- false;

::survivor_table <- [
	// NICK
	{
		entname = "!nick",
		score = 500,
		playername = "",
		perks = ["Juggernog", "Speed Cola"],
		perkmessage = "",
		overridemessage = "", // Overrides perk display if overriden is true
		overriden = false
	},

	// COACH
	{
		entname = "!coach",
		score = 500,
		playername = "",
		perks = ["Double Tap", "Stamin-Up"],
		perkmessage = "",
		overridemessage = "",
		overriden = false
	},

	// ROCHELLE
	{
		entname = "!rochelle",
		score = 500,
		playername = "",
		perks = ["Widow's Wine", "PHD Floppa"],
		perkmessage = "",
		overridemessage = "",
		overriden = false
	},

	// ELLIS
	{
		entname = "!ellis",
		score = 500,
		playername = "",
		perks = ["RAAAAAAAAAAAAAH"],
		perkmessage = "",
		overridemessage = "",
		overriden = false
	}
]

::ForceResetHUD <- function(player)
{
	if (!player) {return}
	local idx = ::GetSurvivorIndex(player);

	printl("Forcefully resetting HUD for player(s)");

	::survivor_table[idx].overriden <- false
}

::OverrideHUD <- function(string, player)
{
	if (!player) { return }
	local idx = ::GetSurvivorIndex(player);

	printl("Setting HUD for index " + idx);

	if (string != false)
	{
		printl("Enabling hud")
		::survivor_table[idx].overridemessage <- string
		::survivor_table[idx].overriden <- true
	}
	else
	{
		printl("Disabling hud")
		::survivor_table[idx].overriden <- false
	}
}

::GetSurvivorIndex <- function(player)
{

	local name = ""
	if (type(player) == "instance")
	{
		name = player.GetPlayerName();
	}
	else if (type(player) == "string")
	{
		name = player;
	}
	else
	{
		printl("MUTATIONSCRIPT: GetSurvivorIndex failed.");
		return false;
	}

	for (local i = 0; i < ::survivor_table.len(); i++)
	{
		if ( ::survivor_table[i].playername == name )
		{
			return i
		}
	}
	return false;
}

function SetUpPlayerTable()
{
	// extremely inefficient for testing I guess
	// probably need to re-do this later.

	local entity = null;
	foreach (entry in ::survivor_table)
	{
		entity = Ent(entry.entname)
		if ( entity != null ) {
			entry.playername = entity.GetPlayerName()
		}
	}
}

// leftover from test version of the mutationscript. Is this even relevant?
::GetPlayerScore <- function(player)
{
	local idx = ::GetSurvivorIndex(player);
	if ( idx == false ) { return };

	return ( ::survivor_table[idx].score );
}

::GetPlayerPerkmessage <- function(player)
{
	local idx = ::GetSurvivorIndex(player);
	if ( idx == false ) { return };

	return ( ::survivor_table[idx].overridemessage )
}

::GetCurrentRound <- function()
{
	return 0; // for now
}

function SetupModeHUD()
{
	ModeHUD <-
	{
		Fields =
		{
			perks =
			{
				slot = HUD_TICKER,
				name = "perks",
				datafunc = function() {
					//return ( ::GetPlayerPerkmessage(Convars.GetStr("name")) );
					local self = Convars.GetStr("name");
					local idx = ::GetSurvivorIndex(self)
					if (idx == false) { return "" };

					if ( ::survivor_table[idx].overriden == true )
					{
						return ( ::survivor_table[idx].overridemessage )
					}
					else
					{
						return ( ::survivor_table[idx].perkmessage )
					}
				}
			},
			score =
			{
				slot = HUD_FAR_LEFT,
				name = "score",
				datafunc = function() {
					return ( ::GetPlayerScore(Convars.GetStr("name")) );
				}
			}
			round =
			{
				slot = HUD_FAR_RIGHT,
				name = "round",
				datafunc = function() {
					return ( ::GetCurrentRound() );
				}
			}
		}
	}
	// load the modehud table
	HUDSetLayout( ModeHUD );
}

function UpdateScore(value, player)
{
	local idx = ::GetSurvivorIndex(player);
	if ( idx == false )
		{
			printl("MUTATIONSCRIPT: Tried to update score of invalid player?");
			return
		};

	::survivor_table[idx].score <- value;
}

function UpdatePerks(perks = [], player = "")
{
	local idx = ::GetSurvivorIndex(player);
	if ( idx == false ) { return };

	local currentmessage = ""

	if ( perks.len() > 0 )
	{
		currentmessage += "Perks: "
		foreach (perk in perks)
		{
			currentmessage += perk + " | ";
		}

		if ( currentmessage.len() > 0 )
		{
			// forgot what this is even for
			// carried over from test version
			currentmessage = currentmessage.slice(0, currentmessage.len() - 3)
		}

		::survivor_table[idx].perkmessage <- currentmessage
	} else {
		::survivor_table[idx].perkmessage <- ""
	}
}

function Update()
{
	SetUpPlayerTable();
	foreach (entry in ::survivor_table)
	{
		if ( entry.playername != "" )
		{
			// update everything
			UpdatePerks(entry.perks, entry.playername);
		}
	}

	SetupModeHUD()
}