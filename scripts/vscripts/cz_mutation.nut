printl(" ----- COD ZOMBIES MODE INIT ----- ")

::round <- 0
::power <- true; // defaults to true for Nacht Der Untoten
::is_singleplayer <- false;
valid_players <- 4
spawning <- true;
::double_points <- false;
::instakill <- false;

::instakill_time <- {}
::double_points_time <- {}

horde_size <- 7
zombie_speed <- 90
global_time <- {};
LocalTime(global_time);
LocalTime(::instakill_time);
LocalTime(::double_points_time)

// ported primarily directly from One Last Thrill's older versions.
DirectorOptions <-
{
    GasCansOnBacks = false // I swear, I look away and this becomes true again without me realising.
    JockeyLimit = 0
    SpitterLimit = 50
    ChargerLimit = 50
    HunterLimit = 50
    SmokerLimit = 50
    BoomerLimit = 50

    MaxSpecials = 50
    ZombieSpawnRange = 1000
    TotalSpecials = -1
    TotalSpitter = 0
    TotalCharger = 0
    TotalHunter = 0
    TotalSmoker = 0
    TotalBoomer = 0

	WanderingZombieDensityModifier = 0
	IntensityRelaxAllowWanderersThreshold = 0
    ProhibitBosses = true
	ZombieDontClear = true
	NearAcquireRange = 999999
	FarAcquireRange = 99999999
	FarAcquireTime = 0.1
	NearAcquireTime = 0.1

    MobSpawnMinTime = -1
    MobSpawnMaxTime = -1

	MegaMobSize = 10
    MobMinSize = 0
    MobMaxSize = 0

    SustainPeakMinTime = 99999
	SustainPeakMaxTime = 99999
	IntensityRelaxThreshold = 0
	RelaxMinInterval = 9999999
	RelaxMaxInterval = 9999999
	RelaxMaxFlowTravel = 9999999

    cm_AggressiveSpecials = true
    cm_AllowSurvivorRescue = false
    cm_AllowPillConversion = false
    cm_TempHealthOnly = false
    cm_NoSurvivorBots = false // I tried, and now we do the hacky method.
	cm_WanderingZombieDensityModifier = 0
    ZombieTankHealth = 1000
	PreferredMobDirection = SPAWN_NO_PREFERENCE

    function CycleLimits( horde_size )
    {
        //MobMinSize = horde_size
        //MobMaxSize = horde_size + 10
		MegaMobSize = horde_size
    }
}

::survivor_table <- [
	// NICK
	{
		entname = "!nick",
		score = 500,
		playername = "",
		perks = [],
		perkmessage = "",
		overridemessage = "", // Overrides perk display if overriden is true
		overriden = false,
		time_since_hurt = 0
	},

	// COACH
	{
		entname = "!coach",
		score = 500,
		playername = "",
		perks = [],
		perkmessage = "",
		overridemessage = "",
		overriden = false,
		time_since_hurt = 0
	},

	// ROCHELLE
	{
		entname = "!rochelle",
		score = 500,
		playername = "",
		perks = [],
		perkmessage = "",
		overridemessage = "",
		overriden = false,
		time_since_hurt = 0
	},

	// ELLIS
	{
		entname = "!ellis",
		score = 500,
		playername = "",
		perks = [],
		perkmessage = "",
		overridemessage = "",
		overriden = false,
		time_since_hurt = 0
	}
]

::box_state <-
[
	"idle",
	"idle",
	"idle"
]

::ForceResetHUD <- function(player)
{
	if (!player) {return}
	local idx = ::GetSurvivorIndex(player);

	::survivor_table[idx].overriden <- false
}

::OverrideHUD <- function(string, player)
{
	if (!player) { return }
	local idx = ::GetSurvivorIndex(player);

	if (string != false)
	{
		::survivor_table[idx].overridemessage <- string
		::survivor_table[idx].overriden <- true
	}
	else
	{
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
	else if (type(player) == "integer")
	{
		name = GetPlayerFromUserID(player);
		if (name == null) { return false }
		name = name.GetPlayerName()
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

::TimeToSeconds <- function(t)
{
    return (t.hour * 3600) + (t.minute * 60) + (t.second)
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

// this is the most redundant function imagineable. I'm sorry.
::GetCurrentRound <- function()
{
	return ::round;
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

::UpdateScore <- function(value, player)
{
	local idx = ::GetSurvivorIndex(player);
	if ( idx == false )
		{
			printl("MUTATIONSCRIPT: Tried to update score of invalid player?");
			printl("INVALID PLAYER: " + player);
			return
		};

	::survivor_table[idx].score += value;
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

// All this does is kill bots when the mission starts.
// If it weren't for my shitty coding skills, I wouldn't have to do this.
// But I'll keep it in, because it's way funnier.
function SuperHackyBotCheckThatImNotProudAbout(entry)
{
	local entity = Ent(entry.entname)
	if ( IsPlayerABot(entity) && entity.GetHealth() >= 1)
	{
		entity.SetReviveCount(3);
		entity.TakeDamage(1000, 0, null); // DIE
	}
}

// ported directly from old version
function UpdateDirector(new_round)
{
	::round = new_round

	local director = Ent("director")

	local speed_increment = 2.5
	local new_speed = zombie_speed + speed_increment
	zombie_speed <- (new_speed > 130) ? 130 : new_speed // cap z_speed at 130

	Convars.SetValue("z_speed", zombie_speed)
	Convars.SetValue("z_health", (16 * ::round))
	DirectorOptions.CycleLimits(horde_size * ::round)

	EntFire("director", "ScriptedPanicEvent", "panic_wave", 0.1, null)
}

// UPDATE LOOP BELOW

function Update()
{
	local entity = null;
	SetUpPlayerTable();
	foreach (entry in ::survivor_table)
	{
		if ( entry.playername != "" )
		{
			entity = Ent(entry.entname)
			// update everything
			SuperHackyBotCheckThatImNotProudAbout(entry);
			UpdatePerks(entry.perks, entry.playername);
			if ( (entry.time_since_hurt + 3 < ::TimeToSeconds(global_time)) && entity.GetHealth() < 100)
			{
				entity.SetHealth(entity.GetHealth() + 5 )
			}
			else if (entity.GetHealth() > 100)
			{
				entity.SetHealth(100)
			}
		}
	}

	if ( ::TimeToSeconds(instakill_time) + 30 < ::TimeToSeconds(global_time) && ::instakill == true )
	{
		Say(GetListenServerHost(), "[GAME] Instakill expired", true)
		printl("instakill disabled")
		::instakill <- false;
	}

	if ( ::TimeToSeconds(::double_points_time) + 30 < ::TimeToSeconds(global_time) && ::double_points == true )
	{
		Say(GetListenServerHost(), "[GAME] Double Points Expired", true)
		printl("doublepoints disabled")
		::double_points <- false;
	}
	LocalTime(global_time)
	SetupModeHUD()
}

// ---- ANYTHING BELOW THIS ----
// For testing purposes only. move to the event script later.

