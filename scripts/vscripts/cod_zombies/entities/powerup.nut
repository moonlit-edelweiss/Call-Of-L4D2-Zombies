// I honestly lost the old version of the powerup scripts, so excuse any apparent "laziness" in here.

local powerups =
[
	"instakill",
	"max_ammo",
	"double_points",
	"kaboom"
]

// variables

local currentplayer = null;
const THINKTIME = 0.5
const LIFESPAN = 140
local NAMESTRING = self.GetName()
local spawn_pos = self.GetOrigin()
local active = false;
local alive_time = 0;

function Disable()
{
	alive_time = 0
	active = false;
	self.SetOrigin(spawn_pos);
}

function MaxAmmo()
{
	Say(GetListenServerHost(), "[GAME] Max Ammo!", true)
	foreach (entry in ::survivor_table)
	{
		Ent(entry.entname).GiveAmmo(5000);
	}
	Disable();
}

function Instakill()
{
	Say(GetListenServerHost(), "[GAME] Instakill!", true)
	::instakill <- true;
	LocalTime(::instakill_time)
	Disable();
}

function DoublePoints()
{
	Say(GetListenServerHost(), "[GAME] Double Points!", true)
	::double_points <- true;
	LocalTime(::double_points_time)
	Disable();
}

function Kaboom()
{
	Say(GetListenServerHost(), "[GAME] Ka-boom!", true)
	foreach (entry in ::survivor_table)
	{
		UpdateScore(400, Ent(entry.entname))
	}
	local infected = null;
	while ((infected = Entities.FindByClassname(infected, "infected")) != null)
	{
		infected.Kill();
	}
	Disable();
}

function Activate()
{
	active = true;
	alive_time = 0;
}


function think()
{
	for ( local i = 0; i < ::survivor_table.len(); i++ )
	{
		currentplayer = Ent(::survivor_table[i].entname)
		if ( self.IsTouching(currentplayer) )
		{
			switch (NAMESTRING)
			{
				case "instakill":
					Instakill();
					break;
				case "max_ammo":
					MaxAmmo();
					break;
				case "double_points":
					DoublePoints();
					break;
				case "kaboom":
					Kaboom();
					break;
			}
		}
	}
	if (active)
	{
		if (LIFESPAN < alive_time)
		{
			Disable();
		}
		else
		{
			alive_time += 1
		}
	}
}