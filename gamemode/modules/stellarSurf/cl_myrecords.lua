--[[
  Author: Niflheimrx
  Description: Displays a list of player obtained records, sorted by Normal, Extra, Stage, Bonus
--]]

MyRecords = {}
MyRecords.Size = { [0] = { 500, 500 }, [1] = { 700, 700 } }

local panel = nil
function MyRecords:Open()
  if panel and IsValid( panel ) then panel:Remove() end
  panel = nil

  local size = MyRecords.Size[Interface.Scale]

  panel = SMPanels.HoverFrame( { title = "Personal Records", subTitle = "List of personal records achieved", center = true, w = size[1], h = size[2] } )
  panel.Loading = true
end

function MyRecords:Update( data, name, index )
  panel.Loading = false

  if (#data == 0) then
    panel.CustomText = "This player doesn't have any records"
  return end

  panel.Title = name .. "'s " .. index .. " Records"

  local writeable = panel.Page
  local barSize = SMPanels.BarSize[Interface.Scale]

  local count = 0
  for _,info in pairs( data ) do
    local szUID, map, time, date, points = info.szUID, info.szMap, info.nTime, info.szDate, info.nPoints or 0

    local center = map .. " (Time: "  .. Timer:Convert( time ) .. ")"
    local left = "Points: " .. math.floor( points )
    local right = "Obtained on: " .. date

    local function doFunc()
      RunConsoleCommand( "say", "/pr " .. szUID .. " " .. map )

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
