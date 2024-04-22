#define PLUGIN "First-Person Death Camera Setter"
#define VERSION "1.0.0"
#define AUTHOR "Jonathan Linat"
#define URL "https://github.com/jonathanlinat"

/*
 * This plugin adjusts the first-person death camera settings to ensure a standardized spectator view in games.
 * It prevents unusual camera angles upon player death by resetting the camera to default spectator settings. 
 *
 * It has been successfully tested with AMX Mod X v1.10+.
 */

#include <amxmodx>
#include <amxmisc>
#include <fakemeta>
#include <dodx>

new Float:timeDied[33];

public plugin_init() {
    register_plugin(PLUGIN, VERSION, AUTHOR, URL);

    register_event("YouDied", "change_view", "bd");
}

public change_view(id) {
    if (is_user_connected(id) && !is_user_alive(id) && !is_user_bot(id) && (get_gametime() < timeDied[id])) {
        set_pev(id, pev_iuser1, 0);
        set_pev(id, pev_iuser2, 0);
        set_pev(id, pev_iuser3, 0);
    }
}

public client_death(killer, victim, wpnindex, hitplace, TK) {
    if (!is_user_bot(victim)) {
        timeDied[victim] = get_gametime() + 1.0;
    }
}
