printl("---- MAP INTERACTABLES INIT ----")

doors <-
[
	{
		name = "Box Room", // doesn't actually do anything, safe to remove
		door_physical_brush = "boxroomdoor", // what the player actually can see
		door_ents_to_remove = ["boxroom_door_button", "Box Room.1000"], // removes things such as buttons and triggers
		door_nav_blockers = ["boxroom_blocker"], // nav blockers to turn off (locked areas always start on)
		price = 1000
	},
	{
		name = "Upstairs",
		door_physical_brush = "upstairs_couch_ent",
		door_ents_to_remove = ["upstairs_couch_button", "Upstairs Couch.1000"],
		door_nav_blockers = ["upstairs_blocker"],
		price = 1000
	},
	{
		name = "Upstairs_alt",
		door_physical_brush = "boxroom_upstairs_blocker",
		door_ents_to_remove = ["upstairs_second_button", "Upstairs Barricade.1000"],
		door_nav_blockers = ["upstairs_blocker", "boxroom_blocker"],
		price = 1000
	}
]

perks <-
[
	{name = "Juggernog", price = 2500, attached_entity = "juggernog_button"},
	{name = "Double Tap", price = 2000, attached_entity = "doubletap_button"},
	{name = "Quick Revive", price = 2000},
	{name = "Speed Cola", price = 3000}
]

weapons <-
[
	{ name = "SMG", internal_name = "smg", price = 750, attached_entity = "scout_wallbuy"},
	{ name = "Pump Shotgun", internal_name = "pumpshotgun", price = 1500, attached_entity = "shotgun_wallbuy" },
	{ name = "Sniper AWP", internal_name = "sniper_awp", price = 2550, attached_entity = "huntingrifle_wallbuy" }
	{ name = "Hunting Rifle", internal_name = "hunting_rifle", price = 1350, attached_entity = "huntingrifle_wallbuy" }

]

function BuyDoor(doorid)
{
	local brush = Ent(doors[doorid].door_physical_brush)
	local nearby_player = null

	local player = activator //Entities.FindByClassnameNearest("player", brush.GetOrigin(), 200 )
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
	local player = activator //Entities.FindByClassnameNearest("player", Ent(weapon.attached_entity).GetOrigin(), 200 )
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
		// no fuck off
		player.GiveAmmo(500)
		::survivor_table[idx].score <- ::survivor_table[idx].score - weapon.price / 2
	}
}

function BuyMysteryBox()
{
	// Price: 950
	// weapon database: weapon_database
	local roll_display = Ent("MysteryBoxWeaponDisplay")
	local weapon_list = {} // unused?
	local player = activator //Entities.FindByClassnameNearest("player", Ent("MysteryBoxWeaponDisplay").GetOrigin(), 300)
	local idx = ::GetSurvivorIndex(player)
	local invtable = {}
	if ( ::box_state[0] == "idle" && ::survivor_table[idx].score >= 950 )
	{
		::survivor_table[idx].score <- ::survivor_table[idx].score - 950
		GetInvTable(player, invtable)
		// cycle through and remove all entries in the player's inventory from weapon database
		::box_state[0] = "rolling"
		local box = Ent("MysteryBoxWeaponSwapper") // potential redundancy
		DoEntFire("MysteryBoxMusic", "PlaySound", "", 0, null, null)
		DoEntFire("MysteryBoxWeaponSwapper", "Enable", "", 0, null, null)
	}
	else if ( ::box_state[0] == "displaying" )
	{
		player.GiveItem(box_weapon_to_give.name)
		box_cycle <- 0
		::box_state[0] = "idle"
		DoEntFire("MysteryBoxWeaponSwapper", "Disable", "", 0, null, null)
		roll_display.SetOrigin(box_original_pos)
	}
}

function BuyPerk(perkid)
{
	local perk = perks[perkid]
	local player = activator // I COULD HAVE FUCKING DONE THIS, THIS ENTIRE TIME??????
	local idx = ::GetSurvivorIndex(player)

	if ( ::survivor_table[idx].perks.find(perk.name) == null )
	{
		if ( ::survivor_table[idx].score >= perk.price)
		{
			::survivor_table[idx].score <- ::survivor_table[idx].score - perk.price
			::survivor_table[idx].perks.append(perk.name);
		}
	}
}


box_cycle <- 0 // temporary value
box_weapon_to_give <- null
box_original_pos <- null
z <- null;

function MysteryBoxTimer(boxid)
{
	// boxid is unused right now
	// Re-fires every second that the current box is active
	local roll_display = Ent("MysteryBoxWeaponDisplay")

	if (box_original_pos == null)
	{
		box_original_pos <- roll_display.GetOrigin();
	}

	if (box_cycle < 10 && ::box_state[boxid] == "rolling")
	{
		z <- weapon_database[RandomInt(0, weapon_database.len() - 1)]
		roll_display.SetModel(z.model)
		box_cycle <- box_cycle + 1
		roll_display.SetOrigin(roll_display.GetOrigin() + Vector(0, 0, 2))
	}
	else if (box_cycle >= 10 && ::box_state[boxid] == "rolling")
	{
		DoEntFire("MysteryBoxMusic", "StopSound", "", 0, null, null)
		::box_state[boxid] = "displaying"
		box_cycle <- 0
		box_weapon_to_give <- z
		roll_display.SetModel(z.model)
	}
	else if ( ::box_state[boxid] == "displaying" && box_cycle < 20 )
	{
		roll_display.SetOrigin(roll_display.GetOrigin() + Vector(0, 0, -1))
		box_cycle <- box_cycle + 1
		roll_display.SetModel(z.model)
	}
	else if ( ::box_state[boxid] == "displaying" && box_cycle >= 20 )
	{
		box_cycle <- 0
		::box_state[boxid] = "idle"
		DoEntFire("MysteryBoxWeaponSwapper", "Disable", "", 0, null, null)
		roll_display.SetOrigin(box_original_pos)
	}
}