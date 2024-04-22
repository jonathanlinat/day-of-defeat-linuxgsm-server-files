#define PLUGIN "Parachute Provider"
#define VERSION "1.0.0"
#define AUTHOR "Jonathan Linat"
#define URL "https://github.com/jonathanlinat"

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

new para_ent[33];

public plugin_init() {
    register_plugin(PLUGIN, VERSION, AUTHOR, URL);

    register_event("ResetHUD", "event_resethud", "be");
}

public plugin_precache() {
    precache_model("models/parachute.mdl");
}

public client_connect(id) {
    if (para_ent[id] > 0) {
        remove_entity(para_ent[id]);
    }

    para_ent[id] = 0;
}

public event_resethud(id) {
    if (para_ent[id] > 0) {
        remove_entity(para_ent[id]);
    }

    para_ent[id] = 0;
}

public client_PreThink(id) {
    if (!is_user_alive(id)) {
        return PLUGIN_CONTINUE;
    }

    if (get_user_button(id) & IN_USE) {
        if (!(get_entity_flags(id) & FL_ONGROUND)) {
            new Float:velocity[3];
            entity_get_vector(id, EV_VEC_velocity, velocity);

            if (velocity[2] < 0) {
                if (para_ent[id] == 0) {
                    para_ent[id] = create_entity("info_target");

                    if (para_ent[id] > 0) {
                        entity_set_model(para_ent[id], "models/parachute.mdl");
                        entity_set_int(para_ent[id], EV_INT_movetype, MOVETYPE_FOLLOW);
                        entity_set_edict(para_ent[id], EV_ENT_aiment, id);
                    }
                }

                if (para_ent[id] > 0) {
                    velocity[2] = (velocity[2] + 40.0 < -100) ? velocity[2] + 40.0 : -100.0;
                    entity_set_vector(id, EV_VEC_velocity, velocity);

                    if (entity_get_float(para_ent[id], EV_FL_frame) < 0.0 || entity_get_float(para_ent[id], EV_FL_frame) > 254.0) {
                        if (entity_get_int(para_ent[id], EV_INT_sequence) != 1) {
                            entity_set_int(para_ent[id], EV_INT_sequence, 1);
                        }

                        entity_set_float(para_ent[id], EV_FL_frame, 0.0);
                    } else {
                        entity_set_float(para_ent[id], EV_FL_frame, entity_get_float(para_ent[id], EV_FL_frame) + 1.0);
                    }
                }
            } else {
                if (para_ent[id] > 0) {
                    remove_entity(para_ent[id]);
                    para_ent[id] = 0;
                }
            }
        } else {
            if (para_ent[id] > 0) {
                remove_entity(para_ent[id]);
                para_ent[id] = 0;
            }
        }
    } else if (get_user_oldbutton(id) & IN_USE) {
        if (para_ent[id] > 0) {
            remove_entity(para_ent[id]);
            para_ent[id] = 0;
        }
    }

    return PLUGIN_CONTINUE;
}
