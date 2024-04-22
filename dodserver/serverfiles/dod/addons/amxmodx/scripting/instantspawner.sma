#define PLUGIN "Instant Spawner"
#define VERSION "1.0.0"
#define AUTHOR "Jonathan Linat"

/*
 * This plugin completely removes the spawn delay when players die.
 * It allows for a more intense game and works on player death or when they type kill in console.
 *
 * It has been successfully tested with AMX Mod X v1.10+.
 */

#include <amxmodx>
#include <amxmisc>
#include <dodx>
#include <fakemeta>

new spawn_switch[33];
new round_start;
new hud_sent[33];

public plugin_init() {
	register_plugin(PLUGIN, VERSION, AUTHOR);

	register_forward(FM_PlayerPreThink, "func_prethink");
	register_event("HLTV", "func_round_new", "a", "1=0", "2=0");
	register_logevent("func_round_end", 2, "1=Round_End");

	register_event("ResetHUD","func_respawn","be");
}

public func_prethink(id) {
	if (hud_sent[id] && round_start && spawn_switch[id] == 0 && pev(id, pev_health) <= 0 && get_pdata_int(id, 366) != -1 && pev(id, pev_team) != 3) {
		set_task(0.4,"func_spawn", 2200+id);
		spawn_switch[id] = 1;
		set_task(0.5,"func_reset", 2201+id);
	}
}

public func_round_new() {
	round_start = 1;
}

public func_round_end() {
	new i;
	round_start = 0;

	for(i=0;i<32;++i) {
		hud_sent[i] = 0;
	}
}

public func_respawn(id) {
	if (round_start) {
		hud_sent[id] = 1;
	}
}

public func_reset(id) {
	id = id - 2201;
	spawn_switch[id] = 0;
}

public func_spawn(id) {
	id = id - 2200;
	set_pev(id, pev_iuser1, 0);
	set_pdata_int(id, 264, 0);
	dllfunc(DLLFunc_Spawn, id);
}
