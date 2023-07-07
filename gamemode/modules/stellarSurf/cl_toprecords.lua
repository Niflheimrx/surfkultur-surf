--[[
  Author: Niflheimrx
  Description: Displays a list of the highest amount of records held.
--]]

TopRecords = {}
TopRecords.Size = { [0] = { 500, 500 }, [1] = { 700, 700 } }

local panel = nil
function TopRecords:Open()
  if panel and IsValid( panel ) then panel:Remove() end
  panel = nil

  local size = TopRecords.Size[Interface.Scale]

  panel = SMPanels.HoverFrame( { title = "Top Records Leaderboard", subTitle = "List of most records achieved by player", center = true, w = size[1], h = size[2] } )
  panel.Loading = true
end

function TopRecords:Update( data, index )
  panel.Loading = false

  if (#data == 0) then
    panel.CustomText = "Failed to fetch top records"
    panel.SubTitle = ""
  return end

  panel.Title = "Top " .. index .. " Records Leaderboard"

  local writeable = panel.Page
  local barSize = SMPanels.BarSize[Interface.Scale]

  local count = 0
  for i,info in pairs(data) do
    local recs, name, szUID = info.recs, info.szLastName, info.szUID

    local center = "#" .. i .. ": " .. name
    local left = "Amount: " .. recs
    local right = ""

    local function doFunc()
      RunConsoleCommand( "say", "/mywr " .. szUID )

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
