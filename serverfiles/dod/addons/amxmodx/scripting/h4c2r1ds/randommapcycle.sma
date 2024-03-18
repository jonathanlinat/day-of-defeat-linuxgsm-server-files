#include <amxmodx>

#define PLUGIN "Random Map Cycle"
#define VERSION "1.0.0"
#define AUTHOR "Jonathan Linat (https://github.com/jonathanlinat)"

#define LOCAL_INFO "lastmaps"

new g_Cvar_MapCycleFile;
new g_Cvar_ExcludeMaps;

public plugin_init() {
    register_plugin(PLUGIN, VERSION, AUTHOR);
    
    g_Cvar_ExcludeMaps = register_cvar("h4c2r1ds_randommapcycle_exclude", "5");
    g_Cvar_MapCycleFile = register_cvar("h4c2r1ds_randommapcycle_file", "mapcycle.txt");
    
    set_task(1.0, "randomize_nextmap");
}

public randomize_nextmap() {
    new i_File_Size;
    new i_Random;
    new s_Random[2];
    new s_File[128];
    new s_Map[32];
    new i_Temp;
    new i_Cvar_NextMap;
    new s_LastMaps[32];
    new i_CountMaps;
    new i_ExcludeMaps;
    new bool:b_ExcludeMaps = false;
    
    get_localinfo(LOCAL_INFO, s_LastMaps, charsmax(s_LastMaps));

    i_ExcludeMaps = get_pcvar_num(g_Cvar_ExcludeMaps);
    i_CountMaps = count_maps(s_LastMaps, 32);

    get_pcvar_string(g_Cvar_MapCycleFile, s_File, charsmax(s_File));

    i_Cvar_NextMap = get_cvar_pointer("amx_nextmap");
    i_File_Size = file_size(s_File, 1);
    i_Random = random_num(0, i_File_Size - 1);

    num_to_str(i_Random, s_Random, charsmax(s_Random));
    
    if (i_File_Size > i_ExcludeMaps) {
        b_ExcludeMaps = true;
    }
    
    while (b_ExcludeMaps && strfind(s_LastMaps, s_Random) != -1) {
        i_Random = random_num(0, i_File_Size - 1);

        num_to_str(i_Random, s_Random, charsmax(s_Random));
    }
    
    read_file(s_File, i_Random, s_Map, charsmax(s_Map), i_Temp);
        
    if (i_CountMaps >= i_ExcludeMaps) {
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
