-- TTT Scoreboard Ranks for ULX --

local CATEGORY_NAME = "TTT Scoreboard Ranks"
local dir = "data/ttt_sb_ranks/"
local ranks = "ranks.txt"
local settings = "settings.txt"
local groups = "groups.txt"
local namecolors = "namecolors.txt"

local TTTSBRanks = {}
local TTTSBSettings = {
    [ "default_rank" ] = "Guest",
    [ "column_name" ] = "Rank",
    [ "column_width" ] = 80,
    [ "default_color" ] = {
        [ "r" ] = 255,
        [ "g" ] = 255,
        [ "b" ] = 255
    },
    [ "default_namecolor" ] = {
        [ "r" ] = 255,
        [ "g" ] = 255,
        [ "b" ] = 255
    }
}
local TTTSBGroups = {}
local TTTSBNamecolors = {}

local function TTTSBRanksRefresh( ply )
    if not ULib.fileExists( dir ) then ULib.fileCreateDir( dir ) end
    if ULib.fileRead( dir .. ranks ) then TTTSBRanks = util.JSONToTable( ULib.fileRead( dir .. ranks ) ) end
    if ULib.fileRead( dir .. settings ) then TTTSBSettings = util.JSONToTable( ULib.fileRead( dir .. settings ) ) end
    if ULib.fileRead( dir .. groups ) then TTTSBGroups = util.JSONToTable( ULib.fileRead( dir .. groups ) ) end
    if ULib.fileRead( dir .. namecolors ) then TTTSBNamecolors = util.JSONToTable( ULib.fileRead( dir .. namecolors ) ) end

    if SERVER then
        net.Start( "ULX_TTTSBRanks" )
        net.WriteTable( TTTSBRanks )
        net.WriteTable( TTTSBSettings )
        net.WriteTable( TTTSBGroups )
        net.WriteTable( TTTSBNamecolors )

        if ply and IsValid( ply ) then
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

function ulx.addranktext( calling_ply, target_ply, rank )
    local sid = target_ply:SteamID()
    TTTSBRanksRefresh()

    if TTTSBRanks[ sid ] and TTTSBRanks[ sid ].text then
        ULib.tsayError( calling_ply, "This player already has a custom rank text." )
    else
        TTTSBRanks[ sid ] = { text = rank }
        ULib.fileWrite( dir .. ranks, util.TableToJSON( TTTSBRanks ) )
        ulx.fancyLogAdmin( calling_ply, "#A added the scoreboard rank text of #T to #s", target_ply, rank )
    end

    TTTSBRanksRefresh()
end
local addranktext = ulx.command( CATEGORY_NAME, "ulx addranktext", ulx.addranktext, "!addranktext" )
addranktext:addParam{ type=ULib.cmds.PlayerArg, hint="Player to set rank for" }
addranktext:addParam{ type=ULib.cmds.StringArg, hint="Custom rank text" }
addranktext:defaultAccess( ULib.ACCESS_ADMIN )
addranktext:help( "Adds custom rank text for the player, using the default colors." )

function ulx.addrankcolor( calling_ply, target_ply, red, green, blue )
    TTTSBRanksRefresh()

    local sid = target_ply:SteamID()
    if TTTSBRanks[ sid ] and TTTSBRanks[ sid ].color == "colors" then
        ULib.tsayError( calling_ply, "This player already has a colored rank." )
    else
        TTTSBRanks[ sid ] = { color = "colors", r = red, g = green, b = blue }

        ULib.fileWrite( dir .. ranks, util.TableToJSON( TTTSBRanks ) )
        ulx.fancyLogAdmin( calling_ply, "#A added the scoreboard rank color for #T to #i, #i, #i.", target_ply, red, green, blue )
    end

    TTTSBRanksRefresh()
end
local addrankcolor = ulx.command( CATEGORY_NAME, "ulx addrankcolor", ulx.addrankcolor, "!addrankcolor" )
addrankcolor:addParam{ type=ULib.cmds.PlayerArg }
addrankcolor:addParam{ type=ULib.cmds.NumArg, min=0, max=255, default=255, hint="Red part of RGB" }
addrankcolor:addParam{ type=ULib.cmds.NumArg, min=0, max=255, default=255, hint="Green part of RGB" }
addrankcolor:addParam{ type=ULib.cmds.NumArg, min=0, max=255, default=255, hint="Blue part of RGB" }
addrankcolor:defaultAccess( ULib.ACCESS_ADMIN )
addrankcolor:help( "Adds scoreboard rank color of a player's rank." )

function ulx.addrankcolorid( calling_ply, sid, red, green, blue )
    TTTSBRanksRefresh()

    if not ULib.isValidSteamID( sid ) then
        if TTTSBRanks[ sid ].color or TTTSBRanks[ sid ].color == "colors" then
            ULib.tsayError( calling_ply, "#s already has an existing colored rank.", sid )
        else
            local sidFormat = sid
            local checkPly = ULib.getPlyByID( sid )

            if checkPly then
                sidFormat = checkPly:Nick() .. " (" .. sid .. ")"
            end

            TTTSBRanks[ sid ] = { r = red, g = green, b = blue }

            ULib.fileWrite( dir .. ranks, util.TableToJSON( TTTSBRanks ) )
            ulx.fancyLogAdmin( calling_ply, "#A added the scoreboard rank color for #s: #i, #i, #i.", sidFormat, red, green, blue )
        end
    else
        ULib.tsayError( calling_ply, "Not a valid Steam ID." )
    end

    TTTSBRanksRefresh()
end
local addrankcolorid = ulx.command( CATEGORY_NAME, "ulx addrankcolorid", ulx.addrankcolorid, "!addrankcolorid" )
addrankcolorid:addParam{ type=ULib.cmds.StringArg, hint="Steam ID of player" }
addrankcolorid:addParam{ type=ULib.cmds.NumArg, min=0, max=255, default=255, hint="Red part of RGB" }
addrankcolorid:addParam{ type=ULib.cmds.NumArg, min=0, max=255, default=255, hint="Green part of RGB" }
addrankcolorid:addParam{ type=ULib.cmds.NumArg, min=0, max=255, default=255, hint="Blue part of RGB" }
addrankcolorid:defaultAccess( ULib.ACCESS_ADMIN )
addrankcolorid:help( "Adds scoreboard rank color of a player's rank using their Steam ID" )

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

    if TTTSBRanks[ sid ] then
        TTTSBRanks[ sid ] = { text = rank, color = "colors", r = red, g = green, b = blue }
        ULib.fileWrite( dir .. ranks, util.TableToJSON( TTTSBRanks ) )
        ulx.fancyLogAdmin( calling_ply, "#A changed the scoreboard rank of #T to #s with color: #i, #i, #i", target_ply, rank, red, green, blue )
    else
        ULib.tsayError( calling_ply, "That player does not have an existing rank." )
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

function ulx.changeranktext( calling_ply, target_ply, rank )
    TTTSBRanksRefresh()

    local sid = target_ply:SteamID()
    if TTTSBRanks[ sid ].text then
        local oldRank = TTTSBRanks[ sid ].text
        TTTSBRanks[ sid ].text = rank

        ULib.fileWrite( dir .. ranks, util.TableToJSON( TTTSBRanks ) )
        ulx.fancyLogAdmin( calling_ply, "#A changed the scoreboard rank text of #T from #s to #s", target_ply, oldRank, rank )
    else
        ULib.tsayError( calling_ply, "This player does not have a custom rank text." )
    end

    TTTSBRanksRefresh()
end
local changeranktext = ulx.command( CATEGORY_NAME, "ulx changeranktext", ulx.changeranktext, "!changeranktext" )
changeranktext:addParam{ type=ULib.cmds.PlayerArg }
changeranktext:addParam{ type=ULib.cmds.StringArg, hint="New rank of player" }
changeranktext:defaultAccess( ULib.ACCESS_ADMIN )
changeranktext:help( "Changes only the scoreboard rank text of a player's rank." )

function ulx.changerankcolor( calling_ply, target_ply, red, green, blue )
    TTTSBRanksRefresh()

    local sid = target_ply:SteamID()
    if not TTTSBRanks[ sid ].color or not TTTSBRanks[ sid ].color == "colors" then
        ULib.tsayError( calling_ply, "This player does not have an existing colored rank." )
    else
        local oldRed = TTTSBRanks[ sid ].r
        local oldGreen = TTTSBRanks[ sid ].g
        local oldBlue = TTTSBRanks[ sid ].b
        TTTSBRanks[ sid ].r = red
        TTTSBRanks[ sid ].b = green
        TTTSBRanks[ sid ].g = blue

        ULib.fileWrite( dir .. ranks, util.TableToJSON( TTTSBRanks ) )
        ulx.fancyLogAdmin( calling_ply, "#A changed the scoreboard rank color of #T from #i, #i, #i to #i, #i, #i.", target_ply, oldRed, oldGreen, oldBlue, red, green, blue )
    end

    TTTSBRanksRefresh()
end
local changerankcolor = ulx.command( CATEGORY_NAME, "ulx changerankcolor", ulx.changerankcolor, "!changerankcolor" )
changerankcolor:addParam{ type=ULib.cmds.PlayerArg }
changerankcolor:addParam{ type=ULib.cmds.NumArg, min=0, max=255, default=255, hint="Red part of RGB" }
changerankcolor:addParam{ type=ULib.cmds.NumArg, min=0, max=255, default=255, hint="Green part of RGB" }
changerankcolor:addParam{ type=ULib.cmds.NumArg, min=0, max=255, default=255, hint="Blue part of RGB" }
changerankcolor:defaultAccess( ULib.ACCESS_ADMIN )
changerankcolor:help( "Changes only the scoreboard rank COLOR of a player's rank." )

function ulx.changerankcolorid( calling_ply, sid, red, green, blue )
    TTTSBRanksRefresh()

    if ULib.isValidSteamID( sid ) then
        if not TTTSBRanks[ sid ].color or not TTTSBRanks[ sid ].color == "colors" then
            ULib.tsayError( calling_ply, "#s does not have an existing colored rank.", sid )
        else
            local sidFormat = sid
            local checkPly = ULib.getPlyByID( sid )

            if checkPly then
                sidFormat = checkPly:Nick() .. " (" .. sid .. ")"
            end

            local oldRed = TTTSBRanks[ sid ].r
            local oldGreen = TTTSBRanks[ sid ].g
            local oldBlue = TTTSBRanks[ sid ].b
            TTTSBRanks[ sid ].r = red
            TTTSBRanks[ sid ].b = green
            TTTSBRanks[ sid ].g = blue

            ULib.fileWrite( dir .. ranks, util.TableToJSON( TTTSBRanks ) )
            ulx.fancyLogAdmin( calling_ply, "#A changed the scoreboard rank color for #s from #i, #i, #i to #i, #i, #i.", sidFormat, oldRed, oldGreen, oldBlue, red, green, blue )
        end
    else
        ULib.tsayError( calling_ply, "Not a valid Steam ID." )
    end

    TTTSBRanksRefresh()
end
local changerankcolorid = ulx.command( CATEGORY_NAME, "ulx changerankcolorid", ulx.changerankcolorid, "!changerankcolorid" )
changerankcolorid:addParam{ type=ULib.cmds.StringArg, hint="Steam ID of player" }
changerankcolorid:addParam{ type=ULib.cmds.NumArg, min=0, max=255, default=255, hint="Red part of RGB" }
changerankcolorid:addParam{ type=ULib.cmds.NumArg, min=0, max=255, default=255, hint="Green part of RGB" }
changerankcolorid:addParam{ type=ULib.cmds.NumArg, min=0, max=255, default=255, hint="Blue part of RGB" }
changerankcolorid:defaultAccess( ULib.ACCESS_ADMIN )
changerankcolorid:help( "Changes only the scoreboard rank COLOR of a player's rank using their Steam ID." )

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

function ulx.removeranktext( calling_ply, target_ply )
    TTTSBRanksRefresh()

    local sid = target_ply:SteamID()

    if TTTSBRanks[ sid ] and TTTSBRanks[ sid ].text then
        TTTSBRanks[ sid ].text = nil

        ULib.fileWrite( dir .. ranks, util.TableToJSON( TTTSBRanks ) )
        ulx.fancyLogAdmin( calling_ply, "#A removed the scoreboard rank text of #T", target_ply )
    else
        ULib.tsayError( calling_ply, "This player does not have a scoreboard rank text." )
    end

    TTTSBRanksRefresh()
end
local removeranktext = ulx.command( CATEGORY_NAME, "ulx removeranktext", ulx.removeranktext, "!removeranktext" )
removeranktext:addParam{ type=ULib.cmds.PlayerArg }
removeranktext:defaultAccess( ULib.ACCESS_ADMIN )
removeranktext:help( "Removes a player's scoreboard rank text." )

function ulx.removeranktextid( calling_ply, sid )
    TTTSBRanksRefresh()

    if ULib.isValidSteamID( sid ) then
        if TTTSBRanks[ sid ] and TTTSBRanks[ sid ].text then
            TTTSBRanks[ sid ].text = nil

            local sidFormat = sid
            local checkPly = ULib.getPlyByID( sid )

            if checkPly then
                sidFormat = checkPly:Nick() .. " (" .. sid .. ")"
            end

            ULib.fileWrite( dir .. ranks, util.TableToJSON( TTTSBRanks ) )
            ulx.fancyLogAdmin( calling_ply, "#A removed the scoreboard rank text of #s", sidFormat )
        end
    else
        ULib.tsayError( calling_ply, "This is not a valid Steam ID." )
    end

    TTTSBRanksRefresh()
end

function ulx.removerankcolor( calling_ply, target_ply )
    TTTSBRanksRefresh()

    local sid = target_ply:SteamID()

    if TTTSBRanks[ sid ] and TTTSBRanks[ sid ].color then
        TTTSBRanks[ sid ].color = nil
        TTTSBRanks[ sid ].r = nil
        TTTSBRanks[ sid ].g = nil
        TTTSBRanks[ sid ].b = nil

        ULib.fileWrite( dir .. ranks, util.TableToJSON( TTTSBRanks ) )
        ulx.fancyLogAdmin( target_ply, "#A removed the custom rank color of #T", target_ply )
    else
        ULib.tsayError( calling_ply, "This player does not have a custom rank color." )
    end

    TTTSBRanksRefresh()
end
local removerankcolor = ulx.command( CATEGORY_NAME, "ulx removerankcolor", ulx.removerankcolor, "!removerankcolor" )
removerankcolor:addParam{ type=ULib.cmds.PlayerArg }
removerankcolor:defaultAccess( ULib.ACCESS_ADMIN )
removerankcolor:help( "Removes a player's scoreboard rank color." )

function ulx.removerankcolorid( calling_ply, sid )
    TTTSBRanksRefresh()

    if ULib.isValidSteamID( sid ) then
        if TTTSBRanks[ sid ] and TTTSBRanks[ sid ].color then
            TTTSBRanks[ sid ].color = nil
            TTTSBRanks[ sid ].r = nil
            TTTSBRanks[ sid ].g = nil
            TTTSBRanks[ sid ].b = nil

            local sidFormat = sid
            local checkPly = ULib.getPlyByID( sid )

            if checkPly then
                sidFormat = checkPly:Nick() .. " (" .. sid .. ")"
            end

            ULib.fileWrite( dir .. ranks, util.TableToJSON( TTTSBRanks ) )
            ulx.fancyLogAdmin( target_ply, "#A removed the custom rank color of #s", sidFormat )
        end
    else
        ULib.tsayError( calling_ply, "This is not a valid Steam ID." )
    end

    TTTSBRanksRefresh()
end
local removerankcolorid = ulx.command( CATEGORY_NAME, "ulx removerankcolorid", ulx.removerankcolorid, "!removerankcolorid" )
removerankcolorid:addParam{ type=ULib.cmds.StringArg, hint="Steam ID for player" }
removerankcolorid:defaultAccess( ULib.ACCESS_ADMIN )
removerankcolorid:help( "Removes a player's scoreboard rank color using their Steam ID." )

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
    ULib.fileWrite( dir .. settings, util.TableToJSON( TTTSBSettings ) )
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

function ulx.setnamecolor( calling_ply, target_ply, red, green, blue )
    TTTSBRanksRefresh()

    TTTSBNamecolors[ target_ply:SteamID() ] = { r = red, g = green, b = blue }
    ULib.fileWrite( dir .. namecolors, util.TableToJSON( TTTSBNamecolors ) )
    ulx.fancyLogAdmin( calling_ply, "#A set the namecolor of #T to #i, #i, #i", target_ply, red, green, blue )

    TTTSBRanksRefresh()
end
local setnamecolor = ulx.command( CATEGORY_NAME, "ulx setnamecolor", ulx.setnamecolor, "!setnamecolor" )
setnamecolor:addParam{ type=ULib.cmds.PlayerArg }
setnamecolor:addParam{ type=ULib.cmds.NumArg, min=0, max=255, default=255, hint="Red part of RGB" }
setnamecolor:addParam{ type=ULib.cmds.NumArg, min=0, max=255, default=255, hint="Green part of RGB" }
setnamecolor:addParam{ type=ULib.cmds.NumArg, min=0, max=255, default=255, hint="Blue part of RGB" }
setnamecolor:defaultAccess( ULib.ACCESS_ADMIN )
setnamecolor:help( "Allows you to change the namecolor on the scoreboard for a specific player." )

function ulx.setnamecolorid( calling_ply, sid, red, green, blue )
    TTTSBRanksRefresh()

    if not ULib.isValidSteamID( sid ) then
        ULib.tsayError( calling_ply, "This is not a valid Steam ID." )
    else
        TTTSBNamecolors[ sid ] = { r = red, g = green, b = blue }
        ULib.fileWrite( dir .. namecolors, util.TableToJSON( TTTSBNamecolors ) )
        ulx.fancyLogAdmin( calling_ply, "#A set the namecolor of #T to #i, #i, #i", target_ply, red, green, blue )
    end

    TTTSBRanksRefresh()
end
local setnamecolorid = ulx.command( CATEGORY_NAME, "ulx setnamecolorid", ulx.setnamecolorid, "!setnamecolorid" )
setnamecolorid:addParam{ type=ULib.cmds.StringArg, hint="Steam ID for player" }
setnamecolorid:addParam{ type=ULib.cmds.NumArg, min=0, max=255, default=255, hint="Red part of RGB" }
setnamecolorid:addParam{ type=ULib.cmds.NumArg, min=0, max=255, default=255, hint="Green part of RGB" }
setnamecolorid:addParam{ type=ULib.cmds.NumArg, min=0, max=255, default=255, hint="Blue part of RGB" }
setnamecolorid:defaultAccess( ULib.ACCESS_ADMIN )
setnamecolorid:help( "Allows you to change the namecolor on the scoreboard for a specific player using their Steam ID." )

function ulx.refreshranks( calling_ply )
    TTTSBRanksRefresh()
    ulx.fancyLogAdmin( calling_ply, true, "#A refreshed the scoreboard ranks manually." )
end
local refreshranks = ulx.command( CATEGORY_NAME, "ulx refreshranks", ulx.refreshranks, "!refreshranks", true )
refreshranks:defaultAccess( ULib.ACCESS_SUPERADMIN )
refreshranks:help( "Manually refreshes the ranks, in case you have edited the configs manually (not recommended to do)." )
