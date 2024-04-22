#define PLUGIN "Scoreboard Hostname Slider"
#define VERSION "1.0.0"
#define AUTHOR "Jonathan Linat"
#define URL "https://github.com/jonathanlinat"

/*
 * This plugin dynamically updates the server's hostname on the scoreboard to create a sliding text effect.
 *
 * It has been successfully tested with AMX Mod X v1.10+.
 */

#include <amxmodx>

new hostname[MAX_NAME_LENGTH*2];
new f_hostname[MAX_NAME_LENGTH*2];
new counter;
new max_chars;
new msg_servername;

public plugin_init() {
    register_plugin(PLUGIN, VERSION, AUTHOR, URL);

    bind_pcvar_string(get_cvar_pointer("hostname"), hostname, charsmax(hostname));
    bind_pcvar_num(create_cvar("hostname_maxchars", "24", FCVAR_NONE, "Maximum displayed characters", true, 1.0, true, 64.0), max_chars);

    msg_servername = get_user_msgid("ServerName");

    set_task(0.25, "update_scoreboard", .flags="b");
}

public update_scoreboard() {
    new total;
    new hostname_len = strlen(hostname);

    if (hostname_len <= max_chars) {
        return PLUGIN_HANDLED;
    }

    if (counter > hostname_len) {
        counter = 0;
    }

    total = formatex(f_hostname, max_chars, "%s%s", counter > hostname_len ? " " : "", hostname[counter]);

    if (total + counter >= max_chars) {
        add(f_hostname, max_chars, fmt(" %s", hostname), max_chars - total);
    }

    message_begin(MSG_BROADCAST, msg_servername);
    write_string(f_hostname);
    message_end();

    counter++;

    return PLUGIN_CONTINUE;
}
