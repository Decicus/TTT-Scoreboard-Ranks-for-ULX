local TTTSBRanks = {}

net.Receive( "ULX_TTTSBRanks", function()

    TTTSBRanks = net.ReadTable()

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

    panel:AddColumn( "Rank", function( ply, label )
    
        local plyR = TTTSBRanks[ ply:SteamID() ]
            
        if plyR then
                
            if plyR.color == "colors" then
                
                label:SetTextColor( Color( plyR.r, plyR.g, plyR.b ) )
                
            else
                
                label:SetTextColor( rainbow() )
                    
            end
                
            return plyR.text
                
                
        else
            
            label:SetTextColor( Color( 255, 255, 255 ) )
            return "Guest"
            
        end
        
    end, 80 )

end
hook.Add( "TTTScoreboardColumns", "TTTSBRanksDisplay", TTTSBRanksDisplay )