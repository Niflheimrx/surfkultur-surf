Client = {}

include( "core.lua" )
include( "core_lang.lua" )
include( "cl_timer.lua" )
include( "cl_receive.lua" )
include( "cl_gui.lua" )
include( "cl_score.lua" )
include( "modules/cl_admin.lua" )

-- SMGRAPI --
include( "cl_smgrapi.lua" )

-- STELLAR MOD --
include( "modules/stellarSurf/sh_init.lua" )

LuaBSP = include "modules/cl_luabsp.lua"

include( "sh_paint.lua" )

--Console Variables--
local CPlayers = CreateClientConVar( "sl_showothers", "1", true, false, "Toggles the visibility of other players on the server. This also includes bots." )
local CHelp = CreateClientConVar( "sl_help", "1", true, false, "Shows the help menu when you join, only active one time unless used with !help" )
local CCrosshair = CreateClientConVar( "sl_crosshair", "1", true, false, "Toggles the crosshair in the middle of the screen." )
local CTargetID = CreateClientConVar( "sl_targetids", "0", true, false, "Toggles the visibility of player names when looking at them. Change this especially if you are recording a demo." )
local CThirdPerson = CreateClientConVar( "sl_thirdperson", "0", true, false, "Toggles the Thirdperson mode. This also toggles the rendering of your playermodel in Thirdperson." )
local LegacyRenderer = CreateClientConVar( "sl_legacyrenderer", "0", true, true, "Enables the legacy renderer. By default this is disabled due to major view fixes." )
local EmoteOnly = CreateClientConVar( "sl_hiderank", "0", true, true, "Toggles the visiblity of chat ranks in chat. By default this is disabled." )

Theme = CreateClientConVar("sl_theme", 3, true, false, "Toggles the theme in the server. Use this to change your look of the timer." )
ShowZones = CreateClientConVar( "sl_showzones", "1", true, false, "Toggles the visibility of the server zones. Change this if you want to see the lazer zones." )
ShowAltZones = CreateClientConVar( "sl_showaltzones", "0", true, false, "Toggles the visibility of the alternate server zones. This includes zones outside of the Normal and Bonus zones." )
Prestrafe = CreateClientConVar( "sl_prestrafe", "1", true, false, "Toggles the prestrafe view in your timer." )
Comparison = CreateClientConVar( "sl_comparison_type", "1", true, true, "Toggles the prestrafe view in your timer." )
Velocity = CreateClientConVar( "sl_velocitytype", "1", true, false, "Toggles the velocity type in your timer. 0 represents XY while 1 represents XYZ." )
VelocityBar = CreateClientConVar( "sl_velocitybar", "1", true, false, "Toggles the velocity bar in your timer. 0 disables the color inside the velocity status." )
Blur = CreateClientConVar( "sl_blur", "1", true, false, "Toggles the visibility of blur menus. Use 0 for better performance." )
Decimals = CreateClientConVar( "sl_enumerator", "2", true, false, "Changes the amount of numbers after the decimal in your timer. 2 is the default enumerator." )
PrintPref = CreateClientConVar( "sl_printchat", "1", true, false, "Decides whether or not to print messages to your chatbox. Use 0 if you want your messages to be printed in the console." )
TotalTime = CreateClientConVar( "sl_totaltime", "1", true, true, "Toggles the total time display.")
Footsteps = CreateClientConVar( "sl_footsteps", "1", true, true, "Toggles the footstep sounds for every player in the server." )
ChatTick = CreateClientConVar( "sl_chattick", "default", true, true, "Changes the sound type of the chat ticker. Use \"Default\" as the default ticker." )
MenuClicker = CreateClientConVar( "sl_clicker", "1", true, false, "When pressing a number inside a menu, a sound will play." )
ShowPing = CreateClientConVar( "sl_showping", "0", true, true, "Toggles between the Ping and Style labels and info when clicked on either label button." )
GUILess = CreateClientConVar( "sl_guiless", "0", true, false, "If supported, allows some GUI elements to open a window with easy to browse information similar to the profile menu." )
ForceBloom = CreateClientConVar( "sl_forcebloom", "0", true, false, "If supported, forces the bloom rendering." )
ForceMotion = CreateClientConVar( "sl_forcemotion", "0", true, false, "If supported, forces the rendering of motion blurs." )
ForceFocus = CreateClientConVar( "sl_forcefocus", "0", true, false, "If supported, forces the focus to loosen on the bottom and top of your display." )
GlobalCheckpoints = CreateClientConVar( "sl_globalcheckpoints", "0", true, true, "Enables the usage of creating/loading global checkpoints." )
SpeedStats = CreateClientConVar( "sl_speedstats", "0", true, true, "Displays your Velocity stats when finishing a zone." )
ShowSpecialRanks = CreateClientConVar( "sl_special_ranks", "1", true, true, "Shows players' special ranks whenever possible" )

CustomChat = CreateClientConVar( "sl_customchat", "0", true, false, "Enables the future look of the chatbox." ):GetBool()
CustomSurfTimer = CreateClientConVar( "sl_customsurftimer", "0", true, false, "Allows custom color scheming for SMPanel-based UIs." )
CustomChatColors = CreateClientConVar( "sl_chattheme", "0", true, false, "Changes the color palette for colored chat messages printed from [Surf Timer]." )

SmoothNoclipping = CreateClientConVar( "sl_smoothnoclip", "0", true, true, "Enables the smooth noclip movement." )
UltrawideCenter = CreateClientConVar( "sl_ultracenter", "0", true, false, "Allows aspect ratios higher than 16:9 to render HUD elements in the center rather than the edges" )

--We will refresh these console variables so we can globally call them on the clientside and continue updating the current value--
local function GrabConVars()
	nGUI = GetConVar( "sl_theme" ):GetInt()
	CR = GetConVar( "sl_custom_r" ):GetInt()
	CG = GetConVar( "sl_custom_g" ):GetInt()
	CB = GetConVar( "sl_custom_b" ):GetInt()
	Accent = GetConVar( "sl_custom_accent" ):GetInt()
	Rainbow = GetConVar( "sl_custom_rainbow" ):GetInt()
	ShowPing = GetConVar( "sl_showping" ):GetInt()
	CPrestige = GetConVar( "sl_custom_prestige" ):GetInt()
	Clicker = GetConVar( "sl_clicker" ):GetInt()
	Custom = Color( CR, CG, CB )

	local CustomSMT = CustomSurfTimer:GetBool()
	local ChatTheme = CustomChatColors:GetInt()
	if Interface and CustomSMT then
		Interface.HighlightColor = Custom
		Interface.ForegroundColor = Color( Custom.r / 3, Custom.g / 3, Custom.b / 3 )
		Interface.BackgroundColor = Color( Custom.r / 4, Custom.g / 4, Custom.b / 4 )
	else
		Interface.BackgroundColor = Color( 20, 20, 20 )
		Interface.ForegroundColor = Color( 40, 40, 40 )
		Interface.HighlightColor = Color( 255, 0, 0 )
	end

	if (ChatTheme == 0) then
		CL.Yellow = Color(228, 244, 111)
		CL.Blue = Color(142, 235, 250)
		CL.Green = Color(0, 255, 155)
	elseif (ChatTheme == 1) then
		CL.Yellow = Color(255, 0, 115)
		CL.Blue = Color(189, 0, 255)
		CL.Green = Color(222, 133, 249)
	elseif (ChatTheme == 2) then
		CL.Yellow = Color(142, 235, 250)
		CL.Blue = Color(36, 130, 255)
		CL.Green = Color(0, 208, 255)
	elseif (ChatTheme == 3) then
		CL.Yellow = Color(255, 89, 89)
		CL.Blue = Color(255, 0, 0)
		CL.Green = Color(255, 100, 43)
	else
		CL = {
			Yellow = Color(228, 244, 111),
			White = Color(255, 255, 255),
			Blue = Color(142, 235, 250),
			Purple = Color(229, 162, 241),
			Green = Color(0, 255, 155),
			Orange = Color(241, 191, 79),
		}
	end
end
hook.Add( "Think", "GetConVars", GrabConVars )

function Client:WeaponName()
	timer.Simple( 0.1, function()
		local uwep =  LocalPlayer():GetActiveWeapon( ):GetPrintName()
		Link:Print( "General", "You have obtained a " .. uwep .. "." )
	end )
end

function Client:ToggleCrosshair( tabData )
	Link:Print( "General", "This functionality has been locked down" )
end

function Client:ToggleTargetIDs()
	local nNew = 1 - CTargetID:GetInt()
	RunConsoleCommand( "sl_targetids", nNew )
	Link:Print( "General", "You have " .. (nNew == 0 and "disabled" or "enabled") .. " player labels" )
end

function Client:ZoneVisibility()
	local nNew = 1 - ShowZones:GetInt()
	RunConsoleCommand( "sl_showzones", nNew )
	Link:Print( "General", "You have " .. (nNew == 0 and "disabled" or "enabled") .. " the zone visibility." )
end

function Client:ZoneAltVisibility()
	local nNew = 1 - ShowAltZones:GetInt()
	RunConsoleCommand( "sl_showaltzones", nNew )
	Link:Print( "General", "You have " .. (nNew == 0 and "disabled" or "enabled") .. " the alternate zone visibility." )
end

function Client:TogglePrestrafe()
	local nNew = 1 - Prestrafe:GetInt()
	RunConsoleCommand( "sl_prestrafe", nNew )
	Link:Print( "General", "You have " .. (nNew == 0 and "disabled" or "enabled") .. " the prestrafe in your timer." )
end

function Client:ToggleMessages()
	local nNew = 1 - PrintPref:GetInt()
	RunConsoleCommand( "sl_printchat", nNew )
	Link:Print( "General", "You have " .. (nNew == 0 and "disabled" or "enabled") .. " the server messages." )
end

function Client:ToggleVelocity()
	local nNew = 1 - Velocity:GetInt()
	RunConsoleCommand( "sl_velocitytype", nNew )
	Link:Print( "General", "You have changed your velocity type to " .. (nNew == 0 and "XYZ" or "XY") )
end

function Client:ToggleTotalTime()
	local nNew = 1 - TotalTime:GetInt()
	RunConsoleCommand( "sl_totaltime", nNew )
	Link:Print( "General", "You have " .. (nNew == 0 and "disabled" or "enabled") .. " the total timer." )
end

function Client:ToggleGlobalCheckpoints()
	local nNew = 1 - GlobalCheckpoints:GetInt()
	RunConsoleCommand( "sl_globalcheckpoints", nNew )
	Link:Print( "General", "You have " .. (nNew == 0 and "disabled" or "enabled") .. " global checkpoints." )
end

function Client:SurflineSound()
	local nSound = GetConVar( "sl_sound" ):GetInt()
	if nSound > 0 then
		Link:Print( "General", "You have disabled the sounds." )
		RunConsoleCommand( "sl_sound", 0 )
	else
		Link:Print( "General", "You have enabled the sounds." )
		RunConsoleCommand( "sl_sound", 1 )
	end
end

function Client:ToggleTheme()
	local nNew = GetConVar( "sl_theme" ):GetInt()
	if nNew == 0 then
		Link:Print( "General", "You have changed the theme to Flow." )
		RunConsoleCommand( "sl_theme", 1 )
	elseif nNew == 1 then
		Link:Print( "General", "You have changed the theme to Minimal." )
		RunConsoleCommand( "sl_theme", 2 )
	elseif nNew == 2 then
		Link:Print( "General", "You have changed the theme to the Holiday." )
		RunConsoleCommand( "sl_theme", 3 )
	elseif nNew == 3 then
		Link:Print( "General", "You have changed the theme to Prestige." )
		RunConsoleCommand( "sl_theme", 4 )
	elseif nNew == 4 then
		Link:Print( "General", "You have changed the theme to Modern." )
		RunConsoleCommand( "sl_theme", 0 )
	end
end

function Client:DecimalEnumerate()
	local nNew = GetConVar( "sl_enumerator" ):GetInt()
	if nNew == 4 then
		Link:Print( "General", "Three numbers after the decimal will be displayed in your timer." )
		RunConsoleCommand( "sl_enumerator", 3 )
	elseif nNew == 3 then
		Link:Print( "General", "Two numbers after the decimal will be displayed in your timer." )
		RunConsoleCommand( "sl_enumerator", 2 )
	elseif nNew == 2 then
		Link:Print( "General", "One number after the decimal will be displayed in your timer." )
		RunConsoleCommand( "sl_enumerator", 1 )
	elseif nNew == 1 then
		Link:Print( "General", "No numbers after the decimal will be displayed in your timer." )
		RunConsoleCommand( "sl_enumerator", 0 )
	elseif nNew == 0 then
		Link:Print( "General", "Four numbers after the decimal will be displayed in your timer." )
		RunConsoleCommand( "sl_enumerator", 4 )
	end
end

function Client:ThemePick( nOption )
	local theme = ""
	if nOption == 0 then theme = "Modern" elseif nOption == 1 then theme = "Flow" elseif nOption == 2 then theme = "Minimal" elseif nOption == 3 then theme = "the Holiday" elseif nOption == 4 then theme = "prestige" end
	Link:Print( "General", "You have changed the theme to " .. theme .. "." )
	RunConsoleCommand( "sl_theme", nOption )
end

function Client:PlayerVisibility( nTarget )
	local nNew = -1
	if CPlayers:GetInt() == nTarget then
		RunConsoleCommand( "sl_showothers", 1 - nTarget )
		timer.Simple( 1, function() RunConsoleCommand( "sl_showothers", nTarget ) end )
		nNew = nTarget
	elseif nTarget < 0 then
		nNew = 1 - CPlayers:GetInt()
		RunConsoleCommand( "sl_showothers", nNew )
	else
		nNew = nTarget
		RunConsoleCommand( "sl_showothers", nNew )
	end

	if nNew >= 0 then
		Link:Print( "General", "You have set player visibility to " .. (nNew == 0 and "invisible" or "visible") )
	end
end

function Client:ShowHelp( tab )
	print( "\n\nBelow is a list of all available commands and their aliases:\n\n" )

	table.sort( tab, function( a, b )
		if not a or not b or not a[ 2 ] or not a[ 2 ][ 1 ] then return false end
		return a[ 2 ][ 1 ] < b[ 2 ][ 1 ]
	end )

	for _,data in pairs( tab ) do
		local desc, alias = data[ 1 ], data[ 2 ]
		local main = table.remove( alias, 1 )

		MsgC( Color( 212, 215, 134 ), "\tCommand: " ) MsgC( Color( 255, 255, 255 ), main .. "\n" )
		MsgC( Color( 212, 215, 134 ), "\t\tAliases: " ) MsgC( Color( 255, 255, 255 ), (#alias > 0 and string.Implode( ", ", alias ) or "None") .. "\n" )
		MsgC( Color( 212, 215, 134 ), "\t\tDescription: " ) MsgC( Color( 255, 255, 255 ), desc .. "\n\n" )
	end

	Link:Print( "General", "A list of commands and their descriptions has been printed in your console! Press ~ to open." )
end

function Client:ShowEmote( data )
	local ply
	for _,p in pairs( player.GetHumans() ) do
		if tostring( p:SteamID() ) == data[ 1 ] then
			ply = p
			break
		end
	end
	if not IsValid( ply ) then return end

	if ply:GetNWInt( "AccessIcon", 0 ) > 0 then
		local tab = {}
		local VIPNameColor = ply:GetNWVector( "VIPNameColor", Vector( -1, 0, 0 ) )
		if VIPNameColor.x >= 0 then
			local VIPName = ply:Name()

			if VIPNameColor.x == 256 then
				tab = Client:GenerateName( tab, VIPName .. " " )
			elseif VIPNameColor.x == 257 then
				tab = Client:GenerateName( tab, VIPName .. " ", ply )
			else
				table.insert( tab, Core.Util:VectorToColor( VIPNameColor ) )
				table.insert( tab, VIPName .. " " )
			end

			if Client.VIPReveal and VIPName != ply:Name() then
				table.insert( tab, GUIColor.White )
				table.insert( tab, "(" .. ply:Name() .. ") " )
			end
		else
			table.insert( tab, Color( 98, 176, 255 ) )
			table.insert( tab, ply:Name() .. " " )
		end

		table.insert( tab, GUIColor.White )
		table.insert( tab, tostring( data[ 2 ] ) )

		chat.AddText( unpack( tab ) )
	end
end

function Client:VerifyList()
	if file.Exists( Cache.M_Name, "DATA" ) then
		Cache:M_Load()
	end
end

function Client:Mute( bMute )
	for _,p in pairs( player.GetHumans() ) do
		if LocalPlayer() and p != LocalPlayer() then
			if bMute and not p:IsMuted() then
				p:SetMuted( true )
			elseif not bMute and p:IsMuted() then
				p:SetMuted( false )
			end
		end
	end

	Link:Print( "General", "All players have been " .. (bMute and "muted" or "unmuted") .. "." )
end

function Client:DoChatMute( szID, bMute )
	for _,p in pairs( player.GetHumans() ) do
		if tostring( p:SteamID() ) == szID then
			p.ChatMuted = bMute
			Link:Print( "General", p:Name() .. " has been " .. (bMute and "chat muted" or "unmuted") .. "!" )
		end
	end
end

function Client:DoVoiceGag( szID, bGag )
	for _,p in pairs( player.GetHumans() ) do
		if tostring( p:SteamID() ) == szID then
			p:SetMuted( bGag )
			Link:Print( "General", p:Name() .. " has been " .. (bGag and "voice gagged" or "ungagged") .. "!" )
		end
	end
end

function Client:GenerateName( tab, szName, gradient )
	szName = szName:gsub('[^%w ]', '')
	local count = #szName
	local start, stop = Core.Util:RandomColor(), Core.Util:RandomColor()
	if gradient then
		local gs = gradient:GetNWVector( "VIPGradientS", Vector( -1, 0, 0 ) )
		local ge = gradient:GetNWVector( "VIPGradientE", Vector( -1, 0, 0 ) )

		if gs.x >= 0 then start = Core.Util:VectorToColor( gs ) end
		if ge.x >= 0 then stop = Core.Util:VectorToColor( ge ) end
	end

	for i = 1, count do
		local percent = i / count
		table.insert( tab, Color( start.r + percent * (stop.r - start.r), start.g + percent * (stop.g - start.g), start.b + percent * (stop.b - start.b) ) )
		table.insert( tab, szName[ i ] )
	end

	return tab
end

function Client:ToggleChat()
	local nTime = GetConVar( "hud_saytext_time" ):GetInt()
	if nTime > 0 then
		Link:Print( "General", "The chat has been hidden." )
		RunConsoleCommand( "hud_saytext_time", 0 )
	else
		Link:Print( "General", "The chat has been restored." )
		RunConsoleCommand( "hud_saytext_time", 12 )
	end
end

function Client:SpecVisibility( arg )
	local nNew = nil
	if not arg then
		nNew = 1 - Timer:GetSpecSetting()
	else
		nNew = tonumber( arg ) or 1
	end

	if nNew then
		RunConsoleCommand( "sl_showspec", nNew )
		Link:Print( "General", "You have set spectator list visibility to " .. (nNew == 0 and "invisible" or "visible") )
	end
end

function Client:BlurVisibility()
	local a = GetConVar( "sl_blur" ):GetInt()
	local c = 1 - a

	RunConsoleCommand( "sl_blur", c )
	Link:Print( "General", "Scoreboard blur has been " .. (c == 0 and "disabled" or "re-enabled") .. "!" )
end

function Client:ChangeWater()
	local a = GetConVar( "r_waterdrawrefraction" ):GetInt()
	local b = GetConVar( "r_waterdrawreflection" ):GetInt()
	local c = 1 - a

	RunConsoleCommand( "r_waterdrawrefraction", c )
	RunConsoleCommand( "r_waterdrawreflection", c )
	Link:Print( "General", "Water reflection and refraction have been " .. (c == 0 and "disabled" or "re-enabled") .. "!" )
end

function Client:ClearDecals()
	RunConsoleCommand( "r_cleardecals" )
	Link:Print( "General", "All players decals have been cleared from your screen." )
end

function Client:Set3DSky()
	local a = GetConVar( "r_3dsky" ):GetInt()
	local b = GetConVar( "r_3dsky" ):GetInt()
	local c = 1 - a

	RunConsoleCommand( "r_3dsky", c )
	RunConsoleCommand( "r_3dsky", c )
	Link:Print( "General", "The 3D Skybox has been " .. (c == 0 and "disabled" or "enabled") .. "!" )
end

function Client:ToggleReveal()
	Client.VIPReveal = not Client.VIPReveal
	Link:Print( "General", "True VIP names will now " .. (Client.VIPReveal and "" or "no longer ") .. "be shown" )
end

function Client:DoFlipWeapons()
	local n = 0
	for _,wep in pairs( LocalPlayer():GetWeapons() ) do
		if wep.ViewModelFlip != Client.FlipStyle then
			wep.ViewModelFlip = Client.FlipStyle
		end

		n = n + 1
	end
	return n
end

function Client:FlipWeapons( bRestart )
	if IsValid( LocalPlayer() ) then
		if not bRestart then
			Client.Flip = not Client.Flip
			Client.FlipStyle = not Client.Flip

			local n = Client:DoFlipWeapons()
			if n > 0 then
				Link:Print( "General", "Your weapons have been flipped!" )
			else
				Link:Print( "General", "You had no weapons to flip." )
			end
		elseif Client.Flip then
			timer.Simple( 0.1, function()
				Client:DoFlipWeapons()
			end )
		end
	end
end

function Client:ToggleSpace( bStart )
	if bStart then
		Client.SpaceToggle = not Client.SpaceToggle
	else
		if not IsValid( LocalPlayer() ) then return end
		if not Client.SpaceEnabled then
			Client.SpaceEnabled = true
			LocalPlayer():ConCommand( "+jump" )
		else
			LocalPlayer():ConCommand( "-jump" )
			Client.SpaceEnabled = nil
		end
	end
end

function Client:ToggleThirdperson()
	local nNew = 1 - CThirdPerson:GetInt()
	RunConsoleCommand( "sl_thirdperson", nNew )
end

function GM:RenderScreenspaceEffects()
	if ForceBloom:GetInt() == 1 then
		RunConsoleCommand( "pp_bloom", 1 )
		DrawBloom( 0.65, 3, 9, 9, 1, 1, 1, 1, 1 )
	else
		RunConsoleCommand( "pp_bloom", 0 )
	end

	if ForceMotion:GetInt() == 1 then
		DrawMotionBlur( 0.4, 0.4, 0.01 )
	end

	if ForceFocus:GetInt() == 1 then
		DrawToyTown( 2, ScrH() / 2 )
	end
end

function GM:CalcView( ply, pos, angles, fov )
	if CThirdPerson:GetBool() then
		if ply.Style == 2 or ply.Style == 3 then
			RunConsoleCommand( "sl_thirdperson", 0 )
			return Link:Print( "General", "You cannot toggle thirdperson when using " .. Core:StyleName( ply.Style ) .. "." )
		elseif ply:GetNWInt( "Spectating", 0 ) == 1 then
			RunConsoleCommand( "sl_thirdperson", 0 )
			return Link:Print( "General", "You cannot toggle thirdperson when spectating." )
		end
		pos = pos - (angles:Forward() * 100) + (angles:Up() * 40)
		local ang = (ply:GetPos() + (angles:Up() * 30 )) - pos
		ang:Normalize()
		angles = ang:Angle()
	end

		return self.BaseClass:CalcView( ply, pos, angles, fov )
end

function GM:HUDDrawTargetID()
	local isSpec = (LocalPlayer():Team() == TEAM_SPECTATOR)
	if isSpec then return end

	local isVisible = CPlayers:GetBool()
	if !isVisible then return end

	local wantsTargetID = CTargetID:GetBool()
	if !wantsTargetID then return end

	local tr = util.GetPlayerTrace( LocalPlayer() )
	local trace = util.TraceLine( tr )
	if !trace.Hit or !trace.HitNonWorld then return end

	local text = "Unknown User (Normal)"
	local best = "Best: 00:00.00"

	local font = "TargetID"
	local bestfont = "TargetIDSmall"

	local target = trace.Entity
	if !IsValid( target ) then return end

	local isPlayer = target:IsPlayer()
	if !isPlayer then return end

	text = target:Nick() .. " (" .. Core:StyleName( target:GetNWInt "Style" ) .. ")"
	best = "Best: " .. Timer:Convert( target:GetNWFloat "Record" )

	surface.SetFont( font )

	local w, h = surface.GetTextSize( text )
	local MouseX, MouseY = gui.MousePos()

	if (MouseX == 0) and (MouseY == 0) then
		MouseX = ScrW() / 2
		MouseY = ScrH() / 2
	end

	local x = MouseX
	local y = MouseY

	x = x - w / 2
	y = y + 30

	draw.SimpleText( text, font, x + 1, y + 1, Color( 0, 0, 0, 120 ) )
	draw.SimpleText( text, font, x + 2, y + 2, Color( 0, 0, 0, 50 ) )
	draw.SimpleText( text, font, x, y, color_white )

	y = y + h + 5

	surface.SetFont( bestfont )
	local w, h = surface.GetTextSize( best )
	local x = MouseX - w / 2

	draw.SimpleText( best, bestfont, x + 1, y + 1, Color( 0, 0, 0, 120 ) )
	draw.SimpleText( best, bestfont, x + 2, y + 2, Color( 0, 0, 0, 50 ) )
	draw.SimpleText( best, bestfont, x, y, color_white )
end

function GM:ShouldDrawLocalPlayer( ply )
	return false
end

function GM:PlayerFootstep( ply )
	local isVisible = CPlayers:GetBool()
	if !isVisible then return true end

	local wantsFootsteps = Footsteps:GetInt()
	local alwaysOff, settingLocal = (wantsFootsteps == 0), (wantsFootsteps == 2)

	if alwaysOff then return true end
	if settingLocal then
		local isLocal = (ply == LocalPlayer())
		if !isLocal then return true end
	end

	return false
end

--[[
function Client:ServerSwitch( data )
	local serverList = {
		[1] =	{ "74.91.119.62:27015", "Stellar Surf | Competitive Skill Surf Server" },
		[2] =	{ "162.248.92.118:27015", "Stellar Surf | Alpha Testing Server" },
	}

	local currentServer = game.GetIPAddress()
	local hookServer = serverList[1][1] == currentServer and serverList[2][2] or serverList[1][2]

	local hopText = {
		[1] = "You are about to switch to a different server, click Yes to continue",
		[2] = "(Target Server: " .. (hookServer or "Unknown Server") .. ")",
	}

	local function SendServer()
		local targetServer = serverList[1][1] == game.GetIPAddress() and serverList[2][1] or serverList[1][1]
		LocalPlayer():ConCommand( "connect " .. targetServer )
	end

	SMPanels.AgreementFrame( { title = "Server Hop", center = true, content = hopText, callback = SendServer } )
end--]]

local function ClientTick()
	if not IsValid( LocalPlayer() ) then timer.Simple( 1, ClientTick ) return end
	timer.Simple( 5, ClientTick )

	local ent = LocalPlayer()
	ent:SetHull( _C["Player"].HullMin, _C["Player"].HullStand )
	ent:SetHullDuck( _C["Player"].HullMin, _C["Player"].HullDuck )

	if not Client.ViewSet then
		ent:SetViewOffset( _C["Player"].ViewStand )
		ent:SetViewOffsetDucked( _C["Player"].ViewDuck )
		Client.ViewSet = true
	end
end

local function ChatEdit( nIndex, szName, szText, szID )
	if szID == "joinleave" then
		return true
	elseif szID == "namechange" then
		return true
	end
end
hook.Add( "ChatText", "SuppressMessages", ChatEdit )

-- This will get the prefix from the players' PlayerTitle, which returns a bullet point and a color based on the title attributes --
function Client:GetTitlePrefix(ply)
	local playerTitle = ply:GetNWString("PlayerTitle", "")
	if (playerTitle == "") then
		return "", color_black
	end

	local titleColor = Playercard.Colors[playerTitle]
	if !titleColor then
		return "", color_black
	end

	return "• ", titleColor
end

Client.ChatTickPointer = {
	["warning"] = "resource/warning.wav",
	["buttonclick"] = "ui/buttonclick.wav",
	["buttonrelease"] = "ui/buttonclickrelease.wav",
	["buttonrollover"] = "ui/buttonrollover.wav",
	["hint"] = "ui/hint.wav",
	["bell"] = "buttons/bell1.wav",
	["blip"] = "buttons/blip2.wav",
	["click"] = "garrysmod/ui_click.wav",
	["downloaded"] = "garrysmod/content_downloaded.wav",
	["balloon"] = "garrysmod/balloon_pop_cute.wav",
	["lowammo"] = "common/warning.wav",
	["beep"] = "tools/ifm/beep.wav",
	["message"] = "friends/message.wav",
	["switch"] = "buttons/lightswitch2.wav"
}

local function ChatTag( ply, szText, bTeam, bDead )
	if ply.ChatMuted then
		print( "[CHAT MUTE] " .. ply:Name() .. ": " .. szText )
		return true
	end

	local tab = {}

	local titlePrefix, titleColor = Client:GetTitlePrefix(ply)
	table.insert( tab, titleColor )
	table.insert( tab, titlePrefix )
	table.insert( tab, color_white )

	if bTeam then
		table.insert( tab, Color( 163, 119, 179 ) )
		table.insert( tab, "" )
	end

	local nAccess = ply:GetNWInt( "AccessIcon", 0 ) or 0

	if ply:GetNWInt( "Spectating", 0 ) == 1 then
		if nAccess > 0 then
			local VIPChat = ply:GetNWVector( "VIPChat", Vector( -1, 0, 0 ) )
			if VIPChat.x >= 0 then
				table.insert( tab, Core.Util:VectorToColor( VIPChat ) )
				table.insert( tab, "*SPEC* " )
			else
				table.insert( tab, Color( 189, 195, 199 ) )
				table.insert( tab, "*SPEC* " )
			end
		else
			table.insert( tab, Color( 189, 195, 199 ) )
			table.insert( tab, "*SPEC* " )
		end
	end

	if IsValid( ply ) and ply:IsPlayer() then
		nAccess = ply:GetNWInt( "AccessIcon", 0 )

		local points = ply:GetNWInt "Points"
		local sRank = ply:GetNWInt "SpecialRank"
		local Rank = Timer:GetRankObject( sRank, points )
		table.insert( tab, GUIColor.White )

		if !(EmoteOnly:GetBool()) then
			local style = ply:GetNWInt("Style", 1)
			local appendedText = (style != 1 and (Core:StyleName(style) .. " - ") or "")

			if nAccess > 0 then
				local VIPTag, VIPTagColor = ply:GetNWString( "VIPTag", "" ), ply:GetNWVector( "VIPTagColor", Vector( -1, 0, 0 ) )
				if VIPTag != "" and VIPTagColor.x >= 0 then
					table.insert( tab, Core.Util:VectorToColor( VIPTagColor ) )
					table.insert( tab, "[" )
					table.insert( tab, appendedText .. VIPTag )
					table.insert( tab, "] " )
					table.insert( tab, GUIColor.White )
				else
					table.insert( tab, Rank[ 2 ] )
					table.insert( tab, "[" )
					table.insert( tab, appendedText .. Rank[ 1 ] )
					table.insert( tab, "] " )
					table.insert( tab, GUIColor.White )
				end
			else
				table.insert( tab, Rank[ 2 ] )
				table.insert( tab, "[" )
				table.insert( tab, appendedText .. Rank[ 1 ] )
				table.insert( tab, "] " )
				table.insert( tab, GUIColor.White )
			end
		end

		if nAccess > 0 then
			local VIPNameColor = ply:GetNWVector( "VIPNameColor", Vector( -1, 0, 0 ) )
			if VIPNameColor.x >= 0 then
				local VIPName = ply:Name()
				if VIPNameColor.x == 256 then
					tab = Client:GenerateName( tab, VIPName )
				elseif VIPNameColor.x == 257 then
					tab = Client:GenerateName( tab, VIPName, ply )
				else
					table.insert( tab, Core.Util:VectorToColor( VIPNameColor ) )
					table.insert( tab, VIPName )
				end

				if Client.VIPReveal and VIPName != ply:Name() then
					table.insert( tab, GUIColor.White )
					table.insert( tab, " (" .. ply:Name() .. ")" )
				end
			else
				table.insert( tab, Color( 203, 71, 71 ) )
				table.insert( tab, ply:Name() )
			end
		else
			table.insert( tab, Color( 203, 71, 71 ) )
			table.insert( tab, ply:Name() )
		end
	else
		table.insert( tab, "Console" )
	end

	table.insert( tab, GUIColor.White )
	table.insert( tab, ": " )

	if nAccess > 0 then
		local VIPChat = ply:GetNWVector( "VIPChat", Vector( -1, 0, 0 ) )
		if VIPChat.x >= 0 then
			table.insert( tab, Core.Util:VectorToColor( VIPChat ) )
		end
	end

	table.insert( tab, szText )

	chat.AddText( unpack( tab ) )

	local chatTickValue = ChatTick:GetString()
	if Client.ChatTickPointer[chatTickValue] then
		surface.PlaySound( Client.ChatTickPointer[chatTickValue] )
	elseif (Client.ChatTickPointer != "disable") then
		chat.PlaySound()
	end

	return true
end
hook.Add( "OnPlayerChat", "TaggedChat", ChatTag )

local function PlayerVisiblityCheck( ply )
	local isDrawing = CPlayers:GetBool()

	local currentColor = ply:GetColor()
	local hiddenColor = ColorAlpha(currentColor, 0)
	ply:SetColor(hiddenColor)

	if !isDrawing then
		ply:SetRenderMode(RENDERMODE_TRANSCOLOR)
		ply:DrawShadow(false)
	else
		ply:SetRenderMode(RENDERMODE_NORMAL)
		ply:DrawShadow(true)
	end
end
hook.Add( "PostPlayerDraw", "PlayerVisiblityCheck", PlayerVisiblityCheck )

local function UpdatePlayerVisibility(_, old, new)
	local isDrawing = new

	for _,ply in pairs(player.GetAll()) do
		local currentColor = ply:GetColor()
		local hiddenColor = ColorAlpha(currentColor, 0)
		ply:SetColor(hiddenColor)

		if !isDrawing then
			ply:SetRenderMode(RENDERMODE_TRANSCOLOR)
			ply:DrawShadow(false)
		else
			ply:SetRenderMode(RENDERMODE_NORMAL)
			ply:DrawShadow(true)
		end
	end
end
cvars.AddChangeCallback("sl_showothers", UpdatePlayerVisibility)

local function Initialize()
	timer.Simple( 5, ClientTick )
	timer.Simple( 5, function() Core:Optimize() end )

	Client:VerifyList()

	if CHelp:GetBool() then Help:Open() end
end
hook.Add( "Initialize", "ClientBoot", Initialize )
