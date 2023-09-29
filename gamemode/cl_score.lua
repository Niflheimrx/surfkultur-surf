surface.CreateFont( "ScoreboardPlayer", { font = "Coolvetica", size = 24, weight = 500, antialias = true, italic = false })
surface.CreateFont( "MersText1", { font = "Coolvetica", size = 16, weight = 1000, antialias = true, italic = false })
surface.CreateFont( "MersRadial", { font = "Lato Light", size = math.ceil( ScrW() / 34 ), weight = 500, antialias = true, italic = false })

local syt = SysTime

local menu = nil
local con = Timer:GetConvert()

local icon_muted = Material( "icon32/muted.png" )
local icon_access = { Material( "icon16/heart.png" ), Material( "icon16/heart_add.png" ), Material( "icon16/report_user.png" ), Material( "icon16/shield.png" ), Material( "icon16/shield_add.png" ), Material( "icon16/script_code_red.png" ), Material( "icon16/house.png" ) }
local icon_ratzi = Material( "icon16/controller.png" )

local function _AA( szAction, szSID )
	if not IsValid( LocalPlayer() ) then return end
	if Admin:IsAvailable() or LocalPlayer():GetNWInt( "AccessIcon", 0 ) > 2 then
		RunConsoleCommand( "say", "!admin " .. szAction .. " " .. szSID )
	else
		Link:Print( "Admin", "Please open the admin panel before trying to access scoreboard functionality." )
	end
end

local function PutPlayerItem( self, pList, ply, mw )
	local btn = vgui.Create( "DButton" )
	btn.player = ply
	btn.ctime = CurTime()
	btn:SetTall( 32 )
	btn:SetText( "" )

	function btn:Paint( w, h )
		surface.SetDrawColor( 35, 35, 35, 0 )
		surface.DrawRect( 0, 0 + h - 2, w, 2 )

		surface.SetDrawColor( self.BoxColor or Color( 150, 150, 150 ) )
		surface.DrawOutlinedRect( 0, 0 + h - 2, w, 2 )

		if IsValid( ply ) and ply:IsPlayer() then
			local s = 0
			local points = ply:GetNWInt "Points"
			local sRank = ply:GetNWInt "SpecialRank"
			local Rank = Timer:GetRankObject( sRank, points )

			local TimerText = con( ply:GetNWFloat( "Record", 0 ) )
			local StyleText = Core:StyleName( ply:GetNWInt( "Style", _C.Style.Normal ) )
			local ColorSpec = ply:GetNWInt( "Spectating", 0 ) == 1 and Color( 180, 180, 180 ) or Color( 255, 255, 255 )
			local nAccess = ply:GetNWInt( "AccessIcon", 0 )

			if ply:GetNWInt( "Style" ) > 14 and ply:GetNWInt( "Style" ) < 40 then StyleText = "Stage " .. ply:GetNWInt( "Style" ) - 14 end
			if ply:GetNWInt( "Practice" ) == 1 then StyleText = "Practice" end

			if ply:IsBot() and StyleText ~= "Unknown" then
				if nGUI == 3 then
					draw.DrawText( StyleText, "ScoreboardPlayer", s + 11, 9, Color( 0, 0, 0 ), TEXT_ALIGN_LEFT )
					draw.DrawText( StyleText, "ScoreboardPlayer", s + 10, 8, color_white, TEXT_ALIGN_LEFT )
				elseif nGUI == 2 then
					draw.DrawText( StyleText, "ScoreboardPlayer", s + 11, 9, Color( 0, 0, 0 ), TEXT_ALIGN_LEFT )
					draw.DrawText( StyleText, "ScoreboardPlayer", s + 10, 8, Color( 255, 255, 255 ), TEXT_ALIGN_LEFT )
				elseif nGUI == 1 then
					draw.DrawText( StyleText, "ScoreboardPlayer", s + 11, 9, Color( 0, 0, 0 ), TEXT_ALIGN_LEFT )
					draw.DrawText( StyleText, "ScoreboardPlayer", s + 10, 8, Color( 255, 0, 0 ), TEXT_ALIGN_LEFT )
				elseif nGUI == 5 then
					draw.DrawText( StyleText, "ScoreboardPlayer", s + 11, 9, Color( 0, 0, 0 ), TEXT_ALIGN_LEFT )
					draw.DrawText( StyleText, "ScoreboardPlayer", s + 10, 8, Color( Custom.r, Custom.g, Custom.b ), TEXT_ALIGN_LEFT )
				else
					draw.DrawText( StyleText, "ScoreboardPlayer", s + 11, 9, Color( 0, 0, 0 ), TEXT_ALIGN_LEFT )
					draw.DrawText( StyleText, "ScoreboardPlayer", s + 10, 8, GUIColor.Header, TEXT_ALIGN_LEFT )
				end
			elseif ply:IsBot() and StyleText == "Unknown" then
				if nGUI == 3 then
					draw.DrawText( "N/A", "ScoreboardPlayer", s + 11, 9, Color( 0, 0, 0 ), TEXT_ALIGN_LEFT )
					draw.DrawText( "N/A", "ScoreboardPlayer", s + 10, 8, color_white, TEXT_ALIGN_LEFT )
				elseif nGUI == 2 then
					draw.DrawText( "N/A", "ScoreboardPlayer", s + 11, 9, Color( 0, 0, 0 ), TEXT_ALIGN_LEFT )
					draw.DrawText( "N/A", "ScoreboardPlayer", s + 10, 8, Color( 255, 255, 255 ), TEXT_ALIGN_LEFT )
				elseif nGUI == 1 then
					draw.DrawText( "N/A", "ScoreboardPlayer", s + 11, 9, Color( 0, 0, 0 ), TEXT_ALIGN_LEFT )
					draw.DrawText( "N/A", "ScoreboardPlayer", s + 10, 8, Color( 255, 0, 0 ), TEXT_ALIGN_LEFT )
				elseif nGUI == 5 then
					draw.DrawText( "N/A", "ScoreboardPlayer", s + 11, 9, Color( 0, 0, 0 ), TEXT_ALIGN_LEFT )
					draw.DrawText( "N/A", "ScoreboardPlayer", s + 10, 8, Color( Custom.r, Custom.g, Custom.b ), TEXT_ALIGN_LEFT )
				else
					draw.DrawText( "N/A", "ScoreboardPlayer", s + 11, 9, Color( 0, 0, 0 ), TEXT_ALIGN_LEFT )
					draw.DrawText( "N/A", "ScoreboardPlayer", s + 10, 8, GUIColor.Header, TEXT_ALIGN_LEFT )
				end
			else
				if nAccess > 0 then
					local VIPTag, VIPTagColor = ply:GetNWString( "VIPTag", "" ), ply:GetNWVector( "VIPTagColor", Vector( -1, 0, 0 ) )
					if VIPTag != "" and VIPTagColor.x >= 0 then
						draw.DrawText( VIPTag, "ScoreboardPlayer", s + 11, 9, Color( 0, 0, 0 ), TEXT_ALIGN_LEFT )
						draw.DrawText( VIPTag, "ScoreboardPlayer", s + 10, 8, VIPTagColor, TEXT_ALIGN_LEFT )
					else
						draw.DrawText( Rank[ 1 ], "ScoreboardPlayer", s + 11, 9, Color( 0, 0, 0 ), TEXT_ALIGN_LEFT )
						draw.DrawText( Rank[ 1 ], "ScoreboardPlayer", s + 10, 8, Rank[ 2 ], TEXT_ALIGN_LEFT )
					end
				else
					draw.DrawText( Rank[ 1 ], "ScoreboardPlayer", s + 11, 9, Color( 0, 0, 0 ), TEXT_ALIGN_LEFT )
					draw.DrawText( Rank[ 1 ], "ScoreboardPlayer", s + 10, 8, Rank[ 2 ], TEXT_ALIGN_LEFT )
				end
			end

			s = s + mw + 56

			local nAccess = ply:GetNWInt( "AccessIcon", 0 )
			if nAccess > 0 then
				local r_icon = ( ply:SteamID() == "STEAM_0:1:29239161" and icon_ratzi or icon_access[ nAccess ] )

				surface.SetMaterial( r_icon )
				surface.SetDrawColor( Color( 255, 255, 255 ) )
				surface.DrawTexturedRect( s + 4, h / 2 - 8, 16, 16 )
				s = s + 20
			end

			if ply:IsMuted() then
				surface.SetMaterial( icon_muted )
				surface.SetDrawColor( Color( 255, 255, 255 ) )
				surface.DrawTexturedRect( s + 4, h / 2 - 16, 32, 32 )
				s = s + 32
			end

			if (sRank > 0 and sRank < 6) then
				if (sRank == 1) then
					surface.SetMaterial( Material( _C.MaterialID .. "/icon_rank13.png" ) )
					surface.SetDrawColor( Color( 255, 255, 255 ) )
					surface.DrawTexturedRect( s + 4, h / 2 - 14, 32, 32 )
					s = s + 32
				elseif (sRank <= 3) then
					surface.SetMaterial( Material( _C.MaterialID .. "/icon_rank12.png" ) )
					surface.SetDrawColor( Color( 255, 255, 255 ) )
					surface.DrawTexturedRect( s + 4, h / 2 - 14, 32, 32 )
					s = s + 32
				elseif (sRank <= 5) then
					surface.SetMaterial( Material( _C.MaterialID .. "/icon_rank11.png" ) )
					surface.SetDrawColor( Color( 255, 255, 255 ) )
					surface.DrawTexturedRect( s + 4, h / 2 - 14, 32, 32 )
					s = s + 32
				end
			elseif (points > 0) then
				surface.SetMaterial( Material( _C.MaterialID .. "/icon_rank" .. ply:GetNWInt( "SubRank", 1 ) .. ".png" ) )
				surface.SetDrawColor( Color( 255, 255, 255 ) )
				surface.DrawTexturedRect( s + 4, h / 2 - 14, 32, 32 )
				s = s + 32
			end

			local PlayerName = ply:Name()

			if ply:IsBot() then
				local szName = ply:GetNWString( "BotName", "Loading..." )
				if szName != "Awaiting playback..." and szName != "Loading..." then
					szName = "by: " .. szName
					local pos = ply:GetNWInt( "WRPos", 0 )
					if pos > 0 then
						szName = "#" .. pos .. " Run " .. szName
					else
						szName = "Run " .. szName
					end
				end
				if not self.BoxColor then
					if nGUI == 3 then
						self.BoxColor = color_white
					elseif nGUI == 2 then
						self.BoxColor = Color( 255, 255, 255 )
					elseif nGUI == 1 then
						self.BoxColor = Color( 255, 0, 0 )
					elseif nGUI == 5 then
						self.BoxColor = Color( Custom.r, Custom.g, Custom.b, 150 )
					else
						self.BoxColor = color_white
					end

				end
				PlayerName = szName
			end

			if nAccess > 0 then
				local VIPName, VIPNameColor = ply:Name(), ply:GetNWVector( "VIPNameColor", Vector( -1, 0, 0 ) )
				if ply:GetNWInt( "Spectating", 0 ) == 1 then
					if nGUI != 4 then
						draw.DrawText( VIPName, "ScoreboardPlayer", s + 11, 9, Color( 0, 0, 0) , TEXT_ALIGN_LEFT )
					end
					draw.DrawText( VIPName, "ScoreboardPlayer", s + 10, 8, ColorSpec, TEXT_ALIGN_LEFT )
				else
					if VIPNameColor.x == 256 then
						draw.DrawText( VIPName, "ScoreboardPlayer", s + 11, 9, Color( 0, 0, 0) , TEXT_ALIGN_LEFT )
						draw.DrawText( VIPName, "ScoreboardPlayer", s + 10, 8, Core.Util:ColorToRainbow(), TEXT_ALIGN_LEFT )
					elseif VIPNameColor.x == 257 then
						local gs = ply:GetNWVector( "VIPGradientS", Vector( -1, 0, 0 ) )
						local ge = ply:GetNWVector( "VIPGradientE", Vector( -1, 0, 0 ) )

						draw.DrawText( VIPName, "ScoreboardPlayer", s + 11, 9, Color( 0, 0, 0) , TEXT_ALIGN_LEFT )
						draw.DrawText( VIPName, "ScoreboardPlayer", s + 10, 8, Core.Util:ColorToRainbow( gs, ge ), TEXT_ALIGN_LEFT )
					elseif VIPNameColor.x >= 0 then
						draw.DrawText( VIPName, "ScoreboardPlayer", s + 11, 9, Color( 0, 0, 0) , TEXT_ALIGN_LEFT )
						draw.DrawText( VIPName, "ScoreboardPlayer", s + 10, 8, VIPNameColor, TEXT_ALIGN_LEFT )
					else
						draw.DrawText( VIPName, "ScoreboardPlayer", s + 11, 9, Color( 0, 0, 0) , TEXT_ALIGN_LEFT )
						draw.DrawText( VIPName, "ScoreboardPlayer", s + 10, 8, ColorSpec, TEXT_ALIGN_LEFT )
					end
				end
			else
				draw.DrawText( PlayerName, "ScoreboardPlayer", s + 11, 9, Color( 0, 0, 0 ), TEXT_ALIGN_LEFT )
				draw.DrawText( PlayerName, "ScoreboardPlayer", s + 10, 8, ColorSpec, TEXT_ALIGN_LEFT )
			end

			surface.SetFont( "ScoreboardPlayer" )
			local wt, ht = surface.GetTextSize( TimerText )
			local wx = 105 - wt
			local o = w - wt - (wx * 2) - menu.RecordOffset

			draw.DrawText( TimerText, "ScoreboardPlayer", o + 1, 9, Color( 0, 0, 0 ), TEXT_ALIGN_RIGHT )
			draw.DrawText( TimerText, "ScoreboardPlayer", o, 8, Color( 255, 255, 255 ), TEXT_ALIGN_RIGHT )

			local nSpecial = ply:GetNWInt( "MapRank", 0 )
			if (nSpecial > 0 and nSpecial < 7) then
				surface.SetMaterial( Material( _C.MaterialID .. "/icon_special" .. nSpecial .. ".png" ) )
				surface.SetDrawColor( Color( 255, 255, 255 ) )
				surface.DrawTexturedRect( o - 110, h / 2 - 16, 32, 32 )
			end

			local rundate = ply:GetNWString( "RunDate", "Unknown" )
			if ply:IsBot() then
				rundate = string.sub( rundate, 1, 10 )
				if nGUI == 3 then
					draw.DrawText( rundate, "ScoreboardPlayer", w - 12, 9, Color( 0, 0, 0 ), TEXT_ALIGN_RIGHT )
					draw.DrawText( rundate, "ScoreboardPlayer", w - 13, 8, color_white, TEXT_ALIGN_RIGHT )
				elseif nGUI == 2 or nGUI == 4 then
					draw.DrawText( rundate, "ScoreboardPlayer", w - 12, 9, Color( 0, 0, 0 ), TEXT_ALIGN_RIGHT )
					draw.DrawText( rundate, "ScoreboardPlayer", w - 13, 8, Color( 255, 255, 255 ), TEXT_ALIGN_RIGHT )
				elseif nGUI == 5 then
					draw.DrawText( rundate, "ScoreboardPlayer", w - 12, 9, Color( 0, 0, 0 ), TEXT_ALIGN_RIGHT )
					draw.DrawText( rundate, "ScoreboardPlayer", w - 13, 8, Color( Custom.r, Custom.g, Custom.b ), TEXT_ALIGN_RIGHT )
				elseif nGUI == 1 then
					draw.DrawText( rundate, "ScoreboardPlayer", w - 12, 9, Color( 0, 0, 0 ), TEXT_ALIGN_RIGHT )
					draw.DrawText( rundate, "ScoreboardPlayer", w - 13, 8, Color( 255, 0, 0 ), TEXT_ALIGN_RIGHT )
				else
					draw.DrawText( rundate, "ScoreboardPlayer", w - 12, 9, Color( 0, 0, 0 ), TEXT_ALIGN_RIGHT )
					draw.DrawText( rundate, "ScoreboardPlayer", w - 13, 8, GUIColor.Header, TEXT_ALIGN_RIGHT )
				end
			else
				if ShowPing == 1 then
					draw.DrawText( ply:Ping(), "ScoreboardPlayer", w - 9, 9, Color( 0, 0, 0 ), TEXT_ALIGN_RIGHT )
					draw.DrawText( ply:Ping(), "ScoreboardPlayer", w - 10, 8, Color( 255, 255, 255 ), TEXT_ALIGN_RIGHT )
				else
					draw.DrawText( StyleText, "ScoreboardPlayer", w - 9, 9, Color( 0, 0, 0 ), TEXT_ALIGN_RIGHT )
					draw.DrawText( StyleText, "ScoreboardPlayer", w - 10, 8, Color( 255, 255, 255 ), TEXT_ALIGN_RIGHT )
				end
			end
		end
	end

	function btn:DoClick()
		GAMEMODE:DoScoreboardActionPopup( ply )
	end

	local stt = "ERROR: NULL"

	if ply:IsBot() then
		stt = "Click on this bot for additional actions"
	else
		stt = "Click on this player for additional actions"
	end

	SMPanels.Tooltip( { parent = btn, text = stt } )

	pList:AddItem( btn )
end

-- temporary, seems nextbots don't return via player.GetBots() anymore?? --
local function GetBots()
	local bots = player.GetAll()
	local tab = {}

	for _,bot in ipairs(bots) do
		if bot:IsBot() then
			table.insert(tab, bot)
		end
	end

	return tab
end

local function ListPlayers( self, pList, mw, botlist )
	local players = {}
	if botlist then
		players = GetBots()
		table.sort( players, function( a, b )
			if not a or not b then return false end
			local ra, rb = a:GetNWInt( "Rank", 1 ), b:GetNWInt( "Rank", 1 )
			if ra == rb then
				return a:GetNWInt( "SpecialRank", 0 ) > b:GetNWInt( "SpecialRank", 0 )
			else
				return ra > rb
			end
		end )
	else
		players = player.GetHumans()
		table.sort( players, function( a, b )
			if a:GetNWInt( "Rank", 1 ) > b:GetNWInt( "Rank", 1 ) then return true end
			if a:GetNWInt( "Rank", 1 ) < b:GetNWInt( "Rank", 1 ) then return false end

			local ra, rb = a:GetNWInt( "Record", 0 ), b:GetNWInt( "Record", 0 )
			ra = ra == 0 and 1e10 or ra
			rb = rb == 0 and 1e10 or rb

			return ra < rb
		end )
	end

	for k,v in pairs( pList:GetCanvas():GetChildren() ) do
		if IsValid( v ) then
			v:Remove()
		end
	end

	for k,ply in pairs( players ) do
		PutPlayerItem( self, pList, ply, mw )
	end

	pList:GetCanvas():InvalidateLayout()
end

local pingTips = {
	[1] = "Click here if you want to switch this group to Style\n\nPing represents a players' connection to the server.\nGenerally a ping of 80 or below is considered excellent for movement gamemodes, anything higher may cause visual delay\n(1 - 80): Excellent\n(81 - 160): Decent\n(161+): Poor",
	[0] = "Click here if you want to switch this group to Ping\n\nStyle represents the kind of movement style a player is currently playing.\nThe default is Normal however there are multiple styles that\ncan drastically change the way you play the game.\nWe have a detailed list of what each style does, you can view it by using !styles\nYou can also spectate a bot to see a general idea on how to play a specific style"
}

local function CreateTeamList( parent, mw )
	local pList

	local pnl = vgui.Create("DPanel", parent)
	pnl:DockPadding(8, 8, 8, 8)

	function pnl:Paint(w, h)
		if nGUI == 1 then
			surface.SetDrawColor( GUIColor.LightGray )
			surface.DrawRect( 2, 2, w - 4, h )
		end
	end

	pnl.RefreshPlayers = function(self)
		ListPlayers(self, pList, mw)
	end

	local headp = vgui.Create("DPanel", pnl)
	headp:DockMargin(0, 0, 0, 4)
	headp:Dock(TOP)
	function headp:Paint() end

	local rank = vgui.Create("DButton", headp)
	rank:SetText("Rank")
	rank:SetFont("HUDTitle")
	rank:SetSize(50, 30)
	rank:Dock(LEFT)
	rank.Paint = function()
		if nGUI == 1 or nGUI == 2 or nGUI == 4 then
			rank:SetTextColor( GUIColor.White )
		elseif nGUI == 3 then
			rank:SetTextColor( color_white )
		elseif nGUI == 5 then
			rank:SetTextColor( Custom )
		else
			rank:SetTextColor( GUIColor.Header )
		end
	end
	SMPanels.Tooltip({parent = rank, text = "Rank represents how many points a player has on the server.\nThe higher the rank, the better the rank title is for the player.\nHigher ranks are also more colorful than the rest.\nYou can view all of the ranks available using !ranks"})

	local player = vgui.Create("DButton", headp)
	player:SetText("Player")
	player:SetFont("HUDTitle")
	player:SetSize(60, 30)
	player:DockMargin(mw + 14, 0, 0, 0)
	player:Dock(LEFT)
	player.Paint = function()
		if nGUI == 1 or nGUI == 2 or nGUI == 4 then
			player:SetTextColor( GUIColor.White )
		elseif nGUI == 3 then
			player:SetTextColor( color_white )
		elseif nGUI == 5 then
			player:SetTextColor( Custom )
		else
			player:SetTextColor( GUIColor.Header )
		end
	end
	SMPanels.Tooltip({parent = player, text = "Player represents the players' name in-game.\nSome players might have custom names and colors. If you wish to see the original names, you can do !vipnames\nYou can donate to the server using !donate if you want to have a custom name/color"})

	local ping = vgui.Create("DButton", headp)
	ping:SetFont "HUDTitle"
	ping:SetText ""
	ping:SetTextColor(color_white)
	ping:SetSize(60, 30)
	ping:DockMargin(0, 0, 0, 0)
	ping:Dock(RIGHT)

	ping.Paint = function()	end
	ping.Think = function(self)
		if (nGUI == 1) or (nGUI == 2) or (nGUI == 4) then
			self:SetTextColor(GUIColor.White)
		elseif (nGUI == 3) then
			self:SetTextColor(color_white)
		elseif (nGUI == 5) then
			self:SetTextColor(Custom)
		else
			self:SetTextColor(GUIColor.Header)
		end

		if (ShowPing == 1) then
			ping:SetText "  Ping"
		else
			ping:SetText "Style"
		end
	end

	ping.DoClick = function(self)
		local tip = self:GetTooltipPanel()
		if (ShowPing == 1) then
			RunConsoleCommand( "sl_showping", 0 )
			self:SetText("Style")

			tip.Text:SetText(pingTips[0])
			tip.Text:SizeToContents()
		else
			RunConsoleCommand( "sl_showping", 1 )
			self:SetText("  Ping")

			tip.Text:SetText(pingTips[1])
			tip.Text:SizeToContents()
		end

		local width, height = tip.Text:GetWide() + 10, tip.Text:GetTall() + 10
		tip:SetSize(width, height)
	end
	SMPanels.Tooltip({parent = ping, text = pingTips[ShowPing]})

	local timer = vgui.Create("DButton", headp)
	timer:SetText("Record")
	timer:SetFont("HUDTitle")
	timer:SetSize(80, 30)
	timer:DockMargin(0, 0, 80 + menu.RecordOffset, 0)
	timer:Dock(RIGHT)
	timer.Paint = function()
		if nGUI == 1 or nGUI == 2 or nGUI == 4 then
			timer:SetTextColor( GUIColor.White )
		elseif nGUI == 3 then
			timer:SetTextColor( color_white )
		elseif nGUI == 5 then
			timer:SetTextColor( Custom )
		else
			timer:SetTextColor( GUIColor.Header )
		end
	end
	SMPanels.Tooltip({parent = timer, text = "Record represents the players' personal best on the current map on their current style.\nSpeedrunning is a crucial part of this gamemode and many players compete for the best times.\nYou can view the map leaderboards by using !maptop"})

	pList = vgui.Create("DScrollPanel", pnl)
	pList:Dock(FILL)

	local sbar = pList:GetVBar()
	function sbar:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 100 ) )
	end
	function sbar.btnUp:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 100 ) )
	end
	function sbar.btnDown:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 100 ) )
	end
	function sbar.btnGrip:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 100 ) )
	end

	local canvas = pList:GetCanvas()
	function canvas:OnChildAdded(child)
		child:Dock(TOP)
		child:DockMargin(0, 0, 0, 4)
	end

	return pnl
end

local function CreateBotList( parent, mw )
	local pnl = vgui.Create("DPanel", parent)
	pnl:DockPadding(8, 8, 8, 8)

	function pnl:Paint(w, h)
		if nGUI == 1 then
			surface.SetDrawColor( GUIColor.LightGray )
			surface.DrawRect(2, 2, w - 4, h - 4)
		end
	end

	pnl.RefreshPlayers = function()
		ListPlayers(self, pList, mw, true)
	end

	local headp = vgui.Create("DPanel", pnl)
	headp:DockMargin(0, 0, 0, 0)
	headp:Dock(TOP)
	function headp:Paint() end

	local type = vgui.Create("DButton", headp)
	type:SetText("Style")
	type:SetFont("HUDTitle")
	type:SetSize(60, 30)
	type:Dock(LEFT)
	type.Paint = function()
		if nGUI == 1 or nGUI == 2 or nGUI == 4 then
			type:SetTextColor( GUIColor.White )
		elseif nGUI == 3 then
			type:SetTextColor( color_white )
		elseif nGUI == 5 then
			type:SetTextColor( Custom )
		else
			type:SetTextColor(GUIColor.Header)
		end
	end
	SMPanels.Tooltip({parent = type, text = "Style represents the style the bot is currently playing. You can view style info using !styles"})

	local player = vgui.Create("DButton", headp)
	player:SetText("Player")
	player:SetFont("HUDTitle")
	player:SetSize(60, 30)
	player:DockMargin(mw, 0, 0, 0)
	player:Dock(LEFT)
	player.Paint = function()
		if nGUI == 1 or nGUI == 2 or nGUI == 4 then
			player:SetTextColor( GUIColor.White )
		elseif nGUI == 3 then
			player:SetTextColor( color_white )
		elseif nGUI == 5 then
			player:SetTextColor( Custom )
		else
			player:SetTextColor(GUIColor.Header)
		end
	end
	SMPanels.Tooltip({parent = player, text = "Player represents the name of the player who obtained the run.\nYou can have your run displayed here if you beat the map record, or if you are faster than the bot.\nFor map leaderboards use !maptop"})

	local date = vgui.Create("DButton", headp)
	date:SetText("Date")
	date:SetFont("HUDTitle")
	date:SetSize(60, 30)
	date:DockMargin(0, 0, 0, 0)
	date:Dock(RIGHT)
	date.Paint = function()
		if nGUI == 1 or nGUI == 2 or nGUI == 4 then
			date:SetTextColor( GUIColor.White )
		elseif nGUI == 3 then
			date:SetTextColor( color_white )
		elseif nGUI == 5 then
			date:SetTextColor( Custom )
		else
			date:SetTextColor(GUIColor.Header)
		end
	end
	SMPanels.Tooltip({parent = date, text = "Date represents the date a run was obtained at"})

	local timer = vgui.Create("DButton", headp)
	timer:SetText("Record")
	timer:SetFont("HUDTitle")
	timer:SetSize(80, 30)
	timer:DockMargin(0, 0, 80 + menu.RecordOffset, 0)
	timer:Dock(RIGHT)
	timer.Paint = function()
		if nGUI == 1 or nGUI == 2 or nGUI == 4 then
			timer:SetTextColor( GUIColor.White )
		elseif nGUI == 3 then
			timer:SetTextColor( color_white )
		elseif nGUI == 5 then
			timer:SetTextColor( Custom )
		else
			timer:SetTextColor(GUIColor.Header)
		end
	end
	SMPanels.Tooltip({parent = timer, text = "Record represents the time achieved on the bot replay"})

	pList = vgui.Create("DScrollPanel", pnl)
	pList:Dock(FILL)

	local sbar = pList:GetVBar()
	function sbar:Paint( w, h ) end
	function sbar.btnUp:Paint( w, h )
		draw.RoundedBoxEx( 8, 0, 0, w, h, Color(0, 0, 0, 140), true, true, false, false )
	end
	function sbar.btnDown:Paint( w, h )
		draw.RoundedBoxEx( 8, 0, 0, w, h, Color(0, 0, 0, 140), false, false, true, true )
	end
	function sbar.btnGrip:Paint( w, h )
		draw.RoundedBox( 0, 0, 0, w, h, Color( 0, 0, 0, 70 ) )
	end

	local canvas = pList:GetCanvas()
	function canvas:OnChildAdded(child)
		child:Dock(TOP)
		child:DockMargin(0, 0, 0, 0)
	end

	return pnl
end

function GM:ScoreboardShow()
	if IsValid( menu ) then
		menu.BlurTime = syt()
		menu:SetVisible(true)

		if menu.Players then
			menu.Players:RefreshPlayers()
		end
		if menu.Bots then
			menu.Bots:RefreshPlayers()
		end
	else
		menu = vgui.Create("DFrame")
		menu:SetSize(ScrW() * 0.5, ScrH() * 0.8)
		menu.BlurTime = syt()
		menu:Center()
		menu:MakePopup()
		menu:SetKeyboardInputEnabled(false)
		menu:SetDeleteOnClose(false)
		menu:SetDraggable(false)
		menu:ShowCloseButton(false)
		menu:SetTitle("")
		menu:DockPadding(4, 4, 4, 4)
		menu.RecordOffset = ((ScrW() - 1280) / 64) * 8

		function menu:PerformLayout()
			menu.Players:SetWidth(self:GetWide())
		end

		function menu:Paint()
			if Blur:GetBool() then
				Derma_DrawBackgroundBlur( self, self.BlurTime )
			end
			if nGUI == 0 or nGUI == 2 then
				draw.RoundedBox( 8, 0, 0, menu:GetWide(), menu:GetTall(), Color( 0, 0, 0, 110 ) )
			elseif nGUI == 3 then
				draw.RoundedBox( 6, 0, 0, menu:GetWide(), menu:GetTall(), Interface.BackgroundColor )

				local frameHeight = draw.GetFontHeight( "MersRadial" )
				draw.RoundedBox( 6, 0, 0, menu:GetWide(), frameHeight, Interface.ForegroundColor )
			elseif nGUI == 4 then
				draw.RoundedBox( 8, 0, 0, menu:GetWide(), menu:GetTall(), Color( 42, 42, 42, 110 ) )
			elseif nGUI == 5 then
				if Accent == 1 then
					draw.RoundedBox( 8, 0, 0, menu:GetWide(), menu:GetTall(), Color( Custom.r, Custom.g, Custom.b, 30 ) )
				else
					draw.RoundedBox( 8, 0, 0, menu:GetWide(), menu:GetTall(), Color( 0, 0, 0, 110 ) )
				end
			elseif nGUI > 5 then

			else
				surface.SetDrawColor(GUIColor.DarkGray)
				surface.DrawRect(0, 0, menu:GetWide(), menu:GetTall())
			end
		end

		menu.Credits = vgui.Create("DPanel", menu)
		menu.Credits:Dock(TOP)
		menu.Credits:DockPadding(8, 6, 8, 0)

		function menu.Credits:Paint() end

		local name = Label( GAMEMODE.DisplayName, menu.Credits )
		name:Dock(LEFT)
		name:SetFont("MersRadial")
		name:SetTextColor(color_white)

		function name:PerformLayout()
			surface.SetFont(self:GetFont())
			local w, h = surface.GetTextSize(self:GetText())
			self:SetSize(w, h)
		end

		local cred = vgui.Create( "DButton", menu.Credits )
		cred:Dock(RIGHT)
		cred:SetFont("HUDLabelSmall")
		cred:DockMargin( 0, -5, 0, 0 )
		cred:SetText("By Gravious\nModified by Niflheimrx\nVersion " .. string.format( "%.2f", _C.Version ) )
		cred.PerformLayout = name.PerformLayout
		cred:SetDrawBackground( false )
		cred:SetDrawBorder( false )
		cred.DoClick = function()
			gui.OpenURL( "https://steamcommunity.com/profiles/76561198089794192" )
		end
		cred.Paint = function()
			cred:SetTextColor(GUIColor.White)
		end

		SMPanels.Tooltip( { parent = cred, text = "These are the people who have developed this gamemode\nIf you have any problems with the gamemode click here and it will take you to their steam community profile.\n(Note: If you have any issues you should use !report instead)" } )

		function menu.Credits:PerformLayout()
			surface.SetFont(name:GetFont())
			local w,h = surface.GetTextSize(name:GetText())
			self:SetTall(h)
		end

		surface.SetFont("ScoreboardPlayer")
		local mw, mh = surface.GetTextSize( "Retrieving..." )
		local tall,num = menu:GetTall(),38

		menu.Players = CreateTeamList(menu, mw)
		menu.Players:Dock(FILL)
		menu.Players:RefreshPlayers()

		menu.Bots = CreateBotList( menu, mw )
		menu.Bots:Dock(BOTTOM)
		menu.Bots:SetSize( menu:GetWide(), 120 )
		menu.Bots:DockMargin( 0, 10, 0, 5)
		menu.Bots:RefreshPlayers()

		local SurfTimerButton = vgui.Create( "DButton", menu )
		SurfTimerButton:SetText( "" )
		SurfTimerButton:SetPos( menu:GetWide() - 100, menu:GetTall() - 25 )
		SurfTimerButton:SetSize( 85, 20 )
		SurfTimerButton:SetImage( "icon16/cog.png" )
		SurfTimerButton.DoClick = function()
			SurfTimer:Open()
			menu:Close()
		end
		SurfTimerButton.Paint = function()
			draw.DrawText( "Settings", "HUDSpeed", 25, 1, GUIColor.White, TEXT_ALIGN_LEFT )
		end
	end
end

local actions
function GM:DoScoreboardActionPopup( ply )
	if not IsValid( ply ) then return end
	actions, open = DermaMenu(), true

	if ply != LocalPlayer() then
		if not ply:IsBot() then
			if ply:IsAdmin() then
				local admin = actions:AddOption("Player is an admin")
				admin:SetIcon("icon16/shield.png")
				actions:AddSpacer()
			end

			local mute = actions:AddOption(ply:IsMuted() and "Unmute" or "Mute")
			mute:SetIcon("icon16/sound_mute.png")
			function mute:DoClick()
				if IsValid(ply) then
					ply:SetMuted(!ply:IsMuted())
				end
			end

			local chatmute = actions:AddOption(ply.ChatMuted and "Chat unmute" or "Chat mute")
			chatmute:SetIcon("icon16/keyboard_delete.png")
			function chatmute:DoClick()
				if IsValid(ply) then
					ply.ChatMuted = not ply.ChatMuted
					Link:Print( "General", ply:Name() .. " has been " .. (ply.ChatMuted and "chat muted" or "chat unmuted") )
				end
			end

			local profile = actions:AddOption("View Profile")
			profile:SetIcon("icon16/vcard.png")
			function profile:DoClick()
				if IsValid(ply) then
					ply:ShowProfile()
				end
			end

			local serverProfile = actions:AddOption("View Server Profile")
			serverProfile:SetIcon("icon16/vcard.png")
			function serverProfile:DoClick()
				if IsValid(ply) then
					RunConsoleCommand( "say", "!profile " .. ply:SteamID() )
				end
			end
		else
			local bot = actions:AddOption("Server Bot")
			bot:SetIcon("icon16/control_end.png")
			actions:AddSpacer()

			local szURI = ply:GetNWString( "ProfileURI", "None" )
			if szURI != "None" then
				local uri = actions:AddOption("View Runner Profile")
				uri:SetIcon("icon16/vcard.png")
				function uri:DoClick()
					gui.OpenURL( "http://steamcommunity.com/profiles/" .. szURI )
				end
			end
		end

		local spec = actions:AddOption("Spectate Player")
		spec:SetIcon("icon16/eye.png")
		function spec:DoClick()
			if IsValid(ply) then
				RunConsoleCommand( "sm_spectate", ply:SteamID(), ply:Name() )
			end
		end

		if IsValid( LocalPlayer() ) and LocalPlayer().Style and LocalPlayer().Style == _C.Style.Practice then
			local tpto = actions:AddOption("Teleport to player")
			tpto:SetIcon("icon16/lightning_go.png")
			function tpto:DoClick()
				if IsValid(ply) then
					RunConsoleCommand( "say", "!tp " .. ply:Name() )
				end
			end
		end
	else
		open = false
	end

	if open and IsValid( LocalPlayer() ) and LocalPlayer():IsAdmin() then
		actions:AddSpacer()

		local Option1 = actions:AddOption("Copy name")
		Option1:SetIcon("icon16/page_copy.png")
		function Option1:DoClick()
			SetClipboardText( ply:Name() )
		end

		local Option3 = actions:AddOption("Copy SteamID")
		Option3:SetIcon("icon16/page_copy.png")
		function Option3:DoClick()
			SetClipboardText( ply:SteamID() )
		end

		actions:AddSpacer()

		local Option4 = actions:AddOption("Move to spectator")
		Option4:SetIcon("icon16/eye.png")
		function Option4:DoClick()
			_AA( "spectator", ply:SteamID() )
		end

		local Option4a = actions:AddOption("Strip weapons")
		Option4a:SetIcon("icon16/delete.png")
		function Option4a:DoClick()
			_AA( "strip", ply:SteamID() )
		end

		local Option4b = actions:AddOption("Monitor sync")
		Option4b:SetIcon("icon16/eye.png")
		function Option4b:DoClick()
			_AA( "monitor", ply:SteamID() )
		end

		local Option5 = actions:AddOption((ply.ChatMuted and "Unm" or "M") .. "ute player")
		Option5:SetIcon("icon16/keyboard_" .. (not ply.ChatMuted and "delete" or "add") .. ".png")
		function Option5:DoClick()
			_AA( "mute", ply:SteamID() )
		end

		local Option6 = actions:AddOption((ply:IsMuted() and "Ung" or "G") .. "ag player")
		Option6:SetIcon("icon16/sound" .. (not ply:IsMuted() and "_mute" or "") .. ".png")
		function Option6:DoClick()
			_AA( "gag", ply:SteamID() )
		end

		local Option7 = actions:AddOption("Kick player")
		Option7:SetIcon("icon16/door_out.png")
		function Option7:DoClick()
			_AA( "kick", ply:SteamID() )
		end

		local Option8 = actions:AddOption("Ban player")
		Option8:SetIcon("icon16/report_user.png")
		function Option8:DoClick()
			_AA( "ban", ply:SteamID() )
		end
	end

	if open then
		actions:Open()
	end
end

function GM:ScoreboardHide() if IsValid( menu ) then menu:Close() if actions then actions:Remove() end end end
function GM:HUDDrawScoreBoard() end
