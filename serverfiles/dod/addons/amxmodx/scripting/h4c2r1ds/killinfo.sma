#include <amxmodx>
#include <dodx>

#define PLUGIN "Kill Info"
#define VERSION "1.0.0"
#define AUTHOR "Jonathan Linat (https://github.com/jonathanlinat)"

new Float:units_meters = 76.0;
new Float:units_feet = 24.0;
new pKillinfo;
new pUnits;

public plugin_init() {
    register_plugin(PLUGIN, VERSION, AUTHOR);
    register_cvar(PLUGIN, VERSION, FCVAR_SERVER | FCVAR_SPONLY);
    register_statsfwd(XMF_DEATH);
    
    pKillinfo = register_cvar("h4c2r1ds_killinfo", "1");
    pUnits = register_cvar("h4c2r1ds_killinfo_units", "1");
}

public client_death(killer, victim, wpnindex, hitplace, TK) {
    if (get_pcvar_num(pKillinfo) != 1 || is_user_connected(killer) != 1 || is_user_connected(victim) != 1 || is_user_bot(killer) == 1 || killer == victim) {
        return PLUGIN_CONTINUE;
    }
        
    new name[33];
    get_user_name(victim, name, 32);
    
    new weapon[32];
    xmod_get_wpnname(wpnindex, weapon, 31);
    
    new bodypart[128];

    switch(hitplace) {
        case HIT_CHEST: {
            copy(bodypart, charsmax(bodypart), "chest");
        }
        case HIT_HEAD: {
            copy(bodypart, charsmax(bodypart), "head");
        }
        case HIT_LEFTARM: {
            copy(bodypart, charsmax(bodypart), "left arm");
        }
        case HIT_LEFTLEG: {
            copy(bodypart, charsmax(bodypart), "left leg");
        }
        case HIT_RIGHTARM: {
            copy(bodypart, charsmax(bodypart), "right arm");
        }
        case HIT_RIGHTLEG: {
            copy(bodypart, charsmax(bodypart), "right leg");
        }
        case HIT_STOMACH: {
            copy(bodypart, charsmax(bodypart), "stomach");
        }
        case HIT_GENERIC: {
            copy(bodypart, charsmax(bodypart), "all over");
        }
    }
        
    new origin1[3];
    new origin2[3];

    get_user_origin(killer, origin1, 0);
    get_user_origin(victim, origin2, 0);

    new distance = get_distance(origin1, origin2);
    new units[7];

    if (distance <= 1.0) {
        switch(get_pcvar_num(pUnits)) {
            case 1: {
                copy(units, charsmax(units), "foot");
            }
            case 2: {
                copy(units, charsmax(units), "meter");
            }
        }
    } else {
        switch(get_pcvar_num(pUnits)) {
            case 1: {
                copy(units, charsmax(units), "feet");
            }
            case 2: {
                copy(units, charsmax(units), "meters");
            }
        }
    }

    if (get_user_team(killer) == 1) {
        set_hudmessage(0, 200, 0, 0.01, 0.06, 0, 3.0, 5.0, 0.5, 1.5, 1);
    } else {
        set_hudmessage(200, 0, 0, 0.01, 0.06, 0, 3.0, 5.0, 0.5, 1.5, 1);
    }
    
    new message[512] = "killed: %s^ndistance: %.1f %s^nweapon: %s^nhitplace: %s";

    if (TK == 1) {
        add(message, 127, "^n*Team Kill*");
    }
    
    if (get_pcvar_num(pUnits) == 1) {
        show_hudmessage(killer, message, name, distance / units_feet, units, weapon, bodypart);
    } else if (get_pcvar_num(pUnits) == 2) {
        show_hudmessage(killer, message, name, distance / units_meters, units, weapon, bodypart);
    }
    
    return PLUGIN_CONTINUE;
}
