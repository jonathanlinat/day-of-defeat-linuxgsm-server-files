#define PLUGIN "Stamina Unlimiter"
#define VERSION "1.0.0"
#define AUTHOR "Jonathan Linat"
#define URL "https://github.com/jonathanlinat"

/*
 * This plugin eliminates stamina limitations for players.
 *
 * It has been successfully tested with AMX Mod X v1.10+.
 */

#include <amxmodx>
#include <amxmisc>
#include <dodfun>
 
public plugin_init() {
    register_plugin(PLUGIN, VERSION, AUTHOR, URL);

    register_event("ResetHUD", "give_stamina", "be");
    register_clcmd("fullupdate", "clcmd_fullupdate");
}
 
public give_stamina(id) {
    dod_set_stamina(id, STAMINA_SET, 100, 100);

    return PLUGIN_HANDLED;
}
 
public clcmd_fullupdate() {
    return PLUGIN_HANDLED;
}
