#define PLUGIN "SVC Bad Preventer"
#define VERSION "1.0.0"
#define AUTHOR "Jonathan Linat"

#include <amxmodx>

/*
 * This plugin aims to prevent the following error:
 * "Error: server failed to transmit file 'AY&SYea'"
 *
 * It has been successfully tested with AMX Mod X v1.10+.
 */

public plugin_init() {
    register_plugin(PLUGIN, VERSION, AUTHOR);

    set_msg_block(49, BLOCK_SET);
}
