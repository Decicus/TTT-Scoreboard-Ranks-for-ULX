-- TTT Scoreboard Ranks for ULX --

-- Very minor performance improvement by caching ULib and ulx in local variables
local ULib = ULib
local ulx = ulx

local CATEGORY_NAME = "TTT Scoreboard Ranks"
local dir = "data/ttt_sb_ranks/"
local ranks = "ranks.txt"
local settings = "settings.txt"
local groups = "groups.txt"

local TTTSBRanks = {}

-- Load settings with initial defaults
-- Gets overwritten when loading from file
local TTTSBSettings = {
    ["default_rank"] = "Guest",
    ["column_name"] = "Rank",
    ["column_width"] = 80
}

local TTTSBGroups = {}

-- Cache of group names used for command completion.
local groupNames = {}

--[[
    Used to load data from files into the tables
    The saved files are considered the "Source of Truth"
    Any external edits done directly on the data files, will override any in-memory changes done by ULX commands while the server is running.
--]]
local function LoadRankDataFromFiles()
    if not ULib.fileExists(dir) then
        ULib.fileCreateDir(dir)
    end

    if ULib.fileRead(dir .. ranks) then
        TTTSBRanks = util.JSONToTable(ULib.fileRead(dir .. ranks))
    end

    if ULib.fileRead(dir .. settings) then
        TTTSBSettings = util.JSONToTable(ULib.fileRead(dir .. settings))
    end

    if ULib.fileRead(dir .. groups) then
        TTTSBGroups = util.JSONToTable(ULib.fileRead(dir .. groups))
    end
end
LoadRankDataFromFiles() -- Load data when script is loaded

local function SaveRankDataToFile()
    ULib.fileWrite(dir .. ranks, util.TableToJSON(TTTSBRanks))
end

local function SaveGroupsDataToFile()
    ULib.fileWrite(dir .. groups, util.TableToJSON(TTTSBGroups))
end

local function SaveSettingsToFile()
    ULib.fileWrite(dir .. settings, util.TableToJSON(TTTSBSettings))
end

local function SaveAllFiles()
    SaveRankDataToFile()
    SaveGroupsDataToFile()
    SaveSettingsToFile()
end

local function TTTSBRanksRefresh(ply)
    LoadRankDataFromFiles()

    if SERVER then
        net.Start("ULX_TTTSBRanks")
        net.WriteTable(TTTSBRanks)
        net.WriteTable(TTTSBSettings)
        net.WriteTable(TTTSBGroups)

        if ply then
            net.Send(ply)
        else
            net.Broadcast()
        end
    end
end
hook.Add("PlayerInitialSpawn", "ULXTTTRefresh_PlayerJoin", TTTSBRanksRefresh)

--[[
    Sends an update to all clients about a specific player's rank.
    This is useful when a player's rank is changed while they are connected,
    ensuring that the change is reflected immediately on their scoreboard.
--]]
local function UpdatePlayerRank(ply)
    if type(ply) ~= "Player" and type(ply) ~= "string" then
        return
    end

    -- Assume input is a SteamID by default
    local steamId = ply
    if IsValid(ply) and ply:IsPlayer() then
        steamId = ply:SteamID()
    end

    local playerRank = TTTSBRanks[steamId] or {}

    net.Start("ULX_TTTSBRanks_UpdatePlayer")
    net.WriteString(steamId)
    net.WriteTable(playerRank)
    net.Broadcast()
end

-- Sends an update to all clients about the rank settings.
local function UpdateSettings()
    LoadRankDataFromFiles()

    net.Start("ULX_TTTSBRanks_UpdateSettings")
    net.WriteTable(TTTSBSettings)
    net.Broadcast()
end

-- Sends an update to all clients about the group ranks.
local function UpdateGroupsData()
    LoadRankDataFromFiles()

    net.Start("ULX_TTTSBRanks_UpdateGroups")
    net.WriteTable(TTTSBGroups)
    net.Broadcast()
end

local function updateGroups()
    table.Empty(groupNames)

    for group, _ in pairs(ULib.ucl.groups) do
        if group ~= ULib.ACCESS_ALL then -- "user" would fallback to the default rank.
            table.insert(groupNames, group)
        end
    end
end

updateGroups() -- Call when script is loaded.
hook.Add(ULib.HOOK_UCLCHANGED, "ULX_TTTSBRanks_groupNames", updateGroups)

function ulx.addrank(calling_ply, target_ply, rank, red, green, blue)
    local sid = target_ply:SteamID()

    if TTTSBRanks[sid] then
        local errorMessage = string.format("The player %s (%s) already has a rank. Please use the command 'changerank' to modify an existing rank.", target_ply:Nick(), sid)
        ULib.tsayError(calling_ply, errorMessage)
        return
    end

    local sidRank = {text = rank, color = "colors", r = red, g = green, b = blue}

    TTTSBRanks[sid] = sidRank

    SaveRankDataToFile()
    ulx.fancyLogAdmin(calling_ply, "#A set the scoreboard rank of #T to #s with color: #i, #i, #i ", target_ply, rank, red, green, blue)

    UpdatePlayerRank(target_ply)
end

local addrank = ulx.command(CATEGORY_NAME, "ulx addrank", ulx.addrank, "!addrank")
addrank:addParam{type = ULib.cmds.PlayerArg}
addrank:addParam{type = ULib.cmds.StringArg, hint = "Custom rank text"}
addrank:addParam{type = ULib.cmds.NumArg, min = 0, max = 255, default = 255, hint = "Red part of RGB"}
addrank:addParam{type = ULib.cmds.NumArg, min = 0, max = 255, default = 255, hint = "Green part of RGB"}
addrank:addParam{type = ULib.cmds.NumArg, min = 0, max = 255, default = 255, hint = "Blue part of RGB"}
addrank:defaultAccess(ULib.ACCESS_ADMIN)
addrank:help("Adds a custom scoreboard rank for a connected player with RGB colorcodes.")

function ulx.addrankid(calling_ply, sid, rank, red, green, blue)
    LoadRankDataFromFiles()

    if not ULib.isValidSteamID(sid) then
        ULib.tsayError(calling_ply, "This is not a valid Steam ID: " .. sid)
        return
    end

    if TTTSBRanks[sid] then
        local errorMessage = string.format("The Steam ID %s already has a rank. Please use the command 'changerankid' to modify an existing rank using the player's Steam ID.", sid)
        ULib.tsayError(calling_ply, errorMessage)
        return
    end

    local sidRank = {text = rank, color = "colors", r = red, g = green, b = blue}

    TTTSBRanks[sid] = sidRank

    SaveRankDataToFile()

    local sidFormat = sid

    -- Player is currently on the server
    local checkPly = ULib.getPlyByID(sid)
    if checkPly then
        sidFormat = string.format("%s (%s)", checkPly:Nick(), sid)
    end

    ulx.fancyLogAdmin(calling_ply, "#A set the scoreboard rank of #s to #s with color: #i, #i, #i", sidFormat, rank, red, green, blue)
    UpdatePlayerRank(sid)
end

local addrankid = ulx.command(CATEGORY_NAME, "ulx addrankid", ulx.addrankid, "!addrankid")
addrankid:addParam{type = ULib.cmds.StringArg, hint = "Steam ID of player"}
addrankid:addParam{type = ULib.cmds.StringArg, hint = "Custom rank text"}
addrankid:addParam{type = ULib.cmds.NumArg, min = 0, max = 255, default = 255, hint = "Red part of RGB"}
addrankid:addParam{type = ULib.cmds.NumArg, min = 0, max = 255, default = 255, hint = "Green part of RGB"}
addrankid:addParam{type = ULib.cmds.NumArg, min = 0, max = 255, default = 255, hint = "Blue part of RGB"}
addrankid:defaultAccess(ULib.ACCESS_ADMIN)
addrankid:help("Adds a custom scoreboard rank for a Steam ID with RGB colorcodes.")

function ulx.rainbowrank(calling_ply, target_ply, rank)
    local sid = target_ply:SteamID()

    LoadRankDataFromFiles()

    TTTSBRanks[sid] = {text = rank, color = "rainbow", r = 0, g = 0, b = 0}
    SaveRankDataToFile()

    ulx.fancyLogAdmin(calling_ply, "#A set the scoreboard rank of #T to #s with rainbow colors.", target_ply, rank)

    UpdatePlayerRank(target_ply)
end

local rainbowrank = ulx.command(CATEGORY_NAME, "ulx rainbowrank", ulx.rainbowrank, "!rainbowrank")
rainbowrank:addParam{type = ULib.cmds.PlayerArg}
rainbowrank:addParam{type = ULib.cmds.StringArg, hint = "Custom rank text"}
rainbowrank:defaultAccess(ULib.ACCESS_ADMIN)
rainbowrank:help("Adds or changes a custom scoreboard rank's color to a rainbow-loop")

function ulx.rainbowrankid(calling_ply, sid, rank)
    LoadRankDataFromFiles()

    if not ULib.isValidSteamID(sid) then
        ULib.tsayError(calling_ply, "This is not a valid Steam ID: " .. sid)
        return
    end

    TTTSBRanks[sid] = {text = rank, color = "rainbow", r = 0, g = 0, b = 0}
    SaveRankDataToFile()

    local sidFormat = sid

    -- Player is currently on the server
    local checkPly = ULib.getPlyByID(sid)
    if checkPly then
        sidFormat = string.format("%s (%s)", checkPly:Nick(), sid)
    end

    ulx.fancyLogAdmin(calling_ply, "#A set the scoreboard rank of #s to #s with rainbow colors.", sidFormat, rank)
    UpdatePlayerRank(sid)
end

local rainbowrankid = ulx.command(CATEGORY_NAME, "ulx rainbowrankid", ulx.rainbowrankid, "!rainbowrankid")
rainbowrankid:addParam{type = ULib.cmds.StringArg, hint = "Steam ID for player"}
rainbowrankid:addParam{type = ULib.cmds.StringArg, hint = "Custom rank text"}
rainbowrankid:defaultAccess(ULib.ACCESS_ADMIN)
rainbowrankid:help("Adds or changes a custom scoreboard rank's color to a rainbow-loop using Steam ID")

function ulx.changerank(calling_ply, target_ply, rank, red, green, blue)
    LoadRankDataFromFiles()

    local sid = target_ply:SteamID()

    if not TTTSBRanks[sid] then
        local errorMessage = string.format("The player %s does not have an existing rank.", target_ply:Nick())
        ULib.tsayError(calling_ply, errorMessage)
        return
    end

    TTTSBRanks[sid] = {text = rank, color = "colors", r = red, g = green, b = blue}

    SaveRankDataToFile()
    ulx.fancyLogAdmin(calling_ply, "#A changed the scoreboard rank of #T to #s with color: #i, #i, #i", target_ply, rank, red, green, blue)

    UpdatePlayerRank(target_ply)
end

local changerank = ulx.command(CATEGORY_NAME, "ulx changerank", ulx.changerank, "!changerank")
changerank:addParam{type = ULib.cmds.PlayerArg}
changerank:addParam{type = ULib.cmds.StringArg, hint = "Custom rank text"}
changerank:addParam{type = ULib.cmds.NumArg, min = 0, max = 255, default = 255, hint = "Red part of RGB"}
changerank:addParam{type = ULib.cmds.NumArg, min = 0, max = 255, default = 255, hint = "Green part of RGB"}
changerank:addParam{type = ULib.cmds.NumArg, min = 0, max = 255, default = 255, hint = "Blue part of RGB"}
changerank:defaultAccess(ULib.ACCESS_ADMIN)
changerank:help("Changes an existing scoreboard rank to different text and color.")

function ulx.changerankid(calling_ply, sid, rank, red, green, blue)
    LoadRankDataFromFiles()

    if not ULib.isValidSteamID(sid) then
        ULib.tsayError(calling_ply, "This is not a valid Steam ID: " .. sid)
        return
    end

    if not TTTSBRanks[sid] then
        local errorMessage = string.format("The Steam ID %s does not have an existing rank.", sid)
        ULib.tsayError(calling_ply, errorMessage)
        return
    end

    TTTSBRanks[sid] = {text = rank, color = "colors", r = red, g = green, b = blue}

    SaveRankDataToFile()

    local sidFormat = sid

    -- Player is currently on the server
    local checkPly = ULib.getPlyByID(sid)
    if checkPly then
        sidFormat = string.format("%s (%s)", checkPly:Nick(), sid)
    end

    ulx.fancyLogAdmin(calling_ply, "#A changed the scoreboard rank of #s to #s with color: #i, #i, #i", sidFormat, rank, red, green, blue)

    UpdatePlayerRank(sid)
end

local changerankid = ulx.command(CATEGORY_NAME, "ulx changerankid", ulx.changerankid, "!changerankid")
changerankid:addParam{type = ULib.cmds.StringArg, hint = "Steam ID for player"}
changerankid:addParam{type = ULib.cmds.StringArg, hint = "Custom rank text"}
changerankid:addParam{type = ULib.cmds.NumArg, min = 0, max = 255, default = 255, hint = "Red part of RGB"}
changerankid:addParam{type = ULib.cmds.NumArg, min = 0, max = 255, default = 255, hint = "Green part of RGB"}
changerankid:addParam{type = ULib.cmds.NumArg, min = 0, max = 255, default = 255, hint = "Blue part of RGB"}
changerankid:defaultAccess(ULib.ACCESS_ADMIN)
changerankid:help("Changes an existing scoreboard rank for a Steam ID to different text and color.")

function ulx.removerank(calling_ply, target_ply)
    local sid = target_ply:SteamID()

    LoadRankDataFromFiles()

    if not TTTSBRanks[sid] then
        local errorMessage = string.format("The player %s (%s) currently does not have a custom rank, there's nothing to remove.", target_ply:Nick(), sid)
        ULib.tsayError(calling_ply, errorMessage)
        return
    end

    TTTSBRanks[sid] = nil

    SaveRankDataToFile()
    ulx.fancyLogAdmin(calling_ply, "#A removed the scoreboard rank of #T", target_ply)
    UpdatePlayerRank(target_ply)
end

local removerank = ulx.command(CATEGORY_NAME, "ulx removerank", ulx.removerank, "!removerank")
removerank:addParam{type = ULib.cmds.PlayerArg}
removerank:defaultAccess(ULib.ACCESS_ADMIN)
removerank:help("Removes a players scoreboard rank.")

function ulx.removerankid(calling_ply, sid)
    LoadRankDataFromFiles()

    if not ULib.isValidSteamID(sid) then
        ULib.tsayError(calling_ply, "This is not a valid Steam ID: " .. sid)
        return
    end

    if not TTTSBRanks[sid] then
        local errorMessage = string.format("The Steam ID %s currently does not have a custom rank, there's nothing to remove.", sid)
        ULib.tsayError(calling_ply, errorMessage)
        return
    end

    TTTSBRanks[sid] = nil
    SaveRankDataToFile()

    local sidFormat = sid
    local checkPly = ULib.getPlyByID(sid)

    if checkPly then
        sidFormat = checkPly:Nick() .. " (" .. sid .. ")"
    end

    ulx.fancyLogAdmin(calling_ply, "#A removed the scoreboard rank of #s", sidFormat)
    UpdatePlayerRank(sid)
end

local removerankid = ulx.command(CATEGORY_NAME, "ulx removerankid", ulx.removerankid, "!removerankid")
removerankid:addParam{type = ULib.cmds.StringArg, hint = "Steam ID for player"}
removerankid:defaultAccess(ULib.ACCESS_ADMIN)
removerankid:help("Removes a scoreboard rank for a Steam ID")

function ulx.columnname(calling_ply, name)
    LoadRankDataFromFiles()

    name = string.Trim(name)
    if name == "" then
        ULib.tsayError(calling_ply, "Column name cannot be blank!")
        return
    end

    TTTSBSettings["column_name"] = name

    SaveSettingsToFile()
    ulx.fancyLogAdmin(calling_ply, true, "#A changed the scoreboard rank column name to \"#s\"", name)
    UpdateSettings()
end

local columnname = ulx.command(CATEGORY_NAME, "ulx columnname", ulx.columnname, "!columnname", true)
columnname:addParam{type = ULib.cmds.StringArg}
columnname:defaultAccess(ULib.ACCESS_SUPERADMIN)
columnname:help("Modifies the name of the column itself, that is displayed at the top of the scoreboard.")

function ulx.defaultrank(calling_ply, rank)
    LoadRankDataFromFiles()

    TTTSBSettings["default_rank"] = rank

    SaveSettingsToFile()
    ulx.fancyLogAdmin(calling_ply, true, "#A changed the default rank to \"#s\"", rank)

    UpdateSettings()
end

local defaultrank = ulx.command(CATEGORY_NAME, "ulx defaultrank", ulx.defaultrank, "!defaultrank", true)
defaultrank:addParam{type = ULib.cmds.StringArg}
defaultrank:defaultAccess(ULib.ACCESS_SUPERADMIN)
defaultrank:help("Changes the default rank for players without a custom rank.")

function ulx.defaultcolor(calling_ply, red, green, blue)
    LoadRankDataFromFiles()

    TTTSBSettings["default_color"] = {red = red, green = green, blue = blue}

    SaveSettingsToFile()
    ulx.fancyLogAdmin(calling_ply, true, "#A changed the color of the default rank to color: #i, #i, #i", red, green, blue)

    UpdateSettings()
end
local defaultcolor = ulx.command(CATEGORY_NAME, "ulx defaultcolor", ulx.defaultcolor, "!defaultcolor", true)
defaultcolor:addParam{type = ULib.cmds.NumArg, min = 0, max = 255, default = 255, hint = "Red part of RGB"}
defaultcolor:addParam{type = ULib.cmds.NumArg, min = 0, max = 255, default = 255, hint = "Green part of RGB"}
defaultcolor:addParam{type = ULib.cmds.NumArg, min = 0, max = 255, default = 255, hint = "Blue part of RGB"}
defaultcolor:defaultAccess(ULib.ACCESS_ADMIN)
defaultcolor:help("Sets the color of the default rank. Default is 255, 255, 255 (white)")

function ulx.columnwidth(calling_ply, width)
    LoadRankDataFromFiles()

    TTTSBSettings["column_width"] = width

    SaveSettingsToFile()
    ulx.fancyLogAdmin(calling_ply, true, "#A changed the column width to #i", width)

    UpdateSettings()
end

local columnwidth = ulx.command(CATEGORY_NAME, "ulx columnwidth", ulx.columnwidth, "!columnwidth", true)
columnwidth:addParam{type = ULib.cmds.NumArg, min = 60, max = 240, default = 80, hint = "Width of the rank column"}
columnwidth:defaultAccess(ULib.ACCESS_SUPERADMIN)
columnwidth:help("Changes the column width in the scoreboard - Default: 80")

function ulx.addgrouprank(calling_ply, group_name, rank, red, green, blue)
    LoadRankDataFromFiles()

    TTTSBGroups[group_name] = {text = rank, color = "colors", r = red, g = green, b = blue}

    SaveGroupsDataToFile()
    ulx.fancyLogAdmin(calling_ply, "#A added a rank for group #s with rank name #s and colors #i, #i, #i.", group_name, rank, red, green, blue)

    UpdateGroupsData()
end

local addgrouprank = ulx.command(CATEGORY_NAME, "ulx addgrouprank", ulx.addgrouprank, "!addgrouprank", true)
addgrouprank:addParam{type = ULib.cmds.StringArg, completes = groupNames, hint = "Group", error = "invalid group \"%s\" specified", ULib.cmds.restrictToCompletes}
addgrouprank:addParam{type = ULib.cmds.StringArg, hint = "Rank title for group"}
addgrouprank:addParam{type = ULib.cmds.NumArg, min = 0, max = 255, default = 255, hint = "Red part of RGB"}
addgrouprank:addParam{type = ULib.cmds.NumArg, min = 0, max = 255, default = 255, hint = "Green part of RGB"}
addgrouprank:addParam{type = ULib.cmds.NumArg, min = 0, max = 255, default = 255, hint = "Blue part of RGB"}
addgrouprank:defaultAccess(ULib.ACCESS_SUPERADMIN)
addgrouprank:help("Add a custom rank per group.")

function ulx.removegrouprank(calling_ply, group_name)
    LoadRankDataFromFiles()

    if not TTTSBGroups[group_name] then
        local errorMessage = string.format("The group %s does not have a custom rank.", group_name)
        ULib.tsayError(calling_ply, errorMessage)
        return
    end

    TTTSBGroups[group_name] = nil

    SaveGroupsDataToFile()
    ulx.fancyLogAdmin(calling_ply, "#A removed a rank for #s", group_name)
    UpdateGroupsData()
end

local removegrouprank = ulx.command(CATEGORY_NAME, "ulx removegrouprank", ulx.removegrouprank, "!removegrouprank", true)
removegrouprank:addParam{type = ULib.cmds.StringArg, completes = groupNames, hint = "Group", error = "invalid group \"%s\" specified", ULib.cmds.restrictToCompletes}
removegrouprank:defaultAccess(ULib.ACCESS_SUPERADMIN)
removegrouprank:help("Remove a custom rank from a group.")

function ulx.rainbowgrouprank(calling_ply, group_name, rank)
    LoadRankDataFromFiles()

    TTTSBGroups[group_name] = {text = rank, color = "rainbow", r = 255, g = 255, b = 255}

    SaveGroupsDataToFile()
    ulx.fancyLogAdmin(calling_ply, "#A added a rainbow rank for group #s, with the title #s", group_name, rank)

    UpdateGroupsData()
end

local rainbowgrouprank = ulx.command(CATEGORY_NAME, "ulx rainbowgrouprank", ulx.rainbowgrouprank, "!rainbowgrouprank", true)
rainbowgrouprank:addParam{type = ULib.cmds.StringArg, completes = groupNames, hint = "Group", error = "invalid group \"%s\" specified", ULib.cmds.restrictToCompletes}
rainbowgrouprank:addParam{type = ULib.cmds.StringArg, hint = "Rank title for group"}
rainbowgrouprank:defaultAccess(ULib.ACCESS_SUPERADMIN)
rainbowgrouprank:help("Sets a group rank to use rainbow colors.")

function ulx.refreshranks(calling_ply)
    TTTSBRanksRefresh()

    ulx.fancyLogAdmin(calling_ply, true, "#A forced a refresh of all scoreboard ranks for all players.")
end

local refreshranks = ulx.command(CATEGORY_NAME, "ulx refreshranks", ulx.refreshranks, "!refreshranks", true)
refreshranks:defaultAccess(ULib.ACCESS_SUPERADMIN)
refreshranks:help("Manually refreshes all the rank data and sends it to all connected players, in case you have edited the configs manually (not recommended to edit the configs manually).")
