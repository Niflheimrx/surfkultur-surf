--[[
  Author: Niflheimrx
  Description: Show a menu where you can select a list of replays to watch
--]]

MakeBot = {}
MakeBot.Size = { [0] = { 400, 400 }, [1] = { 700, 700 } }

local panel = nil
function MakeBot:Open()
  if panel and IsValid( panel ) then panel:Remove() end
  panel = nil

  local size = MakeBot.Size[Interface.Scale]

  panel = SMPanels.MultiHoverFrame( { title = "Makebot Menu", subTitle = "Select a bot to watch a replay of it", center = true, w = size[1], h = size[2], pages = { "Style", "Stage", "Bonus" } } )
  panel.Loading = true
end

function MakeBot:Update( data )
  panel.Loading = false

  if (#data == 0) then
    panel.CustomText = "There are no replays available to watch"
  return end

  local barSize = SMPanels.BarSize[Interface.Scale]
  for group,tab in pairs( data ) do
    local count = 0
    for _,info in pairs( tab ) do
      local center = info[4] .. ": " .. Timer:Convert( info[2] )
      local left = "Record by: " .. info[1]
      local right = "Achieved on: " .. info[3]

      local function doFunc()
        if (info[4] == "Normal") then return end

        RunConsoleCommand( "say", "!bot set " .. info[5] )

        panel:AlphaTo( 0, 0.4, 0, function() end )
        panel:AlphaTo( 0, 0.4, 0, function() end )
        panel:SetMouseInputEnabled( false )
        panel:SetKeyboardInputEnabled( false )

        timer.Simple( 0.5, function()
          panel:Remove()
          panel = nil
        end )
      end

      local pos = Interface:GetBezel( "Medium" ) + barSize * count

      SMPanels.LongBarInfo( { parent = panel.Pages[group], mtext = center, ltext = left, rtext = right, pos = pos, func = doFunc } )
      count = count + 1
    end
  end
end
