#include <amxmodx>
#include <fakemeta>

#define PLUGIN "Infinite Stamina"
#define VERSION "1.0"
#define AUTHOR "Jonathan Linat (https://github.com/jonathanlinat)"

#define MAX_STAMINA 100.0

public plugin_init() {
    register_plugin(PLUGIN, VERSION, AUTHOR);

    set_task(0.1, "restore_stamina", _, _, _, "b");
}

stock set_dod_stamina(id, Float:value) {
    pev(id, pev_fuser4, value);
}

public restore_stamina() {
    new players[32], nums;
    get_players(players, nums, "a");

    for (new i = 0; i < nums; i++) {
        set_dod_stamina(players[i], MAX_STAMINA);
    }
}
