-- TTT Scoreboard Ranks for ULX --

local CATEGORY_NAME = "TTT SB Ranks"
local dir = "data/ttt_sb_ranks/"
local ranks = "ranks.txt"
local settings = "settings.txt"

local TTTSBRanks = {}
local TTTSBSettings = {
    "default_rank" = "Guest",
    "column_name" = "Rank",
    "column_width" = 80
}

local function TTTSBRanksRefresh()

    if not ULib.fileExists( dir ) then ULib.fileCreateDir( dir ) end
    if ULib.fileRead( dir .. ranks ) then TTTSBRanks = util.JSONToTable( ULib.fileRead( dir .. ranks ) ) end
    if ULib.fileRead( dir .. settings ) then TTTSBSettings = util.JSONToTable( ULib.fileRead( dir .. settings ) ) end
    
    if SERVER then
    
        net.Start( "ULX_TTTSBRanks" )
            net.WriteTable( TTTSBRanks )
            net.WriteTable( TTTSBSettings )
        net.Broadcast()
        
    end
    
    print( "TTT Scoreboard Ranks for ULX successfully refreshed." )

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
addrank:help( "Adds a custom scoreboard rank with RGB colorcodes." )

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


function ulx.columnwidth( calling_ply, width )

    TTTSBRanksRefresh()
    
    TTTSBSettings[ "column_width" ] = width
    ULib.fileWrite( dir .. settings, util.TableToJSON( TTTSBSettings ) )
    ulx.fancyLogAdmin( calling_ply, true, "#A changed the column width to #i", width )
    
    TTTSBRanksRefresh()
    
end
local columnwidth = ulx.command( CATEGORY_NAME, "ulx columnwidth", ulx.columnwidth, "!columnwidth", true )
columnwidth:addParam{ type=ULib.cmds.NumArg, min=10, max=1000, default=80, hint="Width of the rank column" }
columnwidth:defaultAccess( ULib.ACCESS_SUPERADMIN )
columnwidth:help( "Changes the column width in the scoreboard." )