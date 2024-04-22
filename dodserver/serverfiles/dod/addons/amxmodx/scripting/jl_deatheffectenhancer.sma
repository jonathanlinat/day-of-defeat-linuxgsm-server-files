#define PLUGIN "Death Effect Enhancer"
#define VERSION "1.0.0"
#define AUTHOR "Jonathan Linat"
#define URL "https://github.com/jonathanlinat"

/*
 * This plugin significantly enriches the visual and gameplay experience upon a player's death in-game.
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

    register_statsfwd(XMF_DEATH);
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

    set_task(0.01, "fade_to_red", victim);
}

public fade_to_red(victim) {
    message_begin(MSG_ONE, get_user_msgid("ScreenFade"), { 0, 0, 0 }, victim);
    write_short(1000);
    write_short(500);
    write_short(0x000F);
    write_byte(255);
    write_byte(0);
    write_byte(0);
    write_byte(255)
    message_end();
}
