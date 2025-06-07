printl("---- MAP MAIN INIT ----")

// variables / constants to be accessed everywhere

barrels_exploded <- 0
barrels_exist <- 3

powerup_ents <-
[
    "instakill",
    "max_ammo",
    "double_points",
    "kaboom"
]

const POWERUP_CHANCE = 5

weapon_database <- [
    { name = "weapon_smg_silenced", model = "models/w_models/weapons/w_smg_a.mdl" },
    { name = "weapon_shotgun_chrome", model = "models/w_models/weapons/w_pumpshotgun_a.mdl" },
    { name = "weapon_rifle_desert", model = "models/w_models/weapons/w_desert_rifle.mdl"},
    { name = "weapon_pumpshotgun", model = "models/w_models/weapons/w_shotgun.mdl"},
    { name = "weapon_shotgun_spas", model = "models/w_models/weapons/w_shotgun_spas.mdl"},
    { name = "weapon_smg_mp5", model = "models/w_models/weapons/w_smg_mp5.mdl"},
    { name = "weapon_smg", model = "models/w_models/weapons/w_smg_uzi.mdl"},
    { name = "weapon_sniper_awp", model = "models/w_models/weapons/w_sniper_awp.mdl"},
    { name = "weapon_rifle_ak47", model = "models/w_models/weapons/w_rifle_ak47.mdl"},
    { name = "weapon_pistol_magnum", model = "models/w_models/weapons/w_desert_eagle.mdl"},
    { name = "weapon_autoshotgun", model = "models/w_models/weapons/w_autoshot_m4super.mdl" },
    { name = "weapon_hunting_rifle", model = "models/w_models/weapons/w_sniper_mini14.mdl"},
    { name = "weapon_sniper_scout", model = "models/w_models/weapons/w_sniper_scout.mdl"},
    { name = "weapon_rifle_sg552", model = "models/w_models/weapons/w_rifle_sg552.mdl"},
    { name = "weapon_rifle_m60", model = "models/w_models/weapons/w_m60.mdl"},
    { name = "weapon_upgradepack_explosive", model = "models/w_models/weapons/w_eq_explosive_ammopack.mdl"},
    { name = "weapon_grenade_launcher", model = "models/w_models/weapons/w_grenade_launcher.mdl"}
]

// functions

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

function EasterEggTick()
{
    printl("Easter egg song ticked :D")
    printl(barrels_exploded);
    barrels_exploded <- barrels_exploded + 1
    if (barrels_exploded >= barrels_exist)
    {
        printl("woaw!")
        DoEntFire("easter_egg_song", "PlaySound", "", 0, null, null)
    }
}