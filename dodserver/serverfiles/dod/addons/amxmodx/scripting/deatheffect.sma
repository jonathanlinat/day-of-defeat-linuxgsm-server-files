#define PLUGIN "Death Effect"
#define VERSION "1.0"
#define AUTHOR "Jonathan Linat"

/*
 * This plugin enhances the death experience in-game by triggering a sprite animation
 * effect when a player is killed.
 *
 * It has been successfully tested with AMX Mod X v1.10+.
 */

#include <amxmodx>
#include <engine>
#include <fakemeta>
#include <hamsandwich>

#define EFFECT_CLASSNAME "ghost_effect"
#define TASK_REVIVE 4415
#define SPRITE_SIZE 5
#define SPRITE_BRIGHTNESS 200

new Float:g_DeadBody[33][3];
new g_DeathSpriteID;

public plugin_init() {
    register_plugin(PLUGIN, VERSION, AUTHOR);
    register_think(EFFECT_CLASSNAME, "effectThink");

    RegisterHam(Ham_Killed, "player", "playerKilledPost", 1);
}

public plugin_precache() {
    g_DeathSpriteID = precache_model("sprites/effects/death_god.spr");
}

public playerKilledPost(victim, attacker) {
    static Float:origin[3];
    pev(victim, pev_origin, origin);
    g_DeadBody[victim] = origin;

    message_begin(MSG_BROADCAST, SVC_TEMPENTITY);
    write_byte(TE_SPRITE);
    engfunc(EngFunc_WriteCoord, origin[0]);
    engfunc(EngFunc_WriteCoord, origin[1]);
    engfunc(EngFunc_WriteCoord, origin[2] + 16.0);
    write_short(g_DeathSpriteID);
    write_byte(SPRITE_SIZE);
    write_byte(SPRITE_BRIGHTNESS);
    message_end();
}

public effectThink(ent) {
    if (!pev_valid(ent)) {
        return;
    }

    set_pev(ent, pev_nextthink, get_gametime() + 0.01);
    set_pev(ent, pev_flags, FL_KILLME);
}
