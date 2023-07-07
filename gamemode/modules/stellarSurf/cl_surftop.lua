--[[
  Author: Niflheimrx
  Description: Display the top players on the server.
               This is essentially a rewrite for the menu so there's no issues with miscalculated point values
--]]

SurfTop = {}
SurfTop.Size = { [0] = { 500, 500 }, [1] = { 900, 900 } }

local panel = nil
function SurfTop:Open()
  if panel and IsValid( panel ) then panel:Remove() end
  panel = nil

  local size = SurfTop.Size[Interface.Scale]
  panel = SMPanels.HoverFrame( { title = "Top Player Leaderboards", subTitle = "List of players with the most amount of points", center = true, w = size[1], h = size[2] } )
  panel.Loading = true
end

function SurfTop:Update( data, style )
  if !panel or !IsValid(panel) then return end

  if (#data == 0) then
    panel.CustomText = "Failed to gather top leaderboards"
  return end

  if style then
    panel.Title = "Top Player Leaderboards [" .. Core:StyleName(style) .. "]"
  end

  panel.Loading = false

  local writeable = panel.Page
  local barSize = SMPanels.BarSize[Interface.Scale]

  local count = 0
  for rank,info in pairs( data ) do
    local center = "#" .. (count + 1) .. ": " .. info[1]
    local left = info[2] .. " pts"
    local right = "Rank: " .. (style == 1 and Timer:GetRankTitle( rank, info[2] ) or "Unranked")

    local function doFunc()
      if (info[3] == LocalPlayer():SteamID()) then
        RunConsoleCommand( "say", "!profile" )
      else
        RunConsoleCommand( "say", "!profile " .. info[3] )
      end

      panel:AlphaTo( 0, 0.4, 0, function() end )
      panel:SetMouseInputEnabled( false )
      panel:SetKeyboardInputEnabled( false )

      timer.Simple( 0.5, function()
        panel:Remove()
        panel = nil
      end )
    end

    local pos = Interface:GetBezel( "Medium" ) + barSize * count
    SMPanels.LongBarInfo( { parent = writeable, mtext = center, ltext = left, rtext = right, pos = pos, func = doFunc } )
    count = count + 1
  end
end
