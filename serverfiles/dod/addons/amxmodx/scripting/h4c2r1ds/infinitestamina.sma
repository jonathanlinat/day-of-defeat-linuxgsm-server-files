#include <amxmodx>
#include <dodfun>

#define PLUGIN "Infinite Stamina"
#define VERSION "1.0"
#define AUTHOR "Jonathan Linat (https://github.com/jonathanlinat)"

#define MIN_STAMINA 100
#define MAX_STAMINA 100

public plugin_init() {
    register_plugin(PLUGIN, VERSION, AUTHOR);

    set_task(1.0, "restore_stamina");
}

public restore_stamina() {
    new players[32];
    new nums;

    get_players(players, nums, "a");

    for (new i = 0; i < nums; i++) {
        dod_set_stamina(players[i], STAMINA_SET, MIN_STAMINA, MAX_STAMINA);
    }
}
