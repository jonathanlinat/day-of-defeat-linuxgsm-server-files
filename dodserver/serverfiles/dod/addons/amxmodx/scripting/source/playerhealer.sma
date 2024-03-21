#define PLUGIN "Player Healer"
#define VERSION "1.0.0"
#define AUTHOR "Jonathan Linat"

/*
 * This plugin enables automatic healing for players in-game, allowing server
 * administrators to configure healing parameters * such as maximum health points
 * for auto-healing, medic call limits, and healing sounds. The plugin supports
 * both manual * medic calls by players and automatic healing when certain conditions
 * are met. It enhances gameplay by providing players * with timely health recovery,
 * ensuring a dynamic and sustained action. The healing responses and conditions can be 
 * customized through server cvars, making it adaptable to different game types and
 * server settings.
 *
 * It has been successfully tested with AMX Mod X v1.10+.
 */

#include <amxmisc>
#include <amxmodx>
#include <dodx>
#include <fakemeta>
#include <hamsandwich>

#define BRITISH 0

new g_medic_ctrl;
new g_auto_time;
new g_auto_step;
new g_auto_maxhp;
new g_medic_time;
new g_medic_step;
new g_medic_maxhp;
new g_medic_maxspeed;
new g_maxspeed_enable;
new g_medic_maxcalls;
new g_medic_sound;
new g_sounds[3][] = {
    "player/britmedic.wav", "player/usmedic.wav", "player/germedic.wav"
};
new g_negative_response[32][] = {
    "You're at full strength, soldier!", "You don't need me, you're topped off!",
    "All healthy here, move along!", "Your vitals are perfect, no need for me.",
    "You're in peak condition already!", "Save the call for when you're hurt.",
    "You're as fit as a fiddle!", "You must mistake me for someone else; you're full on health!",
    "No scratches on you, warrior!", "Why call? You're in perfect shape!",
    "You seem more than capable as is.", "Not a scratch on you, no medic needed.",
    "I see no wounds to tend here.", "You're already battle-ready!",
    "Looks like you've been avoiding trouble!", "No ailments detected, you're clear.",
    "You're fighting fit, save the medkits for later.",
    "You're wasting my time, you're already healed!", "Full health, go back to the fight!",
    "Your health bar disagrees with your call.", "I'm not needed here, you're at full capacity.",
    "Looking strong and healthy, soldier!", "No attention needed here, you're at 100%.",
    "I don't fix what isn't broken.", "Try not to get hit next time, just for practice.",
    "You're just showing off your health now.", "Looks like you're in better shape than me!",
    "You're all set, back to your post.", "Full health? Someone's been careful!",
    "I can't make you any healthier than this!", "You're in top-notch condition, keep it that way.",
    "Perfect health! Keep it up, soldier!"
}
new g_healing_response[32][] = {
    "Heading to your position!", "Hold tight, I'm coming!", "Hang in there, help is on the way!",
    "Assistance incoming!", "Stay strong, I'm en route!", "I've got you, don't move!", "Healing is inbound!",
    "Keep your head down, I'm on my way!", "Relief is just moments away!", "Approaching your location!",
    "You're my next stop!", "Just a moment, I'll be there soon!", "Stay put, I'm heading to you!",
    "Your medic is on the move!", "Brace yourself, healing en route!", "Don't worry, I'm closing in!",
    "Your call has been heard, I'm on my way!", "Be there in a jiffy!", "You won't be alone for long!",
    "Support is on its way!", "I'm sprinting to you now!", "Hold on, relief is coming!",
    "I'm just around the corner!", "Healing support incoming!", "Rushing to your aid!", "You called, I'm answering!",
    "Making my way to you now!", "Assistance is moments away!", "You're my priority, on my way!",
    "I'm your lifeline, coming through!", "No soldier left behind, I'm coming!", "Ready for a patch-up, heading over!"
};
new g_medic_calls[33];
new g_task_set[33] = {0, ...};
new Float:g_p_speed[33];

public plugin_precache() {
    precache_sound("player/britmedic.wav");
    precache_sound("player/usmedic.wav");
    precache_sound("player/germedic.wav");
}

public plugin_init() {
    g_medic_ctrl = register_cvar("amx_playerhealer_ctrl", "3");
    g_auto_time = register_cvar("amx_playerhealer_autotime", "1.0");
    g_auto_step = register_cvar("amx_playerhealer_autostep", "1");
    g_auto_maxhp = register_cvar("amx_playerhealer_automaxhp", "80");
    g_medic_time = register_cvar("amx_playerhealer_time", "0.1");
    g_medic_step = register_cvar("amx_playerhealer_step", "1");
    g_medic_maxhp = register_cvar("amx_playerhealer_maxhp", "100");
    g_medic_maxspeed = register_cvar("amx_playerhealer_maxspeed", "30");
    g_maxspeed_enable = register_cvar("amx_playerhealer_maxspeed_enable", "0");
    g_medic_sound = register_cvar("amx_playerhealer_sound", "1");
    g_medic_maxcalls = register_cvar("amx_playerhealer_calls", "2");

    register_plugin(PLUGIN, VERSION, AUTHOR);
    register_concmd("amx_playerhealer", "control_medic", ADMIN_CFG, "<#|?>");
    register_clcmd("say_team /medic", "cmd_medic", 0, "Call for a Medic");
    register_forward(FM_SetClientMaxspeed, "fwd_maxspeed");

    RegisterHam(Ham_Spawn, "player", "ham_player_spawn", 1);
    RegisterHam(Ham_Killed, "player", "ham_player_death", 1);
    RegisterHam(Ham_TakeDamage, "player", "ham_player_damage", 1);
}

public cmd_medic(id) {
    if (get_pcvar_num(g_medic_ctrl) == 1 || get_pcvar_num(g_medic_ctrl) == 3) {
        if (!is_user_alive(id) || !g_medic_calls[id]) {
            return PLUGIN_CONTINUE;
        }

        if (pev(id, pev_health) >= get_pcvar_num(g_medic_maxhp)) {
            client_print(id, print_chat, "Medic: %s", g_negative_response[random(32)]);

            return PLUGIN_CONTINUE;
        }

        --g_medic_calls[id];

        if (get_pcvar_num(g_medic_sound)) {
            new myteam = get_user_team(id);

            myteam = (myteam == AXIS) ? AXIS : (dod_get_map_info(MI_ALLIES_TEAM) ? BRITISH : ALLIES);

            emit_sound(id, CHAN_VOICE, g_sounds[myteam], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
        }

        clear_task(id);
        client_print(id, print_chat, "Medic: %s", g_healing_response[random(32)]);
        set_task(get_pcvar_float(g_medic_time), "heal_player", id, "", 0, "b");
        g_task_set[id] = 2;

        if (get_pcvar_num(g_maxspeed_enable)) {
            set_pev(id, pev_maxspeed, get_pcvar_float(g_medic_maxspeed));
        }
    }

    return PLUGIN_CONTINUE;
}

public ham_player_death(victim, attacker, gib) {
    clear_task(victim);
}

public ham_player_damage(victim, inflictor, attacker, Float:damage, dmgtype) {
    if (!g_task_set[victim] && get_pcvar_num(g_medic_ctrl) > 1 && pev(victim, pev_health) > 0) {
        if (pev(victim, pev_health) < get_pcvar_num(g_auto_maxhp)) {
            set_task(get_pcvar_float(g_auto_time), "heal_player", victim, "", 0, "b");
            g_task_set[victim] = 1;
        }
    }
}

public heal_player(id) {
    new p_health = pev(id, pev_health);

    switch(g_task_set[id]) {
        case 1: {
            if (p_health >= get_pcvar_num(g_auto_maxhp)) {
                clear_task(id);
                return;
            }

            p_health = clamp(p_health + get_pcvar_num(g_auto_step), 0, get_pcvar_num(g_auto_maxhp));
        }
        case 2: {
            if (p_health >= get_pcvar_num(g_medic_maxhp)) {
                clear_task(id);
                return;
            }

            p_health = clamp(p_health + get_pcvar_num(g_medic_step), 0, get_pcvar_num(g_medic_maxhp));
        }
    }

    set_pev(id, pev_health, float(p_health));
}

public fwd_maxspeed(id, Float:speed) {
    g_p_speed[id] = speed;

    if (g_task_set[id] == 2 && get_pcvar_num(g_maxspeed_enable)) {
        return FMRES_SUPERCEDE;
    }

    return FMRES_IGNORED;
}  

public ham_player_spawn(id) {
    if (is_user_alive(id)) {
        clear_task(id);
        g_medic_calls[id] = get_pcvar_num(g_medic_maxcalls);
    }
}

public client_disconnected(id) {
    clear_task(id);
}

public client_putinserver(id) {
    clear_task(id);
}

public clear_task(id) {
    remove_task(id);
    g_task_set[id] = 0;
    set_pev(id, pev_maxspeed, g_p_speed[id]);
}

public control_medic(id, lvl, cid) {
    if (!cmd_access(id, lvl, cid, 2)) {
        return PLUGIN_HANDLED;
    }
    
    new tmpstr[32];
    read_argv(1, tmpstr, 31);
    trim(tmpstr);

    new tmpctrl = str_to_num(tmpstr);

    if (tmpctrl < 0 || tmpctrl > 3) {
        return PLUGIN_HANDLED;
    }

    set_pcvar_num(g_medic_ctrl, tmpctrl);
    get_user_name(id, tmpstr, 31);

    return PLUGIN_HANDLED;
}
