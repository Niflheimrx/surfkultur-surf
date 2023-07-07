GUIColor = {
	White = Color( 255, 255, 255 ),
	Header = Color( 118, 35, 131 ),
	LightGray = Color( 42, 42, 42 ),
	DarkGray = Color( 35, 35, 35 ),
	Holiday = Color( 0, 255, 255 ),
}

local Fonts = {
	Label = "HUDLabelSmall",
	MediumLabel = "HUDLabelMed",
	StrongLabel = "HUDLabel"
}

local function CreateFonts()
	surface.CreateFont( "HUDHeaderBig", { size = 44, font = "Coolvetica" } )
	surface.CreateFont( "HUDHeader", { size = 30, font = "Coolvetica" } )
	surface.CreateFont( "HUDTitle", { size = 24, font = "Coolvetica" } )
	surface.CreateFont( "HUDTitleSmall", { size = 20, font = "Coolvetica" } )

	surface.CreateFont( "HUDFont", { size = 22, weight = 800, font = "Tahoma" } )
	surface.CreateFont( "HUDFontSmall", { size = 14, weight = 800, font = "Tahoma" } )
	surface.CreateFont( "HUDLabelSmall", { size = 12, weight = 800, font = "Tahoma" } )
	surface.CreateFont( "HUDLabelMed", { size = 15, weight = 550, font = "Verdana" } )
	surface.CreateFont( "HUDLabel", { size = 17, weight = 550, font = "Verdana" } )
	surface.CreateFont( "HUDPrint", { size = 17, weight = 800, font = "Trebuchet24" } )

	surface.CreateFont( "HUDSpecial", { size = 17, weight = 550, font = "Verdana", italic = true } )
	surface.CreateFont( "HUDSpeed", { size = 16, weight = 800, font = "Tahoma", true } )
	surface.CreateFont( "HUDTimer", { size = 17, weight = 800, font = "Trebuchet24", antialias = true } )
	surface.CreateFont( "HUDMessage", { size = 30, weight = 800, font = "Verdana" } )
	surface.CreateFont( "HUDCounter", { size = 144, weight = 800, font = "Coolvetica" } )

	surface.CreateFont( "BottomHUDTiny", { size = 16, font = "Lato" } )
	surface.CreateFont( "BottomHUDStress", { size = 16, weight = 800, font = "Lato" } )
	surface.CreateFont( "BottomHUDSemi", { size = 18, font = "Lato" } )
	surface.CreateFont( "BottomHUDStressL", { size = 18, weight = 800, font = "Lato" } )
	surface.CreateFont( "BottomHUDTime", { size = 20, font = "Lato" } )
	surface.CreateFont( "BottomHUDSpec", { size = 32, font = "Lato" } )
	surface.CreateFont( "BottomHUDVelocity", { size = 34, font = "Lato" } )

	surface.CreateFont( "HUDVelocity", { size = 30, font = "Trebuchet24", weight = 800 } )
end
hook.Add( "InitPostEntity", "LoadFonts", CreateFonts )

Window = {}
Window.Unclosable = {}
Window.NoThink = { "Admin", "VIP" }

Window.List = {
	WR = { Dim = { 280, 226 }, Title = "Records" },
	Nominate = { Dim = { 280, 330 }, Title = "Nominate" },
	Vote = { Dim = { 370, 230 }, Title = "Voting" },
	Spectate = { Dim = { 140, 80 }, Title = "Spectate?" },
	Style = { Dim = { 185, 190 }, Title = "Choose Style" },
	Top = { Dim = { 310, 234 }, Title = "Top List" },
	Ranks = { Dim = { 235, 250 }, Title = "Rank List" },
	Maps = { Dim = { 460, 250 }, Title = "Maps" },
	Checkpoints = { Dim = { 260, 250 }, Title = "Checkpoints" },
	Stats = { Dim = { 185, 130 }, Title = "Stats" },
	Profile = { Dim = { 700, 300 }, Title = "Profile" },
	Admin = { Dim = { 0, 0 }, Title = "Admin Panel" },
	VIP = { Dim = { 0, 0 }, Title = "VIP Panel" },
	PersonalRecord = { Dim = { 0, 0 }, Title = "Personal Record" },
	MapTop = { Dim = { 0, 0 }, Title = "Map Top" },
}

local ActiveWindow = nil
local KeyLimit = false
local KeyLimitDelay = 1 / 4
local KeyChecker = LocalPlayer

local WindowThink = function() end
local WindowPaint = function() end

local chatOpen
hook.Add("StartChat", "sm_chatfinish", function() chatOpen = true end)
hook.Add("FinishChat", "sm_chatfinish", function() chatOpen = false end)

hook.Add( "PlayerBindPress", "surf_SPIDERSAYSFIXTHISPLS", function( _, bind )
	if ActiveWindow and IsValid(ActiveWindow) then
		local hasChatOpen = chatOpen
		local isValidBind = string.StartWith( bind, "say")
		local isCommand = string.StartWith( bind, "say !")

		if !hasChatOpen and !isCommand and isValidBind then return true end
	end
end )

function Window:Open( szIdentifier, varArgs, bForce )
	if IsValid( ActiveWindow ) and not bForce then
		if ActiveWindow.Data and table.HasValue( Window.Unclosable, ActiveWindow.Data.ID ) then
			return
		end
	end

	Window:Close()

	ActiveWindow = vgui.Create( "DFrame" )
	ActiveWindow:SetTitle( "" )
	ActiveWindow:SetDraggable( false )
	ActiveWindow:ShowCloseButton( false )

	ActiveWindow.Data = Window:LoadData( szIdentifier, varArgs )

	if IsValid( ActiveWindow ) then
		if not table.HasValue( Window.NoThink, szIdentifier ) then
			ActiveWindow.Think = WindowThink
		end

		ActiveWindow.Paint = WindowPaint
	end
end

function Window:Update( szIdentifier, varArgs )
	if not IsValid( ActiveWindow ) then return end
	if not ActiveWindow.Data then return end

	ActiveWindow.Data = Window:LoadData( szIdentifier, varArgs, ActiveWindow.Data )
end

function Window:Close()
	if not IsValid( ActiveWindow ) then return end
	ActiveWindow:Close()
	ActiveWindow = nil
end

function Window:LoadData( szIdentifier, varArgs, varUpdate )
	local wnd = varUpdate or { ID = szIdentifier, Labels = {}, Offset = 35 }

	local FormData = Window.List[ szIdentifier ]
	if not FormData then return end

	if not varUpdate then
		if szIdentifier == "Admin" or szIdentifier == "VIP" then
			Window.List[ szIdentifier ].Title = varArgs.Title
			Window.List[ szIdentifier ].Dim = { varArgs.Width, varArgs.Height }
			FormData = Window.List[ szIdentifier ]
		end

		wnd.Title = FormData.Title
		KeyLimitDelay = 1 / 4
		ActiveWindow:SetSize( FormData.Dim[ 1 ], FormData.Dim[ 2 ] )
		ActiveWindow:SetPos( 20 + Interface.Wide, ScrH() / 2 - ActiveWindow:GetTall() / 2 )
	end

	if szIdentifier == "Vote" then
		wnd.bVoted = false
		wnd.nVoted = -1
		wnd.VoteEnd = CurTime() + 30
		wnd.Votes = { 0, 0, 0, 0, 0, 0, 0 }
		wnd.Data = {}

		for i = 1, 7 do
			if i < 6 then
				local tab = Cache.V_Data[ i ]
				if not tab then continue end
				wnd.Data[ i ] = { tab[ 2 ] or 1, tab[ 3 ] or 1, tonumber( tab[ 4 ] ) or 1 }
				Cache.V_Data[ i ] = tab[ 1 ] .. " (Tier " .. wnd.Data[ i ][ 2 ] .. " " .. _C.MapTypes[ wnd.Data[ i ][ 3 ] ] .. ")"
			else
				if i == 6 and Cache.V_Data[ i ] and Cache.V_Data[ i ][ 1 ] == "__NO_EXTEND__" then
					Cache.V_Data[ i ] = "Extended Frequently"
					wnd.bNoExtend = true
				else
					Cache.V_Data[ i ] = i == 7 and "Random Map" or "Extend For 30 Minutes"
				end
			end

			wnd.Labels[ i ] = Window.MakeLabel{ parent = ActiveWindow, x = 15, y = wnd.Offset, font = Fonts.StrongLabel, color = labelcolor, text = i .. " [" .. wnd.Votes[ i ] .. "] " .. Cache.V_Data[ i ] }
			wnd.Offset = wnd.Offset + 20

			if i == 6 and wnd.bNoExtend then
				wnd.Labels[ i ]:SetColor( Color( 125, 125, 125 ) )
			end
		end

		local d = Window.List.WR.Dim[ 2 ]
		wnd.Labels[ 10 ] = Window.MakeLabel{ parent = ActiveWindow, x = 15, y = d - (2 * 16), font = Fonts.StrongLabel, color = labelcolor, text = "0. Close" }

		timer.Simple( 31, function() if not Window.AbortClose then Window:Close() end end )

	elseif szIdentifier == "WR" then
		ActiveWindow:SetSize( FormData.Dim[ 1 ] + 60, FormData.Dim[ 2 ] )
		local nType = varArgs[ 1 ]
		wnd.nType = nType
		if nType == 2 then
			local tData, nStyle, nPage, nTotal, szMap = varArgs[ 2 ], varArgs[ 3 ], varArgs[ 4 ], varArgs[ 5 ], varArgs[ 6 ]
			Cache.T_Data[ nStyle ] = {}
			for n,data in pairs( tData ) do
				Cache.T_Data[ nStyle ][ n ] = data
			end

			local nOffset = _C.PageSize * nPage - _C.PageSize
			wnd.Title = Core:StyleName( nStyle ) .. " Records (#" .. nTotal .. ")"
			wnd.nPages = math.ceil( nTotal / _C.PageSize )
			wnd.nPage = 1
			wnd.nStart = wnd.nPage
			wnd.nStyle = nStyle
			wnd.vLoaded = { true }

			if szMap then
				wnd.szMap = szMap
				wnd.Title = wnd.szMap .. " " .. Core:StyleName( nStyle ) .. " Records (#" .. nTotal .. ")"

				for s,d in pairs( Cache.T_Data ) do
					if s != nStyle then
						Cache.T_Data[ s ] = {}
					end
				end

				ActiveWindow:SetSize( FormData.Dim[ 1 ] + 60, FormData.Dim[ 2 ] )
			else
				Timer:GetFirstTimes()
			end

			local data = Cache.T_Data[ nStyle ]
			if data and #data > 0 then
				for i = 1, _C.PageSize do
					wnd.Labels[ i ] = Window.MakeLabel{ parent = ActiveWindow, x = 15, y = wnd.Offset, font = Fonts.MediumLabel, color = labelcolor, text = data[ i + nOffset ] and (i  .. ". [#" .. i + nOffset .. " " .. Timer:Convert( data[ i + nOffset ][ 3 ] ) .. "]: " .. data[ i + nOffset ][ 2 ]) or "" }
					wnd.Offset = wnd.Offset + 16
					wnd.nPage = math.floor( (i + nOffset) / _C.PageSize )
				end
			else
				wnd.Labels[ 1 ] = Window.MakeLabel{ parent = ActiveWindow, x = 15, y = wnd.Offset, font = Fonts.MediumLabel, color = labelcolor, text = "No records!" }
			end

			local d = Window.List.WR.Dim[ 2 ]
			wnd.Labels[ 8 ] = Window.MakeLabel{ parent = ActiveWindow, x = 15, y = d - (4 * 16), font = Fonts.MediumLabel, color = labelcolor, text = "8. Previous" }
			wnd.Labels[ 9 ] = Window.MakeLabel{ parent = ActiveWindow, x = 15, y = d - (3 * 16), font = Fonts.MediumLabel, color = labelcolor, text = "9. Next" }
			wnd.Labels[ 10 ] = Window.MakeLabel{ parent = ActiveWindow, x = 15, y = d - (2 * 16), font = Fonts.MediumLabel, color = labelcolor, text = "0. Close" }

			if wnd.nPage == 1 then wnd.Labels[ 8 ]:SetVisible( false ) end
			if wnd.nPage == wnd.nPages or nTotal < _C.PageSize + 1 then wnd.Labels[ 9 ]:SetVisible( false ) end
		elseif nType == 4 then
			local tData, nPage, nTotal = varArgs[ 2 ], varArgs[ 3 ], varArgs[ 4 ]
			local bDirection = nPage - wnd.nStart < 0
			local nPages = math.ceil( nTotal / _C.PageSize )
			wnd.nPage = nPage
			wnd.nStart = wnd.nPage

			if wnd.nPages != nPages then
				wnd.nPages = nPages
				wnd.vLoaded = { [wnd.nPage] = true }
				wnd.Title = Core:StyleName( wnd.nStyle ) .. " Records (#" .. nTotal .. ")"
			else
				wnd.vLoaded[ wnd.nPage ] = true
			end

			for n,data in pairs( tData ) do
				Cache.T_Data[ wnd.nStyle ][ n ] = data
			end

			if wnd.szMap then
				wnd.Title = wnd.szMap .. " " .. Core:StyleName( wnd.nStyle ) .. " Records (#" .. nTotal .. ")"
			end

			local data = Cache.T_Data[ wnd.nStyle ]
			if data and #data > 0 then
				local Index = _C.PageSize * wnd.nPage - _C.PageSize

				for i = 1, _C.PageSize do
					local Item = data[ Index + i ]
					if Item then
						wnd.Labels[ i ]:SetText( i  .. ". [#" .. Index + i .. " " .. Timer:Convert( Item[ 3 ] ) .. "]: " .. Item[ 2 ] )
						wnd.Labels[ i ]:SizeToContents()
						wnd.Labels[ i ]:SetVisible( true )
					else
						wnd.Labels[ i ]:SetText( "" )
						wnd.Labels[ i ]:SetVisible( false )
					end
				end

				Window.PageToggle( wnd, bDirection )
			end
		elseif nType == 6 then
			local tData, nStage, nStyle, nPage, nTotal, szMap = varArgs[ 2 ], varArgs[ 3 ], varArgs[ 4 ], varArgs[ 5 ], varArgs[ 6 ], varArgs[ 7 ]
			Cache.T_Data[ nStyle ] = {}
			for n,data in pairs( tData ) do
				Cache.T_Data[ nStyle ][ n ] = data
			end

			local nOffset = _C.PageSize * nPage - _C.PageSize
			wnd.Title = "Stage " .. nStage .. " Top Records"
			wnd.nPages = math.ceil( nTotal / _C.PageSize )
			wnd.nPage = 1
			wnd.nStart = wnd.nPage
			wnd.nStage = nStage
			wnd.nStyle = nStyle
			wnd.vLoaded = { true }

			if szMap then
				wnd.szMap = szMap
				wnd.Title = wnd.szMap .. " Stage " .. nStage .. " Top Records"

				for s,d in pairs( Cache.T_Data ) do
					if s != nStyle then
						Cache.T_Data[ s ] = {}
					end
				end

				ActiveWindow:SetSize( FormData.Dim[ 1 ] + 60, FormData.Dim[ 2 ] )
			end

			local data = Cache.T_Data[ nStyle ]
			if data and #data > 0 then
				for i = 1, _C.PageSize do
					wnd.Labels[ i ] = Window.MakeLabel{ parent = ActiveWindow, x = 15, y = wnd.Offset, font = Fonts.MediumLabel, color = labelcolor, text = data[ i + nOffset ] and (i  .. ". [#" .. i + nOffset .. " " .. Timer:Convert( data[ i + nOffset ][ 3 ] ) .. "]: " .. data[ i + nOffset ][ 2 ]) or "" }
					wnd.Offset = wnd.Offset + 16
					wnd.nPage = math.floor( (i + nOffset) / _C.PageSize )
				end
			else
				wnd.Labels[ 1 ] = Window.MakeLabel{ parent = ActiveWindow, x = 15, y = wnd.Offset, font = Fonts.MediumLabel, color = labelcolor, text = "No records!" }
			end

			local d = Window.List.WR.Dim[ 2 ]
			wnd.Labels[ 10 ] = Window.MakeLabel{ parent = ActiveWindow, x = 15, y = d - (2 * 16), font = Fonts.MediumLabel, color = labelcolor, text = "0. Close" }
		elseif nType == 8 then
			local tData, nPage, nTotal = varArgs[ 2 ], varArgs[ 3 ], varArgs[ 4 ]
			local bDirection = nPage - wnd.nStart < 0
			local nPages = math.ceil( nTotal / _C.PageSize )
			wnd.nPage = nPage
			wnd.nStart = wnd.nPage

			if wnd.nPages != nPages then
				wnd.nPages = nPages
				wnd.vLoaded = { [wnd.nPage] = true }
				wnd.Title = "Stage " .. wnd.nStage .. " Top Records"
			else
				wnd.vLoaded[ wnd.nPage ] = true
			end

			for n,data in pairs( tData ) do
				Cache.T_Data[ wnd.nStyle ][ n ] = data
			end

			if wnd.szMap then
				wnd.Title = wnd.szMap .. " Stage " .. wnd.nStage .. " Top Records"
			end

			local data = Cache.T_Data[ wnd.nStyle ]
			if data and #data > 0 then
				local Index = _C.PageSize * wnd.nPage - _C.PageSize

				for i = 1, _C.PageSize do
					local Item = data[ Index + i ]
					if Item then
						wnd.Labels[ i ]:SetText( i  .. ". [#" .. Index + i .. " " .. Timer:Convert( Item[ 3 ] ) .. "]: " .. Item[ 2 ] )
						wnd.Labels[ i ]:SizeToContents()
						wnd.Labels[ i ]:SetVisible( true )
					else
						wnd.Labels[ i ]:SetText( "" )
						wnd.Labels[ i ]:SetVisible( false )
					end
				end

				Window.PageToggle( wnd, bDirection )
			end
		end
	elseif szIdentifier == "Nominate" then
		wnd.nServer = tonumber( varArgs[ 1 ] )
		if #Cache.M_Data == 0 or wnd.nServer != Cache.M_Version then
			Link:Send( "MapList", { Cache.M_Version } )
			Window:Close()
		else
			if wnd.nServer != Cache.M_Version then
				return Link:Send( "MapList", { Cache.M_Version } )
			end

			wnd.Title = "Nominate (" .. #Cache.M_Data .. " maps)"
			wnd.nSort = varArgs[ 2 ] and tonumber( varArgs[ 2 ] ) or 1
			wnd.bVoted = false
			wnd.bPoints = true
			wnd.nPages = math.ceil( #Cache.M_Data / _C.PageSize )
			wnd.nPage = 1

			if varArgs[ 2 ] and tonumber( varArgs[ 2 ] ) then
				wnd.bHold = true
			end

			if varArgs[ 3 ] != nil then
				wnd.bPoints = varArgs[ 3 ]
			end

			if wnd.nSort == 1 then
				table.sort( Cache.M_Data, function( a, b )
					return a[ 1 ] < b[ 1 ]
				end )
			elseif wnd.nSort == 2 then
				table.sort( Cache.M_Data, function( a, b )
					return a[ 2 ] < b[ 2 ]
				end )
			elseif (wnd.nSort == 3) then
				table.sort( Cache.M_Data, function( a, b )
					return a[ 2 ] > b[ 2 ]
				end )
			end

			if wnd.bPoints then
				ActiveWindow:SetSize( FormData.Dim[ 1 ] + 140, FormData.Dim[ 2 ] )
			end

			local Index = _C.PageSize * wnd.nPage - _C.PageSize
			for i = 1, _C.PageSize do
				local Item = Cache.M_Data[ Index + i ]
				local Color
				if GetConVar( "sl_theme" ):GetInt() != 4 then
					Color = Cache:L_Check( Item and Item[ 1 ] or "" ) and _C.Prefixes.Notification or labelcolor
				else
					Color = Cache:L_Check( Item and Item[ 1 ] or "" ) and _C.Prefixes.Notification or GUIColor.Marshmallow
				end
				wnd.Labels[ i ] = Window.MakeLabel{ parent = ActiveWindow, x = 15, y = wnd.Offset, font = Fonts.StrongLabel, color = Color, text = Item and i .. ". " .. (wnd.bPoints and "[" .. Item[ 2 ] .. "] " or "") .. Item[ 1 ] .. ((Item[ 3 ] and wnd.bPoints) and " - Tier " .. Item[ 3 ] .. (Item[ 4 ] and " " .. _C.MapTypes[ tonumber( Item[ 4 ] ) ] or "") or "") or "" }
				wnd.Offset = wnd.Offset + 20
			end

			wnd.Labels[ 8 ] = Window.MakeLabel{ parent = ActiveWindow, x = 15, y = wnd.Offset + 20, font = Fonts.StrongLabel, color = labelcolor, text = "8. Previous" }
			wnd.Labels[ 9 ] = Window.MakeLabel{ parent = ActiveWindow, x = 15, y = wnd.Offset + 40, font = Fonts.StrongLabel, color = labelcolor, text = "9. Next" }
			wnd.Labels[ 10 ] = Window.MakeLabel{ parent = ActiveWindow, x = 15, y = wnd.Offset + 60, font = Fonts.StrongLabel, color = labelcolor, text = "0. Close" }

			wnd.Labels[ 11 ] = Window.MakeLabel{ parent = ActiveWindow, x = 15, y = wnd.Offset + 100, font = Fonts.StrongLabel, color = labelcolor, text = "N. Toggle details" }
			wnd.Labels[ 12 ] = Window.MakeLabel{ parent = ActiveWindow, x = 15, y = wnd.Offset + 120, font = Fonts.StrongLabel, color = labelcolor, text = "M. Toggle sorting mode" }

			if wnd.nPage == 1 then wnd.Labels[ 8 ]:SetVisible( false ) end
			if wnd.nPage == wnd.nPages then wnd.Labels[9]:SetVisible( false ) end
		end
	elseif szIdentifier == "Style" then
		for i = _C.Style.Normal, _C.Style.Bonus do
			wnd.Labels[ i ] = Window.MakeLabel{ parent = ActiveWindow, x = 15, y = wnd.Offset, font = Fonts.StrongLabel, color = i == Timer.Style and _C.Prefixes.Notification or labelcolor, text = i .. ". " .. Core:StyleName( i ) }
			wnd.Offset = wnd.Offset + 20
		end

		wnd.Offset = wnd.Offset + 20
		wnd.Labels[ #wnd.Labels + 1 ] = Window.MakeLabel{ parent = ActiveWindow, x = 15, y = wnd.Offset, font = Fonts.StrongLabel, color = labelcolor, text = "0. Close" }
	elseif szIdentifier == "Top" then
		local nType = varArgs[ 1 ]
		if nType == 2 then
			local tData, nPage, nTotal, nType = varArgs[ 2 ], varArgs[ 3 ], varArgs[ 4 ], varArgs[ 5 ]

			Cache.R_Data = {}
			for n,data in pairs( tData ) do
				Cache.R_Data[ n ] = data
			end

			local nOffset = _C.PageSize * nPage - _C.PageSize
			wnd.nType = nType
			if wnd.nType == 5 then                                                                              -- if type = 5 (100 tick ) then
				wnd.Title = (wnd.nType == 5 and "100 Tick") .. " Top List (" .. nTotal .. " Players)"
			elseif wnd.nType == 3 or wnd.nType == 4 then
				wnd.Title = (wnd.nType == 3 and "Normal" or "Angled") .. " Top List (" .. nTotal .. " Players)"
			end
			wnd.nPages = math.ceil( nTotal / _C.PageSize )
			wnd.nPage = 1
			wnd.nStart = wnd.nPage
			wnd.vLoaded = { true }

			local data = Cache.R_Data
			if data and #data > 0 then
				for i = 1, _C.PageSize do
					wnd.Labels[ i ] = Window.MakeLabel{ parent = ActiveWindow, x = 15, y = wnd.Offset, font = Fonts.MediumLabel, color = labelcolor, text = data[ i + nOffset ] and ("#" .. i + nOffset .. ": " .. data[ i + nOffset ][ 1 ] .. " with " .. data[ i + nOffset ][ 2 ] .. " pts") or "" }
					wnd.Offset = wnd.Offset + 16
					wnd.nPage = math.floor( (i + nOffset) / _C.PageSize )

				end
			else
				for i = 1, _C.PageSize do
					wnd.Labels[ i ] = Window.MakeLabel{ parent = ActiveWindow, x = 15, y = wnd.Offset, font = Fonts.MediumLabel, color = labelcolor, text = i == 1 and "No available records." or "" }
				end
			end

			local d = Window.List.Top.Dim[ 2 ]
			wnd.Labels[ 8 ] = Window.MakeLabel{ parent = ActiveWindow, x = 15, y = d - (4 * 16), font = Fonts.MediumLabel, color = labelcolor, text = "8. Previous" }
			wnd.Labels[ 9 ] = Window.MakeLabel{ parent = ActiveWindow, x = 15, y = d - (3 * 16), font = Fonts.MediumLabel, color = labelcolor, text = "9. Next" }
			wnd.Labels[ 10 ] = Window.MakeLabel{ parent = ActiveWindow, x = 15, y = d - (2 * 16), font = Fonts.MediumLabel, color = labelcolor, text = "0. Close" }

			if wnd.nPage == 1 then wnd.Labels[ 8 ]:SetVisible( false ) end
			if wnd.nPage == wnd.nPages or nTotal < _C.PageSize + 1 then wnd.Labels[ 9 ]:SetVisible( false ) end
		elseif nType == 4 then
			local tData, nPage, nTotal, nType = varArgs[ 2 ], varArgs[ 3 ], varArgs[ 4 ], varArgs[ 5 ]
			local bDirection = nPage - wnd.nStart < 0
			local nPages = math.ceil( nTotal / _C.PageSize )
			wnd.nPage = nPage
			wnd.nStart = wnd.nPage
			wnd.nType = nType

			if wnd.nPages != nPages then
				wnd.nPages = nPages
				wnd.vLoaded = { [wnd.nPage] = true }
				if wnd.nType == 5 then                                                                           -- if type = 5 (100 tick ) then
					wnd.Title = (wnd.nType == 5 and "100 Tick") .. " Top List (" .. nTotal .. " Players)"
				elseif wnd.nType == 3 or wnd.nType == 4 then
					wnd.Title = (wnd.nType == 3 and "Normal" or "Angled") .. " Top List (" .. nTotal .. " Players)"
				end
			else
				wnd.vLoaded[ wnd.nPage ] = true
			end

			for n,data in pairs( tData ) do
				Cache.R_Data[ n ] = data
			end

			local data = Cache.R_Data
			if data and #data > 0 then
				local Index = _C.PageSize * wnd.nPage - _C.PageSize

				for i = 1, _C.PageSize do
					local Item = data[ Index + i ]
					if Item then
						wnd.Labels[ i ]:SetText( "#" .. Index + i .. ": " .. Item[ 1 ] .. " with " .. Item[ 2 ] .. " pts" )
						wnd.Labels[ i ]:SizeToContents()
						wnd.Labels[ i ]:SetVisible( true )
					else
						wnd.Labels[ i ]:SetText( "" )
						wnd.Labels[ i ]:SetVisible( false )
					end
				end

				Window.PageToggle( wnd, bDirection )
			end
		end
	elseif szIdentifier == "Maps" then
		local szType = varArgs[ 1 ]
		if varArgs[ 2 ] then
			Cache.L_Data = varArgs[ 2 ]
		end

		wnd.tabList = {}
		wnd.tabData = {}

		if not Cache.M_Data or (Cache.M_Data and #Cache.M_Data == 0) then
			Window:Close()
			return Link:Print( "General", "You must have opened the !nominate menu at least once to use this command" )
		end

		for _,d in pairs( Cache.M_Data ) do
			table.insert( wnd.tabList, d[ 1 ] )
			wnd.tabData[ d[ 1 ] ] = { d[ 2 ], d[ 3 ], d[ 4 ] }
		end

		wnd.szType = szType
		wnd.szStyle = Core:StyleName(varArgs[3] or 1)

		if szType == "Completed" then
			wnd.tabList = Cache.L_Data
			ActiveWindow:SetSize( FormData.Dim[ 1 ] - 120, FormData.Dim[ 2 ] )
		elseif szType == "Left" then
			for _,d in pairs( Cache.L_Data ) do
				table.RemoveByValue( wnd.tabList, d[ 1 ] )
			end

			local TempList = {}
			for _,m in pairs( wnd.tabList ) do
				table.insert( TempList, { Map = m, Points = wnd.tabData[ m ][ 1 ] or 1 } )
			end

			table.SortByMember( TempList, "Points" )

			wnd.tabList = {}
			for _,d in ipairs( TempList ) do
				table.insert( wnd.tabList, { d.Map, d.Points } )
			end

			ActiveWindow:SetSize( FormData.Dim[ 1 ] - 60, FormData.Dim[ 2 ] )
		elseif szType == "WR" then
			wnd.tabList = Cache.L_Data
			szType = "with #1 WR"
		elseif szType == "RR" then
			wnd.tabList = Cache.L_Data
		end

		wnd.nCount = #wnd.tabList
		wnd.nPage = 1
		wnd.nPages = math.ceil( wnd.nCount / _C.PageSize )

		if wnd.szType != "RR" then
			wnd.Title = "Maps " .. szType .. " (" .. wnd.nCount .. ") [" .. wnd.szStyle .. "]"
		else
			wnd.Title = "Recent " .. Core:StyleName( Timer.Style ) .. " Records"
		end

		for i = 1, _C.PageSize do
			local Index = _C.PageSize * wnd.nPage - _C.PageSize + i
			local Item = wnd.tabList[ Index ]
			local Text = ""

			if Item then
				if wnd.szType == "Completed" then
					Text = Index .. ". [" .. Timer:Convert( Item[ 2 ] ) .. "] " .. Item[ 1 ]
				elseif wnd.szType == "Left" then
					Text = Index .. ". " .. Item[ 1 ] .. " (" .. Item[ 2 ] .. " pts - Tier " .. wnd.tabData[ Item[ 1 ] ][ 2 ] .. " " .. _C.MapTypes[ tonumber( wnd.tabData[ Item[ 1 ] ][ 3 ] ) ] .. ")"
				elseif wnd.szType == "WR" then
					Text = Index .. ". [" .. Timer:Convert( Item[ 2 ] ) .. "] " .. Item[ 1 ] .. " (Style: " .. Core:StyleName( Item[ 3 ] ) .. ")"
				elseif wnd.szType == "RR" then
					Text = Index .. ". [" .. Item[ 1 ] .. "] " .. Item[ 3 ] .. " (Time: " .. Timer:Convert( Item[ 2 ] ) .. ")"
				end
			end

			if GetConVar( "sl_theme" ):GetInt() != 4 then
				wnd.Labels[ i ] = Window.MakeLabel{ parent = ActiveWindow, x = 15, y = wnd.Offset, font = Fonts.StrongLabel, color = labelcolor, text = Text }
			else
				wnd.Labels[ i ] = Window.MakeLabel{ parent = ActiveWindow, x = 15, y = wnd.Offset, font = Fonts.StrongLabel, color = GUIColor.Marshmallow, text = Text }
			end
			wnd.Offset = wnd.Offset + 20
		end

		wnd.Labels[ 8 ] = Window.MakeLabel{ parent = ActiveWindow, x = 15, y = wnd.Offset, font = Fonts.StrongLabel, color = labelcolor, text = "8. Previous" }
		wnd.Labels[ 9 ] = Window.MakeLabel{ parent = ActiveWindow, x = 15, y = wnd.Offset + 20, font = Fonts.StrongLabel, color = labelcolor, text = "9. Next" }
		wnd.Labels[ 10 ] = Window.MakeLabel{ parent = ActiveWindow, x = 15, y = wnd.Offset + 40, font = Fonts.StrongLabel, color = labelcolor, text = "0. Close" }

		if wnd.nPage == 1 then wnd.Labels[ 8 ]:SetVisible( false ) end
		if wnd.nPage >= wnd.nPages then wnd.Labels[ 9 ]:SetVisible( false ) end
	elseif szIdentifier == "Checkpoints" then
		wnd.bDelay = false
		wnd.bDelete = false

		wnd.Labels[ 1 ] = Window.MakeLabel{ parent = ActiveWindow, x = 15, y = wnd.Offset, font = Fonts.StrongLabel, color = labelcolor, text = "1. Most recent" }
		wnd.Offset = wnd.Offset + 20

		for i = 2, _C.PageSize do
			local Item = Cache.C_Data[ i ]
			wnd.Labels[ i ] = Window.MakeLabel{ parent = ActiveWindow, x = 15, y = wnd.Offset, font = Fonts.StrongLabel, color = labelcolor, text = Item and i .. ". " .. Item or i .. ". None" }
			wnd.Offset = wnd.Offset + 20
		end

		wnd.Labels[ 8 ] = Window.MakeLabel{ parent = ActiveWindow, x = 15, y = wnd.Offset, font = Fonts.StrongLabel, color = labelcolor, text = "8. Turn Delay " .. (wnd.bDelay and "Off" or "On") }
		wnd.Labels[ 9 ] = Window.MakeLabel{ parent = ActiveWindow, x = 15, y = wnd.Offset + 20, font = Fonts.StrongLabel, color = labelcolor, text = "9. Turn Delete " .. (wnd.bDelete and "Off" or "On") }
		wnd.Labels[ 10 ] = Window.MakeLabel{ parent = ActiveWindow, x = 15, y = wnd.Offset + 40, font = Fonts.StrongLabel, color = labelcolor, text = "0. Close Window" }
	elseif szIdentifier == "Stats" then
		wnd.Title = varArgs.Title .. " Stats"

		local tabRender = {
			"Distance: " .. varArgs.Distance .. " units",
			"Prestrafe: " .. varArgs.Prestrafe .. " u/s",
			"Average Sync: " .. varArgs.Sync .. "%",
			"Strafes: " .. #varArgs.SyncValues
		}

		for id,data in pairs( tabRender ) do
			wnd.Labels[ id ] = Window.MakeLabel{ parent = ActiveWindow, x = 15, y = wnd.Offset, font = Fonts.StrongLabel, color = labelcolor, text = data }
			wnd.Offset = wnd.Offset + 20
		end

		if timer.Exists( "StatsCloser" ) then timer.Remove( "StatsCloser" ) end
		timer.Create( "StatsCloser", 5, 1, function() Window:Close() end )
	elseif szIdentifier == "Spectate" then
		ActiveWindow:SetSize( FormData.Dim[ 1 ] + 30, FormData.Dim[ 2 ] )
		wnd.Title = (LocalPlayer() and LocalPlayer():Team() == TEAM_SPECTATOR) and "Stop Spectating?" or "Start Spectating?"
		ActiveWindow:Center()
		ActiveWindow:MakePopup()

		Window.MakeButton{ parent = ActiveWindow, w = 32, h = 24, x = 33, y = 38, text = "Yes", onclick = function() Window:Close() RunConsoleCommand( "sm_spectate" ) end }
		Window.MakeButton{ parent = ActiveWindow, w = 32, h = 24, x = 105, y = 38, text = "No", onclick = function() Window:Close() end }
	elseif szIdentifier == "Admin" or szIdentifier == "VIP" then
		Admin:GenerateGUI( ActiveWindow, varArgs )
	elseif szIdentifier == "PersonalRecord" then
		local pbdata = varArgs[1]
		if !pbdata or (#pbdata == 0) then
			Link:Print( "Surf Timer", "Failed to find any valid zone entries" )
			Window:Close()
		return end

		wnd.tabList = pbdata
		wnd.nCount = #pbdata
		wnd.nStyle = varArgs[2]
		wnd.nPage = 1
		wnd.nPages = math.ceil( wnd.nCount / _C.PageSize )

		local title = pbdata[0]
		wnd.szMap = title[2]
		wnd.Title = "Personal Record for " .. title[1] .. " (" .. title[2] .. ") [" .. Core:StyleName(wnd.nStyle) .. "]"

		local count = 1
		for i = 1, _C.PageSize do
			local Index = _C.PageSize * wnd.nPage - _C.PageSize + i
			local Item = wnd.tabList[ Index ]
			local Text, time, rank = "", "", ""

			if Item then
				time = i .. ") " .. Item[1]
				rank = Item[2]

				wnd.Labels[ count ] = Window.MakeLabel{ parent = ActiveWindow, x = 15, y = wnd.Offset, font = "HUDFont", color = color_white, text = time }
				wnd.Labels[ count + 1 ] = Window.MakeLabel{ parent = ActiveWindow, x = 15, y = wnd.Offset + 20, font = "HUDFont", color = color_white, text = rank }
				wnd.Labels[ count + 2 ] = Window.MakeLabel{ parent = ActiveWindow, x = 15, y = wnd.Offset + 40, font = "HUDFont", color = color_white, text = Text }

				count = count + 3
				wnd.Offset = wnd.Offset + 60
			end
		end

		wnd.Offset = wnd.Offset + 70

		-- The height represents how many groups of zones we have, width represents the title (since it's the longest width out of all items) --
		local height, width = wnd.Offset, Interface:GetTextWidth( { wnd.Title }, "HUDTitle" )
		ActiveWindow:SetSize( width, height )
		ActiveWindow:SetPos( 20 + Interface.Wide, ScrH() / 2 - ActiveWindow:GetTall() / 2 )

		wnd.Labels[ 98 ] = Window.MakeLabel{ parent = ActiveWindow, x = 15, y = height - 80, font = "HUDFont", color = color_white, text = "8. Previous" }
		wnd.Labels[ 99 ] = Window.MakeLabel{ parent = ActiveWindow, x = 15, y = height - 55, font = "HUDFont", color = color_white, text = "9. Next" }
		wnd.Labels[ 100 ] = Window.MakeLabel{ parent = ActiveWindow, x = 15, y = height - 30, font = "HUDFont", color = color_white, text = "0. Close" }

		if wnd.nPage == 1 then wnd.Labels[ 98 ]:SetVisible( false ) end
		if wnd.nPage >= wnd.nPages then wnd.Labels[ 99 ]:SetVisible( false ) end
	elseif szIdentifier == "MapTop" then
		local mtop = varArgs
		-- This shouldn't happen, but in-case there's a network error let the client know the issue --
		if !mtop or (#mtop == 0) then
			Link:Print( "Surf Timer", "There was an error trying to process this menu" )
			Window:Close()
		return end

		wnd.tabList = mtop
		wnd.nCount = #mtop
		wnd.nPage = 1
		wnd.nPages = math.ceil( wnd.nCount / _C.PageSize )
		wnd.Title = "[ " .. mtop[0] .. " ]"

		wnd.ScaleCache = {}

		for i = 1, _C.PageSize do
			local Index = _C.PageSize * wnd.nPage - _C.PageSize + i
			local Item = wnd.tabList[ Index ]
			local Text = ""

			if Item then
				local time, difference, name = Item[1], Item[2], Item[3]
				Text = i .. ") Rank " .. i .. ": " .. time .. " (" .. difference .. ") - " .. name

				local userSteam = (Item[4] == LocalPlayer():SteamID())
				local topcolor = (userSteam and _C.Prefixes.Notification or color_white)

				wnd.Labels[ i ] = Window.MakeLabel{ parent = ActiveWindow, x = 15, y = wnd.Offset, font = "HUDFont", color = topcolor, text = Text }
				wnd.ScaleCache[ i ] = Text

				wnd.Offset = wnd.Offset + 25
			end
		end

		wnd.Offset = wnd.Offset + 90

		-- The height represents how many groups of zones we have, width represents the title (since it's the longest width out of all items) --
		local height, width = wnd.Offset, Interface:GetTextWidth( wnd.ScaleCache, "HUDFont" )
		ActiveWindow:SetSize( width, height )
		ActiveWindow:SetPos( 20 + Interface.Wide, ScrH() / 2 - ActiveWindow:GetTall() / 2 )

		wnd.Labels[ 98 ] = Window.MakeLabel{ parent = ActiveWindow, x = 15, y = height - 80, font = "HUDFont", color = color_white, text = "8. Previous" }
		wnd.Labels[ 99 ] = Window.MakeLabel{ parent = ActiveWindow, x = 15, y = height - 55, font = "HUDFont", color = color_white, text = "9. Next" }
		wnd.Labels[ 100 ] = Window.MakeLabel{ parent = ActiveWindow, x = 15, y = height - 30, font = "HUDFont", color = color_white, text = "0. Close" }

		if wnd.nPage == 1 then wnd.Labels[ 98 ]:SetVisible( false ) end
		if wnd.nPage >= wnd.nPages then wnd.Labels[ 99 ]:SetVisible( false ) end
	elseif szIdentifier == "Ranks" then
		local ranks = _C["Ranks"]
		local specialranks = _C["SpecialRanks"]

		local points = LocalPlayer():GetNWInt("Points", 0)
		local rank = LocalPlayer():GetNWInt("SpecialRank", 0)

		-- This should never happen, but its better to be safe than not --
		if !ranks or (#ranks == 0) then
			Link:Print( "Surf Timer", "There was an error trying to process this menu" )
			Window:Close()
		return end

		wnd.nPage = 1
		wnd.nPages = 1
		wnd.Title = "Surf Rank List (" .. points .. " pts)"

		wnd.ScaleCache = {}

		for i = 1, #ranks do
			local Item = ranks[i]
			local Text = ""

			if Item then
				local rankName, rankColor = Item[1], Item[2]
				local rankPoints, rankDifference = Item[3], (Item[3] - points)
				if (rankDifference < 0) then
					rankDifference = ""
				else
					rankDifference = "[Points Left: " .. rankDifference .. "]"
				end

				Text = rankName .. " (" .. rankPoints .. " pts) " .. rankDifference

				wnd.Labels[ i ] = Window.MakeLabel{ parent = ActiveWindow, x = 15, y = wnd.Offset, font = "HUDFont", color = rankColor, text = Text }
				wnd.ScaleCache[ i ] = Text

				wnd.Offset = wnd.Offset + 25
			end
		end

		local futureIndex = #wnd.Labels
		wnd.Offset = wnd.Offset + 25
		for i = 5, 1, -1 do
			local Item = specialranks[i]
			local Text = ""

			if Item then
				local rankName, rankColor = Item[1], Item[2]
				local rankRequirement = " (Rank " .. i .. ")"
				local rankDifference = (rank - i)
				if (rankDifference <= 0) then
					rankDifference = ""
				else
					rankDifference = " [Ranks Away: " .. rankDifference .. "]"
				end

				Text = rankName .. rankRequirement .. rankDifference

				wnd.Labels[ futureIndex + i ] = Window.MakeLabel{ parent = ActiveWindow, x = 15, y = wnd.Offset, font = "HUDFont", color = rankColor, text = Text }
				wnd.ScaleCache[ futureIndex + i ] = Text

				wnd.Offset = wnd.Offset + 25
			end
		end

		wnd.Offset = wnd.Offset + 60

		-- The height represents how many groups of zones we have, width represents the title (since it's the longest width out of all items) --
		local height, width = wnd.Offset, Interface:GetTextWidth( wnd.ScaleCache, "HUDFont" )
		ActiveWindow:SetSize( width, height )
		ActiveWindow:SetPos( 20 + Interface.Wide, ScrH() / 2 - ActiveWindow:GetTall() / 2 )

		wnd.Labels[ 100 ] = Window.MakeLabel{ parent = ActiveWindow, x = 15, y = height - 30, font = "HUDFont", color = color_white, text = "0. Close" }
	end

	return wnd
end

WindowPaint = function()
	if not IsValid( ActiveWindow ) then return end

	local w, h = ActiveWindow:GetWide(), ActiveWindow:GetTall()
	if nGUI == 0 then
		draw.RoundedBox( 8, 0, 0, w, h, Color( 0, 0, 0, 110) )
	elseif nGUI == 2 then
		draw.RoundedBox( 8, 0, 0, w, h, Color( 0, 0, 0, 110 ) )
	elseif nGUI == 3 then
		draw.RoundedBox( 6, 0, 0, w, h, Interface.BackgroundColor )
		draw.RoundedBoxEx( 6, 0, 0, w, 30, Interface.ForegroundColor, true, true, false, false )
	elseif nGUI == 4 then
		if CPrestige != 0 then
			if Accent == 1 then
				surface.SetDrawColor( Color( Custom.r, Custom.g, Custom.b, 30 ) )
			else
				surface.SetDrawColor( Color( 0, 0, 0, 150 ) )
			end
		else
			surface.SetDrawColor( Color( 0, 0, 0, 150 ) )
		end
		surface.DrawRect( 0, 0, w, h )
	elseif nGUI == 5 then
		if Accent == 1 then
			draw.RoundedBox( 8, 0, 0, w, h, Color( Custom.r, Custom.g, Custom.b, 30 ) )
		else
			draw.RoundedBox( 8, 0, 0, w, h, Color( 0, 0, 0, 110 ) )
		end
	elseif nGUI > 5 then

	else
		if ActiveWindow.Data.Title != "" then
			surface.SetDrawColor( GUIColor.DarkGray )
			surface.DrawRect( 0, 0, w, h )
			surface.SetDrawColor( GUIColor.LightGray )
			surface.DrawRect( 10, 30, w - 20, h - 40 )
		else
			surface.SetDrawColor( GUIColor.DarkGray )
			surface.DrawRect( 0, 0, w, h )
		end
	end


	local title = ActiveWindow.Data and ActiveWindow.Data.Title or ""

	if nGUI == 0 then
		draw.SimpleText( title, "HUDTitle", 10, 5, GUIColor.Header, TEXT_ALIGN_LEFT )
	elseif nGUI == 1 then
		draw.SimpleText( title, "HUDTitle", 10, 5, labelcolor, TEXT_ALIGN_LEFT )
	elseif nGUI == 2 then
		draw.SimpleText( title, "HUDTitle", 10, 5, labelcolor, TEXT_ALIGN_LEFT )
	elseif nGUI == 3 then
		draw.SimpleText( title, "HUDTitle", w / 2, 5, color_white, TEXT_ALIGN_CENTER )
	elseif nGUI == 4 then
		draw.SimpleText( title, "HUDTitle", 10, 5, GUIColor.Marshmallow, TEXT_ALIGN_LEFT )
	elseif nGUI == 5 then
		draw.SimpleText( title, "HUDTitle", 10, 5, Custom, TEXT_ALIGN_LEFT )
	else
		draw.SimpleText( title, "HUDTitle", 10, 5, labelcolor, TEXT_ALIGN_LEFT )
	end
end

local tempPanel

WindowThink = function()
	if not IsValid( ActiveWindow ) then return end
	local wnd = ActiveWindow.Data
	if not wnd then return end

	if IsValid(tempPanel) then return end

	local Key = -1
	for KeyID = 1, 10 do
		if input.IsKeyDown( KeyID ) then
			Key = KeyID - 1
			break
		end
	end

	if KeyChecker and IsValid( KeyChecker() ) and KeyChecker():IsTyping() then
		Key = -1
	end

	local ID = wnd.ID
	if ID == "Vote" then
		local TimeTitle = "Vote for a new map!"
		if TimeTitle != wnd.Title then wnd.Title = TimeTitle end

		if wnd.EnableExtend then
			Cache.V_Data[ 6 ] = "Extend for 30 minutes"
			wnd.bNoExtend = nil
			wnd.EnableExtend = nil
			wnd.VoteEnd = CurTime() + 30
			wnd.Labels[ 6 ]:SetText( "6 [" .. wnd.Votes[ 6 ] .. "] " .. Cache.V_Data[ 6 ] )
			if GetConVar( "sl_theme" ):GetInt() != 4 then
				wnd.Labels[ 6 ]:SetColor( labelcolor )
			else
				wnd.Labels[ 6 ]:SetColor( GUIColor.Marshmallow )
			end

			Window.AbortClose = true
			timer.Simple( 30, function() Window:Close() Window.AbortClose = nil end )
		end

		if wnd.InstantVote then
			wnd.bVoted = true
			wnd.nVoted = wnd.InstantVote
			wnd.Labels[ wnd.nVoted ]:SetColor( _C.Prefixes.Notification )

			Link:Send( "Vote", { wnd.nVoted } )

			KeyLimitDelay = 0.01
			wnd.InstantVote = nil
		end

		if Key > 0 and Key < 8 and not KeyLimit and not wnd.bVoted then
			if Key == 6 and wnd.bNoExtend then return end

			wnd.bVoted = true
			wnd.nVoted = Key
			wnd.Labels[ Key ]:SetColor( _C.Prefixes.Notification )

			Link:Send( "Vote", { Key } )
			surface.PlaySound( "garrysmod/save_load4.wav" )

			KeyLimitDelay = 0.01
		elseif Key > 0 and Key < 8 and not KeyLimit and wnd.bVoted and Key != wnd.nVoted then
			if Key == 6 and wnd.bNoExtend then return end

			if GetConVar( "sl_theme" ):GetInt() != 4 then
				wnd.Labels[ wnd.nVoted ]:SetColor( labelcolor )
				wnd.Labels[ Key ]:SetColor( _C.Prefixes.Notification )
			else
				wnd.Labels[ wnd.nVoted ]:SetColor( GUIColor.Marshmallow )
				wnd.Labels[ Key ]:SetColor( _C.Prefixes.Notification )
			end

			Link:Send( "Vote", { Key, wnd.nVoted } )
			surface.PlaySound( "garrysmod/save_load4.wav" )

			wnd.nVoted = Key
			KeyLimitDelay = 0.01
		end

		if wnd.Update then
			wnd.Update = false

			for i = 1, 7 do
				if not wnd.Votes[ i ] then continue end

				wnd.Labels[ i ]:SetText( i .. " [" .. wnd.Votes[ i ] .. "] " .. (Cache.V_Data[ i ] or "ERROR") )
				wnd.Labels[ i ]:SizeToContents()
			end
		end
	elseif ID == "WR" then
		if Key > 0 and Key < 8 and not KeyLimit then
			if wnd.nType == 6 or wnd.nType == 8 then return end
			local Index = _C.PageSize * wnd.nPage - _C.PageSize + Key
			local Item = Cache.T_Data[ wnd.nStyle ][ Index ]
			if Item then
				if Admin.EditType and Admin.EditType == 17 and not wnd.szMap then
					Admin:ReqAction( Admin.EditType, { wnd.nStyle, Index, Item[ 1 ], Item[ 2 ] } )
				else
					local Speed, szMap = Vector( 0, 0, 0 ), wnd.szMap or game.GetMap()
					if Item[ 5 ] then Speed = Core.Util:StringToTab( Item[ 5 ] ) end

					if GUILess:GetBool() then
						StatsData( Item, Index, szMap, wnd.nStyle, Speed )
					else
						Link:Print( "Surf Timer", "The #" .. Index .. " record on " .. szMap .. " (Exact Time: " .. ( Item[ 3 ] or 0 ) .. ") was obtained by " .. (Item[ 2 ] or "Unknown Player") .. (Item[ 4 ] and " at " .. Item[ 4 ] or "") .. " on the " .. Core:StyleName( wnd.nStyle ) .. " style" .. (Speed[ 1 ] + Speed[ 2 ] > 0 and ". Their top velocity was " .. math.floor( Speed[ 1 ] ) .. " and had an average velocity of " .. math.floor( Speed[ 2 ] ) .. (Speed[ 3 ] and " - old time: " .. Timer:Convert( Speed[ 3 ] ) or " -") .. ((Speed[ 4 ] and Speed[ 4 ] > 0) and " captured sync was: " .. Speed[ 4 ] .. "%" or "") or ".") )
					end
				end
			end
		elseif not KeyLimit and ((Key == 8 and wnd.nPage != 1) or (Key == 9 and wnd.nPage != wnd.nPages)) then
			if wnd.nType == 6 or wnd.nType == 8 then return end
			local bPrev = Key == 8 and true or false
			wnd.nPage = wnd.nPage + (bPrev and -1 or 1)

			if not wnd.vLoaded[ wnd.nPage ] then
				Link:Send( "WRList", { wnd.nPage, wnd.nStyle, wnd.szMap } )
			else
				local Index = _C.PageSize * wnd.nPage - _C.PageSize

				for i = 1, _C.PageSize do
					local Item = Cache.T_Data[ wnd.nStyle ][ Index + i ]
					if Item then
						wnd.Labels[ i ]:SetText( i  .. ". [#" .. Index + i .. " " .. Timer:Convert( Item[ 3 ] ) .. "]: " .. Item[ 2 ] )
						wnd.Labels[ i ]:SizeToContents()
						wnd.Labels[ i ]:SetVisible( true )
					else
						wnd.Labels[ i ]:SetText( "" )
						wnd.Labels[ i ]:SetVisible( false )
					end
				end

				Window.PageToggle( wnd, bPrev )
			end
		end
	elseif ID == "Nominate" then
		if Key > 0 and Key < 8 and not KeyLimit then
			local Index = _C.PageSize * wnd.nPage - _C.PageSize + Key
			local szVotedMap = Cache.M_Data[ Index ]
			if not szVotedMap or not szVotedMap[ 1 ] then return end
			wnd.bVoted = true

			RunConsoleCommand( "sm_nominate", szVotedMap[ 1 ] )
			timer.Simple( 0.25, function() Window:Close() end )
		elseif not KeyLimit and not wnd.bVoted and ((Key == 8 and wnd.nPage != 1) or (Key == 9 and wnd.nPage != wnd.nPages)) then
			local bPrev = Key == 8 and true or false
			wnd.nPage = wnd.nPage + (bPrev and -1 or 1)
			local Index = _C.PageSize * wnd.nPage - _C.PageSize

			for i = 1, _C.PageSize do
				if Cache.M_Data[ Index + i ] then
					local Item = Cache.M_Data[ Index + i ]

					local Color
					if GetConVar( "sl_theme" ):GetInt() != 4 then
						Color = Cache:L_Check( Item and Item[ 1 ] or "" ) and _C.Prefixes.Notification or labelcolor
					else
						Color = Cache:L_Check( Item and Item[ 1 ] or "" ) and _C.Prefixes.Notification or GUIColor.Marshmallow
					end
					wnd.Labels[ i ]:SetText( i .. ". " .. (wnd.bPoints and "[" .. Item[ 2 ] .. "] " or "") .. Item[ 1 ] .. ((Item[ 3 ] and wnd.bPoints) and " - Tier " .. Item[ 3 ] .. (Item[ 4 ] and " " .. _C.MapTypes[ tonumber( Item[ 4 ] ) ] or "") or "") )
					wnd.Labels[ i ]:SetColor( Color )
					wnd.Labels[ i ]:SizeToContents()
					wnd.Labels[ i ]:SetVisible( true )
				else
					wnd.Labels[ i ]:SetText( "" )
					wnd.Labels[ i ]:SetColor( labelcolor )
					wnd.Labels[ i ]:SetVisible( false )
				end
			end

			Window.PageToggle( wnd, bPrev )
		elseif input.IsKeyDown( KEY_N ) and not KeyLimit and not wnd.bVoted then
			if wnd.bHold then return end
			wnd.bHold = true
			wnd.bPoints = not wnd.bPoints

			local dim = Window.List[ ID ].Dim
			if wnd.bPoints then
				ActiveWindow:SetSize( dim[ 1 ] + 140, dim[ 2 ] )
			else
				ActiveWindow:SetSize( dim[ 1 ], dim[ 2 ] )
			end

			local Index = _C.PageSize * wnd.nPage - _C.PageSize
			for i = 1, _C.PageSize do
				if Cache.M_Data[ Index + i ] then
					local Item = Cache.M_Data[ Index + i ]
					wnd.Labels[ i ]:SetText( i .. ". " .. (wnd.bPoints and "[" .. Item[ 2 ] .. "] " or "") .. Item[ 1 ] .. ((Item[ 3 ] and wnd.bPoints) and " - Tier " .. Item[ 3 ] .. (Item[ 4 ] and " " .. _C.MapTypes[ tonumber( Item[ 4 ] ) ] or "") or "") )
					wnd.Labels[ i ]:SizeToContents()
					wnd.Labels[ i ]:SetVisible( true )
				else
					wnd.Labels[ i ]:SetText( "" )
					wnd.Labels[ i ]:SetVisible( false )
				end
			end

			Key = 20
		elseif input.IsKeyDown( KEY_M ) and not KeyLimit and not wnd.bVoted then
			if wnd.bHold then return end
			wnd.bHold = true

			local tabSort = { "their name.", "their multiplier (ascending).", "their multiplier (descending)." }
			wnd.nSort = wnd.nSort + 1
			if wnd.nSort > 3 then wnd.nSort = 1 end
			Window:Open( "Nominate", { wnd.nServer, wnd.nSort, wnd.bPoints } )

			Link:Print( "General", "Maps are now sorted by " .. tabSort[ wnd.nSort ] or "an undefined parameter." )
			Key = 20
		elseif not KeyLimit then
			wnd.bHold = nil
		end
	elseif ID == "Style" then
		if Key > 0 and Key <= _C.Style.Bonus and not KeyLimit and not wnd.Selected then
			wnd.Selected = true
			if GetConVar( "sl_theme" ):GetInt() != 4 then
				wnd.Labels[ Timer.Style ]:SetColor( labelcolor )
				wnd.Labels[ Key ]:SetColor( _C.Prefixes.Notification )
			else
				wnd.Labels[ Timer.Style ]:SetColor( GUIColor.Marshmallow )
				wnd.Labels[ Key ]:SetColor( _C.Prefixes.Notification )
			end
			RunConsoleCommand( "sm_style", tostring( Key ) )
			Key = 0
		end
	elseif ID == "Ranks" then
		if not KeyLimit and ((Key == 8 and wnd.nPage != 1) or (Key == 9 and wnd.nPage != wnd.nPages)) then
			local bPrev = Key == 8 and true or false
			wnd.nPage = wnd.nPage + (bPrev and -1 or 1)
			local Index = _C.PageSize * wnd.nPage - _C.PageSize

			for i = 1, _C.PageSize do
				local Item = _C.Ranks[ Index + i ]
				if Item then
					wnd.Labels[ i ]:SetText( Index + i .. ". " .. Item[ 1 ] .. " (" .. math.ceil( Item[ wnd.nType ] ) .. ")" )
					wnd.Labels[ i ]:SetColor( Item[ 2 ] )
					wnd.Labels[ i ]:SetFont( Index + i == wnd.nRank and "HUDSpecial" or Fonts.StrongLabel )
					wnd.Labels[ i ]:SizeToContents()
					wnd.Labels[ i ]:SetVisible( true )
				else
					wnd.Labels[ i ]:SetText( "" )
					wnd.Labels[ i ]:SetVisible( false )
				end
			end

			Window.PageToggle( wnd, bPrev )
		end
	elseif ID == "Top" then
		if not KeyLimit and ((Key == 8 and wnd.nPage != 1) or (Key == 9 and wnd.nPage != wnd.nPages)) then
			local bPrev = Key == 8 and true or false
			wnd.nPage = wnd.nPage + (bPrev and -1 or 1)

			if not wnd.vLoaded[ wnd.nPage ] then
				Link:Send( "TopList", { wnd.nPage, wnd.nType } )
			else
				local Index = _C.PageSize * wnd.nPage - _C.PageSize

				for i = 1, _C.PageSize do
					local Item = Cache.R_Data[ Index + i ]
					if Item then
						wnd.Labels[ i ]:SetText( "#" .. Index + i .. ": " .. Item[ 1 ] .. " with " .. Item[ 2 ] .. " pts" )
						wnd.Labels[ i ]:SizeToContents()
						wnd.Labels[ i ]:SetVisible( true )
					else
						wnd.Labels[ i ]:SetText( "" )
						wnd.Labels[ i ]:SetVisible( false )
					end
				end

				Window.PageToggle( wnd, bPrev )
			end
		end
	elseif ID == "Maps" then
		if Key > 0 and Key < 8 and not KeyLimit then
			local Index = _C.PageSize * wnd.nPage - _C.PageSize
			local Item = wnd.tabList[ Index + Key ]
			if wnd.szType == "WR" and Item and Item[ 4 ] then
				local Sub = Item[ 4 ]
				local Speed = Vector( 0, 0, 0 )
				if Sub[ 2 ] then Speed = Core.Util:StringToTab( Sub[ 2 ] ) end
				Link:Print( "Surf Timer", "You obtained the #1 record on " .. Item[ 1 ] .. " (Time: " .. Timer:Convert( Item[ 2 ] or 0 ) .. (Sub[ 3 ] and " - Points: " .. Sub[ 3 ] or "") .. ")" .. (Sub[ 1 ] and " at " .. Sub[ 1 ] or "") .. " with the nickname " .. (Sub[ 4 ] or "Unknown Player") .. " on the " .. Core:StyleName( Item[ 3 ] ) .. " style" .. (Speed[ 1 ] + Speed[ 2 ] > 0 and ". Your top velocity was " .. math.floor( Speed[ 1 ] ) .. " and you had an average velocity of " .. math.floor( Speed[ 2 ] ) .. (Speed[ 3 ] and " - old time: " .. Timer:Convert( Speed[ 3 ] ) or " -") .. ((Speed[ 4 ] and Speed[ 4 ] > 0) and " captured sync was: " .. Speed[ 4 ] .. "%" or "") or ".") )
			elseif Item and Item[ 1 ] then
				RunConsoleCommand( "sm_nominate", Item[ 1 ] )
			end
		elseif not KeyLimit and ((Key == 8 and wnd.nPage != 1) or (Key == 9 and wnd.nPage < wnd.nPages)) then
			local bPrev = Key == 8 and true or false
			wnd.nPage = wnd.nPage + (bPrev and -1 or 1)
			local Index = _C.PageSize * wnd.nPage - _C.PageSize

			for i = 1, _C.PageSize do
				local Item = wnd.tabList[ Index + i ]
				if Item then
					local Text = ""
					if wnd.szType == "Completed" then
						Text = Index + i .. ". [" .. Timer:Convert( Item[ 2 ] ) .. "] " .. Item[ 1 ]
					elseif wnd.szType == "Left" then
						Text = Index + i .. ". " .. Item[ 1 ] .. " (" .. Item[ 2 ] .. " pts - Tier " .. wnd.tabData[ Item[ 1 ] ][ 2 ] .. " " .. _C.MapTypes[ tonumber( wnd.tabData[ Item[ 1 ] ][ 3 ] ) ] .. ")"
					elseif wnd.szType == "WR" then
						Text = Index + i .. ". [" .. Timer:Convert( Item[ 2 ] ) .. "] " .. Item[ 1 ] .. " (Style: " .. Core:StyleName( Item[ 3 ] ) .. ")"
					elseif wnd.szType == "RR" then
						Text = Index + i .. ". [" .. Item[ 1 ] .. "] " .. Item[ 3 ] .. " (Time: " .. Timer:Convert( Item[ 2 ] ) .. ")"
					end

					wnd.Labels[ i ]:SetText( Text )
					wnd.Labels[ i ]:SetVisible( true )
					wnd.Labels[ i ]:SizeToContents()
				else
					wnd.Labels[ i ]:SetText( "" )
					wnd.Labels[ i ]:SetVisible( false )
					wnd.Labels[ i ]:SizeToContents()
				end
			end

			Window.PageToggle( wnd, bPrev )
		end
	elseif ID == "Checkpoints" then
		if Key > 0 and Key < 8 and not KeyLimit then
			Link:Send( "Checkpoints", { Key, wnd.bDelay, wnd.bDelete } )
		elseif not KeyLimit and Key == 8 then
			wnd.bDelay = not wnd.bDelay
			wnd.Labels[ 8 ]:SetText( "8. Turn Delay " .. (wnd.bDelay and "Off" or "On") )
			wnd.Labels[ 8 ]:SizeToContents()
		elseif not KeyLimit and Key == 9 then
			wnd.bDelete = not wnd.bDelete
			wnd.Labels[ 9 ]:SetText( "9. Turn Delete " .. (wnd.bDelete and "Off" or "On") )
			wnd.Labels[ 9 ]:SizeToContents()
		end
	elseif ID == "PersonalRecord" then
		if Key > 0 and Key < 8 and !KeyLimit then
			local cmdList = {
				["Map"] = "!" .. Core.StyleIDToShortName(wnd.nStyle) .. "sr",
				["Bonus"] = "!btop",
				["Stage"] = "!stop",
			}

			local Index = _C.PageSize * wnd.nPage - _C.PageSize
			local Item = wnd.tabList[ Index + Key ]

			if Item and Item[1] then
				local phrasedText = string.Explode( ":", Item[1] )
				local cmdType = cmdList[phrasedText[1]]

				if (string.StartWith(phrasedText[1], "Bonus")) then
					cmdType = "!bsr"

					local style = Core:GetStyleID(phrasedText[1])
					if (style == 0) then style = 4 end

					local sequence = Core.BonusToSequence(style)
					cmdType = cmdType .. " " .. sequence
				elseif (string.StartWith(phrasedText[1], "Stage")) then
					cmdType = "!cpr"

					local stage = tonumber(string.sub(phrasedText[1], 6))
					cmdType = cmdType .. " " .. stage
				elseif !cmdType then
					cmdType = "!" .. Core.StyleIDToShortName(wnd.nStyle) .. "sr"
				end

				local pullMap = wnd.szMap
				local externalMap = pullMap and (pullMap != game.GetMap())
				if externalMap then
					cmdType = cmdType .. " " .. pullMap
				end

				RunConsoleCommand( "say", cmdType )
			end
		elseif !KeyLimit and ((Key == 8 and wnd.nPage != 1) or (Key == 9 and wnd.nPage < wnd.nPages)) then
			local bPrev = Key == 8 and true or false
			wnd.nPage = wnd.nPage + (bPrev and -1 or 1)
			local Index = _C.PageSize * wnd.nPage - _C.PageSize

			local count = 1
			for i = 1, _C.PageSize do
				local Item = wnd.tabList[ Index + i ]
				local Text, time, rank = "", "", ""

				if Item then
					time = i .. ") " .. Item[1]
					rank = Item[2]

					local wasEmpty = wnd.Labels[ count ]:GetText() == ""

					wnd.Labels[ count ]:SetText( time )
					wnd.Labels[ count ]:SetVisible( true )
					wnd.Labels[ count ]:SizeToContents()

					wnd.Labels[ count + 1 ]:SetText( rank )
					wnd.Labels[ count + 1 ]:SetVisible( true )
					wnd.Labels[ count + 1 ]:SizeToContents()

					wnd.Labels[ count + 2 ]:SetText( Text )
					wnd.Labels[ count + 2 ]:SetVisible( true )
					wnd.Labels[ count + 2 ]:SizeToContents()

					if wasEmpty then
						wnd.Offset = wnd.Offset + 60
					end
				else
					wnd.Labels[ count ]:SetText( "" )
					wnd.Labels[ count ]:SetVisible( false )
					wnd.Labels[ count ]:SizeToContents()

					wnd.Labels[ count + 1 ]:SetText( "" )
					wnd.Labels[ count + 1 ]:SetVisible( false )
					wnd.Labels[ count + 1 ]:SizeToContents()

					wnd.Labels[ count + 2 ]:SetText( "" )
					wnd.Labels[ count + 2 ]:SetVisible( false )
					wnd.Labels[ count + 2 ]:SizeToContents()

					wnd.Offset = wnd.Offset - 60
				end

				count = count + 3
			end

			Window.PageToggle( wnd, bPrev, true )

			local height, width = wnd.Offset, ActiveWindow:GetWide()
			ActiveWindow:SetSize( width, height )
			ActiveWindow:SetPos( 20 + Interface.Wide, ScrH() / 2 - ActiveWindow:GetTall() / 2 )

			wnd.Labels[ 98 ]:SetPos( 15, height - 80 )
			wnd.Labels[ 99 ]:SetPos( 15, height - 55 )
			wnd.Labels[ 100 ]:SetPos( 15, height - 30 )
		end
	elseif ID == "MapTop" then
		if Key > 0 and Key < 8 and !KeyLimit then
			-- Insert !prinfo or something here --
			local Index = _C.PageSize * wnd.nPage - _C.PageSize
			local Item = wnd.tabList[ Index + Key ]

			if Item and Item[1] then
				local time, difference, name = Item[1] or 0, Item[2] or 0, Item[3] or "Unknown Player"
				local date = Item[5] or "N/A"
				local vData, prestrafe, points = Core.Util:StringToTab(Item[6] or ""), Item[7] or 0, Item[8] or 0

				local topSpeed = vData[1] and vData[1] != "" and vData[1] or 0
				local averageSpeed = vData[2] and vData[2] != "" and vData[2] or 0
				local oldTime = vData[3] and vData[3] != "" and vData[3] or 0
				local sync = vData[4] and vData[4] != "" and vData[4] or 0

				local displayContent = {
					[1] = "Time Obtained [Exact]: " .. time .. " (" .. difference .. ")",
					[2] = "Old Time: " .. Timer:Convert(oldTime),
					[3] = "Record Set At: " .. date,
					[4] = "Points Obtained: " .. points .. " pts",
					[6] = "- Speed Stats -",
					[7] = "Max Speed: " .. topSpeed .. " u/s",
					[8] = "Average Speed: " .. averageSpeed .. " u/s",
					[9] = "Prestrafe: " .. prestrafe .. " u/s",
					[10] = "Sync: " .. sync .. "%"
				}

				tempPanel = SMPanels.ContentFrame( { title = "Detailed Record Information For " .. name, center = true, content = displayContent } )
			end
		elseif !KeyLimit and ((Key == 8 and wnd.nPage != 1) or (Key == 9 and wnd.nPage < wnd.nPages)) then
			local bPrev = Key == 8 and true or false
			wnd.nPage = wnd.nPage + (bPrev and -1 or 1)
			wnd.ScaleCache = {}

			local Index = _C.PageSize * wnd.nPage - _C.PageSize

			for i = 1, _C.PageSize do
				local Item = wnd.tabList[ Index + i ]
				if Item then
					local time, difference, name = Item[1], Item[2], Item[3]
					Text = i .. ") Rank " .. ( Index + i ) .. ": " .. time .. " (" .. difference .. ") - " .. name

					local userSteam = (Item[4] == LocalPlayer():SteamID())
					local topcolor = (userSteam and _C.Prefixes.Notification or color_white)

					local wasEmpty = wnd.Labels[ i ]:GetText() == ""

					wnd.Labels[ i ]:SetText( Text )
					wnd.Labels[ i ]:SetVisible( true )
					wnd.Labels[ i ]:SizeToContents()
					wnd.Labels[ i ]:SetColor( topcolor )

					if wasEmpty then
						wnd.Offset = wnd.Offset + 25
					end

					wnd.ScaleCache[ i ] = Text
				else
					wnd.Labels[ i ]:SetText( "" )
					wnd.Labels[ i ]:SetVisible( false )
					wnd.Labels[ i ]:SizeToContents()

					wnd.Offset = wnd.Offset - 25
				end
			end

			Window.PageToggle( wnd, bPrev, true )

			local height, width = wnd.Offset, Interface:GetTextWidth( wnd.ScaleCache, "HUDFont" )
			ActiveWindow:SetSize( width, height )
			ActiveWindow:SetPos( 20 + Interface.Wide, ScrH() / 2 - ActiveWindow:GetTall() / 2 )

			wnd.Labels[ 98 ]:SetPos( 15, height - 80 )
			wnd.Labels[ 99 ]:SetPos( 15, height - 55 )
			wnd.Labels[ 100 ]:SetPos( 15, height - 30 )
		end
	end

	if Key == 0 and not KeyLimit and not table.HasValue( Window.Unclosable, ID ) then
		timer.Simple( KeyLimitDelay, function()
			if IsValid( ActiveWindow ) then
				ActiveWindow:Close()
				ActiveWindow = nil
			end
		end )
	elseif Key >= 0 and not KeyLimit then
		KeyLimit = true
		timer.Simple( KeyLimitDelay, function()
			KeyLimit = false
		end )
	end
end


function Window:GetActive()
	return ActiveWindow
end

function Window:IsActive( szIdentifier )
	if IsValid( ActiveWindow ) then
		if not ActiveWindow.Data then return false end
		return ActiveWindow.Data.ID == szIdentifier
	end

	return false
end

function Window.PageToggle( data, bPrev, custom )
	local first, second = 8, 9
	if custom then
		first, second = 98, 99
	end

	if not bPrev then
		if data.nPage == data.nPages then
			data.Labels[ first ]:SetVisible( true )
			data.Labels[ second ]:SetVisible( false )
		else
			data.Labels[ first ]:SetVisible( true )
			data.Labels[ second ]:SetVisible( true )
		end
	else
		if data.nPage == 1 then
			data.Labels[ first ]:SetVisible( false )
			data.Labels[ second ]:SetVisible( true )
		else
			data.Labels[ first ]:SetVisible( true )
			data.Labels[ second ]:SetVisible( true )
		end
	end
end

function Window.MakeLabel( t )
	local lbl = vgui.Create( "DLabel", t.parent )
	lbl:SetPos( t.x, t.y )
	lbl:SetFont( t.font )
	lbl:SetColor( t.color )
	lbl:SetText( t.text )
	lbl:SizeToContents()
	return lbl
end

function Window.MakeButton( t )
	local btn = vgui.Create( "DButton", t.parent )
	btn:SetSize( t.w, t.h )
	btn:SetPos( t.x, t.y )
	btn:SetText( t.text )
	if t.id then btn.SetID = t.id end
	btn.DoClick = t.onclick
	return btn
end

function Window.MakeAvatar( t )
	local avt = vgui.Create( "AvatarImage", t.parent )
	avt:SetSize( t.w, t.h )
	avt:SetPos( t.x, t.y )
	avt:SetPlayer( t.player, t.size )
	return avt
end

function Window.MakeTextBox( t )
	local txt = vgui.Create( "DTextEntry", t.parent )
	txt:SetPos( t.x, t.y )
	txt:SetSize( t.w, t.h )
	txt:SetText( t.text or "" )
	return txt
end

-- 01/16/2022: This looked old so I updated it a bit using the new SMPanel structure --
function Window.MakeQuery( cap, t, ... )
	cap = string.Explode("\n", cap)
	local panel = SMPanels.ContentFrame({title = t, center = true, noclose = true, content = cap})

	local arg = {...}
	local bezel = Interface:GetBezel "Medium"
	local sizex, sizey = unpack(SMPanels.BoxButton[Interface.Scale])
	local x, y, c = bezel, panel:GetTall() - sizey - bezel, 1

	for k = 1, #arg, 2 do
		local text, func = arg[k], arg[k + 1] or function() end
		local newFunc = function()
			func()
			panel:Remove()
		end

		SMPanels.Button( { parent = panel, text = text, font = Interface:GetTinyFont(), func = newFunc, x = x, y = y } )

		x, c = x + sizex + bezel, c + 1
		if c > 4 then x, y, c = bezel, y + sizey + bezel, 1 end
	end

	panel:SizeToChildren(true, true)
	local finalx, finaly = panel:GetWide(), panel:GetTall()
	panel:SetSize(finalx + bezel, finaly + bezel)
	panel:Center()
end

function Window.MakeRequest( cap, t, d, f, l )
	cap = string.Explode("\n", cap)
	local panel = SMPanels.ContentFrame({title = t, center = true, noclose = true, content = cap})

	local bezel = Interface:GetBezel "Medium"
	local sizex, sizey = unpack(SMPanels.BoxButton[Interface.Scale])
	local x, y = bezel, panel:GetTall() - sizey - bezel
	local buttonSize = SMPanels.GenericSize[Interface.Scale]

	local mid = (panel:GetWide() / 2)

	local response
	local submitFunc = function()
		local text = response:GetText()
		f(text)
		ActiveWindow:Close()
		panel:Remove()
	end

	local failFunc = function()
		l()
		panel:Remove()
	end

	response = SMPanels.TextEntry( { parent = panel, x = x, y = y, w = panel:GetWide() - bezel, h = buttonSize, text = d or "", noremove = true, func = submitFunc } )
	response:RequestFocus()
	SMPanels.Button( { parent = panel, text = "Submit", font = Interface:GetFont(), func = submitFunc, x = mid - sizex - bezel, y = y + buttonSize + bezel } )
	SMPanels.Button( { parent = panel, text = "Cancel", font = Interface:GetFont(), func = failFunc, x = mid + bezel, y = y + buttonSize + bezel } )

	panel:SizeToChildren(true, true)
	local finalx, finaly = panel:GetWide(), panel:GetTall()
	panel:SetSize(finalx + bezel, finaly + bezel)
	panel:Center()
end
