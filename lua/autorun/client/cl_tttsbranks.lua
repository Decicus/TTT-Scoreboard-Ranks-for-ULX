local TTTSBRanks = {}
local TTTSBSettings = {}
local TTTSBGroups = {}
local TTTSBNamecolors = {}

net.Receive( "ULX_TTTSBRanks", function()
    TTTSBRanks = net.ReadTable()
    TTTSBSettings = net.ReadTable()
    TTTSBGroups = net.ReadTable()
    TTTSBNamecolors = net.ReadTable()
    gamemode.Call( "ScoreboardCreate" )
    if not input.IsKeyDown( KEY_TAB ) then
        gamemode.Call( "ScoreboardHide" ) -- Only hide if player isn't using scoreboard.
    end
end )

-- Based on rejax's "TTT Easy Scoreboard": https://github.com/rejax/TTT-EasyScoreboard
local function rainbow()
    local f = 0.5
    local t = RealTime()
    local r = math.sin( f * t ) * 127 + 128
    local g = math.sin( f * t + 2 ) * 127 + 128
    local b = math.sin( f * t + 4 ) * 127 + 128
    return Color( r, g, b )
end

function TTTSBRanksDisplay( panel )
    panel:AddColumn( TTTSBSettings[ "column_name" ], function( ply, label )
        local plyR = TTTSBRanks[ ply:SteamID() ]
        local groupR = TTTSBGroups[ ply:GetUserGroup() ]
        local settings = TTTSBSettings

        if plyR then
            if plyR.color == "colors" or not plyR.color then -- if plyR.color isn't set, assume to fallback to default.
                local defColors = settings[ "default_color" ]
                local red = plyR.r or defColors.r
                local green = plyR.g or defColors.g
                local blue = plyR.b or defColors.b
                label:SetTextColor( Color( red, green, blue ) )
            else
                label:SetTextColor( rainbow() )
            end

            return plyR[ "text" ] or settings[ "default_rank" ]
        elseif groupR then
            if groupR.color == "colors" then
                label:SetTextColor( Color( groupR.r, groupR.g, groupR.b ) )
            else
                label:SetTextColor( rainbow() )
            end

            return groupR[ "text" ]
        else
            local colors = settings[ "default_color" ]
            label:SetTextColor( Color( colors.r, colors.g, colors.b ) )
            return settings[ "default_rank" ]
        end
    end, TTTSBSettings[ "column_width" ] )
end
hook.Add( "TTTScoreboardColumns", "TTTSBRanksDisplay", TTTSBRanksDisplay )

function TTTSBNamecolorsDisplay( ply )
    local defColors = TTTSBSettings[ "default_namecolor" ]
    if TTTSBNamecolors[ ply:SteamID() ] then
        local colors = TTTSBNamecolors[ ply:SteamID() ]
        return Color( colors.r, colors.g, colors.b )
    else
        return Color( defColors.r, defColors.g, defColors.b ) or nil
    end
end
hook.Add( "TTTScoreboardColorForPlayer", "TTTSBNamecolorsDisplay", TTTSBNamecolorsDisplay )
