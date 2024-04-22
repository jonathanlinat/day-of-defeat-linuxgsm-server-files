#define PLUGIN "Advanced Machine Gun Deployer"
#define VERSION "1.0.0"
#define AUTHOR "Jonathan Linat"
#define URL "https://github.com/jonathanlinat"

/*
 * This plugin enhances the deployment mechanism for machine guns in-game.
 *
 * It has been successfully tested with AMX Mod X v1.10+.
 */

#include <amxmodx>
#include <amxmisc>
#include <dodx>
#include <fakemeta>

#pragma semicolon 1

#define TRACE_DIST_A 250.0
#define TRACE_DIST_B 30.0
#define TRACE_V_OFFSET 20.0
#define SANDBAG_RANGE 25.0

new Float:g_fBelowLines[3] = { -5.0, -10.0, -15.0 };
new Float:g_ViewOfs[33];

public plugin_init() {
    register_plugin(PLUGIN, VERSION, AUTHOR, URL);

    register_forward(FM_PlayerPreThink, "hook_player_prethink");
    register_forward(FM_UpdateClientData, "hook_update_client_data_post", 1);
}

public hook_player_prethink(id) {
    if (!is_user_alive(id) || is_user_bot(id)) {
        return PLUGIN_CONTINUE;
    }

    if (dod_get_deploystate(id) < 2 && !touching_sandbag(id)) {
        dod_set_deploystate(id, get_deploy_ability(id));
    }

    return PLUGIN_CONTINUE;
}

public get_deploy_ability(id) {
    if (dod_get_pronestate(id) || pev(id, pev_button) & IN_DUCK || !deployable_weapon(id)) {
        return 0;
    }

    new bClear_Above = clear_path(id, TRACE_DIST_A, TRACE_V_OFFSET);

    if (bClear_Above && support_below(id, TRACE_DIST_B)) {
        return 1;
    }

    g_ViewOfs[id] = 0.0;

    return 0;
}

public hook_update_client_data_post(id, sendweapons, cd_handle) {
    if (is_user_bot(id)) {
        return PLUGIN_CONTINUE;
    }

    if (g_ViewOfs[id] != 0.0 && dod_get_deploystate(id) == 2) {
        new Float:fNewView[3];
        get_view_ofs(id, fNewView);
        set_cd(cd_handle, CD_ViewOfs, fNewView);
    } else if (g_ViewOfs[id] != 0.0 && dod_get_deploystate(id) == 0) {
        g_ViewOfs[id] = 0.0;
    }

    return PLUGIN_CONTINUE;
}

stock clear_path(id, Float:fDist, Float:fZOffset) {
    new Float:fStartOrigin[3], Float:fAngle[3], Float:fSize[3];
    pev(id, pev_origin, fStartOrigin);
    pev(id, pev_v_angle, fAngle);
    pev(id, pev_size, fSize);

    fStartOrigin[2] += fZOffset;

    new Float:fEndOrigin[3];
    fEndOrigin[0] = fStartOrigin[0] + floatcos(fAngle[1], degrees) * (fDist + fSize[0]);
    fEndOrigin[1] = fStartOrigin[1] + floatsin(fAngle[1], degrees) * (fDist + fSize[1]);
    fEndOrigin[2] = (fStartOrigin[2] - floatsin(fAngle[0], degrees) * (fDist + fSize[2])) + 5;

    new Float:fStop[3];
    fm_trace_line(id, fStartOrigin, fEndOrigin, fStop);

    return vectors_equal(fEndOrigin, fStop);
}

stock support_below(id, Float:fZOffset) {
    for (new i; i < sizeof g_fBelowLines; i++) {
        if (!clear_path(id, fZOffset, g_fBelowLines[i])) {
            g_ViewOfs[id] = g_fBelowLines[i];

            return 1;
        }
    }

    return 0;
}

stock get_view_ofs(id, Float:fNewView[3]) {    
    fNewView[2] = 22.0 + g_ViewOfs[id];
}

stock vectors_equal(Float:vec_a[3], Float:vec_b[3]) {
    if (vec_a[0] == vec_b[0] && vec_a[1] == vec_b[1] && vec_a[2] == vec_b[2]) {
        return 1;
    }

    return 0;
}

stock touching_sandbag(id) {
    new m_curEnt = -1, m_flOrigin[3];
    pev(id, pev_origin, m_flOrigin);

    while((m_curEnt = engfunc(EngFunc_FindEntityInSphere, m_curEnt, m_flOrigin, SANDBAG_RANGE)) != 0) {
        new m_szClassname[32];
        pev(m_curEnt, pev_classname, m_szClassname, 31);
    
        if (equal(m_szClassname, "dod_trigger_sandbag")) {
            return m_curEnt;
        }
    }

    return 0;
}

stock deployable_weapon(id) {
    new clip, ammo, wpn = get_user_weapon(id, clip, ammo);

    if (wpn == DODW_30_CAL || wpn == DODW_MG34 || wpn == DODW_MG42 || wpn == DODW_BAR || wpn == DODW_FG42 || wpn == DODW_BREN) {
        return 1;
    }

    return 0;
}

stock fm_trace_line(ignoreent, const Float:start[3], const Float:end[3], Float:ret[3]) {
    engfunc(EngFunc_TraceLine, start, end, ignoreent == -1 ? 1 : 0, ignoreent, 0);

    new ent = get_tr2(0, TR_pHit);
    get_tr2(0, TR_vecEndPos, ret);

    return pev_valid(ent) ? ent : 0;
}

stock dod_set_deploystate(id, flag) {
    new Float:m_vector[3];
    m_vector[0] = float(flag);
    set_pev(id, pev_vuser1, m_vector);
}

stock dod_get_deploystate(id) {
    new Float:m_vector[3];
    pev(id, pev_vuser1, m_vector);

    return floatround(m_vector[0]);
}
