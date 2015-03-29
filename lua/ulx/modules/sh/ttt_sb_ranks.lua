-- TTT Scoreboard Ranks for ULX --

local CATEGORY_NAME = "TTT SB Ranks"
local dir = "data/ttt_sb_ranks/"
local ranks = "ranks.txt"

local TTTSBRanks = {}

local function TTTSBRanksRefresh()

    if ULib.fileRead( dir .. ranks ) then
        
        table.Empty( TTTSBRanks )
        TTTSBRanks = util.JSONToTable( ULib.fileRead( dir .. ranks ) )
        
    else
    
        TTTSBRanks = {}
        
    end
    
    if SERVER then
    
        net.Start( "ULX_TTTSBRanks" )
            net.WriteTable( TTTSBRanks )
        net.Broadcast()
        
    end
    
    
    print( "TTT Scoreboard Ranks for ULX successfully refreshed." )

end
hook.Add( "PlayerInitialSpawn", "ULXTTTRefresh_PlayerJoin", TTTSBRanksRefresh )
hook.Add( "TTTBeginRound", "ULXTTTRefresh_BeginRound", TTTSBRanksRefresh )
hook.Add( "TTTEndRound", "ULXTTTRefresh_EndRound", TTTSBRanksRefresh )

function ulx.addrank( calling_ply, target_ply, rank, red, green, blue )

    local sid = target_ply:SteamID()
    local sidRank = { text = rank, color = "colors", r = red, g = green, b = blue }
    
    TTTSBRanksRefresh()
    
    if not ULib.fileExists( dir ) then ULib.fileCreateDir( dir ) end
        
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
addrank:defaultAccess( ULib.ACCESS_SUPERADMIN )
addrank:help( "Adds a custom scoreboard rank with RGB colorcodes." )

function ulx.rainbowrank( calling_ply, target_ply, rank )

    local sid = target_ply:SteamID()
    if not ULib.fileExists( dir ) then ULib.fileCreateDir( dir ) end
    
    TTTSBRanksRefresh()
    
    TTTSBRanks[ sid ] = { text = rank, color = "rainbow", r = 0, g = 0, b = 0 }
    ULib.fileWrite( dir .. ranks, util.TableToJSON( TTTSBRanks ) )
    
    ulx.fancyLogAdmin( calling_ply, "#A set the scoreboard rank of #T to #s with rainbow colors.", target_ply, rank )
    TTTSBRanksRefresh()

end
local rainbowrank = ulx.command( CATEGORY_NAME, "ulx rainbowrank", ulx.rainbowrank, "!rainbowrank" )
rainbowrank:addParam{ type=ULib.cmds.PlayerArg }
rainbowrank:addParam{ type=ULib.cmds.StringArg, hint="Custom rank text" }
rainbowrank:defaultAccess( ULib.ACCESS_SUPERADMIN )
rainbowrank:help( "Adds or changes a custom scoreboard rank's color to a rainbow-loop" )

function ulx.changerank( calling_ply, target_ply, rank, red, green, blue )

    local sid = target_ply:SteamID()
    if not ULib.fileExists( dir ) then ULib.fileCreateDir( dir ) end
    
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
changerank:defaultAccess( ULib.ACCESS_SUPERADMIN )
changerank:help( "Changes an existing scoreboard rank to different text and color." )

function ulx.removerank( calling_ply, target_ply )
    
    local sid = target_ply:SteamID()
    if not ULib.fileExists( dir ) then ULib.fileCreateDir( dir ) end
    
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
removerank:defaultAccess( ULib.ACCESS_SUPERADMIN )
removerank:help( "Removes a players scoreboard rank." )