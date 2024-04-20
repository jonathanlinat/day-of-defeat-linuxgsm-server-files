#define PLUGIN "Next Map Selection Randomizer"
#define VERSION "1.0.0"
#define AUTHOR "Jonathan Linat"

/*
 * This plugin aims to randomize the next map selection to enhance variety and player
 * engagement by choosing from a specified map cycle list. Configurable options allow server
 * administrators to exclude recently played maps and customize the map cycle file, ensuring
 * players experience a wide range of environments without repetition.
 *
 * It has been successfully tested with AMX Mod X v1.10+.
 */

#include <amxmodx>

#define LOCAL_INFO "lastmaps"
#define EXCLUDE_MAPS_COUNT 5
#define MAP_CYCLE_FILE "mapcycle.txt"

public plugin_init() {
    register_plugin(PLUGIN, VERSION, AUTHOR);
    set_task(1.0, "randomize_nextmap");
}

public randomize_nextmap() {
    new i_File_Size;
    new i_Random;
    new s_Random[2];
    new s_Map[32];
    new i_Temp;
    new i_Cvar_NextMap;
    new s_LastMaps[32];
    new i_CountMaps;
    new bool:b_ExcludeMaps = false;
    
    get_localinfo(LOCAL_INFO, s_LastMaps, charsmax(s_LastMaps));
    i_CountMaps = count_maps(s_LastMaps, 32);

    i_Cvar_NextMap = get_cvar_pointer("amx_nextmap");
    i_File_Size = file_size(MAP_CYCLE_FILE, 1);
    i_Random = random_num(0, i_File_Size - 1);

    num_to_str(i_Random, s_Random, charsmax(s_Random));
    
    if (i_File_Size > EXCLUDE_MAPS_COUNT) {
        b_ExcludeMaps = true;
    }
    
    while (b_ExcludeMaps && strfind(s_LastMaps, s_Random) != -1) {
        i_Random = random_num(0, i_File_Size - 1);
        num_to_str(i_Random, s_Random, charsmax(s_Random));
    }
    
    read_file(MAP_CYCLE_FILE, i_Random, s_Map, charsmax(s_Map), i_Temp);
        
    if (i_CountMaps >= EXCLUDE_MAPS_COUNT) {
        format(s_LastMaps, charsmax(s_LastMaps), "%d ", i_Random);
    } else {
        if (i_CountMaps) {
            format(s_LastMaps, charsmax(s_LastMaps), "%s%d ", s_LastMaps, i_Random);
        } else {
            format(s_LastMaps, charsmax(s_LastMaps), "%d ", i_Random);
        }
    }
        
    set_localinfo(LOCAL_INFO, s_LastMaps);
    set_pcvar_string(i_Cvar_NextMap, s_Map);
}

public count_maps(s_String[], i_Char) {
    new i_Count = 0, i = 0, i_Temp;
    
    while ((i_Temp = s_String[i++])) {
        if (i_Temp == i_Char) {
            i_Count++;
        }
    }
    
    return i_Count;
}
