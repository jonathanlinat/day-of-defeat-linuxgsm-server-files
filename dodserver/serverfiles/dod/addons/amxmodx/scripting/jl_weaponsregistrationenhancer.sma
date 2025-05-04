#define PLUGIN "Weapons Registration Enhancer"
#define VERSION "1.0.0"
#define AUTHOR "Jonathan Linat"
#define URL "https://github.com/jonathanlinat"

/*
 * This plugin optimizes hit detection for various weapons in the game, ensuring more reliable and consistent registration of hits. 
 * It dynamically adjusts the likelihood of a hit being registered based on the type of weapon being used, thereby refining the 
 * gameplay experience. The plugin assigns different chances for hits to register based on weapon classes, ranging from melee weapons 
 * to heavy firearms, which aims to balance gameplay and align hit registration more closely with player expectations.
 *
 * It has been successfully tested with AMX Mod X v1.10+.
 */

#include <amxmodx>
#include <dodx>
#include <fakemeta>

new chance[33];

public plugin_init() {
    register_plugin(PLUGIN, VERSION, AUTHOR, URL);

    register_forward(FM_TraceLine, "trace_line", 1);
    register_event("CurWeapon", "current_weapon", "be", "1=1");
}

public current_weapon(id) { 
    if (!is_user_bot(id)) {
        new weapon = read_data(2);
        
        switch(weapon) {
            case DODW_AMERKNIFE, DODW_BRITKNIFE, DODW_ENFIELD_BAYONET, DODW_GARAND_BUTT, DODW_GERKNIFE, DODW_K43_BUTT, DODW_KAR_BAYONET, DODW_SPADE: {
                chance[id] = 0;
            }
            case DODW_ENFIELD, DODW_FOLDING_CARBINE, DODW_GARAND, DODW_K43, DODW_KAR, DODW_M1_CARBINE, DODW_SCOPED_ENFIELD, DODW_SCOPED_KAR, DODW_SPRINGFIELD: {
                chance[id] = 2;
            }
            case DODW_GREASEGUN, DODW_MP40, DODW_STEN, DODW_STG44, DODW_THOMPSON: {
                chance[id] = 4;
            }
            case DODW_COLT, DODW_LUGER, DODW_WEBLEY: {
                chance[id] = 6;
            }
            case DODW_30_CAL, DODW_BAR, DODW_BREN, DODW_FG42, DODW_MG34, DODW_MG42, DODW_SCOPED_FG42: {
                chance[id] = 8;
            }
            default: {
                chance[id] = 0;
            }
        }
    }
}

public trace_line(Float:v1[3], Float:v2[3], noMonsters, id, ptr) {
    if (!is_user_connected(id) || !is_user_alive(id) || is_user_bot(id) || !chance[id]) {
        return FMRES_IGNORED;
    }

    new button = pev(id,pev_button);
    
    if (button & IN_ATTACK) {
        if (random_num(1, chance[id]) == 1) {
            new origin[3];
            new Float:fl_origin[3];

            get_user_origin(id, origin, 3);
            IVecFVec(origin, fl_origin);
            
            set_tr2(ptr, TR_vecEndPos, fl_origin);
            
            new ent;
            new body;
            get_user_aiming(id, ent, body);
            
            if (pev_valid(ent) && is_user_alive(ent)) {
                set_tr2(ptr,TR_flFraction, 0.1);
                set_tr2(ptr,TR_pHit, ent);
                set_tr2(ptr,TR_iHitgroup, body);
            }
        }
    }

    return FMRES_IGNORED
}
