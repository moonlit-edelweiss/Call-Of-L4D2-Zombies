printl("---- MAP ROUNDS INIT ----")

spawning <- true;

function BeginFirstRound()
{
	local modescript = ::g_ModeScript
	::round <- 1
	printl("First round started")
	modescript.UpdateDirector(::round)
}

function BeginRound()
{
	local entity = null
	local modescript = ::g_ModeScript
	::round <- ::round + 1
	printl("Round " + round + " started")
	modescript.UpdateDirector(::round)

	foreach ( entry in ::survivor_table )
	{
		entity = Ent(entry.entname)
		if (!IsPlayerABot(entity))
		{
			entity.ReviveByDefib()
			entity.ReviveFromIncap()
		}

	}
}

function RoundCheckTimer()
{
    if ( Director.GetCommonInfectedCount() == 0 && spawning == false )
    {
        BeginRound()
        spawning <- true
    }
    else if ( Director.GetCommonInfectedCount() != 0 && spawning == true )
    {
        spawning <- false
    }
}