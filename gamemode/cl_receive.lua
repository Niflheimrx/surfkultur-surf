Cache = {}

Cache.T_Data = {
	[_C.Style.Normal] = {},
	[_C.Style.Sideways] = {},
	[_C.Style["Half-Sideways"]] = {},
	[_C.Style["100 Tick"]] = {},
	[_C.Style["33 Tick"]] = {},
	[_C.Style.Wicked] = {},
	[_C.Style.Bonus] = {},
	[_C.Style["Bonus 2"]] = {},
	[_C.Style["Bonus 3"]] = {},
	[_C.Style["Bonus 4"]] = {},
	[_C.Style["Bonus 5"]] = {},
	[_C.Style["Bonus 6"]] = {},
	[_C.Style["Bonus 7"]] = {},
	[_C.Style["Bonus 8"]] = {},
	[_C.Style["Bonus 9"]] = {},
	[_C.Style["Bonus 10"]] = {},
}

Cache.ST_Data = {
	[1] = {},
	[2] = {},
	[3] = {},
	[4] = {},
	[5] = {},
	[6] = {},
	[7] = {},
	[8] = {},
	[9] = {},
	[10] = {},
	[11] = {},
	[12] = {},
	[13] = {},
	[14] = {},
	[15] = {},
	[16] = {},
	[17] = {},
	[18] = {},
	[19] = {},
	[20] = {},
	[21] = {},
	[22] = {},
	[23] = {},
	[24] = {},
}
Cache.T_Mode = _C.Style.Normal

Cache.M_Data = {}
Cache.M_Version = 0
Cache.M_Name = _C.Identifier .. "-surf.txt"

Cache.S_Data = { Contains = nil, Bot = false, Player = "Unknown", Start = nil, Record = nil }
Cache.V_Data = {}
Cache.R_Data = {}
Cache.L_Data = {}
Cache.C_Data = {}
Cache.H_Data = {}

CL = {
	Yellow = Color( 228, 244, 111 ),
	White = Color( 255, 255, 255 ),
	Blue = Color( 142, 235, 250 ),
	Purple = Color( 229, 162, 241 ),
	Green = Color( 0, 255, 155 ),
	Orange = Color( 241, 191, 79 ),
}

local CS_LocalList = {}
local CS_RemoteList = {}
local CS_Type = 3

local function CS_Clear()
	CS_LocalList = {}
	CS_RemoteList = {}

	Cache.S_Data = { Contains = nil, Bot = false, Player = "Unknown", Start = nil, Record = nil }
	CS_Type = 3

	Timer:SpectateUpdate()
	Timer:SpectateData( {}, true, 0, true )
end

local function CS_Mode( nMode )
	CS_Type = nMode
	if CS_Type == 3 then
		CS_Clear()
	end
end

local function CS_Remote( varList )
	CS_RemoteList = varList
	Timer:SpectateData( varList, true, #varList )
end

local function CS_Viewer( bLeave, szName, szUID )
	if not bLeave then
		if not CS_LocalList[ szUID ] or CS_LocalList[ szUID ] != szName then
			CS_LocalList[ szUID ] = szName
		end
	else
		if CS_LocalList[ szUID ] then
			CS_LocalList[ szUID ] = nil
		end
	end

	local nCount = 0
	for _,s in pairs( CS_LocalList ) do
		nCount = nCount + 1
	end

	Timer:SpectateData( CS_LocalList, false, nCount )
end

local function CS_Player( nTimer, nRecord, nServer, varList, sTimer )
	if nServer then Timer:Sync( nServer ) end
	if varList then if type( varList ) == "table" and #varList > 0 then CS_Remote( varList ) end else CS_Remote( {} ) end

	Cache.S_Data.Bot = false
	Cache.S_Data.Start = nTimer and nTimer + Timer:GetDifference() or nil
	Cache.S_Data.Best = nRecord or 0
	Cache.S_Data.StageStart = sTimer and sTimer or nil
	Cache.S_Data.Contains = true
	Timer:SpectateUpdate()
end

local function CS_Bot( nTimer, szName, nRecord, nServer, varList )
	if nServer then Timer:Sync( nServer ) end
	if varList then if type( varList ) == "table" and #varList > 0 then CS_Remote( varList ) end else CS_Remote( {} ) end

	Cache.S_Data.Bot = true
	Cache.S_Data.Player = szName or "Bot"
	Cache.S_Data.Start = nTimer and nTimer + Timer:GetDifference() or nil
	Cache.S_Data.Best = nRecord or 0
	Cache.S_Data.Contains = true
	Timer:SpectateUpdate()
end


function Cache:S_GetType()
	return CS_Type
end

function Cache:M_Load()
	local data = file.Read( Cache.M_Name, "DATA" )
	local version = tonumber( string.sub( data, 1, 5 ) )
	if not version then return end
	local remain = util.Decompress( string.sub( data, 6 ) )
	if not remain then return end
	local tab = util.JSONToTable( remain )

	if #tab > 0 then
		Cache.M_Version = version
		Cache.M_Data = tab
		Cache:M_Update()
	end
end

function Cache:M_Save( varList, nVersion, bOpen )
	Cache.M_Data = varList or {}
	Cache.M_Version = nVersion
	Cache:M_Update()

	if #Cache.M_Data > 0 then
		local data = util.Compress( util.TableToJSON( Cache.M_Data ) )
		if not data then return end

		file.Write( Cache.M_Name, string.format( "%.5d", nVersion ) .. data )
		if bOpen then
			Window:Open( "Nominate", { nVersion } )
		end
	else
		Window:Close()
	end
end

function Cache:M_Update()
	for i,d in pairs( Cache.M_Data ) do
		Cache.M_Data[ i ][ 2 ] = tonumber( d[ 2 ] )
	end
end

function Cache:V_Update( varList )
	if Window:IsActive( "Vote" ) then
		local wnd = Window:GetActive()
		wnd.Data.Votes = varList
		wnd.Data.Update = true
	end
end

function Cache:V_InstantVote( nID )
	if Window:IsActive( "Vote" ) then
		local wnd = Window:GetActive()
		wnd.Data.InstantVote = nID
	end
end

function Cache:V_VIPExtend()
	if Window:IsActive( "Vote" ) then
		local wnd = Window:GetActive()
		wnd.Data.EnableExtend = true
	end
end

function Cache:L_Check( szMap )
	if not Cache.L_Data or #Cache.L_Data == 0 then return false end

	for _,data in pairs( Cache.L_Data ) do
		if data[ 1 ] == szMap then
			return true
		end
	end

	return false
end


Link = {}
Link.Protocol = "SecureTransfer"
Link.Protocol2 = "BinaryTransfer"


function Link:Print( szPrefix, varText )
	if not varText then return end
	if type( varText ) != "table" then varText = { varText } end

	if GetConVar( "sl_printchat" ):GetInt() == 1 then
		chat.AddText( _C.Prefixes[ szPrefix ], "[", szPrefix, "] - ", GUIColor.White, unpack( varText ) )
	else
		print( "[" .. szPrefix .. "] " .. unpack( varText ) )
	end
end

function Link:Send( szAction, varArgs )
	net.Start( Link.Protocol )
	net.WriteString( szAction )

	if varArgs and type( varArgs ) == "table" then
		net.WriteBit( true )
		net.WriteTable( varArgs )
	else
		net.WriteBit( false )
	end

	net.SendToServer()
end


local function TransferHandle( szAction, varArgs )
	if szAction == "GUI_Open" then
		Window:Open( tostring( varArgs[ 1 ] ), varArgs[ 2 ] )
	elseif szAction == "GUI_Update" then
		Window:Update( tostring( varArgs[ 1 ] ), varArgs[ 2 ] )
	elseif szAction == "Playercard" then
		if varArgs and varArgs[1] then
			Playercard:Update( varArgs[1] )
		else
			Playercard:Open()
		end
	elseif szAction == "MakeBot" then
		if varArgs and varArgs[1] then
			MakeBot:Update( varArgs[1] )
		else
			MakeBot:Open()
		end
	elseif szAction == "SurfTop" then
		if varArgs and varArgs[1] then
			SurfTop:Update( varArgs[1], varArgs[2] )
		else
			SurfTop:Open()
		end
	elseif szAction == "RecentRecords" then
		if varArgs and varArgs[1] then
			RecentRecords:Update( varArgs[1], varArgs[2] )
		else
			RecentRecords:Open()
		end
	elseif szAction == "SurfTimer" then
		local isLegacy = varArgs[1]
		if isLegacy then
			SurfTimerLegacy()
		else
			SurfTimer:Open()
		end
	elseif szAction == "MyRecords" then
		if varArgs and varArgs[1] then
			MyRecords:Update( varArgs[1], varArgs[2], varArgs[3] )
		else
			MyRecords:Open()
		end
	elseif szAction == "TopRecords" then
		if varArgs and varArgs[1] then
			TopRecords:Update( varArgs[1], varArgs[2] )
		else
			TopRecords:Open()
		end
	elseif szAction == "Help" then
		local wantsRules = varArgs[1]
		if wantsRules then
			Help:OpenRules()
		else
			Help:Open()
		end
	elseif szAction == "Cheats" then
		local decider = varArgs[1]
		if decider == "Fullbright" then
			Cheats.ToggleFullbright()
		elseif decider == "Playerclips" then
			Cheats.TogglePlayerclips()
		elseif decider == "DebugTrace" then
			local hasData = varArgs[2]
			if hasData then
				Cheats:ReceiveIndex( hasData )
			return end

			Cheats.ToggleDebugTrace()
		end
	elseif szAction == "SideTimer" then
		local isOnlyRec = !varArgs[1]
		local isOnlyUpdate = (!varArgs[2] and !varArgs[3])

		if isOnlyRec then
			Timer:SetSideTimerInitialData( varArgs[2] )
		elseif isOnlyUpdate then
			Timer:SetSideTimerMapData( varArgs[1], varArgs[4] )
		else
			Timer:SetSideTimerData( varArgs[1], varArgs[2], varArgs[3], varArgs[4] )
		end
	elseif szAction == "Style" then
		StyleSelect.Open()
	elseif szAction == "Sound" then
		WRSound.Play( tonumber(varArgs[1]), tonumber(varArgs[2]), tonumber(varArgs[3]) )
	elseif szAction == "Prestrafe" then
		local currentPrestrafe = varArgs[1]
		Timer:SetPrestrafe( currentPrestrafe )
	elseif szAction == "Print" then
		Link:Print( tostring( varArgs[ 1 ] ), tostring( varArgs[ 2 ] ) )
	elseif szAction == "Timer" then
		local timerMode = varArgs[1]
		if !timerMode then
			Surf:Notify( "Error", "Failed to fetch modetype for Timer" )
		return end

		local timerAction, timerData = varArgs[2], varArgs[3]
		if !timerAction then
			Surf:Notify( "Error", "Failed to fetch actiontype for Timer" )
		return end

		if (timerMode == "Map") then
			if (timerAction == "Start") then
				Timer:SetStart( timerData )
			elseif (timerAction == "Finish") then
				Timer:SetFinish( timerData )
			end
		elseif (timerMode == "Stage") then
			if (timerAction == "Start") then
				Timer:SetStageStart( timerData )
			elseif (timerAction == "Finish") then
				Timer:SetStageFinish( timerData )
			end
		elseif (timerMode == "Initial") then
			Timer:SetInitial( timerAction )
		elseif (timerMode == "Record") then
			Timer:SetRecord( timerAction )
		elseif (timerMode == "Style") then
			Timer:SetStyle( timerAction )
		elseif (timerMode == "Prestrafe") then
			Timer:SetPrestrafe( timerAction )
		elseif (timerMode == "Checkpoint") then
			Timer:SetCheckpointHUD(tonumber(varArgs[2]), tonumber(varArgs[3]), tonumber(varArgs[4]))
		end
	elseif szAction == "Client" then
		local szType = tostring( varArgs[ 1 ] )

		if szType == "HUDEditToggle" then
			Timer:ToggleEdit()
		elseif szType == "HUDEditRestore" then
			Timer:RestoreTo( varArgs[ 2 ] )
		elseif szType == "HUDOpacity" then
			Timer:SetOpacity( varArgs[ 2 ] )
		elseif szType == "Crosshair" then
			Client:ToggleCrosshair( varArgs[ 2 ] )
		elseif szType == "TargetIDs" then
			Client:ToggleTargetIDs()
		elseif szType == "PlayerVisibility" then
			Client:PlayerVisibility( tonumber( varArgs[ 2 ] ) )
		elseif szType == "Chat" then
			Client:ToggleChat()
		elseif szType == "SurflineSound" then
			Client:SurflineSound()
		elseif szType == "EmitSound" then
			Client:EmitSound()
		elseif szType == "Mute" then
			Client:Mute( varArgs[ 2 ] )
		elseif szType == "SpecVisibility" then
			Client:SpecVisibility( varArgs[ 2 ] )
		elseif szType == "GUIVisibility" then
			Timer:GUIVisibility( tonumber( varArgs[ 2 ] ) )
		elseif szType == "ZoneVisibility" then
			Client:ZoneVisibility()
		elseif szType == "ZoneAltVisibility" then
			Client:ZoneAltVisibility()
		elseif szType == "Prestrafe" then
			Client:TogglePrestrafe()
		elseif szType == "DevTools" then
			DevTools:Open()
		elseif szType == "CustomSkin" then
			SurfTimer.OpenCustomMenu()
		elseif szType == "Zone" then
			CreateZone()
		elseif szType == "PanelData" then
			LoadPanelProperties()
		elseif szType == "PrintMessages" then
			Client:ToggleMessages()
		elseif szType == "Velocity" then
			Client:ToggleVelocity()
		elseif szType == "ShowKeys" then
			Client:ToggleKeys()
		elseif szType == "TotalTime" then
			Client:ToggleTotalTime()
		elseif szType == "ScoreOpacity" then
			Score:SetOpacity( varArgs[ 2 ] )
		elseif szType == "ScoreBlur" then
			Client:BlurVisibility( tonumber( varArgs[ 2 ] ) )
		elseif szType == "GlobalCheckpoints" then
			Client:ToggleGlobalCheckpoints()
		elseif szType == "Water" then
			Client:ChangeWater()
		elseif szType == "Decals" then
			Client:ClearDecals()
		elseif szType == "Sky" then
			Client:Set3DSky()
		elseif szType == "Theme" then
			Client:ToggleTheme()
		elseif szType == "ThemeChoice" then
			Client:ThemePick( varArgs[ 2 ] )
		elseif szType == "Enumerator" then
			Client:DecimalEnumerate()
		elseif szType == "Reveal" then
			Client:ToggleReveal()
		elseif szType == "Tutorial" then
			gui.OpenURL( varArgs[ 2 ] )
		elseif szType == "Display" then
			Timer:SetCPSData( varArgs[ 2 ] )
		elseif szType == "WeaponFlip" then
			Client:FlipWeapons( varArgs[ 2 ] )
		elseif szType == "Space" then
			Client:ToggleSpace( varArgs[ 2 ] )
		elseif szType == "Thirdperson" then
			Client:ToggleThirdperson()
		elseif szType == "Server" then
			Client:ServerSwitch( varArgs[ 2 ] )
		elseif szType == "Emote" then
			Client:ShowEmote( varArgs[ 2 ] )
		elseif szType == "KnifeName" then
			Client:WeaponName()
		elseif szType == "Shop" then
			LocalPlayer():ConCommand( "ps_shop" )
		end
	elseif szAction == "Spectate" then
		local szType = tostring( varArgs[ 1 ] )

		if szType == "Clear" then
			CS_Clear()
		elseif szType == "Mode" then
			CS_Mode( tonumber( varArgs[ 2 ] ) )
		elseif szType == "Viewer" then
			CS_Viewer( varArgs[ 2 ], varArgs[ 3 ], varArgs[ 4 ] )
		elseif szType == "Timer" then
			if varArgs[ 2 ] then
				CS_Bot( varArgs[ 3 ], varArgs[ 4 ], varArgs[ 5 ], varArgs[ 6 ], varArgs[ 7 ] )
			else
				CS_Player( varArgs[ 3 ], varArgs[ 4 ], varArgs[ 5 ], varArgs[ 6 ], varArgs[ 7 ] )
			end
		end
	elseif szAction == "RTV" then
		local szType = tostring( varArgs[ 1 ] )

		if szType == "GetList" then
			Cache.V_Data = varArgs[ 2 ] or {}
			Window:Open( "Vote" )
		elseif szType == "VoteList" then
			Cache:V_Update( varArgs[ 2 ] )
		elseif szType == "InstantVote" then
			Cache:V_InstantVote( varArgs[ 2 ] )
		elseif szType == "VIPExtend" then
			Cache:V_VIPExtend()
		end
	elseif szAction == "Manage" then
		local szType = tostring( varArgs[ 1 ] )

		if szType == "Mute" then
			Client:DoChatMute( varArgs[ 2 ], varArgs[ 3 ] )
		elseif szType == "Gag" then
			Client:DoVoiceGag( varArgs[ 2 ], varArgs[ 3 ] )
		end
	elseif szAction == "Checkpoints" then
		local szType = tostring( varArgs[ 1 ] )

		if szType == "Open" then
			Window:Open( "Checkpoints" )
		elseif szType == "Update" then
			Timer:SetCheckpoint( varArgs[ 2 ], varArgs[ 3 ], varArgs[ 4 ] )
		elseif szType == "Delay" then
			Timer:StartCheckpointDelay()
		end
	elseif szAction == "Admin" then
		Admin:Receive( varArgs )
	end
end

local function TransferReceive()
	local szAction = net.ReadString()
	local bTable = net.ReadBit() == 1
	local varArgs = {}

	if bTable then
		varArgs = net.ReadTable()
	end

	TransferHandle( szAction, varArgs )
end
net.Receive( Link.Protocol, TransferReceive )

-- Works similarly below, but will work outside of network messages --
function Link:ProcessMessage( ... )
	local message = { ... }
	if !message then return end

	local formattableColors = {
		["#CL.Yellow#"] = CL.Yellow,
		["#CL.Blue#"] 	= CL.Blue,
		["#CL.White#"] 	= CL.White,
		["#CL.Purple#"] = CL.Purple,
		["#CL.Green#"] 	= CL.Green,
		["#CL.Orange#"] = CL.Orange,
	}

	local tab = {}
	for _,data in pairs( message ) do
		local readable = data
		if isstring(readable) and formattableColors[readable] then
			readable = formattableColors[readable]
		end

		table.insert( tab, readable )
	end

	Link:Print( "Surf Timer", tab )
end

net.Receive( "sm_message", function()
	local formattableColors = {
		["#CL.Yellow#"] = CL.Yellow,
		["#CL.Blue#"] 	= CL.Blue,
		["#CL.White#"] 	= CL.White,
		["#CL.Purple#"] = CL.Purple,
		["#CL.Green#"] 	= CL.Green,
		["#CL.Orange#"] = CL.Orange,
	}

	local function readChatTable()
		local function read(n)
			if n == 0 then return end
			local isColor = net.ReadBool()
			local readable
			if isColor then
				readable = net.ReadColor()
			else
				readable = net.ReadString()
				if formattableColors[readable] then
					readable = formattableColors[readable]
				end
			end
			return readable, read(n - 1)
		end

		return read(net.ReadUInt(8))
	end

	Link:Print( "Surf Timer", { readChatTable() } )
end )

net.Receive( "sm_messagebase", function()
	local formattableColors = {
		["#CL.Yellow#"] = CL.Yellow,
		["#CL.Blue#"] 	= CL.Blue,
		["#CL.White#"] 	= CL.White,
		["#CL.Purple#"] = CL.Purple,
		["#CL.Green#"] 	= CL.Green,
		["#CL.Orange#"] = CL.Orange,
	}

	local function readChatTable()
		local function read(n)
			if n == 0 then return end
			local isColor = net.ReadBool()
			local readable
			if isColor then
				readable = net.ReadColor()
			else
				readable = net.ReadString()
				if formattableColors[readable] then
					readable = formattableColors[readable]
				end
			end
			return readable, read(n - 1)
		end

		return read(net.ReadUInt(8))
	end

	chat.AddText( CL.Orange, unpack( { readChatTable() } ) )
end )
