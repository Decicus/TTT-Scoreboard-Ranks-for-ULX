local TTTSBRanks = {}
local TTTSBSettings = {}
local TTTSBGroups = {}

-- Debug convar, to enable/disable debug messages for changes to ranks, settings etc.
local DebugConvarName = "tttsbranks_debug"
CreateClientConVar(DebugConvarName, "0", true, false, "Enable debug messages for TTT SB Ranks, on receiving network messages.")
local IsDebugMode = GetConVar("tttsbranks_debug"):GetBool()
cvars.AddChangeCallback(DebugConvarName, function(convarName, oldValue, newValue)
    IsDebugMode = tobool(tonumber(newValue) or 0)
end)

local IsScoreBoardOpen = false
hook.Add("ScoreboardShow", "ULX_TTTSBRanks_ScoreboardShow", function()
    IsScoreBoardOpen = true
end)

hook.Add("ScoreboardHide", "ULX_TTTSBRanks_ScoreboardHide", function()
    IsScoreBoardOpen = false
end)

local function ReloadScoreboard()
    -- Recreate the scoreboard to apply changes.
    gamemode.Call("ScoreboardCreate")

    if not IsScoreBoardOpen then
        gamemode.Call("ScoreboardHide")
    end
end

net.Receive("ULX_TTTSBRanks", function()
    if IsDebugMode then
        print("[ULX_TTTSBRanks] Received full update from server.")
        print("[ULX_TTTSBRanks] Old data: ")
        PrintTable(TTTSBRanks)
        print("[ULX_TTTSBRanks] Old settings: ")
        PrintTable(TTTSBSettings)
        print("[ULX_TTTSBRanks] Old groups: ")
        PrintTable(TTTSBGroups)
    end

    TTTSBRanks = net.ReadTable()
    TTTSBSettings = net.ReadTable()
    TTTSBGroups = net.ReadTable()

    if IsDebugMode then
        print("[ULX_TTTSBRanks] New data: ")
        PrintTable(TTTSBRanks)
        print("[ULX_TTTSBRanks] New settings: ")
        PrintTable(TTTSBSettings)
        print("[ULX_TTTSBRanks] New groups: ")
        PrintTable(TTTSBGroups)
    end

    ReloadScoreboard()
end)

local function HandlePlayerUpdate()
    local steamId = net.ReadString()
    local playerRank = net.ReadTable()

    -- If the received rank is an empty table, treat it as nil (no custom rank).
    if table.IsEmpty(playerRank) then
        print("[ULX_TTTSBRanks] Received empty rank table for " .. steamId .. ", treating as nil (no custom rank).")
        playerRank = nil
    end

    if IsDebugMode then
        print("[ULX_TTTSBRanks] Received player update from server for " .. steamId)
        print("[ULX_TTTSBRanks] Old rank: ")
        if TTTSBRanks[steamId] then
            PrintTable(TTTSBRanks[steamId])
        else
            print("nil (no custom rank)")
        end

        print("[ULX_TTTSBRanks] New rank: ")
        if playerRank then
            PrintTable(playerRank)
        else
            print("nil (no custom rank)")
        end
    end

    TTTSBRanks[steamId] = playerRank

    ReloadScoreboard()
end
net.Receive("ULX_TTTSBRanks_UpdatePlayer", HandlePlayerUpdate)

local function HandleSettingsUpdate()
    if IsDebugMode then
        print("[ULX_TTTSBRanks] Received settings update from server.")
        print("[ULX_TTTSBRanks] Old settings: ")
        PrintTable(TTTSBSettings)
    end

    TTTSBSettings = net.ReadTable()

    if IsDebugMode then
        print("[ULX_TTTSBRanks] New settings: ")
        PrintTable(TTTSBSettings)
    end

    ReloadScoreboard()
end
net.Receive("ULX_TTTSBRanks_UpdateSettings", HandleSettingsUpdate)

local function HandleGroupsUpdate()
    if IsDebugMode then
        print("[ULX_TTTSBRanks] Received groups update from server.")
        print("[ULX_TTTSBRanks] Old groups: ")
        PrintTable(TTTSBGroups)
    end

    TTTSBGroups = net.ReadTable()

    if IsDebugMode then
        print("[ULX_TTTSBRanks] New groups: ")
        PrintTable(TTTSBGroups)
    end

    ReloadScoreboard()
end
net.Receive("ULX_TTTSBRanks_UpdateGroups", HandleGroupsUpdate)

-- Based on rejax's "TTT Easy Scoreboard": https://github.com/rejax/TTT-EasyScoreboard
local function rainbow()
    local f = 0.5
    local t = RealTime()
    local r = math.sin(f * t) * 127 + 128
    local g = math.sin(f * t + 2) * 127 + 128
    local b = math.sin(f * t + 4) * 127 + 128

    return Color(r, g, b)
end

local function DisplayPlayerRank(ply, label)
    local rank = TTTSBRanks[ply:SteamID()]
    local group = TTTSBGroups[ply:GetUserGroup()]

    -- Player rank overrides group rank
    if rank then
        if rank.color == "colors" then
            label:SetTextColor(Color(rank.r, rank.g, rank.b))
        else
            label:SetTextColor(rainbow())
        end

        return rank.text
    end

    -- No player rank, check for group rank
    if group then
        if group.color == "colors" then
            label:SetTextColor(Color(group.r, group.g, group.b))
        else
            label:SetTextColor(rainbow())
        end

        return group.text
    end

    -- No player or group rank, use default
    local defColor = TTTSBSettings["default_color"]
    local labelColor = Color(255, 255, 255)

    if defColor ~= nil then
        labelColor = Color(defColor.red or 255, defColor.green or 255, defColor.blue or 255)
    end

    label:SetTextColor(labelColor)
    return TTTSBSettings["default_rank"]
end

function TTTSBRanksDisplay(panel)
    panel:AddColumn(TTTSBSettings["column_name"] or "", DisplayPlayerRank, TTTSBSettings["column_width"] or 80)
end
hook.Add("TTTScoreboardColumns", "TTTSBRanksDisplay", TTTSBRanksDisplay)
