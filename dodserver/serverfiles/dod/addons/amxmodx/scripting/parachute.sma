#define PLUGIN "Parachute"
#define VERSION "1.0.0"
#define AUTHOR "Jonathan Linat"

/*
 * This plugin provides a parachute to players when they are falling from a height, allowing for
 * a slow and safe descent. Players can activate the parachute by pressing the 'use' key while
 * in mid-air. It contributes to a fun and dynamic gameplay experience in the server.
 *
 * It has been successfully tested with AMX Mod X v1.10+.
 */

#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <fun>

#define MAX_AUTHID_LENGTH 64
#define MAX_IP_LENGTH 16

new const Float:DEFAULT_GRAVITY = 1.0;
new const Float:PARACHUTE_GRAVITY = 0.1;

new g_model;
new g_cvarFallSpeed;

public plugin_precache() {
    g_model = precache_model("models/parachute.mdl");
}

public plugin_init() {
    register_plugin(PLUGIN, VERSION, AUTHOR);

    g_cvarFallSpeed = register_cvar("amx_parachute_fallspeed", "50.0");
}

public client_PreThink(id) {
    if (!is_user_connected(id) || !is_user_alive(id)) {
        return PLUGIN_CONTINUE;
    }

    new Float:fallspeed = -get_pcvar_float(g_cvarFallSpeed);
    new button = get_user_button(id), oldbutton = get_user_oldbutton(id), flags = get_entity_flags(id);

    if (flags & FL_ONGROUND) {
        if (get_user_gravity(id) != DEFAULT_GRAVITY) {
            set_user_gravity(id, DEFAULT_GRAVITY);
        }
        return PLUGIN_CONTINUE;
    }

    new Float:velocity[3];
    entity_get_vector(id, EV_VEC_velocity, velocity);

    if ((button & IN_USE)) {
        set_user_gravity(id, PARACHUTE_GRAVITY);
        velocity[2] = (velocity[2] > fallspeed) ? fallspeed : velocity[2];

        entity_set_vector(id, EV_VEC_velocity, velocity);
        create_parachute_effect(id);
    } else if (oldbutton & IN_USE && get_user_gravity(id) != DEFAULT_GRAVITY) {
        set_user_gravity(id, DEFAULT_GRAVITY);
    }
    
    return PLUGIN_CONTINUE;
}

public create_parachute_effect(id) {
    message_begin(MSG_PVS, SVC_TEMPENTITY, { 0, 0, 0 }, 0);
    write_byte(TE_PLAYERATTACHMENT);
    write_byte(id);
    write_coord(-MAX_AUTHID_LENGTH);
    write_short(g_model);
    write_short(MAX_IP_LENGTH);
    message_end();
}
