hook.Add( "Initialize", "ULX_TTTSBRanks_Initialize", function()
    util.AddNetworkString( "ULX_TTTSBRanks" )
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