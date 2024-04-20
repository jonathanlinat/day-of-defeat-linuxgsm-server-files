#define PLUGIN "Simplified Gore"
#define VERSION "1.0.0"
#define AUTHOR "Jonathan Linat"

/*
 * This plugin enhances the visual gore effects by enabling detailed blood effects
 * upon player damage in-game. It is designed to be lightweight and straightforward,
 * offering basic blood effects without the complexities of gib management or multi-mod support.
 *
 * It has been successfully tested with AMX Mod X v1.10+.
 */

#include <amxmodx>
#include <engine>
#include <fakemeta>

#define MAX_PLAYERS 32

#define BLOOD_COLOR_RED 247
#define BLOOD_STREAM_RED 70

new bool:player_in_game[MAX_PLAYERS+1];

public plugin_init() {
    register_plugin(PLUGIN, VERSION, AUTHOR);
    register_event("Damage", "handle_damage", "b");
}

public plugin_precache() {
    precache_model("sprites/blood.spr");
}

public handle_damage() {
    new iVictim = read_data(1);
    new damage = read_data(2);

    if (iVictim > 0 && iVictim <= MAX_PLAYERS && player_in_game[iVictim]) {
        show_blood_effect(iVictim, damage);
    }
}

show_blood_effect(iPlayer, damage) {
    new Float:origin[3];
    pev(iPlayer, pev_origin, origin);

    if (damage > 25) {
        create_blood_stream(origin);
    } else {
        create_blood_drip(origin);
    }
}

create_blood_stream(Float:origin[3]) {
    message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
    write_byte(TE_BLOODSTREAM);
    write_coord(origin[0]);
    write_coord(origin[1]);
    write_coord(origin[2] + 20);
    write_coord(0);
    write_coord(0);
    write_coord(-1);
    write_byte(BLOOD_COLOR_RED);
    write_byte(255);
    message_end();
}

create_blood_drip(Float:origin[3]) {
    message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
    write_byte(TE_WORLDDECAL);
    write_coord(origin[0]);
    write_coord(origin[1]);
    write_coord(origin[2] - 20);
    write_byte(BLOOD_STREAM_RED);
    message_end();
}

public client_putinserver(id) {
    player_in_game[id] = true;
}

public client_disconnected(id) {
    player_in_game[id] = false;
}
