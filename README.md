# TTT Scoreboard Ranks for ULX

## What does this do?
It's an easier way of adding custom ranks to the scoreboard in TTT.  
It allows you to change what it says at the top, set one rank and color for a group or make the text show rainbow colors.  
TTT Scoreboard Ranks will often be abbreviated as "TTT SB Ranks".

## Current features:
- Allows you to add, change existing, remove ranks and customize color.
- Allows you to add or change an existing rank to use "rainbow" colors. This will gradually change colors.
- Changing the default rank and color of the default rank.
- Changing column width.
- Changing column name.
- Support for setting group ranks.

## Planned features:
- A complete rewrite for cleaning up code and improving overall performance.
    - No ETA.

## Current permissions:
- Admins:
    - Adding, changing and removing ranks (colors + rainbows) using player names and Steam ID.
- Superadmins:
    - Changing the default rank, column width and column name.
    - Adding, changing (via addgrouprank) and removing group ranks (colors + rainbows).

## Changelog:
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
- Restart the server.

## Requirements:
- [ULX & ULib](https://ulyssesmod.net/)
- Trouble in Terrorist Town version [2014-03-09](http://ttt.badking.net/releases/2014-03-09) or newer (basically if you have updated your server after March 2014).
