-- TTT Scoreboard Ranks for ULX --

local CATEGORY_NAME = "TTT Scoreboard Ranks"
local dir = "data/ttt_sb_ranks/"
local ranks = "ranks.txt"
local settings = "settings.txt"
local groups = "groups.txt"

local TTTSBRanks = {}
local TTTSBSettings = {
    [ "default_rank" ] = "Guest",
    [ "column_name" ] = "Rank",
    [ "column_width" ] = 80,
    [ "default_color" ] = {
        [ "r" ] = 255,
        [ "g" ] = 255,
        [ "b" ] = 255
    }
}
local TTTSBGroups = {}

local function TTTSBRanksRefresh( ply )

    if not ULib.fileExists( dir ) then ULib.fileCreateDir( dir ) end
    if ULib.fileRead( dir .. ranks ) then TTTSBRanks = util.JSONToTable( ULib.fileRead( dir .. ranks ) ) end
    if ULib.fileRead( dir .. settings ) then TTTSBSettings = util.JSONToTable( ULib.fileRead( dir .. settings ) ) end
    if ULib.fileRead( dir .. groups ) then TTTSBGroups = util.JSONToTable( ULib.fileRead( dir .. groups ) ) end

    if SERVER then

        net.Start( "ULX_TTTSBRanks" )
        net.WriteTable( TTTSBRanks )
        net.WriteTable( TTTSBSettings )
        net.WriteTable( TTTSBGroups )

        if ply then

            net.Send( ply )

        else

            net.Broadcast()

        end

    end

end
hook.Add( "PlayerInitialSpawn", "ULXTTTRefresh_PlayerJoin", TTTSBRanksRefresh )

function ulx.addrank( calling_ply, target_ply, rank, red, green, blue )

    local sid = target_ply:SteamID()
    local sidRank = { text = rank, color = "colors", r = red, g = green, b = blue }

    TTTSBRanksRefresh()

    TTTSBRanks[ sid ] = sidRank

    ULib.fileWrite( dir .. ranks, util.TableToJSON( TTTSBRanks ) )
    ulx.fancyLogAdmin( calling_ply, "#A set the scoreboard rank of #T to #s with color: #i, #i, #i ", target_ply, rank, red, green, blue )

    TTTSBRanksRefresh()

end
local addrank = ulx.command( CATEGORY_NAME, "ulx addrank", ulx.addrank, "!addrank" )
addrank:addParam{ type=ULib.cmds.PlayerArg }
addrank:addParam{ type=ULib.cmds.StringArg, hint="Custom rank text" }
addrank:addParam{ type=ULib.cmds.NumArg, min=0, max=255, default=255, hint="Red part of RGB" }
addrank:addParam{ type=ULib.cmds.NumArg, min=0, max=255, default=255, hint="Green part of RGB" }
addrank:addParam{ type=ULib.cmds.NumArg, min=0, max=255, default=255, hint="Blue part of RGB" }
addrank:defaultAccess( ULib.ACCESS_ADMIN )
addrank:help( "Adds a custom scoreboard rank for a connected player with RGB colorcodes." )

function ulx.addrankid( calling_ply, sid, rank, red, green, blue )

    TTTSBRanksRefresh()

    if ULib.isValidSteamID( sid ) then

        if TTTSBRanks[ sid ] then

            ULib.tsayError( calling_ply, "This Steam ID already has a rank. Please use 'changerankid' to modify a rank using a Steam ID." )

        else

            local sidRank = { text = rank, color = "colors", r = red, g = green, b = blue }

            TTTSBRanks[ sid ] = sidRank

            ULib.fileWrite( dir .. ranks, util.TableToJSON( TTTSBRanks ) )

            local sidFormat = sid
            local checkPly = ULib.getPlyByID( sid )

            if checkPly then

                sidFormat = checkPly:Nick() .. " (" .. sid .. ")"

            end

            ulx.fancyLogAdmin( calling_ply, "#A set the scoreboard rank of #s to #s with color: #i, #i, #i", sidFormat, rank, red, green, blue )

        end

    else

        ULib.tsayError( calling_ply, "This is not a valid Steam ID." )

    end

    TTTSBRanksRefresh()

end
local addrankid = ulx.command( CATEGORY_NAME, "ulx addrankid", ulx.addrankid, "!addrankid" )
addrankid:addParam{ type=ULib.cmds.StringArg, hint="Steam ID of player" }
addrankid:addParam{ type=ULib.cmds.StringArg, hint="Custom rank text" }
addrankid:addParam{ type=ULib.cmds.NumArg, min=0, max=255, default=255, hint="Red part of RGB" }
addrankid:addParam{ type=ULib.cmds.NumArg, min=0, max=255, default=255, hint="Green part of RGB" }
addrankid:addParam{ type=ULib.cmds.NumArg, min=0, max=255, default=255, hint="Blue part of RGB" }
addrankid:defaultAccess( ULib.ACCESS_ADMIN )
addrankid:help( "Adds a custom scoreboard rank for a Steam ID with RGB colorcodes." )

function ulx.rainbowrank( calling_ply, target_ply, rank )

    local sid = target_ply:SteamID()

    TTTSBRanksRefresh()

    TTTSBRanks[ sid ] = { text = rank, color = "rainbow", r = 0, g = 0, b = 0 }
    ULib.fileWrite( dir .. ranks, util.TableToJSON( TTTSBRanks ) )

    ulx.fancyLogAdmin( calling_ply, "#A set the scoreboard rank of #T to #s with rainbow colors.", target_ply, rank )

    TTTSBRanksRefresh()

end
local rainbowrank = ulx.command( CATEGORY_NAME, "ulx rainbowrank", ulx.rainbowrank, "!rainbowrank" )
rainbowrank:addParam{ type=ULib.cmds.PlayerArg }
rainbowrank:addParam{ type=ULib.cmds.StringArg, hint="Custom rank text" }
rainbowrank:defaultAccess( ULib.ACCESS_ADMIN )
rainbowrank:help( "Adds or changes a custom scoreboard rank's color to a rainbow-loop" )

function ulx.rainbowrankid( calling_ply, sid, rank )

    TTTSBRanksRefresh()

    if ULib.isValidSteamID( sid ) then

        TTTSBRanks[ sid ] = { text = rank, color = "rainbow", r = 0, g = 0, b = 0 }
        ULib.fileWrite( dir .. ranks, util.TableToJSON( TTTSBRanks ) )

        local sidFormat = sid
        local checkPly = ULib.getPlyByID( sid )

        if checkPly then

            sidFormat = checkPly:Nick() .. " (" .. sid .. ")"

        end

        ulx.fancyLogAdmin( calling_ply, "#A set the scoreboard rank of #s to #s with rainbow colors.", sidFormat, rank )

    else

        ULib.tsayError( calling_ply, "This is not a valid Steam ID." )

    end

    TTTSBRanksRefresh()

end
local rainbowrankid = ulx.command( CATEGORY_NAME, "ulx rainbowrankid", ulx.rainbowrankid, "!rainbowrankid" )
rainbowrankid:addParam{ type=ULib.cmds.StringArg, hint="Steam ID for player" }
rainbowrankid:addParam{ type=ULib.cmds.StringArg, hint="Custom rank text" }
rainbowrankid:defaultAccess( ULib.ACCESS_ADMIN )
rainbowrankid:help( "Adds or changes a custom scoreboard rank's color to a rainbow-loop using Steam ID" )

function ulx.changerank( calling_ply, target_ply, rank, red, green, blue )

    local sid = target_ply:SteamID()

    TTTSBRanksRefresh()

    if not TTTSBRanks[ sid ] then

        ULib.tsayError( calling_ply, "That player does not have an existing rank." )

    else

        TTTSBRanks[ sid ] = { text = rank, color = "colors", r = red, g = green, b = blue }
        ULib.fileWrite( dir .. ranks, util.TableToJSON( TTTSBRanks ) )
        ulx.fancyLogAdmin( calling_ply, "#A changed the scoreboard rank of #T to #s with color: #i, #i, #i", target_ply, rank, red, green, blue )

    end

    TTTSBRanksRefresh()

end
local changerank = ulx.command( CATEGORY_NAME, "ulx changerank", ulx.changerank, "!changerank" )
changerank:addParam{ type=ULib.cmds.PlayerArg }
changerank:addParam{ type=ULib.cmds.StringArg, hint="Custom rank text" }
changerank:addParam{ type=ULib.cmds.NumArg, min=0, max=255, default=255, hint="Red part of RGB" }
changerank:addParam{ type=ULib.cmds.NumArg, min=0, max=255, default=255, hint="Green part of RGB" }
changerank:addParam{ type=ULib.cmds.NumArg, min=0, max=255, default=255, hint="Blue part of RGB" }
changerank:defaultAccess( ULib.ACCESS_ADMIN )
changerank:help( "Changes an existing scoreboard rank to different text and color." )

function ulx.changerankid( calling_ply, sid, rank, red, green, blue )

    TTTSBRanksRefresh()

    if ULib.isValidSteamID( sid ) then

        if not TTTSBRanks[ sid ] then

            ULib.tsayError( calling_ply, "That player does not have an existing rank." )

        else

            TTTSBRanks[ sid ] = { text = rank, color = "colors", r = red, g = green, b = blue }
            ULib.fileWrite( dir .. ranks, util.TableToJSON( TTTSBRanks ) )

            local sidFormat = sid
            local checkPly = ULib.getPlyByID( sid )

            if checkPly then

                sidFormat = checkPly:Nick() .. " (" .. sid .. ")"

            end

            ulx.fancyLogAdmin( calling_ply, "#A changed the scoreboard rank of #s to #s with color: #i, #i, #i", sidFormat, rank, red, green, blue )

        end

    else

        ULib.tsayError( calling_ply, "This is not a valid Steam ID." )

    end

    TTTSBRanksRefresh()

end
local changerankid = ulx.command( CATEGORY_NAME, "ulx changerankid", ulx.changerankid, "!changerankid" )
changerankid:addParam{ type=ULib.cmds.StringArg, hint="Steam ID for player" }
changerankid:addParam{ type=ULib.cmds.StringArg, hint="Custom rank text" }
changerankid:addParam{ type=ULib.cmds.NumArg, min=0, max=255, default=255, hint="Red part of RGB" }
changerankid:addParam{ type=ULib.cmds.NumArg, min=0, max=255, default=255, hint="Green part of RGB" }
changerankid:addParam{ type=ULib.cmds.NumArg, min=0, max=255, default=255, hint="Blue part of RGB" }
changerankid:defaultAccess( ULib.ACCESS_ADMIN )
changerankid:help( "Changes an existing scoreboard rank for a Steam ID to different text and color." )

function ulx.removerank( calling_ply, target_ply )

    local sid = target_ply:SteamID()

    TTTSBRanksRefresh()

    if not TTTSBRanks[ sid ] then

        ULib.tsayError( calling_ply, "That player does not have a rank." )

    else

        TTTSBRanks[ sid ] = nil
        ULib.fileWrite( dir .. ranks, util.TableToJSON( TTTSBRanks ) )
        ulx.fancyLogAdmin( calling_ply, "#A removed the scoreboard rank of #T", target_ply )

    end

    TTTSBRanksRefresh()

end
local removerank = ulx.command( CATEGORY_NAME, "ulx removerank", ulx.removerank, "!removerank" )
removerank:addParam{ type=ULib.cmds.PlayerArg }
removerank:defaultAccess( ULib.ACCESS_ADMIN )
removerank:help( "Removes a players scoreboard rank." )

function ulx.removerankid( calling_ply, sid )

    TTTSBRanksRefresh()

    if ULib.isValidSteamID( sid ) then

        if not TTTSBRanks[ sid ] then

            ULib.tsayError( calling_ply, "That Steam ID does not have a rank." )

        else

            TTTSBRanks[ sid ] = nil
            ULib.fileWrite( dir .. ranks, util.TableToJSON( TTTSBRanks ) )

            local sidFormat = sid
            local checkPly = ULib.getPlyByID( sid )

            if checkPly then

                sidFormat = checkPly:Nick() .. " (" .. sid .. ")"

            end

            ulx.fancyLogAdmin( calling_ply, "#A removed the scoreboard rank of #s", sidFormat )

        end

    else

        ULib.tsayError( calling_ply, "This is not a valid Steam ID." )

    end

    TTTSBRanksRefresh()

end
local removerankid = ulx.command( CATEGORY_NAME, "ulx removerankid", ulx.removerankid, "!removerankid" )
removerankid:addParam{ type=ULib.cmds.StringArg, hint="Steam ID for player" }
removerankid:defaultAccess( ULib.ACCESS_ADMIN )
removerankid:help( "Removes a scoreboard rank for a Steam ID" )

function ulx.columnname( calling_ply, name )

    TTTSBRanksRefresh()

    if name ~= "" then

        TTTSBSettings[ "column_name" ] = name
        ULib.fileWrite( dir .. settings, util.TableToJSON( TTTSBSettings ) )
        ulx.fancyLogAdmin( calling_ply, true, "#A changed the scoreboard rank column name to \"#s\"", name )

    else

        ULib.tsayError( calling_ply, "Column name cannot be blank!" )

    end

    TTTSBRanksRefresh()

end
local columnname = ulx.command( CATEGORY_NAME, "ulx columnname", ulx.columnname, "!columnname", true )
columnname:addParam{ type=ULib.cmds.StringArg, hint="Name of column in the scoreboard" }
columnname:defaultAccess( ULib.ACCESS_SUPERADMIN )
columnname:help( "Modifies the name of the column in the scoreboard." )

function ulx.defaultrank( calling_ply, rank )

    TTTSBRanksRefresh()

    TTTSBSettings[ "default_rank" ] = rank
    ULib.fileWrite( dir .. settings, util.TableToJSON( TTTSBSettings ) )
    ulx.fancyLogAdmin( calling_ply, true, "#A changed the default rank to \"#s\"", rank )

    TTTSBRanksRefresh()

end
local defaultrank = ulx.command( CATEGORY_NAME, "ulx defaultrank", ulx.defaultrank, "!defaultrank", true )
defaultrank:addParam{ type=ULib.cmds.StringArg, hint="Default rank for players without a custom one" }
defaultrank:defaultAccess( ULib.ACCESS_SUPERADMIN )
defaultrank:help( "Changes the default rank for players without a custom rank." )

function ulx.defaultcolor( calling_ply, red, green, blue )
    TTTSBRanksRefresh()

    TTTSBSettings[ "default_color" ] = {
        [ "r" ] = red,
        [ "g" ] = green,
        [ "b" ] = blue
    }
    ULIb.fileWrite( dir .. settings, util.TableToJSON( TTTSBSettings ) )
    ulx.fancyLogAdmin( calling_ply, true, "#A changed the default rank color to: #i, #i, #i", red, green, blue )
end
local defaultcolor = ulx.command( CATEGORY_NAME, "ulx defaultcolor", ulx.defaultcolor, "!defaultcolor", true )
defaultcolor:addParam{ type=ULib.cmds.NumArg, min=0, max=255, default=255, hint="Red part of RGB" }
defaultcolor:addParam{ type=ULib.cmds.NumArg, min=0, max=255, default=255, hint="Green part of RGB" }
defaultcolor:addParam{ type=ULib.cmds.NumArg, min=0, max=255, default=255, hint="Blue part of RGB" }
defaultcolor:defaultAccess( ULib.ACCESS_SUPERADMIN )
defaultcolor:help( "Changes the default color of the rank for players without a custom rank color." )

function ulx.columnwidth( calling_ply, width )

    TTTSBRanksRefresh()

    TTTSBSettings[ "column_width" ] = width
    ULib.fileWrite( dir .. settings, util.TableToJSON( TTTSBSettings ) )
    ulx.fancyLogAdmin( calling_ply, true, "#A changed the column width to #i", width )

    TTTSBRanksRefresh()

end
local columnwidth = ulx.command( CATEGORY_NAME, "ulx columnwidth", ulx.columnwidth, "!columnwidth", true )
columnwidth:addParam{ type=ULib.cmds.NumArg, min=60, max=240, default=80, hint="Width of the rank column" }
columnwidth:defaultAccess( ULib.ACCESS_SUPERADMIN )
columnwidth:help( "Changes the column width in the scoreboard - Default: 80" )

local groupNames = {}
local function updateGroups()

    table.Empty( groupNames )

    for group, _ in pairs( ULib.ucl.groups ) do

        if group ~= ULib.ACCESS_ALL then -- "user" would fallback to the default rank.

            table.insert( groupNames, group )

        end

    end

end
updateGroups() -- Call when script is loaded.
hook.Add( ULib.HOOK_UCLCHANGED, "ULX_TTTSBRanks_groupNames", updateGroups )

function ulx.addgrouprank( calling_ply, group_name, rank, red, green, blue )

    TTTSBRanksRefresh()

    TTTSBGroups[ group_name ] = { text = rank, color = "colors", r = red, g = green, b = blue  }
    ULib.fileWrite( dir .. groups, util.TableToJSON( TTTSBGroups ) )
    ulx.fancyLogAdmin( calling_ply, "#A added a rank for group #s with rank name #s and colors #i, #i, #i.", group_name, rank, red, green, blue )

    TTTSBRanksRefresh()

end
local addgrouprank = ulx.command( CATEGORY_NAME, "ulx addgrouprank", ulx.addgrouprank, "!addgrouprank", true )
addgrouprank:addParam{ type=ULib.cmds.StringArg, completes=groupNames, hint="Group", error="invalid group \"%s\" specified", ULib.cmds.restrictToCompletes }
addgrouprank:addParam{ type=ULib.cmds.StringArg, hint="Rank title for group" }
addgrouprank:addParam{ type=ULib.cmds.NumArg, min=0, max=255, default=255, hint="Red part of RGB" }
addgrouprank:addParam{ type=ULib.cmds.NumArg, min=0, max=255, default=255, hint="Green part of RGB" }
addgrouprank:addParam{ type=ULib.cmds.NumArg, min=0, max=255, default=255, hint="Blue part of RGB" }
addgrouprank:defaultAccess( ULib.ACCESS_SUPERADMIN )
addgrouprank:help( "Add a custom rank per group." )


function ulx.removegrouprank( calling_ply, group_name )

    TTTSBRanksRefresh()

    if not TTTSBGroups[ group_name ] then

        ULib.tsayError( calling_ply, "That group does not have a rank." )

    else

        TTTSBGroups[ group_name ] = nil
        ULib.fileWrite( dir .. groups, util.TableToJSON( TTTSBGroups ) )
        ulx.fancyLogAdmin( calling_ply, "#A removed a rank for #s", group_name )

    end

    TTTSBRanksRefresh()

end
local removegrouprank = ulx.command( CATEGORY_NAME, "ulx removegrouprank", ulx.removegrouprank, "!removegrouprank", true )
removegrouprank:addParam{ type=ULib.cmds.StringArg, completes=groupNames, hint="Group", error="invalid group \"%s\" specified", ULib.cmds.restrictToCompletes }
removegrouprank:defaultAccess( ULib.ACCESS_SUPERADMIN )
removegrouprank:help( "Remove a custom rank from a group." )

function ulx.rainbowgrouprank( calling_ply, group_name, rank )

    TTTSBRanksRefresh()

    TTTSBGroups[ group_name ] = { text = rank, color = "rainbow", r = red, g = green, b = blue  }
    ULib.fileWrite( dir .. groups, util.TableToJSON( TTTSBGroups ) )
    ulx.fancyLogAdmin( calling_ply, "#A added a rainbow rank for group #s, with the title #s", group_name, rank )

    TTTSBRanksRefresh()

end
local rainbowgrouprank = ulx.command( CATEGORY_NAME, "ulx rainbowgrouprank", ulx.rainbowgrouprank, "!rainbowgrouprank", true )
rainbowgrouprank:addParam{ type=ULib.cmds.StringArg, completes=groupNames, hint="Group", error="invalid group \"%s\" specified", ULib.cmds.restrictToCompletes }
rainbowgrouprank:addParam{ type=ULib.cmds.StringArg, hint="Rank title for group" }
rainbowgrouprank:defaultAccess( ULib.ACCESS_SUPERADMIN )
rainbowgrouprank:help( "Sets a group rank to use rainbow colors." )

function ulx.refreshranks( calling_ply )

    TTTSBRanksRefresh()
    ulx.fancyLogAdmin( calling_ply, true, "#A refreshed the scoreboard ranks manually." )

end
local refreshranks = ulx.command( CATEGORY_NAME, "ulx refreshranks", ulx.refreshranks, "!refreshranks", true )
refreshranks:defaultAccess( ULib.ACCESS_SUPERADMIN )
refreshranks:help( "Manually refreshes the ranks, in case you have edited the configs manually (not recommended to do)." )
