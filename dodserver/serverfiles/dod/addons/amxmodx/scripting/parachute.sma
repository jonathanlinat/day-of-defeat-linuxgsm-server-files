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
#include <amxmisc>
#include <engine>

new g_parachute_entity[33];

public plugin_precache() {
    precache_model("models/parachute.mdl");
}

public plugin_init() {
    register_plugin(PLUGIN, VERSION, AUTHOR);
}

public client_PreThink(id) {
    if (!is_user_alive(id)) {
        return PLUGIN_CONTINUE;
    }
    
    if (get_user_button(id) & IN_USE) {
        if (!(get_entity_flags(id) & FL_ONGROUND)) {
            new Float:velocity[3];
            entity_get_vector(id, EV_VEC_velocity, velocity);
            
            if (velocity[2] < 0.0) {
                deploy_parachute(id, velocity);
            } else {
                remove_parachute(id);
            }
        } else {
            remove_parachute(id);
        }
    } else if (get_user_oldbutton(id) & IN_USE) {
        remove_parachute(id);
    }
    
    return PLUGIN_CONTINUE;
}

public deploy_parachute(id, Float:velocity[3]) {
    if (g_parachute_entity[id] == 0) {
        g_parachute_entity[id] = create_entity("info_target");
        
        if (g_parachute_entity[id] > 0) {
            entity_set_model(g_parachute_entity[id], "models/parachute.mdl");
            entity_set_int(g_parachute_entity[id], EV_INT_movetype, MOVETYPE_FOLLOW);
            entity_set_edict(g_parachute_entity[id], EV_ENT_aiment, id);
        }
    }
    
    if (g_parachute_entity[id] > 0) {
        velocity[2] = -16.0;
        entity_set_vector(id, EV_VEC_velocity, velocity);
        animate_parachute(g_parachute_entity[id]);
    }
}

public remove_parachute(id) {
    if (g_parachute_entity[id] > 0) {
        remove_entity(g_parachute_entity[id]);
        g_parachute_entity[id] = 0;
    }
}

public animate_parachute(entity) {
    if (entity_get_float(entity, EV_FL_frame) < 0.0 || entity_get_float(entity, EV_FL_frame) > 254.0) {
        if (entity_get_int(entity, EV_INT_sequence) != 1) {
            entity_set_int(entity, EV_INT_sequence, 1);
        }
        entity_set_float(entity, EV_FL_frame, 0.0);
    } else {
        entity_set_float(entity, EV_FL_frame, entity_get_float(entity, EV_FL_frame) + 1.0);
    }
}
