#include <amxmisc>
#include <amxmodx>
#include <dodx>
#include <fakemeta>
#include <hamsandwich>

#define PLUGIN "Field Medic"
#define VERSION "1.0.0"
#define AUTHOR "Jonathan Linat"

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
    "player/britmedic.wav",
    "player/usmedic.wav",
    "player/germedic.wav"
};
new g_response[16][] = {
    "Shake It Off", "Apply Some Ice", "Just A Scratch", "Time For A Break",
    "Breathe Deeply", "Count To Ten", "Chin Up, Buttercup", "Laugh It Off",
    "On Your Feet, Soldier", "Magic Potion Time", "Summon The Healing Fairy", "Channel Your Inner Phoenix",
    "Embrace The Pain", "Call For Backup", "Ready For Round Two?", "Patch It Up, Move On"
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
    g_medic_ctrl = register_cvar("amx_fieldmedic_ctrl", "3");
    g_auto_time = register_cvar("amx_fieldmedic_autotime", "1.0");
    g_auto_step = register_cvar("amx_fieldmedic_autostep", "1");
    g_auto_maxhp = register_cvar("amx_fieldmedic_automaxhp", "80");
    g_medic_time = register_cvar("amx_fieldmedic_time", "0.1");
    g_medic_step = register_cvar("amx_fieldmedic_step", "1");
    g_medic_maxhp = register_cvar("amx_fieldmedic_maxhp", "100");
    g_medic_maxspeed = register_cvar("amx_fieldmedic_maxspeed", "30");
    g_maxspeed_enable = register_cvar("amx_fieldmedic_maxspeed_enable", "0");
    g_medic_sound = register_cvar("amx_fieldmedic_sound", "1");
    g_medic_maxcalls = register_cvar("amx_fieldmedic_calls", "2");

    register_plugin(PLUGIN, VERSION, AUTHOR);
    register_concmd("amx_fieldmedic", "control_medic", ADMIN_CFG, "<#|?>");
    register_clcmd("say_team /medic", "cmd_medic", 0, "Call for a Medic");
    register_forward(FM_SetClientMaxspeed, "fwd_maxspeed");

    RegisterHam(Ham_Spawn, "player", "ham_player_spawn", 1);
    RegisterHam(Ham_Killed, "player", "ham_player_death", 1);
    RegisterHam(Ham_TakeDamage, "player", "ham_player_damage", 1);
}

public cmd_medic(id) {
    if (get_pcvar_num(g_medic_ctrl) == 1 || get_pcvar_num(g_medic_ctrl) == 3) {
        if (g_medic_calls[id]) {
            --g_medic_calls[id];

            if (get_pcvar_num(g_medic_sound)) {
                new myteam = get_user_team(id);

                if (myteam != AXIS) {
                    myteam = dod_get_map_info(MI_ALLIES_TEAM) ? BRITISH : ALLIES;
                }

                emit_sound(id, CHAN_VOICE, g_sounds[myteam], VOL_NORM, ATTN_NORM, 0, PITCH_NORM);
            }

            if (pev(id, pev_health) >= get_pcvar_num(g_medic_maxhp)) {
                client_print(id, print_chat, "Medic: Quit Wasting My Time!");

                return PLUGIN_CONTINUE;
            }

            clear_task(id);
            client_print(id, print_chat, "Medic: On my way!");
            set_task(get_pcvar_float(g_medic_time), "heal_player", id, "", 0, "b");
            g_task_set[id] = 2;

            if (get_pcvar_num(g_maxspeed_enable)) {
                set_pev(id, pev_maxspeed, get_pcvar_float(g_medic_maxspeed));
            }
        } else {
            client_print(id, print_chat, pev(id, pev_health) >= get_pcvar_num(g_medic_maxhp) ?
                "Medic: Leave Me Alone!" : "Medic: %s!", g_response[random(16)]);
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

    if (equal(tmpstr, "?")) {
        console_print(id, "^nField Medic Control: amx_fieldmedic #");
        console_print(id, "  0 - Disables amx_fieldmedic plugin");
        console_print(id, "  1 - Play must 'say /medic' to heal - fast");
        console_print(id, "  2 - Player automatically heals - slow");
        console_print(id, "  3 - Enables Mode 1 and Mode 2 simultaneously");
        console_print(id, "amx_fieldmedic is currently set to: %d^n", get_pcvar_num(g_medic_ctrl));

        return PLUGIN_HANDLED;
    }

    new tmpctrl = str_to_num(tmpstr);

    if (tmpctrl < 0 || tmpctrl > 3) {
        console_print(id, "amx_fieldmedic parameter out of range (0 - 3)");

        return PLUGIN_HANDLED;
    }

    set_pcvar_num(g_medic_ctrl, tmpctrl);
    get_user_name(id, tmpstr, 31);
    console_print(id, "amx_fieldmedic control changed to %d", tmpctrl);

    return PLUGIN_HANDLED;
}
