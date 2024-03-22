______________________________________
Day of Defeat
v1.3 Release Documentation -- Readme.txt
http://www.dayofdefeat.com
______________________________________


v1.3
-----
[6.30.04]

- fixed crash on spectating scoped enfield or scoped fg42
- fixed mortars not doing proper damage
- increased mp44 recoil
- reduced BAR, Bren side to side recoil
- increased undeployed machine gun recoil
- increased stamina drain while firing undeployed machine gun
- fixed bug that appeared to give deployable weapons perfect accuracy while strafing
- fixed cl_drawmodels exploit
- added map dod_saints
- added map dod_falaise
- added map dod_sturm
- added map dod_northbound
- updated map dod_glider
- updated map dod_flugplatz

v1.2
-----
[4.2.03]

Weapons
-------------
· Bazooka is now a selectable class
· added K43 butt smack
· increased garand accuracy ( 0.019 -> 0.016 )
· increase bullet penetration by 10%
· further increased mg bullet penetration ( factor 0.75 -> 0.65 )
· reduced K43 recoil ( 0.15 -> 0.13 )
· reduced greasegun recoil to match thompson ( 0.5 -> 0.4 )
· reduced FG42 recoil to match BAR ( 1.3 -> 1.0 )
· reduced Bren recoil to match BAR ( 1.3 -> 1.0 )
· reduced Enfield aim penalty to match K98
· increased K98 and Enfield recoil ( 1.0 -> 1.5 ) to match garand
· fixed Enfield being less accurate than k98
· fixed unzoomed, scoped fg42 being less accurate than regular fg42
· rewrote recoil system and tweaked all recoil amounts to match old values
· increased movement accuracy penalty on Enfield to match K98 ( 0.1 -> 0.15 )
· fixed Springfield re-zoom behavior
· fixed prone garand butt / bayonet animation never playing
· lowered standing view height from 28 to 22 units above player origin
· reorganized slots, primary weapons are all in slot 3 now ( if you like your primary weapons in slot 4, bind the '4' key to "slot3" )

Bugs
------
· fixed bug where throwing a grenade straight down when prone would throw the grenade out of the world
· fixed weapons not calling Deploy client side if nextweapon and prevweapon were used, fixes crosshair disappearing for long amounts of time after a reload
· fixed helmet not popping off of allied carbine classes
· dropped weapons reset their attack times - fixes a bug where a weapon dropped in mid reload could not be fired until the reload time was up, even if another player picked it up
· fixed exploit where player could fire a rocket, change teams and destroy objectives
· fix player yaw / gaityaw popping when rotating to the right
· default font will now draw 32 players on the scoreboard without clipping 
· reset and reload all client env models when demo recording starts - fixes models disappearing in demo playback
· fixed %s in saytext exploit
· fixed class limit cvars for fg42s
· fixed crash when rockets hit an unbreakable glass func_breakable
· fixed minimap changes not triggering userinfo change on the server
· fixed view randomly swaying if lastFOV held bad data
· players suiciding after taking DMG_BLAST damage no longer play explosion death anim
· fixed spectators spawning as players if they managed to select a class
· fixed players sprinting from prone being able to sprint further
	
Performance
----------------
· optimized particles
· optimized cvar lookups
· optimized minimap drawing
· optimized player model drawing
· removed unused effects and sprites
· removed Movewith
· removed lightning and extra unused weather features
· removed cutscenes
· added entity lookup hash to speed up searching for entities
· removed w_ models for weapons that can't be dropped
	
Misc
-------
· New blood hit effect
· fixed names starting with # exploit
· increased number of custom objective icons per map to 6
· Label in class select menu shows class limit and how many are in that class
· class menu now omits banned classes and greys out full classes
· added mapinfo text files that can edit map properties - ban specific classes and remove spawned bazookas
· print warning message if map tries to load too many client_env_models
· removed hint message on bazooka /piat /pschreck pickup

New cvars and commands
-------------------
"cl_hudfont"
· Change to vary the size of the saytext and voice menu text ( 0 = small, 1 = normal, 2 = big )

"mp_combinemglimits"
· Setting to 1 will combine the mg34 and mg42 class limits and count either class as being a "machinegunner". New limit is the sum of "mp_limitaxismg34" and "mp_limitaximg42", including negative numbers.

"mp_limitalliesbazooka"
"mp_limitaxispschreck"
"mp_limitbitpiat"
· Class limit cvars for the new bazooka classes

"mp_alliesclasses"
· Mask of allowed classes for the allied team. "-1" allows all classes. To set the mask, reference the table of values below and add them together to get the class mask value. This can be set per map in the map cfg files. For example:

mp_alliesclasses 29   - ( 29 = 1 + 4 + 8 + 16 = garand + thompson + greasegun + sniper )

To add the 'random' class, you would find random, see the value 512, and add that to 29 - 541.

mp_alliesclasses 541

The list of classes:

American classes
Garand		1
Carbine		2
Thompson	4
GreaseGun	8
Sniper		16
BAR		32
30cal		64
Bazooka		128
Random		512

British classes
Enfield 	1
Sten 		2
Sniper		4
Bren		8
PIAT		16
Random		64

"mp_axisclasses"
· Mask of allowed classes for the axis team. "-1" allows all classes. On non-para maps, fg42 bipod and scoped will not be available.

Axis classes
K98		1
K43		2
MP40		4
MP44		8
Sniper		16
FG42Bipod	32 	//not available on non-para maps
FG42Sniper	64 	//not available on non-para maps				
MG34		128
MG42		256
Pschreck	512
Random		2048

"mp_spawnbazookas"
· Set to 1 to allow bazookas to spawn in the level.

And for those of you wondering what the missing class is in each of these lists, its a mortar. This weapon is not included in this release, as its not completed yet.


v1.1c
-----
[12.10.03]

- added client side env_models for static prop type models
- random class now abides by class limits
- no random class in clan matches
- added exit decal on gunshots
- restored door opening behavior to original style ( face the door and it opens away from you, face away and it opens towards you )
- fixed sniper rifle lowering when a sniper moved, even though he was still scoped
- fixed a bug where you would drop your weapon, pick it back up and it would have less ammo
- re-added weapon names to console death messages ( bob killed fred with garand )
- added "teamkill" text to the console death messages ( bob teamkilled chuck with kar )
- fixed being able to jumpshoot if the minimap was open fullscreen
- fixed a cut off label in scoreboard
- now cannot +use grenades while deployed
- fixed player animation being 90 degrees off on mg sandbag deploy
- draw correct spectator angles on minimap player icons
- fixed strange health numbers drawing in the spec bar
- fixed gunshot decal on subsequent bullet hits
- added control point name to log file cap messages
- fixed hud reset on stop demo recording
- fixed ammo on mg42 and 30cal view model not showing above 8 bullets
- fixed player models jittering because of animation blend
- fixed an evil evil hack that stopped the player from shooting when their mg42 overheated
- fixed some more empty cells in the scoreboard showing up as squares

Dod HLTV
	
- fixed client env_models drawing
- fixed brit sleeves
- draw objective icons on hud and in minimap
- draw grenades on the minimap for both teams
- fixed teams and playerclass in the scoreboard
- added timeleft and number of hltv spectators to the spec bar
- fixed weather effects not drawing
- no vgui menus in hltv spec


v1.1b
-----
[11.18.03]

- fixed mg42 and 30cal weapons showing full bullet clips on the model when the clip was empty
- fixed recoil continuing after the map ends
- fixed squares drawing in the scoreboard in blank spaces
- added top bar to scoreboard for drawing the hostname
- fixed a bug where the reinforcement timer would not draw in first person spectator mode
- added cvars "mp_log_scores" and "mp_log_scores_delay"
- fixed an exploit where many people could select a class over the class limit before the first person spawned
- fixed a bug where a joining player was sent the wrong team information for other players
- fixed bad subtitle on #voice_subtitle_pschreckspotted
- re-added BAR weapon deploy animation
- reduced BAR deploy time
- on demo recording start, resend all player team info
- fixed empty weapon click on all weapons
- increased max materials to 1300


New cvars and commands
-------------------
"mp_log_scores"
Set to 1 to periodically log the team scores. Default is 0.

"mp_log_scores_delay"
When logging scores, how often ( in seconds ) to log the team scores. Default is 60 seconds.


v1.1
----
[10.13.03]

Changes/Additions :
-------------------
- New map dod_flugplatz
- New map dod_escape
- New map dod_switch 
- Added VGUI2 menu system

Weapons
- no longer auto reload any weapon while it is deployed
- mg42 now fires two bullets per click
- reduced mg42 aim cone from 0.03 to 0.025
- adjusted weapon overheat values to be a bit slower to heat, faster to cool
- reset mg heat when player reloads
- increased mg42 reload time to coincide with animation
- fix mg34 and mg42 not drawing correct animations when low on bullets
- new mg42 overheat effect
- sniper zoomed speed reduced to 45 from 50
- K98 and Enfield - adjusted accuracy from 0.01 to 0.014 ( Garand and K43 unchanged at 0.019 )
- K98 and Enfield - adjusted kar moving penalty from 0.1 to 0.15
- fixed enfield allowing secondary attacks immediately after firing
- fixed weapons not stopping their reload sequence when you holster them
- fixed fg42 being able to fire instantly on deploy
- reduced pistols and m1carbine firedelay from 0.15 to 0.1 to make it smoother
- fixed m1 carbine showing wrong model ( para vs nonpara )
- fixed mp40 clip holding 32 bullets instead of 30
- added 0.5 second delay after zooming sniper rifles before you can fire
- fixed exploit where player could reload with the scope still up

Player
- added 9-way player animation blending
- hits to player arms that would hit the body will now count as body hits
- removed stamina recovery while crouched and in the air
- fixed "white model" bug
- fixed "spectator killer" bug
- Fixed explosion death animation never playing
- unzoom player if they go prone or unprone
- unzoom player if they jump, or fall too far off a ledge
- Fixed players being able to pick up bazookas at round's end
- fix tracer origin on prone players
- added voice icon to minimap, draws when a player uses a voice command or hand signal
- fixed players killing themselves with their own shots, getting killed when shooting very close to other players or items
- added voice icon over players on minimap when using voice
- fixed icons drawing over players when using voice menu / hand signals

Other
- deathcam - don't draw the player name over top of players
- deathcam - shortened cam trace time
- Optimized visibility calculation
- Optimized rain and snow particle effects
- Optimized minimap data sending - now will not send to players if the minimap is not open
- fixed cap areas completing a cap when one of the cappers died
- new map marker system
- rewrote bullet penetration to allow multiple penetrations
- adjusted material strength ( sand is stronger now )
- fixed low stamina heavy breathing sound
- localize saytext to fix %l, %c, %t macros
- Added time-based points for clan mode scoring
- Fixed dropped ammo boxes respawning
- scale objects on the minimap according to map zoom
- "mp_fadetoblack" now only works while in a clan match
- disallow marking the map on the client if the player is dead
- fixed certain walls not being solid on round restart
- fixed minimap not drawing while recording demos
- fixed ammo display in demo playback
- spawn client side corpse when player dies. duration of model can be set with cl_corpsestay.
- fixed mortar sound and effect not lining up
- added scope view to first person spectator while target is zoomed
- fixed particle angles in third person
- fixed doors blocking the player and making endless sound


New cvars and commands
-------------------
"firemarker"
Fires a map marker out into the world. A map marker will be created at that location in the world and will appear on teammates' minimaps.

"nextmarker"
Select the next map marker.

"prevmarker"
Select the previous map marker.

"cl_autoreload"
Setting to 0 disables all auto reloading. Deployed weapons will now never auto reload.

"cl_dynamiclights"
Setting to 0 turns off dynamic lights generated by weapons and grenades.

"cl_identiconmode"
0 - no icons above the heads of other players
1 - only draw icon a player we are looking at
2 - draw icons over all friendly players

"cl_xhair_style"
0 is default. Setting to non-zero ( 1 - 16 ) sets the crosshair to another slot in the "sprites/customXHair.spr" sprites
Each slot is 64x64.

1  2  3  4
5  6  7  8
9  10 11 12
13 14 15 16 

"cl_corpsestay"
Time in seconds that dead bodies will remain in the map. Default is 10.

"mp_clan_scoring"
Set to 1 to enable clan mode scoring ( only works in clan match mode )

"mp_clan_scoring_values_allies"
A string such as "112233". Determines the point value for the allied team when holding flags. Flag order in the string is the same as the order of flags on the hud. Must be set per map.

"mp_clan_scoring_values_axis"
A string such as "112233". Determines the point value for the axis team when holding flags. Flag order in the string is the same as the order of flags on the hud. Must be set per map.

"mp_clan_scoring_delay"
Sets how many seconds to go between giving time-based points.

"mp_clan_match_warmup"
Once a match is underway, set this to 1 to return to warmup mode.

"mp_clan_ready_signal"
Change this string to change what teams must say to start a mp_clan_readyrestart clan match. Default is "ready".

"mp_clan_scoring_bonus_allies" / "mp_clan_scoring_bonus_axis"
Amount of points to give the team that wins the round. Default is -1 and gives the normal amount of points. Only works in clan match mode.

"mp_nummapmarkers"
This determines the max number of map markers each player can place. Minimum and default is 1.

"mp_markerstaytime"
How long, in seconds, marker will stay on the minimap.
