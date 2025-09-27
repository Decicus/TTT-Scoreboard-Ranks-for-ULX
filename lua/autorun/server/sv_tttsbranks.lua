hook.Add("Initialize", "ULX_TTTSBRanks_Initialize", function()
    -- Update all data, typically only sent when they first load into the map.
    util.AddNetworkString("ULX_TTTSBRanks")

    -- Update a single player, typically sent when their rank changes.
    util.AddNetworkString("ULX_TTTSBRanks_UpdatePlayer")
    -- Update settings, typically sent when settings change.
    util.AddNetworkString("ULX_TTTSBRanks_UpdateSettings")
    -- Update groups, typically sent when groups change.
    util.AddNetworkString("ULX_TTTSBRanks_UpdateGroups")
end)

-- Fill in placeholders after ULX has loaded.
hook.Add(ulx.HOOK_ULXDONELOADING, "ULX_TTTSBRanks_Placeholders", function()
    local dir = "data/ttt_sb_ranks/"
    local settingsFile = "settings.txt"
    local defaultSettings = {
        ["default_rank"] = "Guest",
        ["column_name"] = "Rank",
        ["column_width"] = 80
    }

    if not ULib.fileExists(dir) then
        ULib.fileCreateDir(dir)
    end

    if not ULib.fileExists(dir .. settingsFile) then
        ULib.fileWrite(dir .. settingsFile, util.TableToJSON(defaultSettings))
    end
end)
