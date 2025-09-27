# TTT Scoreboard Ranks for ULX

## What does this do?

It's an easier way of adding custom "ranks" to the scoreboard in TTT.  
It allows you to change what it says at the top, set one rank and color for a group or make the text show rainbow colors.  
TTT Scoreboard Ranks will often be abbreviated as "TTT SB Ranks".

## Current features:

- Allows you to add, change existing, remove ranks and customize color.
- Allows you to add or change an existing rank to use "rainbow" colors. This will cycle through colors constantly, in a "rainbow effect".
- Changing the default rank and color of the default rank.
- Changing column width.
- Changing column name.
- Support for setting group ranks.
    - Group ranks are only shown if the player does not have a custom rank specifically for them.

## Planned features:
- ~~A complete rewrite for cleaning up code and improving overall performance.~~
    - Done in 32905c9c6c4d0effc69027a5b32a085e5f457b9f I guess

## Default permissions:

These permissions can be changed by superadmins via ULX's XGUI (`!menu`) or using the `ulx groupallow` / `ulx groupdeny` commands (I recommend the former).

- Admins:
    - Adding, changing and removing ranks (colors + rainbows) using player names and Steam ID.
        - `addrank`, `addrankid`, `changerank`, `changerankid`, `removerank`, `removerankid`, `rainbowrank` & `rainbowrankid` respectively.
        - Note that `addrankid` and `removerankid` can technically target any Steam ID (including the ones linked to superadmin users). If you don't trust your admins to not abuse this, you should consider removing this permission from them... though I'd probably argue that they shouldn't be admins to begin with if you don't trust them.
- Superadmins:
    - All permission granted to admins.
    - Changing the default rank + color, column width and column name displayed on the scoreboard.
        - `defaultrank`, `defaultcolor`, `columnwidth` & `columnname` respectively.
    - Adding, changing and removing group ranks (colors + rainbows).
        - `addgrouprank`, `removegrouprank` & `rainbowgrouprank` respectively.
    - Forcing a complete rank update to all players connected to the server.
        - `refreshranks` - This command will _load data from the data files_ and then send the complete dataset to all players connected to the server.
            - Note that if the data files have been modified manually while the server is running. Though, unless you know exactly what you're doing, I'd refrain from editing them manually at all.

## Changelog:

- Version 2.0.0
    - Major refactor of the entire addon functionality should remain exactly the same.
        - In other words: Cleaning up the code structure.
    - Minor performance improvements in the way changes to ranks are sent to players connected to the server.
        - Instead of sending the complete dataset to all players every time a change is made, it now only sends the specific change to all players instead.
    - Added a new client console variable: `tttsbranks_debug` which will print debug information to the console whenever rank/settings updates are sent to players.
        - This is mainly for development purposes, but can be useful for server owners as well, I guess.
        - `tttsbranks_debug 0` to disable (default).
        - `tttsbranks_debug 1` to enable.
- Version 1.2.0
    - Adds `ulx defaultcolor`, which adjusts the color of the default rank.
- Version 1.1.1
    - Hotfixes a scoreboard issue with missing MIA and CD players.
- Version 1.1
    - Added the ability to add, modify, remove and "rainbow" someones rank using their [Steam ID](https://developer.valvesoftware.com/wiki/SteamID#Legacy_Format)
- Version 1.0
    - Added the ability to add, modify, remove and "rainbow" someones rank using their player name (has to be connected).
    - Added the ability to modify the default rank, width of column for ranks and name of said column.
    - Added the ability to add, modify, remove and "rainbow" ranks for groups.

## Notes:

- Custom, per-user ranks will override group ranks.
- Other information can be found via the Ulysses Forums: [https://forums.ulyssesmod.net/index.php/topic,8607.0.html](https://forums.ulyssesmod.net/index.php/topic,8607.0.html)

## Installation:

- For the latest, stable release; Click ["Releases"](https://github.com/Decicus/TTT-Scoreboard-Ranks-for-ULX/releases) and find the latest available version.
- Download the zip or tar.gz file and extract it. There should be a folder called "TTT-Scoreboard-Ranks-for-ULX" and inside that should be some files.
- Put this folder inside your "garrysmod/addons" on the server, either locally or via FTP (depending on how it is hosted).
    - If you are hosting on Linux, you will most likely have to rename the addon folder to something lowercase (such as `ttt-sb-ranks`, for example) as uppercase-named addons cause issues with Garry's Mod on Linux.
- Change the map or restart the server.

## Requirements:

- [ULX & ULib](https://ulyssesmod.net/)
- Your server needs to be running Trouble in Terrorist Town (aka TTT). It should also be compatible with TTT2, but I haven't personally tested it.
    - Worst case, v1.2.0 should still be compatible with TTT2.
