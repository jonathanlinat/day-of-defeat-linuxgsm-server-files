#define PLUGIN "Low Health Effect Enhancer"
#define VERSION "1.0.0"
#define AUTHOR "Jonathan Linat"

/*
 * This plugin enhances the gaming experience by introducing a health-dependent visual and audio cue
 * for players. When a player's health falls below a defined threshold, a breathing sound effect is
 * triggered, and their screen momentarily fades to a specific color, indicating low health. This feature
 * aims to increase the urgency and realism of gameplay.
 *
 * It has been successfully tested with AMX Mod X v1.10+.
 */

#include <amxmodx>

new dmgcvar;
new lowdmgfade;
new bool:low_dmg[33] = false;
new color;
new r;
new g;
new b;

public plugin_precache() { 
	precache_sound("effects/breathe.wav"); 
} 

public plugin_init() { 
	register_plugin(PLUGIN, VERSION, AUTHOR); 
	
	dmgcvar = register_cvar("amx_lowhealtheffectenhancer_dmg", "26"); 
	lowdmgfade = register_cvar("amx_lowhealtheffectenhancer_dmg_sfade", "1");
	color = register_cvar("amx_lowhealtheffectenhancer_color", "210 0 0");
	
	register_event("Damage", "event_damage", "be");
	register_event("DeathMsg", "event_deathmsg", "a");
	register_event("HLTV", "event_new_round", "a", "1=0", "2=0");

	new colors[16], red[4], green[4], blue[4];
	get_pcvar_string(color, colors, sizeof colors - 1);
	parse(colors, red, 3, green, 3, blue, 3);
	r = str_to_num(red);
	g = str_to_num(green);
	b = str_to_num(blue);
}

public event_damage(id) {
	if (!is_user_connected(id) || is_user_bot(id)) {
		return PLUGIN_HANDLED;
  }
	
	if (get_user_health(id) < get_pcvar_num(dmgcvar)) {
		if (low_dmg[id] == true) {
			return PLUGIN_HANDLED;
		} else {
			set_task(1.7, "lowdmg", id, _, _, "b");
			low_dmg[id] = true;
		}
	}

	return PLUGIN_CONTINUE;
}

public event_deathmsg() {
	new id = read_data(2);
	
	if (!is_user_connected(id) || is_user_bot(id) || low_dmg[id] == false) {
		return PLUGIN_HANDLED;
  }
	
	remove_task(id);
	low_dmg[id] = false;
	
	return PLUGIN_CONTINUE;
}

public event_new_round() {
	new pnum, id, players[32];
	
	get_players(players, pnum, "c");
	
	for (new i = 0; i < pnum; i++) {
		id = players[i];
		
		if (is_user_connected(id) && low_dmg[id] == true) {
			remove_task(id);
			low_dmg[id] = false;
		}
	}  
}

public lowdmg(id) {
	if (get_user_health(id) > get_pcvar_num(dmgcvar)) {
		remove_task(id);
		low_dmg[id] = false;

		return;
	}

	client_cmd(id, "spk sound/effects/breathe.wav");
    
	if (get_pcvar_num(lowdmgfade)) {
		message_begin(MSG_ONE, get_user_msgid("ScreenFade"), { 0, 0, 0 }, id);
		write_short(10<<12);
		write_short(10<<16);
		write_short(1<<0);
		write_byte(r);
		write_byte(g);
		write_byte(b);
		write_byte(210);
		message_end();
	}
}
