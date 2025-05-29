printl("---- MAP INTERACTABLES INIT ----")

doors <-
[
	{
		name = "Box Room", // doesn't actually do anything, safe to remove
		door_physical_brush = "boxroomdoor", // what the player actually can see
		door_ents_to_remove = ["boxroom_door_button", "Box Room.750"], // removes things such as buttons and triggers
		door_nav_blockers = ["boxroom_blocker"], // nav blockers to turn off (locked areas always start on)
		price = 500
	}
]

perks <-
[
	{name = "Juggernog", price = 2500},
	{name = "Quick Revive", price = 1500},
	{name = "Double Tap", price = 2000},
	{name = "Speed Cola", price = 3000}
]

weapons <-
[
	{ name = "Sniper Scout", internal_name = "sniper_scout", price = 500, attached_entity = "scout_wallbuy"},
	{name = "SMG Silenced", internal_name = "smg_silenced", price = 500}
]

function BuyDoor(doorid)
{
	local brush = Ent(doors[doorid].door_physical_brush)
	local nearby_player = null

	local player = Entities.FindByClassnameNearest("player", brush.GetOrigin(), 200 )
	local idx = ::GetSurvivorIndex(player)

	if ( ::survivor_table[idx].score >= doors[doorid].price )
	{
		::survivor_table[idx].score <- ::survivor_table[idx].score - doors[doorid].price
		printl("Buying door " + doors[doorid].name);
		foreach (entity in doors[doorid].door_ents_to_remove)
		{
			Ent(entity).Kill();
		}

		// force disable HUD for players in range
		while ( nearby_player = Entities.FindByClassnameWithin(nearby_player, "player", brush.GetOrigin(), 150) )
		{
			::ForceResetHUD(nearby_player)
		}

		brush.Kill();

		foreach (blocker in doors[doorid].door_nav_blockers)
		{
			EntFire(blocker, "UnblockNav", null, 0, null);
		}
	}

}

function BuyWeapon(weaponid)
{
	local weapon = weapons[weaponid]

	local invtable = {}
	local player = Entities.FindByClassnameNearest("player", Ent(weapon.attached_entity).GetOrigin(), 200 )
	local idx = ::GetSurvivorIndex(player)
	local primary = null

	GetInvTable(player, invtable)

	if ( "slot0" in invtable )
	{
		primary = invtable.slot0
		primary = primary.GetClassname()
	}

	if ( ::survivor_table[idx].score >= weapon.price && primary != ("weapon_" + weapon.internal_name) )
	{
		::survivor_table[idx].score <- ::survivor_table[idx].score - weapon.price
		player.GiveItem(weapon.internal_name)
	}
	else if ( primary == "weapon_" + weapon.internal_name && ::survivor_table[idx].score > weapon.price / 2 )
	{
		// improve this later to have increased price for packed weapons
		player.GiveAmmo(500)
		::survivor_table[idx].score <- ::survivor_table[idx].score - weapon.price / 2
	}
}

function BuyMysteryBox()
{
	// Price: 950

}