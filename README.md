# Day of Defeat 1.3: Custom LinuxGSM Server Files

This repository contains all custom files used for the **Day of Defeat 1.3 Community** server, hosted at `108.61.151.70:27015`.

![](https://github.com/user-attachments/assets/de60caca-a783-4d64-adeb-b1281d01cfb8)

The server setup follows the procedures outlined in the related [Day of Defeat 1.3: Set Up a Server with LinuxGSM](https://github.com/jonathanlinat/day-of-defeat-linuxgsm-server-setup) guide. Its custom files are managed and maintained here to ensure consistent deployment and easy updates for the community server.

| 💬 Join an Active Community |
| -- |
| [![DoD Game Info](https://dcbadge.vercel.app/api/server/dodcommunity?style=plastic)](https://discord.gg/dodcommunity) |

## Features and Architecture

This custom server is based on [LinuxGSM](https://linuxgsm.com/servers/dodserver/) (`24.1.5`).

### Addons and Modules

> [!NOTE]
> All the addons and modules are located in the `dodserver/serverfiles/dod/addons/` directory.

* **AMX Mod X** (`1.10.0.5467`, commit `27f451a`), AlliedModders (https://github.com/alliedmodders/amxmodx)
* **Metamod-r** (`1.3.0.149`, commit `603a257`), ReHLDS (https://github.com/rehlds/Metamod-R)
* **ReHLDS** (`3.15.0.866-dev`, commit `1571474`), ReHLDS (https://github.com/rehlds/ReHLDS)
* **ReAPI** (`5.29.0.345-dev`, commit `66f6096`), ReHLDS (https://github.com/rehlds/reapi)
* **ReUnion** (`0.2.0.27`, commit `95d3e93`), ReHLDS (https://github.com/rehlds/reunion)
* **SafeNameAndChat** (`1.2 Beta 3`, commit `a9241b2`), WPMGPRoSToTeMa (https://github.com/WPMGPRoSToTeMa/SafeNameAndChat)
* **VoiceTranscoder** (`2017RC5`, commit `a9ae70b`), WPMGPRoSToTeMa (https://github.com/WPMGPRoSToTeMa/VoiceTranscoder)

### Third-party AMX Mod X Plugins

> [!NOTE]
> All the plugins and related scripts are located in the `dodserver/serverfiles/dod/addons/amxmodx/` directory.

#### ✅ Enabled

* **Away From Keyboard Kicker** (`1.0.0`), Jonathan Linat (https://github.com/jonathanlinat)
   - Identifies and kicks players who are away from their keyboard (AFK) for a specified duration, enhancing game flow and fairness on multiplayer servers.
* **Death Effect Enhancer** (`1.0.0`), Jonathan Linat (https://github.com/jonathanlinat)
   - Significantly enriches the visual and gameplay experience upon a player's death in-game.
* **Instant Spawner** (`1.0.0`), Jonathan Linat (https://github.com/jonathanlinat)
   - Completely removes the spawn delay when players die. It allows for a more intense game and works on player death or when they type kill in console.
* **Machine Gun Deployment Enhancer** (`1.0.0`), Jonathan Linat (https://github.com/jonathanlinat)
   - Enhances the deployment mechanism for machine guns in-game.
* **Parachute Provider** (`1.0.0`), Jonathan Linat (https://github.com/jonathanlinat)
   - Provides a parachute to players when they are falling from a height, allowing for a slow and safe descent. Players can activate the parachute by pressing the 'use' key while in mid-air. It contributes to a fun and dynamic gameplay experience in the server.
* **Player Healer** (`1.0.0`), Jonathan Linat (https://github.com/jonathanlinat)
   - Enables automatic healing for players in-game, allowing server administrators to configure healing parameters such as maximum health points for auto-healing, medic call limits, and healing sounds.
* **Scoreboard Hostname Slider** (`1.0.0`), Jonathan Linat (https://github.com/jonathanlinat)
   - Dynamically updates the server's hostname on the scoreboard to create a sliding text effect.
* **SVC Bad Preventer** (`1.0.0`), Jonathan Linat (https://github.com/jonathanlinat)
   - Aims to prevent the following error: "Error: server failed to transmit file 'AY&SYea'".
* **Weapons Registration Enhancer** (`1.0.0`), Jonathan Linat (https://github.com/jonathanlinat)
   - Optimizes hit detection for various weapons in the game, ensuring more reliable and consistent registration of hits. It dynamically adjusts the likelihood of a hit being registered based on the type of weapon being used, thereby refining the gameplay experience. The plugin assigns different chances for hits to register based on weapon classes, ranging from melee weapons to heavy firearms, which aims to balance gameplay and align hit registration more closely with player expectations.

#### ❌ Disabled

* **Next Map Selection Randomizer** (`1.0.0`), Jonathan Linat (https://github.com/jonathanlinat)
   - Aims to randomize the next map selection to enhance variety and player engagement by choosing from a specified map cycle list. Configurable options allow server administrators to exclude recently played maps and customize the map cycle file, ensuring players experience a wide range of environments without repetition.
* **Stamina Unlimiter** (`1.0.0`), Jonathan Linat (https://github.com/jonathanlinat)
   - Eliminates stamina limitations for players.

### Maps

This server hosts `22` original and `31` custom maps.

> [!NOTE]
> All the maps are located in the `dodserver/serverfiles/dod/maps/` directory.

#### Official

* **dod_anzio**, Davide "Chow_Yun_Fat" Pernigo (bido@halflifeitalia.com)
* **dod_avalanche**, Iikka "Fingers" Keranen
* **dod_caen**, Tim "Waldo" Holt (timh@valvesoftware.com)
* **dod_charlie**, Joel "c0w" Weech (cow@shaw.ca)
* **dod_chemille**, Chris "Narby" Auty (narby@counter-strike.net)
* **dod_donner**, Svante "xerent" Ekholm (xerent@xerent.dodhq.net)
* **dod_escape**, Arjan "IR" Bak (arjanb@invasionworks.com)
* **dod_falaise**, Wes "FuzzDad" Shull (wesley.b.shull@xo.com)
* **dod_flash**, Svante "xerent" Ekholm (xerent@xerent.dodhq.net)
* **dod_flugplatz**, Wes "FuzzDad" Shull (wesley.b.shull@xo.com)
* **dod_forest**, Brian "Arcturus" Schurko (arcturus@dayofdefeatmod.com)
* **dod_glider**, Wesley "Fuzzdad" Shull (wesley.b.shull@xo.com)
* **dod_jagd**, Arjan "IR" Bak (arjanb@invasionworks.com)
* **dod_kalt**, Tim "Waldo" Holt (timh@valvesoftware.com)
* **dod_kraftstoff**, Chris "Unreal" Scott (unreal@gamer.net.nz)
* **dod_merderet**, Arjan "IR" Bak (arjanb@invasionworks.com)
* **dod_northbound**, Arttu "skdr" Maki (http://skdr.dayofdefeat.fi)
* **dod_saints**, Arjan "IR" Bak (arjanb@nuclear-dawn.net)
* **dod_sturm**, Arjan "IR" Bak (arjanb@nuclear-dawn.net)
* **dod_switch**, Jeremy "Izuno" Miller (izuno@planethalflife.com)
* **dod_vicenza**, Jeremy "Izuno" Miller (izuno@planethalflife.com)
* **dod_zalec**, Patrick "Mojo" Krefting (mojo@theposse.org)

#### Custom

* **dod_a32_b1**, marteew (https://dayofdefeat.home.blog)
* **dod_adrenalin4**, Darkwing
* **dod_advance**, Magnar "insta" Jenssen (magnar.jenssen@gmail.com)
* **dod_aleutian**, Larry "slaughter" Walper (lwalper@hotmail.com)
* **dod_angriff2_b1**, marteew (https://dayofdefeat.home.blog)
* **dod_bastogne**, Dan Paris
* **dod_brucke_b1**, marteew (https://dayofdefeat.home.blog)
* **dod_calais2_b1**, marteew (https://dayofdefeat.home.blog)
* **dod_cherbourg**, Bryan "Arcturus" S (arcturus@dayofdefeatmod.com)
* **dod_dani_b3**, StreamlineData (angusycheng@gmail.com)
* **dod_diversion**, Darkwing
* **dod_eden**, {GSR} Boxy =[76AD]=
* **dod_gunst2_b1**, marteew (https://dayofdefeat.home.blog)
* **dod_heutau_r3**, marteew (https://dayofdefeat.home.blog)
* **dod_lennon2**, Jordon "Lerfooled" Lervold and Stephen "Hisey" Lerf
* **dod_liberte_b2**, J "KR8" L (KR34T3@gmail.com)
* **dod_putten2_b3**, marteew (https://dayofdefeat.home.blog)
* **dod_railroad**, Instacrome (instacrome@hotmail.com)
* **dod_railroad2_b2**, Insta (magstave@online.no)
* **dod_saints_b7**, Day of Defeat 1.3 Community (https://discord.gg/dodcommunity)
* **dod_sidestreets_b1**, marteew (https://dayofdefeat.home.blog)
* **dod_siegen2_b2**, marteew (https://dayofdefeat.home.blog)
* **dod_snowcity2_b1**, marteew (https://dayofdefeat.home.blog)
* **dod_snowmountain_b2**, marteew (https://dayofdefeat.home.blog)
* **dod_sulz**, Christian "DaKurt" Schulte zu Berge (cszb@cszb.net)
* **dod_tensions2_b2**, Anna
* **dod_thunder2_b5a**, Day of Defeat 1.3 Community (https://discord.gg/dodcommunity)
* **dod_tiger2_r2**, marteew (https://dayofdefeat.home.blog)
* **dod_veghel_b3**, Kyle "Siron" Florence (kyle@dork.cx)
* **dod_volonne**, Jeremy "Izuno" Miller (izuno@planethalflife.com)
* **dod_vonbrewski_b1**, marteew (https://dayofdefeat.home.blog)

## Server Settings and Environment Variables

Some of the server settings are managed through environment variables. These variables are configured in **GitHub** and automatically injected into the appropriate files via **GitHub Actions** workflows whenever a commit is pushed to the repository.

> [!NOTE]
> All the environment variables are set in this repository's `Settings` section and are manageable only by official contributors.

> [!WARNING]
> `sys_ticrate` cannot surpass `1000` because of intense _vCPU_ usage.
>
> ![Vultr.com Intense vCPU Usage](https://github.com/user-attachments/assets/727bae49-3f9c-454b-abae-cc9882db108d)


| Environment Variable Name | Game Variable Name | Assigned Value |
| -- | -- | -- |
| `VPS_GAMESERVER_CONFIG_FRIENDLYFIRE` | `mp_friendlyfire` | `0` |
| `VPS_GAMESERVER_CONFIG_HOSTNAME` | `hostname` | `[DoD 1.3 Community] US (https://discord.gg/dodcommunity)` |
| `VPS_GAMESERVER_CONFIG_MAXPLAYERS` | `maxplayers` | `32` |
| `VPS_GAMESERVER_CONFIG_MAXRATE` | `sv_maxrate` | `0` |
| `VPS_GAMESERVER_CONFIG_MAXUPDATERATE` | `sv_maxupdaterate` | `102` |
| `VPS_GAMESERVER_CONFIG_MINRATE` | `sv_minrate` | `100000` |
| `VPS_GAMESERVER_CONFIG_MINUPDATERATE` | `sv_minupdaterate` | `100` |
| `VPS_GAMESERVER_CONFIG_PINGBOOST` | `pingboost` | `3` |
| `VPS_GAMESERVER_CONFIG_SYSTICRATE` | `sys_ticrate` | `1000` |
| `VPS_GAMESERVER_CONFIG_TIMELIMIT` | `mp_timelimit` | `20` |
| `VPS_GAMESERVER_CONFIG_ZONE` | `zone` | `4096` |

### Secrets

| Environment Variable Name |
| -- |
| `VPS_GAMESERVER_CONFIG_AMXX_ADMINS` |
| `VPS_GAMESERVER_BINARY` |
| `VPS_GAMESERVER_CONFIG_METAMOD_REUNION_STEAMIDHASHSALT` |
| `VPS_GAMESERVER_CONFIG_RCON_PASSWORD` |
| `VPS_GAMESERVER_OPENSSH_ID` |
| `VPS_GAMESERVER_OPENSSH_PRIVATE_KEY` |
| `VPS_GAMESERVER_RSYNC_DEST_PATH` |
| `VPS_GAMESERVER_RSYNC_SOURCE_PATH` |
| `VPS_GAMESERVER_USERNAME` |
| `VPS_HOSTNAME` |

## Extra Tools

Several tools are included to help manage the server files locally.

> [!NOTE]
> All the tools are located in the `tools/` directory.

* **RESGen** (`2.0.3`), created by Sāfto "kriswema" Rangen (https://github.com/kriswema/resgen)
   - Generates resource (`.res`) files for Half-Life and its mods. To generate all resource files, run the following command from the root of the repository: `./tools/resgen -d dodserver/serverfiles/dod/maps/ -o`. For more information about available commands, execute `./tools/resgen -h`.
