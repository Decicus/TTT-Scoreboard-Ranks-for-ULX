hook.Add( "Initialize", "ULX_TTTSBRanks_Initialize", function()
    util.AddNetworkString( "ULX_TTTSBRanks" )
end )

-- Version checking
hook.Add( "PlayerInitialSpawn", "ULX_TTTSBRanks_VersionCheck", function( ply )
    local version = "1.0"
    http.Fetch( "https://www.thomassen.xyz/tttsbranks/version.txt", function( body, len, headers, status_code )
        local body = tostring( body )
        if body ~= version then
            if ply:IsSuperAdmin() then
                ply:ChatPrint( "TTT Scoreboard Ranks for ULX is out of date!\nThe newest version is " .. body .. " - You are currently running " .. version .. "\nGet the new version at: http://decic.us/tttsbranks" )
            end 
        end
    end )
end )

-- Fill in placeholders after ULX has loaded.
hook.Add( ulx.HOOK_ULXDONELOADING, "ULX_TTTSBRanks_Placeholders", function()
    local dir = "data/ttt_sb_ranks/"
    local settingsFile = "settings.txt"
    local defaultSettings = {
        [ "default_rank" ] = "Guest",
        [ "column_name" ] = "Rank",
        [ "column_width" ] = 80
    }
    
    if not ULib.fileExists( dir ) then ULib.fileCreateDir( dir ) end
    if not ULib.fileExists( dir .. settingsFile ) then ULib.fileWrite( dir .. settingsFile, util.TableToJSON( defaultSettings ) ) end
end )