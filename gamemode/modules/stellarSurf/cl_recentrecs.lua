--[[
  Author: Niflheimrx
  Description: Displays a list of recent records, grouped by three categories, Style, Stage, Bonus
--]]

RecentRecords = {}
RecentRecords.Size = { [0] = { 500, 500 }, [1] = { 900, 900 } }

local panel = nil
function RecentRecords:Open()
  if panel and IsValid( panel ) then panel:Remove() end
  panel = nil

  local size = RecentRecords.Size[Interface.Scale]

	panel = SMPanels.HoverFrame( { title = "Recent Records", subTitle = "Please wait while we gather the data...", center = true, w = size[1], h = size[2] } )
  panel.Loading = true
end

function RecentRecords:Update( data, mode )
  panel.Loading = false

  if (#data == 0) then
    panel.CustomText = "Failed to gather recent records"
  return end

	local writeable = panel.Page
	panel.Title = "Recent " .. mode .. " Records"
  panel.SubTitle = "These are the most recent records on the server"

  local barSize = SMPanels.BarSize[Interface.Scale]
	local count = 0
	for _,info in pairs( data ) do
		local center = info.szMap .. " (Time: "  .. Timer:Convert( info.nTime ) .. ")" .. (mode == "Stage" and " [Stage " .. info.nStage .. "]" or mode == "Bonus" and " [" .. Core:StyleName( info.nStyle ) .. "]" or "")
		local left = "User: " .. info.szLastName
		local right = "Obtained on: " .. info.szDate

		local function doFunc()
			if (info.nStage) then
				RunConsoleCommand( "say", "!cpr " .. info.nStage .. " " .. info.szMap )
			else
				RunConsoleCommand( "say", "!sr " .. info.szMap )
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
