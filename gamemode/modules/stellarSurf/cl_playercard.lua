-- A playercard module, this is relative to SurfKultur's old Profile Menu but a LOT better --
-- Yes, this is derived from my dev gamemode, give me suggestions and let me know if you like it! --

--[[
		Author: Niflheimrx
		Description: Displays a player's playercard which contains information about that player
--]]

print( "[SM] Initialized Playercard Module." )

Playercard = Playercard or {}
Playercard.MenuSize = { [0] = { 600, 375 }, [1] = { 800, 500 } }
Playercard.CloseButton = { [0] = 30, [1] = 40 }
Playercard.GenericButton = { [0] = { 120, 30 }, [1] = { 160, 40 } }

-- I added a playertitle system, so you can give players custom titles as you seem fit. It only shows up here. Setup your colors here as well --
Playercard.Colors = {
	["Gamemode Founder"] = Color( 0, 255, 255 ),
	["Developer Elitist"] = Color( 255, 29, 142 ),
	["Developer"] = Color( 255, 0, 255 ),
	["SurfKultur Therapist"] = Color( 255, 255, 0 ),
	["Surf Enthusiast"] = Color( 0, 255, 0 ),
	["SurfKultur Member"] = Color( 255, 0, 0 ),
	["SurfKultur Apprentice Member"] = Color(0, 226, 255),
	["Anomaly Within"] = Color( 128, 0, 128 ),
	["Polygon Master"] = Color( 255, 102, 153 ),
	["SurfKultur Wicked Surfer"] = Color( 255, 102, 51 ),
}

local styleOptions = {
	[1] = "Normal",
	[2] = "Sideways",
	[3] = "Half-Sideways",
	[4] = "Wicked",
	[5] = "100 Tick",
	[6] = "33 Tick"
}

local MainMenu = nil

function Playercard:Open()
	if IsValid(MainMenu) then MainMenu.Data = nil return end

	MainMenu = nil
	local size = Playercard.MenuSize[Interface.Scale]
	MainMenu = SMPanels.HoverFrame( { title = "Profile Menu", subTitle = "Fetching data...", center = true, w = size[1], h = size[2] } )
	MainMenu.Paint = function( _, w, h )
		local bezel = Interface:GetBezel( "Frame" )
		draw.RoundedBox( 6, 0, 0, w, h, Interface.BackgroundColor )
		draw.RoundedBoxEx( 6, 0, 0, w, bezel, Interface.ForegroundColor, true, true )

		local colors = Playercard.Colors[MainMenu.SubTitle] and Playercard.Colors[MainMenu.SubTitle] or color_white
		draw.SimpleText( MainMenu.Title, Interface:GetBoldFont(), w / 2, Interface:GetBezel( "Large" ), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		draw.SimpleText( MainMenu.SubTitle, Interface:GetFont(), w / 2, bezel - Interface:GetBezel( "Large" ), colors, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

		if not MainMenu.Data then
			draw.SimpleText( "Loading...", Interface:GetBoldFont(), w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		else
			local stats = MainMenu.Data
			local font = Interface:GetFont()
			local frbezel = Interface.FrameBezel[Interface.Scale]
			local mdbezel = Interface.MediumBezel[Interface.Scale]
			local bgbezel = Interface.BigBezel[Interface.Scale]

			if !stats.GameSteam then
				MainMenu.Title = "Unknown User"
				MainMenu.SubTitle = ""

				draw.SimpleText( "User does not exist on the database", Interface:GetBoldFont(), w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				return
			elseif !(stats.ServerRank and stats.PlayerPoints) or (stats.ServerRank == 0 or stats.PlayerPoints == 0) then
				draw.SimpleText( "User has no records", Interface:GetBoldFont(), w / 2, h / 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				return
			end

			local rankTitle = Timer:GetRankTitle( stats.ServerRank, stats.PlayerPoints )
			if stats.ServerRank <= 5 then
				rankTitle = _C.SpecialRanks[stats.ServerRank][1]
			end

			draw.SimpleText( "-- Stats --", font, mdbezel, frbezel + bgbezel, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
			draw.SimpleText( stats.GameLastJoined, font, mdbezel, frbezel + bgbezel * 2, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
			draw.SimpleText( "Times Joined: " .. stats.GameJoins, font, mdbezel, frbezel + bgbezel * 3, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
			draw.SimpleText( "Time Played: " .. string.NiceTime( stats.GamePlaytime * 60 ) .. " [" .. stats.GamePlaytime .. "]", font, mdbezel, frbezel + bgbezel * 4, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )

			draw.SimpleText( "-- Ranking --", font, mdbezel, frbezel + bgbezel * 6, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
			draw.SimpleText( "Points: " .. stats.PlayerPoints .. " pts [" .. rankTitle .. "]", font, mdbezel, frbezel + bgbezel * 7, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
			draw.SimpleText( "Rank: " .. ( stats.ServerRank != -1 and ( stats.ServerRank .. "/" .. stats.TotalRank ) or "Unranked" ), font, mdbezel, frbezel + bgbezel * 8, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )

			draw.SimpleText( "-- Normal --", font, mdbezel, frbezel + bgbezel * 10, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
			draw.SimpleText( "Maps Beaten: " .. stats.MapBeats .. "/" .. stats.TotalMaps, font, mdbezel, frbezel + bgbezel * 11, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
			draw.SimpleText( "Map Completion: " .. stats.MapPercent .. "%", font, mdbezel, frbezel + bgbezel * 12, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
			draw.SimpleText( "Map Records: " .. stats.MapRecords, font, mdbezel, frbezel + bgbezel * 13, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )

			draw.SimpleText( "-- Stages --", font, w - mdbezel, frbezel + bgbezel, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
			draw.SimpleText( "Stages Beaten: " .. stats.StageBeats .. "/" .. stats.TotalStages, font, w - mdbezel, frbezel + bgbezel * 2, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
			draw.SimpleText( "Stage Completion: " .. stats.StagePercent .. "%", font, w - mdbezel, frbezel + bgbezel * 3, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
			draw.SimpleText( "Stage Records: " .. stats.StageRecords, font, w - mdbezel, frbezel + bgbezel * 4, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )

			draw.SimpleText( "-- Bonuses --", font, w - mdbezel, frbezel + bgbezel * 6, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
			if (stats.Style != 1) then
				draw.SimpleText( "Unavailable for this style", font, w - mdbezel, frbezel + bgbezel * 8, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
			else
				draw.SimpleText( "Bonuses Beaten: " .. stats.BonusBeats .. "/" .. stats.TotalBonuses, font, w - mdbezel, frbezel + bgbezel * 7, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
				draw.SimpleText( "Bonus Completion: " .. stats.BonusPercent .. "%", font, w - mdbezel, frbezel + bgbezel * 8, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
				draw.SimpleText( "Bonus Records: " .. stats.BonusRecords, font, w - mdbezel, frbezel + bgbezel * 9, color_white, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
			end
		end
	end
end

function Playercard:Update( data )
	if not MainMenu then return end
	if not IsValid( MainMenu ) then return end
	if MainMenu.IsClosing then return end

	MainMenu.Data = data
	MainMenu.Title = data.PlayerName
	MainMenu.SubTitle = data.GameTitle

	local GenericSize = Playercard.GenericButton[Interface.Scale]
	local AvatarSize = Interface:GetBezel( "Frame" )
	local AvatarPos = { Interface:GetBezel( "Medium" ) }

	SMPanels.Avatar( { parent = MainMenu, player = data.Player, x = AvatarPos, y = AvatarPos, size = AvatarSize } )

	if !(data.GameSteam and data.ServerRank) then return end
	local FrameSize = Playercard.MenuSize[Interface.Scale]

	local posx = FrameSize[1] - GenericSize[1] - Interface:GetBezel( "Medium" )
	local posy = FrameSize[2] - GenericSize[2] - ( Interface:GetBezel( "Medium" ) )

	local function wrFunc()
		local commandName = Core.StyleIDToShortName(data.Style) .. "mywr " .. data.GameSteam

		RunConsoleCommand( "say", "/" .. commandName )
		Playercard:CloseMenu( MainMenu )
	end

	SMPanels.Button( { parent = MainMenu, text = "User Records", func = wrFunc, x = posx, y = posy } )

	posx = FrameSize[1] - GenericSize[1] - Interface:GetBezel( "Medium" )
	posy = FrameSize[2] - ( GenericSize[2] * 2 ) - ( Interface:GetBezel( "Medium" ) * 2 )

	local function mapsbeatFunc()
		local commandName = Core.StyleIDToShortName(data.Style) .. "mapsbeat " .. data.GameSteam

		RunConsoleCommand( "say", "/" .. commandName )
		Playercard:CloseMenu( MainMenu )
	end

	SMPanels.Button( { parent = MainMenu, text = "Maps Beat", func = mapsbeatFunc, x = posx, y = posy } )

	posx = FrameSize[1] - ( GenericSize[1] * 2 ) - ( Interface:GetBezel( "Medium" ) * 2 )
	posy = FrameSize[2] - ( GenericSize[2] * 2 ) - ( Interface:GetBezel( "Medium" ) * 2 )

	local function changeStyle(style)
		if !(MainMenu.Data) then
			Link:Print( "Surf Timer", "This content is still loading, please wait a moment before changing the styles again" )
		return end

		if (style == 5) then style = 44 elseif (style == 4) then style = 6 elseif (style == 6) then style = 45 end
		local commandName = Core.StyleIDToShortName(style) .. "profile " .. data.GameSteam

		MainMenu.Data = nil
		MainMenu.SubTitle = "Reloading statistics, please wait a moment..."

		RunConsoleCommand( "say", "/" .. commandName )
	end
	SMPanels.MultiButton( { parent = MainMenu, text = "View Style", tip = "Changes the content display for the selected style", select = styleOptions, func = changeStyle, x = posx, y = posy, norep = true, reverse = true } )

	posx = FrameSize[1] - ( GenericSize[1] * 2 ) - ( Interface:GetBezel( "Medium" ) * 2 )
	posy = FrameSize[2] - GenericSize[2] - ( Interface:GetBezel( "Medium" ) )

	local function openTopMenu()
		local prefix = Core.StyleIDToShortName(MainMenu.Data.Style)
		RunConsoleCommand("say", "/" .. prefix .. "top")
		Playercard:CloseMenu( MainMenu )
	end

	SMPanels.Button( { parent = MainMenu, text = "Top Players", func = openTopMenu, x = posx, y = posy } )
end

function Playercard:CloseMenu( panel )
	if not panel then return end
	if not IsValid( panel ) then return end

	panel:AlphaTo( 0, 0.4, 0, function() end )
	panel:SetMouseInputEnabled( false )
	panel:SetKeyboardInputEnabled( false )

	timer.Simple( 0.5, function()
		panel:Remove()
		panel = nil
	end )
end
