#define PLUGIN "Away From Keyboard Kicker"
#define VERSION "1.0.0"
#define AUTHOR "Jonathan Linat"
#define URL "https://github.com/jonathanlinat"

/*
 * This plugin automatically identifies and kicks players who are away from their keyboard (AFK) 
 * for a specified duration, enhancing game flow and fairness on multiplayer servers. 
 *
 * It has been successfully tested with AMX Mod X v1.10+.
 */

#include <amxmodx>

#define MIN_AFK_TIME 30
#define MAX_AFK_TIME 90
#define MIN_PLAYERS 16
#define WARNING_TIME 15
#define CHECK_FREQ 5

new g_oldangles[33][3];
new g_afktime[33];
new bool:g_spawned[33] = { true, ... };

public plugin_init() {
    register_plugin(PLUGIN, VERSION, AUTHOR, URL);

    set_task(float(CHECK_FREQ), "checkPlayers", _, _, _, "b");
    register_event("ResetHUD", "playerSpawned", "be");
}

public checkPlayers() {
    for (new i = 1; i <= get_maxplayers(); i++) {
        if (is_user_alive(i) && is_user_connected(i) && !is_user_bot(i) && !is_user_hltv(i) && g_spawned[i]) {
            new newangle[3];
            get_user_origin(i, newangle);

            if (newangle[0] == g_oldangles[i][0] && newangle[1] == g_oldangles[i][1] && newangle[2] == g_oldangles[i][2]) {
                g_afktime[i] += CHECK_FREQ;
                check_afktime(i);
            } else {
                g_oldangles[i][0] = newangle[0];
                g_oldangles[i][1] = newangle[1];
                g_oldangles[i][2] = newangle[2];
                g_afktime[i] = 0;
            }
        }
    }

    return PLUGIN_HANDLED;
}

public check_afktime(id) {
    new playersnum = get_playersnum();

    if (playersnum >= MIN_PLAYERS) {
        if (MAX_AFK_TIME - WARNING_TIME <= g_afktime[id] && g_afktime[id] < MAX_AFK_TIME) {
            new timeleft = MAX_AFK_TIME - g_afktime[id];
            client_print(id, print_chat, "You have %i seconds to move or you will be kicked for being AFK.", timeleft);
        } else if (g_afktime[id] >= MAX_AFK_TIME) {
            new name[32];
            get_user_name(id, name, 31);

            client_print(0, print_chat, "%s was kicked for being AFK longer than %i seconds.", name, MAX_AFK_TIME);
            log_amx("%s was kicked for being AFK longer than %i seconds.", name, MAX_AFK_TIME);
            server_cmd("kick #%d ^"You were kicked for being AFK longer than %i seconds.^"", get_user_userid(id), MAX_AFK_TIME);
        }
    }
}

public client_connect(id) {
    g_afktime[id] = 0;

    return PLUGIN_HANDLED;
}

public client_putinserver(id) {
    g_afktime[id] = 0;

    return PLUGIN_HANDLED;
}

public playerSpawned(id) {
    g_spawned[id] = false;

    new sid[1];
    sid[0] = id;

    set_task(0.75, "delayedSpawn", _, sid, 1);

    return PLUGIN_HANDLED;
}

public delayedSpawn(sid[]) {
    get_user_origin(sid[0], g_oldangles[sid[0]]);
    g_spawned[sid[0]] = true;

    return PLUGIN_HANDLED;
}
