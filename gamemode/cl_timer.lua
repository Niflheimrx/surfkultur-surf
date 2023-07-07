--[[
	Rewritten on 01/19/2021:
	Main objective here was to reduce the overall size of this file
--]]

Timer = {}
Timer.Style = _C.Style.Normal

-- Ease of access stuff --
local fl, fo, sf, ab, cl, ct, lp = math.floor, string.format, string.find, math.abs, math.Clamp, CurTime, LocalPlayer
local ts = _C.Team.Spectator

-- Timer storage --
local start, finish = 0, 0
local best, difference = 0, 0
local prestrafe = 0

local records = {}

local stRecord, stPBRecord = {}, {}
local mTier, mType = 1, 0
local stageCount = 1

-- Checkpoint shit --
local cpDisplay = 0
local cpIndex, cpTime, cpDiff = 0, 0, 0, 0
local cpColor = Color(0, 0, 0, 0)

-- ConVars --
ViewGUI = CreateClientConVar( "sl_showgui", "1", true, false, "Toggles the visibility of the timer." )
local ViewSpec = CreateClientConVar( "sl_showspec", "1", true, false, "Toggles the visibility of the spectator list." )
local GUI_X = CreateClientConVar( "sl_gui_xoffset", "20", true, false, "Changes the x-position of the timer." )
local GUI_Y = CreateClientConVar( "sl_gui_yoffset", "115", true, false, "Changes the y-position of the timer." )
local GUI_O = CreateClientConVar( "sl_gui_opacity", "255", true, false, "Changes the opacity of the timer." )
local STATS = CreateClientConVar( "sl_sidetimer", "1", true, false, "Toggles the SideTimer panel. Use 1 to see detailed info such as the current stage, stage record, and your stage timer." )
local STATS_POS = CreateClientConVar( "sl_sidetimer_pos", "0", true, false, "Changes the position of the SideTimer panel." )
local SimSpeed = CreateClientConVar( "sk_velocity", "0", true, false, "Toggles the visibility of the header velocity when using the Simple theme." )
local CUSTOM_R = CreateClientConVar( "sl_custom_r", "141", true, false, "The amount of red shown in your Custom theme GUI." )
local CUSTOM_G = CreateClientConVar( "sl_custom_g", "0", true, false, "The amount of blue shown in your Custom theme GUI." )
local CUSTOM_B = CreateClientConVar( "sl_custom_b", "202", true, false, "The amount of yellow shown in your Custom theme GUI." )
local CUSTOM_ACCENT = CreateClientConVar( "sl_custom_accent", "0", true, false, "Toggles the accent on the GUI when the Custom theme is used." )
local CUSTOM_RAINBOW = CreateClientConVar( "sl_custom_rainbow", "0", true, false, "Toggles the rainbow effect when using the Custom theme." )
local CUSTOM_PRESTIGE = CreateClientConVar( "sl_custom_prestige", "0", true, false, "Changes the colors of the Prestige GUI if set to 1." )
local SimpleNG = CreateClientConVar( "sl_netgraph", "0", true, false, "The alternate to net_graph. Simplified and easier to read." )
local LocationNG = CreateClientConVar( "sl_netgraphpos", "0", true, false, "Toggles the location the simple net_graph interface. " )
local CenterSpeed = CreateClientConVar( "sl_velocity_center", "0", true, false, "Toggles the visibility of the center velocity." )
local OldCenterSpeed = CreateClientConVar( "sl_old_centervelocity", "0", true, false, "Uses the old center speed velocity module." )
local CPHUD = CreateClientConVar( "sl_checkpoint_hud", "0", true, false, "Displays checkpoint comparisons at the top middle of the screen" )

-- Base Timer functions (basically record handling and stuff kinda like an API?) --
function Timer:SetStart( data )
	start = data
	finish = nil

	-- Notify users when their timer starts if their hud is disabled --
	local hudEnabled = ViewGUI:GetBool()
	if !start or hudEnabled then return end

	local isBonus = Core.IsBonus( Timer.Style )
	local styleName = Core:StyleName( Timer.Style )
	if isBonus then
		Link:ProcessMessage( "You have started your timer on Bonus [", CL.Yellow, styleName, "]" )
	else
		Link:ProcessMessage( "You have started your timer" )
	end
end

function Timer:SetStageStart( data )
	local stageMode = LocalPlayer():GetNWBool "StageTimer"
	if !stageMode then return end

	start = data
	finish = nil

	-- Notify users when their timer starts if their hud is disabled --
	local hudEnabled = ViewGUI:GetBool()
	if !start or hudEnabled then return end

	local nStage = LocalPlayer():GetNWInt "Stage"
	Link:ProcessMessage( "You have started your timer on Stage [", CL.Yellow, "Stage " .. nStage, "]" )
end

function Timer:SetFinish( data )
	finish = data
end

function Timer:SetStageFinish( data )
	local stageMode = LocalPlayer():GetNWBool "StageTimer"
	if !stageMode then return end

	finish = data
end

function Timer:SetPrestrafe( data )
	prestrafe = data
end

function Timer:SetCheckpointHUD(checkpoint, time, comparison)
	cpDisplay = CurTime()
	cpIndex, cpTime = checkpoint, time
	cpDiff = (time - comparison)

	if (comparison > 0) then
		if (cpDiff > 0) then
			cpColor = Color(255, 0, 0)
		elseif (cpDiff < 0) then
			cpColor = Color(0, 255, 0)
		else
			cpColor = color_white
		end
	else
		cpColor = color_white
	end

	local timeDifference = comparison and (comparison != 0) and (time - comparison) or ""
	local differenceText = timeDifference != "" and (timeDifference >= 0 and "+ " or "- " ) or ""
	cpDiff = differenceText .. (timeDifference != "" and Timer:Convert(math.abs(timeDifference)) or "")
end

function Timer:SetSideTimerInitialData( data )
	stRecord = data
end

function Timer:SetSideTimerData( map, rec, pb, stages )
	stRecord, stPBRecord = {}, {}

	mTier, mType = map[1], map[2]
	stRecord = rec
	stPBRecord = pb
	stageCount = stages
end

function Timer:SetSideTimerMapData( map, stages )
	mTier, mType = map[1], map[2]
	stageCount = stages
end

function Timer:SetRecord( data )
	best = data
end

function Timer:SetInitial( data )
	records = data
end

function Timer:SetStyle( data )
	Timer.Style = data
	LocalPlayer().Style = data
end

function Timer:Sync( data )
	Tdifference = CurTime() - data
end

function Timer:GetDifference()
	return Tdifference
end

function Timer:SetStageCount( data )
	stageCount = data
end

function Timer:GetRankTitle( rank, pts )
	local rankTitle = ""
	local wantsSpecial = ShowSpecialRanks:GetBool()

	if wantsSpecial and rank <= 5 then
		rankTitle = _C.SpecialRanks[rank][1]
	else
		for n,value in pairs( _C.Ranks ) do
			if (n < 0) then continue end

			local rankPoints = math.ceil( value[3] )

			if pts >= rankPoints then
				rankTitle = value[1]
			end
		end
	end

	return rankTitle
end

function Timer:GetRankObject( rank, pts )
	local rankObj = _C.Ranks[-1]
	local wantsSpecial = ShowSpecialRanks:GetBool()

	if wantsSpecial and rank <= 5 and rank > 0 then
		rankObj = _C.SpecialRanks[rank]
	else
		for n,value in pairs( _C.Ranks ) do
			if (n < 0) then continue end

			local rankPoints = math.ceil( value[3] )

			if pts >= rankPoints then
				rankObj = value
			end
		end
	end

	return rankObj
end

-- Major speedup compared to older version, you can also technically now use enumerators higher than 4 lol --
local function ConvertTime( ns )
	local dec = Decimals:GetInt()
	local frm = 10 ^ dec
	local decimalFormat = (".%." .. dec .. "d")
	if (dec == 0) then
		decimalFormat = ""
		frm = 1
	end

	if ns > 3600 then
		return fo( "%d:%.2d:%.2d" .. decimalFormat, fl( ns / 3600 ), fl( ns / 60 % 60 ), fl( ns % 60 ), fl( ns * frm % frm ) )
	else
		return fo( "%.2d:%.2d" .. decimalFormat, fl( ns / 60 % 60 ), fl( ns % 60 ), fl( ns * frm % frm ) )
	end
end
function Timer:Convert( ns ) return ConvertTime( ns ) end
function Timer:GetConvert() return ConvertTime end

local function GetCurrentTime()
	if !finish and start then
		return ct() - start
	elseif finish and start then
		return finish - start
	else
		return 0
	end
end
function Timer:GetCurrentTime() return GetCurrentTime() end

local function GetTimePiece( query, style, stage )
	local record = records[style]
	if !record then return "" end

	local recordBest = record[3]
	if stage then
		local index = stRecord[style] and stRecord[style][stage] and stRecord[style][stage][1]
		if index then
			recordBest = index
		end
	end

	local difference = query - recordBest
	local abs = ab(difference)

	if (difference < 0.014) and (difference > -0.014) then
		return " [SR]"
	elseif (difference < 0) then
		return fo( " [ -%.2d:%.2d]", fl( abs / 60 ), fl( abs % 60 ) )
	else
		return fo( " [+%.2d:%.2d]", fl( abs / 60 ), fl( abs % 60 ) )
	end
end

local function SimpleTimePiece( query, style, stage )
	local record = records[style]
	if !record then return "" end

	local recordBest = record[3]
	if stage then
		local index = stRecord[style] and stRecord[style][stage] and stRecord[style][stage][1]
		if index then
			recordBest = index
		end
	end

	local difference = query - recordBest
	local abs = ab(difference)

	if (difference < 0.014) and (difference > -0.014) then
		return ""
	elseif (difference < 0) then
		return fo( " -%.2d:%.2d", fl( abs / 60 ), fl( abs % 60 ) )
	else
		return fo( " +%.2d:%.2d", fl( abs / 60 ), fl( abs % 60 ) )
	end
end

-- New! Find the index of a record in Timer format --
function Timer:RecordFormatIndex( style, stage )
	local record = records[style]
	if !record then return "None Set" end

	local recordBest = record[3]
	if stage then
		local index = stRecord[style] and stRecord[style][stage] and stRecord[style][stage][1]
		if index then
			recordBest = index
		end
	end

	return Timer:Convert( recordBest )
end

-- Flow HUD variables --
local SXo = ScrW() * 0.5 - 115
local SYo = 170
local SOv = 255

local Xo = GUI_X:GetInt() or 20
local Yo = GUI_Y:GetInt() or 115
local Ov = GUI_O:GetInt() or 255

-- HUD Controllers --
function Timer:SetOpacity( o )
	RunConsoleCommand( "sl_gui_opacity", o )

	Ov = o

	Link:ProcessMessage( "HUD Opacity: ", CL.Blue, o, CL.White, " (", CL.Blue, math.Round( (o / 255) * 100, 1 ) .. "%", CL.White, ")" )
end

function Timer:GUIVisibility( nTarget )
	local nNew = -1
	if nTarget < 0 then
		nNew = 1 - ViewGUI:GetInt()
		RunConsoleCommand( "sl_showgui", nNew )
	else
		nNew = nTarget
		RunConsoleCommand( "sl_showgui", nNew )
	end

	if nNew >= 0 then
		local isEnabled = ViewGUI:GetBool()
		Link:ProcessMessage( "HUD: ", CL.Yellow, isEnabled and "On" or "Off" )
	end
end

function Timer:GetSpecSetting()
	return ViewSpec:GetInt()
end

local CPSData = nil

function Timer:SetCPSData( data )
	SetSyncData( data )
end

local CSList = {}
local CSData = { Contains = nil, Bot = false, Player = "Unknown", Start = nil, Record = nil, StageStart = nil }
local CSRemote = false
local CSTitle = ""
local CSModes = { "First Person", "Chase Cam", "Free Roam" }
local CSDraw = {Player = "Unknown", PlayerInfo = "A Ghost" }

function Timer:SpectateData( varArgs, bRemote, nCount, bReset )
	CSList = varArgs
	CSRemote = bRemote
	CSTitle = ""

	if nGUI == 4 then
		CSTitle = "Spectating: " .. nCount
	else
		CSTitle = "Spectators" .. ": " .. nCount .. ""
	end

	if bReset then
		CSList = {}
		CSTitle = ""
	end
end

function Timer:SpectateUpdate()
	CSData = Cache.S_Data
end

-- HUD Files --
function GM:HUDPaintBackground()
	-- For a clean demo we want to prevent this from showing in videos, just record through obs or something to get around this --
	if (engine.IsPlayingDemo()) then return end

  local isEnabled = ViewGUI:GetBool()
	if !isEnabled then return end

	local lpc = lp()
	if !IsValid( lpc ) then return end

	local nWidth, nHeight = ScrW(), ScrH() - 30
	local nHalfW = nWidth / 2

	local wantsRainbow = (Rainbow == 1)
	if wantsRainbow then
		Custom = Core.Util:ColorToRainbow()
	end

	local isSpectator = (lpc:Team() == ts)
	local ob = (isSpectator and IsValid( lpc:GetObserverTarget() ) and lpc:GetObserverTarget())
	local target = ob or lpc

	local nStyle = target:GetNWInt "Style"
	local nStage = target:GetNWInt "Stage"
	local isPractice = target:GetNWBool "Practice"
	local isStaging = target:GetNWBool "StageTimer"
	local isRepeating = target:GetNWBool "StageAgain"
	local isBonus = Core.IsBonus( nStyle )
	local szStyle = Core:StyleName( nStyle )
	if (nStyle > 14) and (nStyle < 40) then
		szStyle = "Stage " .. (nStyle - 14)
		nStyle = 1
		isStaging = true
	end

	local maxSpeed = GetConVar( "sv_maxvelocity" ):GetInt()
	local nSpeed = target:GetVelocity():Length()

	local wants2DVelocity = Velocity:GetBool()
	local wantsVelocityBar = VelocityBar:GetBool()
	local wantsPrestrafe = Prestrafe:GetBool()
	if wants2DVelocity then
		nSpeed = target:GetVelocity():Length2D()
	end

	local bData = CSData.Contains
	local nCurrent = GetCurrentTime()
	if bData then
		local rate = target:GetNWFloat("Rate", 1)
		nCurrent = CSData.Start and (CurTime() * rate) - CSData.Start or 0
	end

	local nRecord = target:GetNWFloat "Record"
	local nStageRecord = target:GetNWFloat "StageRecord"
	local nStageCompare = nil

	if isStaging then
		nRecord = nStageRecord
		nStageCompare = nStage
	end

	if (nGUI == 0) then
		local specPadding = ob and 145 or 95
		draw.RoundedBox( 8, SXo, ScrH() - SYo, 230, specPadding, Color( 0, 0, 0, 110 ) )

		local currentPrestrafe = (!isSpectator) and (wantsPrestrafe and nCurrent > 0) and " (" .. prestrafe .. ")" or ""
		local cp = cl( nSpeed - 500, 0, maxSpeed ) / maxSpeed
		draw.SimpleText( fo( "%.0f u/s", nSpeed ) .. currentPrestrafe, "HUDSpeed", SXo + 115, ScrH() - SYo + 73, Color(255, 255, 255, SOv), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		if wantsVelocityBar then
			draw.RoundedBox( 0, SXo + 12, ScrH() - SYo + 83, cp * 206, 1, Color( 118, 35, 131 ) )
		end

		if ob then
			if ob:IsBot() then
				CSDraw.Player = ((bData and CSData.Bot) and CSData.Player or "No Bot Recorded") .. " ( " .. szStyle .. " )"
				CSDraw.PlayerInfo = "Spectating Bot - Runner:"
			else
				CSDraw.Player = ob:Name() .. " ( " .. szStyle .. " )"
				CSDraw.PlayerInfo = "Runner:"
			end

			draw.SimpleText( CSDraw.PlayerInfo, "HUDTimer", SXo + 115, ScrH() - SYo + 100, Color(255, 255, 255, SOv), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText( CSDraw.Player, "HUDTimer", SXo + 115, ScrH() - SYo + 125, Color(255, 255, 255, SOv), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

		local suffix = isPractice and " [P]" or ""
		if isSpectator and !ob then
			draw.SimpleText( "Free Roam Mode", "HUDTimer", SXo + 115, ScrH() - SYo + 20, Color(255, 255, 255, SOv), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			draw.SimpleText( "Use +reload to go back", "HUDTimer", SXo + 115, ScrH() - SYo + 45, Color(255, 255, 255, SOv), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		elseif isPractice and (nCurrent == 0) then
			local notify = "Do /noclip to move around!"
			if isSpectator then
				notify = "User is practicing"
			end

			draw.SimpleText( "Practice Mode", "HUDTimer", SXo + 115, ScrH() - SYo + 20, Color(255, 255, 255, SOv), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			draw.SimpleText( notify, "HUDTimer", SXo + 115, ScrH() - SYo + 45, Color(255, 255, 255, SOv), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		else
			draw.SimpleText( "Time:", "HUDTimer", SXo + 12, ScrH() - SYo + 20, Color(255, 255, 255, SOv), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
			draw.SimpleText( "PB:" , "HUDTimer", SXo + 12, ScrH() - SYo + 45, Color(255, 255, 255, SOv), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )

			draw.SimpleText( ConvertTime( nCurrent ) .. GetTimePiece( nCurrent, nStyle, nStageCompare ) .. suffix, "HUDTimer", SXo + 64 + 12, ScrH() - SYo + 20, Color(255, 255, 255, SOv), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
			draw.SimpleText( ConvertTime( nRecord ) .. GetTimePiece( nRecord, nStyle, nStageCompare ), "HUDTimer", SXo + 64 + 12, ScrH() - SYo + 45, Color(255, 255, 255, SOv), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		end
	elseif (nGUI == 1) then
		local Xo = Xo + Interface.Wide
		if (isSpectator and ob or !isSpectator) then
			surface.SetDrawColor( Color(35, 35, 35, Ov) )
			surface.DrawRect( Xo, ScrH() - Yo, 230, 95 )
			surface.SetDrawColor( Color(42, 42, 42, Ov) )
			surface.DrawRect( Xo + 5, ScrH() - Yo + 5, 220, 55 )
			surface.DrawRect( Xo + 5, ScrH() - Yo + 65, 220, 25 )

			local cp = cl( nSpeed - 500, 0, maxSpeed ) / maxSpeed
			if wantsVelocityBar then
				surface.SetDrawColor( Color( 42 + cp * 213, 42, 42, Ov ) )
				surface.DrawRect( Xo + 5, ScrH() - Yo + 65, cp * 220, 25 )
			end

			local currentPrestrafe = (!isSpectator) and (wantsPrestrafe and nCurrent > 0) and " (" .. prestrafe .. ")" or ""
			draw.SimpleText( fo( "%.0f u/s", nSpeed ) .. currentPrestrafe, "HUDSpeed", Xo + 115, ScrH() - Yo + 77, Color(255, 255, 255, Ov), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

			draw.SimpleText( "Time:", "HUDTimer", Xo + 12, ScrH() - Yo + 20, Color(255, 255, 255, Ov), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
			draw.SimpleText( "PB:", "HUDTimer", Xo + 12, ScrH() - Yo + 45, Color(255, 255, 255, Ov), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		end

		if isSpectator then
			if ob then
				if ob:IsBot() then
					CSDraw.Header = "Spectating Bot"
					CSDraw.Player = ((bData and CSData.Bot) and CSData.Player or "Waiting bot") .. " (" .. szStyle .. " style)"
				else
					CSDraw.Header = "Spectating"
					CSDraw.Player = ob:Name() .. " (" .. szStyle .. ")"
				end

				draw.SimpleText( "Time:", "HUDTimer", Xo + 12, ScrH() - Yo + 20, Color(255, 255, 255, Ov), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
				draw.SimpleText( "PB:", "HUDTimer", Xo + 12, ScrH() - Yo + 45, Color(255, 255, 255, Ov), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )

				draw.SimpleText( ConvertTime( nCurrent ) .. GetTimePiece( nCurrent, nStyle, nStageCompare ), "HUDTimer", Xo + 64 + 12, ScrH() - Yo + 20, Color(255, 255, 255, Ov), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
				draw.SimpleText( ConvertTime( nRecord ) .. GetTimePiece( nRecord, nStyle, nStageCompare ), "HUDTimer", Xo + 64 + 12, ScrH() - Yo + 45, Color(255, 255, 255, Ov), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )

				draw.SimpleText( CSDraw.Header, "HUDHeaderBig", nHalfW + 2, nHeight - 58, Color(25, 25, 25, 255), TEXT_ALIGN_CENTER )
				draw.SimpleText( CSDraw.Header, "HUDHeaderBig", nHalfW, nHeight - 60, Color(214, 59, 43, 255), TEXT_ALIGN_CENTER )

				draw.SimpleText( CSDraw.Player, "HUDHeader", nHalfW + 2, nHeight - 18, Color(25, 25, 25, 255), TEXT_ALIGN_CENTER )
				draw.SimpleText( CSDraw.Player, "HUDHeader", nHalfW, nHeight - 20, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER )
			end

			local text = CSModes[ Cache:S_GetType() ] .. " - Press R to change spectate mode"
			draw.SimpleText( text, "HUDHeader", nHalfW + 2, 32, Color(25, 25, 25, 255), TEXT_ALIGN_CENTER )
			draw.SimpleText( text, "HUDHeader", nHalfW, 30, Color(255, 255, 255), TEXT_ALIGN_CENTER )
			draw.SimpleText( "Cycle through players with left/right mouse", "HUDTitleSmall", nHalfW, 60, Color(255, 255, 255), TEXT_ALIGN_CENTER )
		else
			draw.SimpleText( ConvertTime( nCurrent ) .. GetTimePiece( nCurrent, nStyle, nStageCompare ), "HUDTimer", Xo + 64 + 12, ScrH() - Yo + 20, Color(255, 255, 255, Ov), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
			draw.SimpleText( ConvertTime( nRecord ) .. GetTimePiece( nRecord, nStyle, nStageCompare ), "HUDTimer", Xo + 64 + 12, ScrH() - Yo + 45, Color(255, 255, 255, Ov), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		end
	elseif (nGUI == 2) then
		-- New! Table system for this theme as its easier to work/maintain --
		local tab = {}
		local Ov = 255
		local index = 1

		if (isSpectator and ob or !isSpectator) then
			if ob and ob:IsBot() then
				CSDraw.Player = ((bData and CSData.Bot) and CSData.Player or "Record Playback") .. " ( Bot )"
			elseif ob then
				CSDraw.Player = ob:Name()
			end

			local suffix = isPractice and " [Practice]" or ""
			if ob and isPractice and (nCurrent == 0) then
				tab[1] = "Practice Mode"
				tab[2] = "This user is currently practicing"
				index = 2
			elseif isPractice and (nCurrent == 0) then
				tab[1] = "Practice Mode"
				tab[2] = "Use !noclip to move around!"
				index = 2
			else
				tab[index] = "Time: " .. ConvertTime( nCurrent ) .. suffix

				if (nRecord != 0) then
					index = index + 1
					tab[index] = "Best: " .. ConvertTime( nRecord )
				end

				index = index + 1
				if (nCurrent == 0) then
					tab[index] = "WR: " .. Timer:RecordFormatIndex( nStyle, nStageCompare )
				else
					tab[index] = "WR: " .. ConvertTime( nRecord ) .. GetTimePiece( nRecord, nStyle, nStageCompare )
				end
			end
		else
			tab[1] = "Free Roam Mode"
			tab[2] = "Press +reload to change view modes"
			tab[3] = "Cycle through players using +attack/+attack2"

			index = 3
		end

		index = index + 1
		tab[index] = "Vel: " .. fo( "%.0f u/s", nSpeed )

		if (!isSpectator) and (wantsPrestrafe and nCurrent > 0) then
			index = index + 1
			tab[index] = "Start: " .. prestrafe
		end

		if isSpectator then
			index = index + 1
			tab[index] = "Player: " .. CSDraw.Player .. " ( " .. szStyle .. " )"
		end

		for line, text in pairs( tab ) do
			draw.SimpleText( text, "HUDTimer", 15 + Interface.Wide, 20 * line, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		end
	elseif (nGUI == 3) then
		-- This essentially has no changes compared to the previous version --
		local tab, headerText = {}, lpc:GetNWInt( "Stage" ) > 0 and "Staged Map" or "Linear Map"
		Ov = GUI_O:GetInt() or 255

		local currentName = ""
		local hasBest = nRecord > 0
		local currentPrestrafe = ""

		if isSpectator and ob then
			currentName = ob:IsBot() and CSData.Player .. " (Record Bot)" or ob:Name()
			tab[5] = "Spectating: " .. currentName

			if ob:IsBot() and isStaging then
				isStaging = false
			end
		else
			currentPrestrafe = wantsPrestrafe and " (" .. prestrafe .. ")" or ""
		end

		if (isSpectator and ob or !isSpectator) then
			if nStage > 0 then
				headerText = "Stage: " .. nStage .. "/" .. stageCount
			end

			if isBonus then
				headerText = "Bonus Zone"
			end

			if isStaging then
				tab[1] = "[Stage Mode" .. (isRepeating and " | Repeating" or "" ) .. "]"

				if (nCurrent > 0) then
					tab[2] = "Time: " .. ConvertTime( nCurrent )
				else
					tab[2] = "Zone Start: Stage " .. nStage
				end
			elseif isPractice and (nCurrent == 0) then
				tab[1] = "[SurfTimer Disabled]"
				tab[2] = "Best: " .. ( hasBest and ConvertTime( nRecord ) .. GetTimePiece( nRecord, nStyle, nStageCompare ) or "None" )
			else
				local suffix = isPractice and " (Practice)" or ""
				if (nCurrent > 0) then
					tab[1] = "Time: " .. ConvertTime( nCurrent ) .. GetTimePiece( nCurrent, nStyle, nStageCompare ) .. suffix
				else
					tab[1] = nCurrent < 0 and "Restarting Run..." or isPractice and "[Practice Mode]" or "In Start Zone"
				end

				tab[2] = "Best: " .. ( hasBest and ConvertTime( nRecord ) .. GetTimePiece( nRecord, nStyle, nStageCompare ) or "None" )
			end

			tab[3] = "Mode: " .. szStyle
			tab[4] = "Speed: " .. fo( "%.0f u/s", nSpeed ) .. (nCurrent > 0 and currentPrestrafe or "")
		else
			tab[1] = "Free Roam"
			tab[2] = "Use +reload to change viewmode"
		end

		local bezel = Interface:GetBezel( "Big" )
		local font = Interface:GetFont()
		local smallfont = Interface:GetTinyFont()
		local fontHeight = Interface.FontHeight[Interface.Scale]

		local width, height = Interface:GetTextWidth( tab ), Interface:GetTextHeight( tab )
		local sWidth, sHeight = ScrW() / 2, ScrH() - (bezel * 2) - (fontHeight * #tab)

		local tempColor, tempColor2 = Interface.BackgroundColor, Interface.ForegroundColor
		local newColor, newColor2 = Color( tempColor.r, tempColor.g, tempColor.b, Ov ), Color( tempColor2.r, tempColor2.g, tempColor2.b, Ov )

		draw.RoundedBoxEx( 6, sWidth - (width / 2), sHeight, width, height - (bezel / 2), newColor, false, false, true, true )
		draw.RoundedBoxEx( 6, sWidth - (width / 2), sHeight - bezel, width, bezel, newColor2, true, true, false, false )
		draw.SimpleText( headerText, smallfont, sWidth, sHeight - (bezel / 2), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

		for line, text in pairs( tab ) do
			draw.SimpleText( text, font, sWidth, sHeight + ( fontHeight * line ), color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )
		end

		local velocityColor = Interface.HighlightColor
		if wantsVelocityBar then
			local cp = cl( nSpeed, 0, 3500 ) / 3500
			draw.RoundedBox( 0, 0, ScrH() - 5, cp * ScrW(), 5, velocityColor )
		end
	elseif (nGUI == 4) then
		local col = Color( 0, 0, 0, 160 )
		local textBG = Color( 25, 25, 25 )
		local textFG = Color( 255, 255, 255 )

		local sizeX, sizeY = ScrW(), 60
		local posX, posY = 0, (ScrH() - 60)

		local bColor, fColor = Color( 0, 0, 0 ), Color( 118, 35, 131 )

		if (CPrestige == 1) then
			if (Accent == 1) then
				col = Color( Custom.r, Custom.g, Custom.b, 30 )
				fColor = Color( Custom.r, Custom.g, Custom.b, 255 )
			end
		end

		draw.RoundedBox( 0, posX, posY, sizeX, sizeY, col )

		if isSpectator and ob then
			if ob:IsBot() then
				CSDraw.Player = ((bData and CSData.Bot) and CSData.Player or "No Bot Recorded") .. " (Bot - " .. szStyle .. ")"
			else
				CSDraw.Player = ob:Name() .. " ( " .. szStyle .. " )"
			end

			draw.SimpleText( CSDraw.Player, "BottomHUDVelocity", ( ScrW() / 2 ), posY + 18, textBG, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			draw.SimpleText( CSDraw.Player, "BottomHUDVelocity", ( ScrW() / 2 ), posY + 16, textFG, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		end

		local nTPiece = "  [WR" .. SimpleTimePiece( nCurrent, nStyle, nStageCompare ) .. "]"
		local nRPiece = "  [PB" .. SimpleTimePiece( nRecord, nStyle, nStageCompare ) .. "]"
		if nRecord == 0 then
			nTPiece = ""
		end

		local centerText = nil
		local upperText = nil
		local lowerText = nil

		local appendedUpper = nil
		local appendedLower = nil

		if (isSpectator and ob or !isSpectator) then
			local suffix = isPractice and " [Practice]" or ""
			if (nRecord > 0) then
				upperText = "Current Time: "
				lowerText = (ob and ob:IsBot() and "Run Duration: " or "Player's Best: ")

				appendedUpper = ConvertTime( nCurrent ) .. nTPiece .. suffix
				appendedLower = ConvertTime( nRecord ) .. nRPiece

				if ob and isPractice and (nCurrent == 0) then
					upperText = "Practice Mode"
					lowerText = "This user is currently practicing"

					appendedUpper = ""
					appendedLower = ""
				elseif isPractice and (nCurrent == 0) then
					upperText = "Practice Mode"
					lowerText = "Use !noclip to move around!"

					appendedUpper = ""
					appendedLower = ""
				end

				draw.SimpleText( upperText, "BottomHUDTime", 20 + Interface.Wide, posY + 21, textBG, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
				draw.SimpleText( upperText, "BottomHUDTime", 20 + Interface.Wide, posY + 19, textFG, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )

				draw.SimpleText( appendedUpper, "BottomHUDTime", 140 + Interface.Wide, posY + 21, textBG, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
				draw.SimpleText( appendedUpper, "BottomHUDTime", 140 + Interface.Wide, posY + 19, textFG, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )

				draw.SimpleText( lowerText, "BottomHUDTime", 20 + Interface.Wide, posY + 41, textBG, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
				draw.SimpleText( lowerText, "BottomHUDTime", 20 + Interface.Wide, posY + 39, textFG, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )

				draw.SimpleText( appendedLower, "BottomHUDTime", 140 + Interface.Wide, posY + 41, textBG, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
				draw.SimpleText( appendedLower, "BottomHUDTime", 140 + Interface.Wide, posY + 39, textFG, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
			else
				centerText = "Current Time:  " .. ConvertTime( nCurrent )  .. nTPiece .. suffix

				if isPractice and (nCurrent == 0) then
					centerText = "Practice Mode"
				end

				draw.SimpleText( centerText, "BottomHUDVelocity", 20 + Interface.Wide, posY + 32, textBG, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
				draw.SimpleText( centerText, "BottomHUDVelocity", 20 + Interface.Wide, posY + 30, textFG, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
			end

			if (!isSpectator and wantsPrestrafe) and (nCurrent > 0) then
				local width = Interface:GetTextWidth( { "Start: " .. prestrafe }, "BottomHUDTime" )
				surface.DrawRect( ( ScrW() / 2 ) - (width / 2), ScrH() - 80, width, 20 )
				draw.SimpleText( prestrafe, "BottomHUDTime", ScrW() / 2, posY - 8, textBG, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
				draw.SimpleText( prestrafe, "BottomHUDTime", ScrW() / 2, posY - 10, textFG, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			end
		else
			upperText = "Free Roam Mode"
			lowerText = "Use +reload to change view modes"

			draw.SimpleText( upperText, "BottomHUDTime", 20 + Interface.Wide, posY + 21, textBG, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
			draw.SimpleText( upperText, "BottomHUDTime", 20 + Interface.Wide, posY + 19, textFG, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )

			draw.SimpleText( lowerText, "BottomHUDTime", 20 + Interface.Wide, posY + 41, textBG, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
			draw.SimpleText( lowerText, "BottomHUDTime", 20 + Interface.Wide, posY + 39, textFG, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		end

		local svMaxVelocity = GetConVar( "sv_maxvelocity" ):GetInt()
		maxSpeed = (svMaxVelocity * 2) + 500
		if svMaxVelocity > 5000 then
			maxSpeed = svMaxVelocity * 2.35
		elseif svMaxVelocity > 3500 then
			maxSpeed = svMaxVelocity * 2.25
		end

		local cp = cl( nSpeed - 500, 0, maxSpeed ) / maxSpeed

		if cp > 0.4 then
			cp = 0.4
		end

		local font, velPos = "BottomHUDVelocity", 30
		local velocity = "Velocity: " .. fo( "%.0f u/s", nSpeed )
		if isSpectator and ob then
			font = "BottomHUDTime"
			velPos = 43
			velocity = fo( "%.0f u/s", nSpeed )
		end

		draw.SimpleText( velocity, font, ( ScrW() / 2 ), posY + velPos + 2, textBG, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		draw.SimpleText( velocity, font, ( ScrW() / 2 ), posY + velPos, textFG, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

		if wantsVelocityBar then
			draw.RoundedBox( 0, ( ScrW() / 2 ), ScrH() - 3, 0.4 * 206, 3, bColor )
			draw.RoundedBox( 0, ( ScrW() / 2 ), ScrH() - 3, ( cp * 206 ), 3, fColor )

			draw.RoundedBox( 0, ( ScrW() / 2 ) - ( 0.4 * 206 ) + 1, ScrH() - 3, ( 0.4 * 206 ), 3, fColor )
			draw.RoundedBox( 0, ( ScrW() / 2 ) - ( 0.4 * 206 ) + 1, ScrH() - 3, ( 0.4 * 206 ) - ( cp * 206 ), 3, bColor )
		end
	elseif (nGUI == 5) then
		local baseColor = Color( 0, 0, 0, 110 )
		local fullColor = Color( Custom.r, Custom.g, Custom.b )
		if (Accent == 1) then
			baseColor = Color( Custom.r, Custom.g, Custom.b, 30 )
		end

		local specPadding = ob and 145 or 95
		draw.RoundedBox( 8, SXo, ScrH() - SYo, 230, specPadding, baseColor )

		local cp = cl( nSpeed - 500, 0, maxSpeed ) / maxSpeed
		local currentPrestrafe = (!isSpectator) and (wantsPrestrafe and nCurrent > 0) and " (" .. prestrafe .. ")" or ""
		draw.SimpleText( fo( "%.0f u/s", nSpeed ) .. currentPrestrafe, "HUDSpeed", SXo + 115, ScrH() - SYo + 73, Color(255, 255, 255, SOv), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		if wantsVelocityBar then
			draw.RoundedBox( 0, SXo + 12, ScrH() - SYo + 83, cp * 206, 1, fullColor )
		end

		if ob then
			if ob:IsBot() then
				CSDraw.Player = ((bData and CSData.Bot) and CSData.Player or "No Bot Recorded") .. " ( " .. szStyle .. " )"
				CSDraw.PlayerInfo = "Spectating Bot - Runner:"
			else
				CSDraw.Player = ob:Name() .. " ( " .. szStyle .. " )"
				CSDraw.PlayerInfo = "Runner:"
			end

			draw.SimpleText( CSDraw.PlayerInfo, "HUDTimer", SXo + 115, ScrH() - SYo + 100, Color(255, 255, 255, SOv), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText( CSDraw.Player, "HUDTimer", SXo + 115, ScrH() - SYo + 125, Color(255, 255, 255, SOv), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

		local suffix = isPractice and " [P]" or ""
		if isSpectator and !ob then
			draw.SimpleText( "Free Roam Mode", "HUDTimer", SXo + 115, ScrH() - SYo + 20, Color(255, 255, 255, SOv), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			draw.SimpleText( "Use +reload to go back", "HUDTimer", SXo + 115, ScrH() - SYo + 45, Color(255, 255, 255, SOv), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		elseif isPractice and (nCurrent == 0) then
			local notify = "Do /noclip to move around!"
			if isSpectator then
				notify = "User is practicing"
			end

			draw.SimpleText( "Practice Mode", "HUDTimer", SXo + 115, ScrH() - SYo + 20, Color(255, 255, 255, SOv), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			draw.SimpleText( notify, "HUDTimer", SXo + 115, ScrH() - SYo + 45, Color(255, 255, 255, SOv), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		else
			draw.SimpleText( "Time:", "HUDTimer", SXo + 12, ScrH() - SYo + 20, Color(255, 255, 255, SOv), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
			draw.SimpleText( "PB:" , "HUDTimer", SXo + 12, ScrH() - SYo + 45, Color(255, 255, 255, SOv), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )

			draw.SimpleText( ConvertTime( nCurrent ) .. GetTimePiece( nCurrent, nStyle, nStageCompare ) .. suffix, "HUDTimer", SXo + 64 + 12, ScrH() - SYo + 20, Color(255, 255, 255, SOv), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
			draw.SimpleText( ConvertTime( nRecord ) .. GetTimePiece( nRecord, nStyle, nStageCompare ), "HUDTimer", SXo + 64 + 12, ScrH() - SYo + 45, Color(255, 255, 255, SOv), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		end
	else
		local cp = cl( nSpeed - 500, 0, maxSpeed ) / maxSpeed
		local currentPrestrafe = (!isSpectator) and (wantsPrestrafe and nCurrent > 0) and " (" .. prestrafe .. ")" or ""
		draw.SimpleText( fo( "%.0f u/s", nSpeed ) .. currentPrestrafe, "HUDSpeed", SXo + 115, ScrH() - SYo + 73, Color(255, 255, 255, SOv), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		if wantsVelocityBar then
			draw.RoundedBox( 0, SXo + 12, ScrH() - SYo + 83, cp * 206, 1, Color(255, 255, 255, SOv) )
		end

		if ob then
			if ob:IsBot() then
				CSDraw.Player = ((bData and CSData.Bot) and CSData.Player or "No Bot Recorded") .. " ( " .. szStyle .. " )"
				CSDraw.PlayerInfo = "Spectating Bot - Runner:"
			else
				CSDraw.Player = ob:Name() .. " ( " .. szStyle .. " )"
				CSDraw.PlayerInfo = "Runner:"
			end

			draw.SimpleText( CSDraw.PlayerInfo, "HUDTimer", SXo + 115, ScrH() - SYo + 100, Color(255, 255, 255, SOv), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			draw.SimpleText( CSDraw.Player, "HUDTimer", SXo + 115, ScrH() - SYo + 125, Color(255, 255, 255, SOv), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
		end

		local suffix = isPractice and " [P]" or ""
		if isSpectator and !ob then
			draw.SimpleText( "Free Roam Mode", "HUDTimer", SXo + 115, ScrH() - SYo + 20, Color(255, 255, 255, SOv), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			draw.SimpleText( "Use +reload to go back", "HUDTimer", SXo + 115, ScrH() - SYo + 45, Color(255, 255, 255, SOv), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		elseif isPractice and (nCurrent == 0) then
			local notify = "Do /noclip to move around!"
			if isSpectator then
				notify = "User is practicing"
			end

			draw.SimpleText( "Practice Mode", "HUDTimer", SXo + 115, ScrH() - SYo + 20, Color(255, 255, 255, SOv), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
			draw.SimpleText( notify, "HUDTimer", SXo + 115, ScrH() - SYo + 45, Color(255, 255, 255, SOv), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		else
			draw.SimpleText( "Time:", "HUDTimer", SXo + 12, ScrH() - SYo + 20, Color(255, 255, 255, SOv), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
			draw.SimpleText( "PB:" , "HUDTimer", SXo + 12, ScrH() - SYo + 45, Color(255, 255, 255, SOv), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )

			draw.SimpleText( ConvertTime( nCurrent ) .. GetTimePiece( nCurrent, nStyle, nStageCompare ) .. suffix, "HUDTimer", SXo + 64 + 12, ScrH() - SYo + 20, Color(255, 255, 255, SOv), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
			draw.SimpleText( ConvertTime( nRecord ) .. GetTimePiece( nRecord, nStyle, nStageCompare ), "HUDTimer", SXo + 64 + 12, ScrH() - SYo + 45, Color(255, 255, 255, SOv), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		end
	end

	local hasSideTimerEnabled = STATS:GetBool()
	if ViewSpec:GetBool() and (nGUI == 4) then
		local nOffset, bDrawn = nHeight - 55, false
		local nStart = nOffset
		local rDrawW = 175

		local amount = #CSList
		if (amount == 0) then return end

		local maxWidth = Interface:GetTextWidth( CSList, "BottomHUDTime" )
		if rDrawW < maxWidth then
			nWidth = nWidth - maxWidth
			rDrawW = rDrawW + maxWidth
		end

		local isCustom = CPrestige == 1
		local isAccented = Accent == 1
		local baseColor = isCustom and isAccented and Color( Custom.r, Custom.g, Custom.b, 30 ) or Color( 0, 0, 0, 150 )
		local textColor = isCustom and isAccented and Color( Custom.r, Custom.g, Custom.b, 50 ) or Color( 0, 0, 0, 255 )

		for _,name in pairs( CSList ) do
			surface.SetDrawColor( baseColor )
			surface.DrawRect( nWidth - 215 - Interface.Wide, nOffset - 5, rDrawW, 30 )

			draw.SimpleText( "- " .. name, "BottomHUDTime", nWidth - 200 - Interface.Wide, nOffset, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
			nOffset = nOffset - 30
			nStart = nOffset
			bDrawn = true
		end

		draw.RoundedBoxEx( 8, nWidth - 215 - Interface.Wide, nStart - 5, rDrawW, 30, bDrawn and textColor or Color(255, 255, 255, 0), true, true, false, false )
		draw.SimpleText( CSTitle, "BottomHUDTime", nWidth - 200 - Interface.Wide, nStart, bDrawn and Color(255, 255, 255) or Color(255, 255, 255, 0), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
	elseif ViewSpec:GetBool() and !hasSideTimerEnabled then
		-- Flow has a different paint function, let's not complicate things --

		local nStart = (nHeight + 30) / 2 - 50
		local nOffset, bDrawn = nStart + 20, false
		for _,name in pairs( CSList ) do
			if not bDrawn then
				draw.SimpleText( CSTitle, "HUDLabelSmall", nWidth - 165 - Interface.Wide, nStart, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
				bDrawn = true
			end

			draw.SimpleText( "- " .. name, "HUDLabelSmall", nWidth - 165 - Interface.Wide, nOffset, Color(255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
			nOffset = nOffset + 15
		end
	end
end


local szTime = ""
local timeleft = 0
local mapSelect = ""
local isVoting = false
net.Receive( "sl_sendtime", function()
	timeleft = net.ReadDouble()
	mapSelect = net.ReadString()
	isVoting = net.ReadBool()
end )

-- Rewriting this because of previous issues --
local function surf_PaintSideTimer()
	if (engine.IsPlayingDemo()) then return end

	local wantsPaint = STATS:GetBool()
	local wantsRight = STATS_POS:GetBool()
	local wantsHints = GetConVar "sl_command_suggest"
	if !wantsPaint then return end

	local lpc = lp()
	if !wantsRight and Window:GetActive() then return end
	-- This will prevent the SideTimer from showing up when typing out commands while hints are active --
	if wantsHints and !wantsRight and CustomChat and chat.IsOpen() and chat.HasHintsDisplayed() then return end

	local nStyle = 1
	local nStage = 0
	local isOpenArea = false

	local tab = {}

	szTime = "Timeleft: 0 minutes"
	if (mapSelect != "") then
		szTime = "Changing Map: " .. mapSelect
	elseif isVoting then
		szTime = "Voting for next map..."
	else
		szTime = "Timeleft: " .. string.NiceTime( timeleft - CurTime() )
	end

	tab[1] = szTime
	tab[2] = game.GetMap() .. " (Tier " .. mTier .. " - " .. _C.MapTypes[ mType ] .. ")"

	-- Doing this because why not --
	local isSpectating = (lpc:Team() == ts)
	local ob = isSpectating and lpc:GetObserverTarget()
	local target = IsValid(ob) and ob or lpc
	local isBot = target:IsBot()
	local isAFK = target:GetNWBool("sm_afk", false)

	nStyle 			= target:GetNWInt 	"Style"
	nStage 			= target:GetNWInt 	"Stage"
	isOpenArea 	= target:GetNWBool 	"StageOpenArea"

	local mapBest 	= target:GetNWFloat "Record"
	local stageBest = target:GetNWFloat "StageRecord"

	local hasMapBest = (mapBest > 0)
	local hasStageBest = (stageBest > 0)

	local mapRecord = 0
	local mapRecordHolder = ""

	local isStaged = (mType == 1) and (nStage > 0)
	local isStagedStyle = (nStyle > 14 and nStyle < 40)
	if isStagedStyle then
		nStyle = 1
	end

	local styleName = Core:StyleName( nStyle )
	local isBonus = string.StartWith( styleName, "Bonus" )
	if !isSpectating then
		styleName = Core:StyleName( Timer.Style )
		isBonus = string.StartWith( Core:StyleName( Timer.Style ), "Bonus" )
	end

	local stillLoading = !stRecord and !stPBRecord
	if stillLoading then
		tab[4] = "Retrieving data from server..."
	elseif (!isBot) then
		mapRecord = stRecord[nStyle] and stRecord[nStyle][1] or 0
		mapRecordHolder = stRecord[nStyle] and stRecord[nStyle][2] or ""

		if istable( mapRecord ) then
			mapRecord = stRecord[nStyle] and stRecord[nStyle][nStage] and stRecord[nStyle][nStage][1] or 0
			mapRecordHolder = stRecord[nStyle] and stRecord[nStyle][nStage] and stRecord[nStyle][nStage][2] or ""
		elseif isstring( mapRecord ) then
			mapRecord = stRecord[nStyle] and stRecord[nStyle][3] or 0
			mapRecordHolder = stRecord[nStyle] and stRecord[nStyle][2] or ""
		end
	end

	if isOpenArea then
		tab[4] = "- Stage Freezone -"
		tab[5] = "Advance to the next stage zone"
		tab[6] = "to view stage info"
	elseif (!isBot) then
		local pbDisplay = "None"
		local pbDifference = ""

		local wrDisplay = "None"
		local wrHolder = ""

		if isStaged and !isBonus then
			tab[4] = "- Stage " .. nStage .. " -"

			if hasStageBest then
				pbDisplay = Timer:Convert( stageBest )

				if (mapRecord != 0) then
					local difference = math.Round( stageBest - mapRecord, 3 )
					pbDifference = difference > 0 and (" (+" .. Timer:Convert( math.abs( difference ) ) .. ")" ) or ""
				end
			end

			if (mapRecord != 0) then
				wrDisplay = Timer:Convert( mapRecord )
				wrHolder = " (" .. mapRecordHolder .. ")"
			end

			local pbPrefix = (isSpectating and "Player's Best: " or "Personal Best: ")
			local wrPrefix = "WRCP: "

			tab[5] = pbPrefix .. pbDisplay .. pbDifference
			tab[6] = wrPrefix .. wrDisplay .. wrHolder
		else
			local tStart = 4
			if isBonus then
				tab[4] = "- " .. styleName .. " -"
				tStart = 5
			end

			if hasMapBest then
				pbDisplay = Timer:Convert( mapBest )

				if (mapRecord != 0) then
					local difference = math.Round( mapBest - mapRecord, 3 )
					pbDifference = difference > 0 and (" (+" .. Timer:Convert( math.abs( difference ) ) .. ")" ) or ""
				end
			end

			if (mapRecord != 0) then
				wrDisplay = Timer:Convert( mapRecord )
				wrHolder = " (" .. mapRecordHolder .. ")"
			end

			local pbPrefix = (isSpectating and "Player's Best: " or "Personal Best: ")
			local wrPrefix = isBonus and "WRB: " or "WR: "

			tab[tStart] = pbPrefix .. pbDisplay .. pbDifference
			tab[tStart + 1] = wrPrefix .. wrDisplay .. wrHolder
		end
	end

	-- The prestige theme has it's own spectator panel, don't overlap it --
	local isPrestige = (nGUI == 4)
	local wantsSpectators = ViewSpec:GetBool()
	if wantsSpectators and !isPrestige then
		local baseLine = #tab
		local bDraw = false

		local i = 1
		for _,name in pairs( CSList ) do
			if !bDraw then
				tab[baseLine + 2] = CSTitle
				bDraw = true
			end

			tab[i + baseLine + 2] = name
			i = i + 1
		end
	end

	if isAFK then
		tab[#tab + 2] = (isSpectating and "This player is" or "You are") .. " currently AFK"
	end

	local bezel = Interface:GetBezel( "Big" )
	local font = Interface:GetFont()
	local fontHeight = (Interface.FontHeight[Interface.Scale] / 1.5)

	local width, _ = Interface:GetTextWidth( tab ), Interface:GetTextHeight( tab )
	local basePos = wantsRight and (ScrW() - width - bezel - Interface.Wide) or bezel + Interface.Wide

	local sWidth, sHeight = basePos, (ScrH() / 2) - (fontHeight * #tab / 2)
	for line, text in pairs( tab ) do
		draw.SimpleText( text, font, sWidth + 2, sHeight + ( fontHeight * line ) + 2, color_black, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		draw.SimpleText( text, font, sWidth, sHeight + ( fontHeight * line ), color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
	end
end
hook.Add( "HUDPaint", "PaintSideTimer", surf_PaintSideTimer )

local newSpeed, lastSpeed = 0, 0
local ticksNoSpeed, speedOpacity = 0, 255
local lastUpdated, lastColor = nil, color_white
local function HUDPaintCenterSpeed()
	if (engine.IsPlayingDemo()) then return end

	if !CenterSpeed:GetBool() then return end
	if OldCenterSpeed:GetBool() then
		local lpc = lp()
		local isSpec = (lpc:Team() == ts)
		local ob = isSpec and lpc:GetObserverTarget()

		local wants3D = Velocity:GetBool()
		if ob and IsValid( ob ) then
			local nSpeed = ob:GetVelocity()
			if wants3D then nSpeed = nSpeed:Length2D() else nSpeed = nSpeed:Length() end

			newSpeed = nSpeed
		else
			local nSpeed = lpc:GetVelocity()
			if wants3D then nSpeed = nSpeed:Length2D() else nSpeed = nSpeed:Length() end

			newSpeed = nSpeed
		end

		newSpeed = math.Round( newSpeed )

		local midWidth, midHeight = ScrW() / 2, ScrH() / 3
		draw.SimpleText( newSpeed .. " u/s", "HUDHeader", midWidth + 2, midHeight + 2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	return end

	local exceededMaxvel = (newSpeed > 10000)
	if exceededMaxvel then
		newSpeed = 0
	end

	local didGain = (newSpeed > (lastSpeed + 1))
	local didLose = (newSpeed < (lastSpeed - 1))

	local midWidth, midHeight = ScrW() / 2, ScrH() / 4
	local font = Interface:GetBigFont()

	if lastUpdated and CurTime() < (lastUpdated + 0.060) then
		draw.SimpleText( newSpeed .. " u/s", font, midWidth + 2, midHeight + 2, Color( 0, 0, 0, speedOpacity ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		draw.SimpleText( newSpeed .. " u/s", font, midWidth, midHeight, lastColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	return end

	lastUpdated = CurTime()

	local lpc = lp()
	local isSpec = (lpc:Team() == ts)
	local ob = isSpec and lpc:GetObserverTarget()

	local wants3D = Velocity:GetBool()
	if ob and IsValid( ob ) then
		local nSpeed = ob:GetVelocity()
		if wants3D then nSpeed = nSpeed:Length2D() else nSpeed = nSpeed:Length() end

		newSpeed = nSpeed
	else
		local nSpeed = lpc:GetVelocity()
		if wants3D then nSpeed = nSpeed:Length2D() else nSpeed = nSpeed:Length() end

		newSpeed = nSpeed
	end

	newSpeed = math.Round( newSpeed )

	didGain = (newSpeed > (lastSpeed + 1))
	didLose = (newSpeed < (lastSpeed - 1))
	centerColor = didGain and Color( 0, 255, 255, speedOpacity ) or didLose and Color( 255, 0, 0, speedOpacity ) or Color( 255, 255, 255, speedOpacity )
	lastColor = centerColor

	draw.SimpleText( newSpeed .. " u/s", font, midWidth + 2, midHeight + 2, Color( 0, 0, 0, speedOpacity ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	draw.SimpleText( newSpeed .. " u/s", font, midWidth, midHeight, centerColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

	if (newSpeed == 0) then
		ticksNoSpeed = ticksNoSpeed + 1
	else
		ticksNoSpeed = 0
	end

	if ticksNoSpeed > 15 then
		speedOpacity = speedOpacity - 15
	else
		speedOpacity = 255
	end

	lastSpeed = newSpeed
end
hook.Add( "HUDPaint", "PaintCenterSpeed", HUDPaintCenterSpeed )

local graphUpdated = nil
local currentFPS, currentPing = 0, 0

local netGraphPos = {
	[0] = { ScrW() - 90, 15 },
	[1] = { 15, 15 },
	[2] = { 15, ScrH() - 45 },
	[3] = { ScrW() - 90, ScrH() - 45 },
}

local function HUDPaintNetGraph()
	if (engine.IsPlayingDemo()) then return end

	local wantsSimpleGraph = SimpleNG:GetBool()
	if !wantsSimpleGraph then return end

	local lpc = lp()
	local netPos = LocationNG:GetInt()
	local x, y = unpack( netGraphPos[netPos] )

	local fpsColor = (currentFPS < 144 and Color( 255, 0, 0, 180 )) or (currentFPS < 144 and Color( 255, 255, 0, 180 )) or Color( 255, 255, 255, 180 )
	local pingColor = (currentPing > 120 and Color( 255, 0, 0, 180 )) or (currentPing > 70 and Color( 255, 255, 0, 180 )) or Color( 255, 255, 255, 180 )

	if graphUpdated and CurTime() < (graphUpdated + 0.6) then
		draw.SimpleText( "FPS: ", "HUDTimer", x, y, fpsColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		draw.SimpleText( "Ping: ", "HUDTimer", x, y + 15, pingColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )

		draw.SimpleText( currentFPS, "HUDTimer", x + 75, y, fpsColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
		draw.SimpleText( currentPing, "HUDTimer", x + 75, y + 15, pingColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
	return end

	currentFPS = math.Round( 1 / RealFrameTime() )
	currentPing = lpc:Ping()
	graphUpdated = CurTime()

	draw.SimpleText( "FPS: ", "HUDTimer", x, y, fpsColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
	draw.SimpleText( "Ping: ", "HUDTimer", x, y + 15, pingColor, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )

	draw.SimpleText( currentFPS, "HUDTimer", x + 75, y, fpsColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
	draw.SimpleText( currentPing, "HUDTimer", x + 75, y + 15, pingColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
end
hook.Add( "HUDPaint", "PaintNetGraph", HUDPaintNetGraph )

local function HUDPaintCheckpoint()
	if (engine.IsPlayingDemo()) then return end

	local wantsCheckpointHUD = CPHUD:GetBool()
	if !wantsCheckpointHUD then return end

	if (CurTime() > cpDisplay + 5) then
		cpColor = ColorAlpha(cpColor, cpColor.a - 1)
	end

	local font = Interface:GetBigFont()
	local fontHeight = draw.GetFontHeight(font)
	local midWidth, midHeight = ScrW() / 2, ScrH() / 3 + fontHeight

	draw.SimpleText("Checkpoint " .. cpIndex .. ": " .. Timer:Convert(cpTime), font, midWidth, midHeight, cpColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.SimpleText(cpDiff, font, midWidth, midHeight + fontHeight, cpColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end
hook.Add("HUDPaint", "sm_cphud", HUDPaintCheckpoint)
