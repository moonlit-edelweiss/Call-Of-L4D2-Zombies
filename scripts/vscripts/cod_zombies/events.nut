printl("---- MAP EVENTS INIT ----");

// Add points on infected killed
function OnGameEvent_infected_death( params )
{
	local attacker = params.attacker
	local is_headshot = params.headshot

	local survivor = ::GetSurvivorIndex(attacker)
	if ( survivor == false ) { return }

	if (is_headshot == 0)
	{
		if (!::double_points)
		{
			::UpdateScore(10, attacker)
		}
		else
		{
			::UpdateScore(20, attacker)
		}
	}
	else
	{
		if (!::double_points)
		{
			::UpdateScore(100, attacker)
		}
		else
		{
			::UpdateScore(200, attacker)
		}
	}
}

// Player damage script.
// Takes 45 damage per hit unless has jug (reduces to 15)
function OnGameEvent_player_hurt_concise( params )
{

	// indicates how much damage should be done
	local damage_threshold = 45
	local time = {}
	LocalTime(time)

	local victim = params.userid
	local survivor = ::GetSurvivorIndex(victim)
	local attacker = PlayerInstanceFromIndex(params.attackerentid)

	local damage_to_do =  damage_threshold - params.dmg_health

	if (attacker != null)
	{
		// if survivor self-damage or friendly fire, don't
		if ( attacker.GetZombieType() == 9 ) { return }
	}

	if ( survivor != false )
	{
		::survivor_table[survivor].time_since_hurt = ::TimeToSeconds(time)
	}

	if ( survivor == false || damage_to_do <= 21 ) { return } // if not a survivor, or damage taken is above threshold
	if ( ::survivor_table[survivor].perks.find("Juggernog") != null ) { damage_threshold = 15 } // still does at minimum 20 damage on expert

	damage_to_do =  damage_threshold - params.dmg_health
	if (damage_to_do < 0) { damage_to_do = 0 }
	local victim_entindex = GetPlayerFromUserID(victim).GetEntityIndex()

	if ( params.attackerentid != victim_entindex )
	{	// process damage. It took a lot for this "fix" to work, and it no longer crashes the game. Don't ask me how this works; I don't know either.
		GetPlayerFromUserID(victim).TakeDamage(damage_to_do, 0, null);
	}
}


// damage dealt to the infected
function OnGameEvent_infected_hurt( params )
{

	local victim = Ent(params.entityid)
	if ( victim.GetHealth() - params.amount <= 0 )
	{
		if (RandomInt(0, 100) < 2)
		{
			local powerup = Ent(powerup_ents[RandomInt(0, powerup_ents.len() - 1)])
			powerup.SetOrigin(victim.GetOrigin() + Vector(0, 0, 50));
			local powerupscope = powerup.GetScriptScope();
			powerupscope.Activate();
		}
	}

	local attacker = params.attacker
	local survivor = ::GetSurvivorIndex(attacker)
	if ( survivor == false ) { return }

	// deal additional damage if the attacker has double tap in their perk list
	if ( ::survivor_table[survivor].perks.find("Double Tap") != null )
	{
		local actual = params.amount
		// if CurrentWeaponPAP actual = actual * 2
		local x = Ent(params.entityid)
		if (x != false) { x.TakeDamage(actual, 0, x) }
	}
	if (::instakill)
	{
		local x = Ent(params.entityid)
		if (x != false) { x.TakeDamage(9999999999, 0, x) } // very high damage value ok
	}

	if (!::double_points)
	{
		UpdateScore(10, attacker);
	}
	else
	{
		UpdateScore(20, attacker);
	}
}

function OnGameEvent_player_incapacitated( params )
{
	local victim = params.userid
	local survivor = ::GetSurvivorIndex(victim)
	if ( survivor == false ) { return }

	::survivor_table[survivor].perks = [];
}