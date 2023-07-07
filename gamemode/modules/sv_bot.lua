-- If your desire is to only use this module, please leave credits somewhere in your gamemode.

Bot = {}
Bot.RecordAll = true -- Set this to true if you have a really good server; it'll record everyone, always, unless they type !bot remove
Bot.AlwaysDisplayFirst = true -- If you set this to true as well, they can't even use !bot remove, thus the bot will always display the best time (ONLY EFFECTIVE if Bot.RecordAll is set to true)
Bot.Maximum = Bot.RecordAll and 64 or 9
Bot.MinimumTime = 90

local BotPlayer = {}
local BotFrame = {}
local BotFrames = {}
local BotData = {}
local BotInfo = {}

local Queue = {}
local Players = {}

local Recording = {}
local StageRecording = {}

local Frame = {}
local StageFrame = {}

local Pause = {}
local StagePause = {}

local ct = CurTime

local vON = include "sv_von.lua"
local runsLoaded = false

-- Initialization and control
function Bot:Setup()
	BotPlayer = {}
	BotFrame = {}
	BotFrames = {}
	BotInfo = {}
	BotData = {}

	if not file.Exists( _C.GameType .. "/bots/revisions", "DATA" ) then
		file.CreateDir( _C.GameType .. "/bots/revisions" )
	end

	Bot.PerStyle = {}
end

function Bot:LoadData()
	-- We are using MySQL to load the data now --
	local map = game.GetMap()
	local benchStart, benchEnd = RealTime()

	SQL:Prepare(
		"SELECT * FROM (SELECT * FROM game_bots WHERE szMap = {0}) t1 INNER JOIN game_playerinfo ON t1.szSteam = game_playerinfo.szUID",
		{ map }
	):Execute( function( Result, _, szError )
		if Core:Assert( Result, "nTime" ) then
			for _,Info in pairs( Result ) do
				local name = Info["szLastName"]
				local style = Info["nStyle"]
				local time = Info["nTime"]
				local steam = Info["szSteam"]
				local date = Info["szDate"]
				local buffer = Info["szBuffer"]

				BotData[ style ] = vON.deserialize( buffer )
				BotFrame[ style ] = 1
				BotFrames[ style ] = #BotData[ style ][ 1 ]
				BotInfo[ style ] = { Name = name, Time = time, Style = style, SteamID = steam, Date = date, Saved = true, Start = ct(), CompletedRun = true }

				Bot:SetMultiBot( style )
			end
		end

		benchEnd = RealTime()

		runsLoaded = true
		Surf:Notify( "Debug", "Loaded " .. (#BotInfo or 0) .. " bot records [Normal: " .. (BotInfo[1] and BotInfo[1].Name or "None") .. "] [Delay: " .. math.Round( benchEnd - benchStart, 2 ) * 10 .. "ms]" )
	end )
end

-- Updated 05/11/2020 to use new saving method + backups --
function Bot:EndRun( ply, nTime, bStage )
	if !IsValid( ply ) then
		Surf:Notify( "Error", "Failed to retrieve bot/player info during EndRun" )
	return end

	local isPractice = ply:GetNWBool "Practice"
	if isPractice then return end

	local hasRecording = Recording[ply] and Recording[ply][1] and (#Recording[ply][1] != 0)
	if !hasRecording then
		Surf:Notify( "Error", "Failed to retrieve run buffer during EndRun" )
	return end

	local validTime = nTime and nTime > 0
	if !validTime then
		Surf:Notify( "Error", "Failed to retrieve record time during EndRun" )
	return end

	local style = ply.CachedStyle
	local recordTime = BotInfo[style] and BotInfo[style].Time

	local didBeat = !recordTime or nTime < recordTime
	if !didBeat then return end

	Core:SendColor( ply, "Your ", CL.Yellow, Core:StyleName( style ), CL.White, " run (Time: ", CL.Blue, Timer:Convert( nTime ), CL.White, ") has been recorded and is set to be shown on the bot!" )

	BotData[ style ] = Recording[ ply ]
	BotFrame[ style ] = 1
	BotFrames[ style ] = #BotData[ style ][ 1 ]
	BotInfo[ style ] = { Name = ply:Name(), Time = nTime, Style = style, SteamID = ply:SteamID(), Date = os.date( "%Y-%m-%d %H:%M:%S", os.time() ), Saved = false, Start = ct() }

	Bot:SetMultiBot( style )
	Bot:Save( style )
end

function Bot:EndStageRun( ply, nTime, nStage )
	if !IsValid( ply ) then
		Surf:Notify( "Error", "Failed to retrieve bot/player info during EndRun" )
	return end

	local isPractice = ply:GetNWBool "Practice"
	if isPractice then return end

	-- Remember that stage bots only record while in Normal --
	local validStyle = (ply.CachedStyle == 1)
	if !validStyle then return end

	local hasRecording = StageRecording[ply] and StageRecording[ply][1] and (#StageRecording[ply][1] != 0)
	if !hasRecording then
		Surf:Notify( "Error", "Failed to retrieve run buffer during EndRun" )
	return end

	local validTime = nTime and nTime > 0
	if !validTime then
		Surf:Notify( "Error", "Failed to retrieve record time during EndRun" )
	return end

	local style = 14 + nStage
	local recordTime = BotInfo[style] and BotInfo[style].Time

	local didBeat = !recordTime or nTime < recordTime
	if !didBeat then return end

	Core:SendColor( ply, "Your ", CL.Yellow, "Stage " .. nStage, CL.White, " run (Time: ", CL.Blue, Timer:Convert( nTime ), CL.White, ") has been recorded and is set to be shown on the bot!" )

	BotData[ style ] = StageRecording[ ply ]
	BotFrame[ style ] = 1
	BotFrames[ style ] = #BotData[ style ][ 1 ]
	BotInfo[ style ] = { Name = ply:Name(), Time = nTime, Style = style, SteamID = ply:SteamID(), Date = os.date( "%Y-%m-%d %H:%M:%S", os.time() ), Saved = false, Start = ct() }

	Bot:SetMultiBot( style )
	Bot:Save( style )
end

function Bot:Save( style )
	if !style then return end

	if !runsLoaded then
		Surf:Notify( "Error", "Tried to save a bot before runs were loaded" )
	return end

	local info = BotInfo[style]
	if info.Saved then
		-- This should never happen, but better safe than sorry --
		Surf:Notify( "Error", "Attempted to save a bot that has already been saved??" )
	return end

	-- Updates might occur if playing the same map on different servers, so let's verify that --
	SQL:Prepare(
		"SELECT nTime FROM game_bots WHERE szMap = {0} AND nStyle = {1}",
		{ game.GetMap(), style }
	):Execute( function( Exist, _, _ )
		local currentTime 	= Exist and Exist[1] and Exist[1].nTime
		local recordTime 		= info.Time
		local steam 				= info.SteamID
		local date 					= info.Date
		local currentMap		= game.GetMap()
		local buffer 				= vON.serialize( BotData[style] )

		local currentQuery = "INSERT INTO game_bots VALUES ({4}, {0}, {5}, {1}, {2}, {3})"
		if currentTime and recordTime < currentTime then
			currentQuery = "UPDATE game_bots SET nTime = {0}, szSteam = {1}, szDate = {2}, szBuffer = {3} WHERE szMap = {4} and nStyle = {5}"
		end

		SQL:Prepare(
			currentQuery,
			{ recordTime, steam, date, buffer, currentMap, style }
		):Execute( function(_, _, szError)
			if szError then
				Surf:Notify( "Debug", "Failed to store bot, writing in server files [StyleID: " .. style .. "] [SteamID: " .. steam .. "]" )

				-- Implemented a local save method in-case our bot doesn't save --
				local fileName = _C.GameType .. "/bots/bot_" .. os.time() .. "_" .. game.GetMap()
				if style != _C.Style.Normal then
					fileName = fileName .. "_" .. style
				end
				file.Write( fileName .. ".txt", buffer )

				BotInfo[style].Saved = true

				if IsValid(ply) then
					if (style > 14 and style < 40) then
						Core:SendColor(ply, "Your ", CL.Yellow, "Stage " .. (style - 14), CL.White, " run was unable to be saved globally. Contact an Administrator to resolve this issue")
					else
						Core:SendColor(ply, "Your ", CL.Yellow, Core:StyleName(style), CL.White, " run was unable to be saved globally. Contact an Administrator to resolve this issue")
					end
				end
			return end

			Surf:Notify( "Debug", "Saving bot to the database [StyleID: " .. style .. "] [SteamID: " .. steam .. "]" )
			BotInfo[style].Saved = true
		end )
	end )
end

function Bot:ClearStyle( nStyle )
	BotFrame[ nStyle ] = nil
	BotFrames[ nStyle ] = nil
	BotData[ nStyle ] = nil
	BotInfo[ nStyle ] = nil
end

function Bot:SetMultiBot( nStyle )
	local target = nil
	for _,bot in pairs( player.GetBots() ) do
		if nStyle == _C.Style.Normal then
			if bot.Style == _C.Style.Normal and not bot.Temporary then
				target = bot
				break
			end
		else
			if bot.Style != _C.Style.Normal and not bot.Temporary then
				target = bot
				break
			end
		end
	end

	if IsValid( target ) then
		target.Style = nStyle
		Bot:SetInfo( target, nStyle, true )
		BotFrame[ nStyle ] = 1
		BotInfo[ nStyle ].CompletedRun = nil
		BotPlayer[ target ] = nStyle
		Bot:NotifyRestart( nStyle )
	end
end

function Bot:Spawn( bMulti, nStyle, bNone )
	if !runsLoaded then return end

	if not bMulti then
		nStyle = _C.Style.Normal
	end

	for _,bot in pairs( player.GetBots() ) do
		if bot.Temporary then
			bot:SetMoveType( MOVETYPE_NONE )
			bot.Style = nStyle
			bot:StripWeapons()
			bot:SetFOV( 90, 0 )
			bot:SetGravity( 0 )
			bot.Temporary = nil
			Bot:SetInfo( bot, nStyle, true )
			bot.PlaybackRate = 1

			return true
		end
	end

	if #player.GetBots() < 2 then
		Bot.Recent = nStyle
		if bMulti and bNone then
			Bot.Recent = nil
		end

		if BotInfo[ nStyle ] then
			if BotInfo[ nStyle ].Style > 14 and BotInfo[ nStyle ].Style < 40 then
				player.CreateNextBot( "Stage " .. BotInfo[ nStyle ].Style - 14 .. ": " .. BotInfo[ nStyle ].Name )
			else
				player.CreateNextBot( Core:StyleName( BotInfo[ nStyle ].Style ) .. ": " .. BotInfo[ nStyle ].Name )
			end
		elseif not bMulti then
			player.CreateNextBot( "SurfTimer Replay" )
		else
			player.CreateNextBot( "SurfTimer Multi-Replay" )
		end

		timer.Simple( 0.2, function()
			Bot:Spawn( bMulti, nStyle )
		end )
	end
end

function Bot:CheckStatus()
	if Bot.IsStatusCheck then
		return true
	else
		Bot.IsStatusCheck = true
	end

	local nCount = 0
	local bNormal, bMulti

	for _,bot in pairs( player.GetBots() ) do
		if bot.Style == _C.Style.Normal then
			bNormal = true
		elseif bot.Style != _C.Style.Normal then
			bMulti = true
		end

		nCount = nCount + 1
	end

	if nCount < 2 then
		if not bNormal then
			Bot:Spawn()
		end

		if not bMulti then
			local nStyle, bSet = 0, true
			for style,_ in pairs( BotData ) do
				if style != _C.Style.Normal then
					nStyle = style
					bSet = nil
					break
				end
			end

			Bot.SpawnData = { nStyle, bSet }
			timer.Simple( not bNormal and 0.2 or 0, function()
				if Bot and Bot.Spawn and Bot.SpawnData then
					Bot:Spawn( true, Bot.SpawnData[ 1 ], Bot.SpawnData[ 2 ] )
				end
			end )
		end
	end

	timer.Simple( 5, function()
		Bot.IsStatusCheck = nil
	end )
end

-- Dynamic player system
function Bot:CountPlayers()
	local count = 0

	for d,b in pairs( Players ) do
		if b and IsValid( d ) and d:IsPlayer() then
			count = count + 1
		else
			Players[ d ] = nil
		end
	end

	return count
end

function Bot:IsRecorded( ply )
	if Queue[ ply ] then
		Queue[ ply ] = nil
		Players[ ply ] = true
	end

	return Players[ ply ] or false
end

function Bot:AddPlayer( ply, szReason )
	local count = Bot:CountPlayers()

	if count < Bot.Maximum then
		Queue[ ply ] = true
		Players[ ply ] = true
	end
end

function Bot:RemovePlayer( ply )
	if Bot.AlwaysDisplayFirst then
		return Core:Send( ply, "Print", { "Notification", Lang:Get( "BotAlways" ) } )
	end

	if Bot:IsRecorded( ply ) then
		Recording[ ply ] = nil
		Frame[ ply ] = nil
		Players[ ply ] = nil
	end

	Core:Send( ply, "Print", { "Notification", Lang:Get( "BotClear" ) } )
end

function Bot:ShowStatus( ply )

end

function Bot:CleanRecording( ply )
	Recording[ ply ] = {}

	for i = 1, 6 do
		Recording[ ply ][ i ] = {}
	end

	Frame[ ply ] = 1
	Pause[ply] = false

	ply.LastSpeed = 0
	ply.CurrentSpeed = 0

	ply.TopSpeed = 0
	ply.TotalSpeed = 0
	ply.CountSpeed = 0

	if !Players[ ply ] then Players[ ply ] = true end
end

function Bot:CleanStageRecording( ply )
	StageRecording[ ply ] = {}

	for i = 1, 6 do
		StageRecording[ ply ][ i ] = {}
	end

	StageFrame[ ply ] = 1
	StagePause[ply] = false

	local isStaging = ply:GetNWBool "StageTimer"
	if isStaging then
		ply.LastSpeed = 0
		ply.CurrentSpeed = 0

		ply.TopSpeed = 0
		ply.TotalSpeed = 0
		ply.CountSpeed = 0
	end

	if !Players[ ply ] then Players[ ply ] = true end
end

function Bot:PauseRecording( ply )
	Pause[ply] = true
end

function Bot:PauseStageRecording( ply )
	StagePause[ply] = true
end

function Bot:GetMultiStyle()
	for _,bot in pairs( player.GetAll() ) do
		if bot:IsBot() and bot.Style != _C.Style.Normal then
			return bot.Style
		end
	end

	return 0
end

function Bot:ChangeMultiBot( nStyle, bForce )
	local current = Bot:GetMultiStyle()
	if nStyle == _C.Style.Normal then return "Exclude" end
	if current == nStyle then return "Same" end

	if BotInfo[ nStyle ] and BotData[ nStyle ] then
		if bForce or (BotInfo[ current ] and BotInfo[ current ].CompletedRun) then
			local ply = Bot:GetPlayer( current )
			ply.Style = nStyle
			Bot:SetInfo( ply, nStyle, true )
			BotFrame[ nStyle ] = 1
			BotInfo[ nStyle ].CompletedRun = nil
			BotPlayer[ ply ] = nStyle
			Bot:NotifyRestart( nStyle )

			if BotInfo[ nStyle ].Style > 14 and BotInfo[ nStyle ].Style < 40 then
				return "The bot is now displaying " .. BotInfo[ nStyle ].Name .. "'s Stage " .. BotInfo[ nStyle ].Style - 14 .. " run!"
			end

			return "The bot is now displaying " .. BotInfo[ nStyle ].Name .. "'s " .. Core:StyleName( BotInfo[ nStyle ].Style ) .. " run!"
		else
			return "Wait"
		end
	else
		return "Error"
	end
end

-- Find a set of replays, sort them in groups, and return it to the caller --
function Bot:FindReplays()
	-- Create a table in which we will append items to it --
	local append = {}

	-- If our BotData table is empty, just return a blank table --
	if (#BotData == 0) then return append end

	append = {
		[1] = {},
		[2] = {},
		[3] = {}
	}

	-- Sort through the BotInfo table with the styleid --
	for _,data in SortedPairsByMemberValue( BotInfo, "Style" ) do
		-- Receive information from the table --
		local runnerName 	= data.Name
		local runnerTime 	= data.Time
		local runnerDate 	= data.Date
		local runnerID 		= data.Style
		local runnerStyle = ""

		-- Stages don't have the correct style design, so parse it correctly and return it to group 2 --
		if (runnerID > 14) and (runnerID < 40) then
			runnerStyle = "Stage " .. (runnerID - 14)
			table.insert( append[2], { runnerName, runnerTime, runnerDate, runnerStyle, runnerID } )
		else
			runnerStyle = Core:StyleName( runnerID )

			-- If this is a bonus style return it to group 3, otherwise put it on the normal groups --
			-- Check if the style has a valid name first otherwise we might get "Unknown" styles --
			if (string.StartWith(runnerStyle, "Bonus") ) then
				table.insert( append[3], { runnerName, runnerTime, runnerDate, runnerStyle, runnerID } )
			elseif (runnerStyle != "Unknown") then
				table.insert( append[1], { runnerName, runnerTime, runnerDate, runnerStyle, runnerID } )
			end
		end
	end

	-- We collected what we need, send it back to the caller --
	return append
end

function Bot:GetMultiBots()
	local tabStyles = {}
	for style,data in pairs( BotData ) do
		if style != _C.Style.Normal then
			if style > 14 and style < 40 then
				table.insert( tabStyles, "Stage " .. style - 14 )
			else
				table.insert( tabStyles, Core:StyleName( style ) )
			end
		end
	end
	return tabStyles
end

function Bot:SaveBot( ply )
	-- Lol, removed
end


-- Access functions

function Bot:Exists( nStyle )
	return BotFrame[ nStyle ] and BotFrames[ nStyle ] and BotInfo[ nStyle ].Start
end

function Bot:NotifyRestart( nStyle )
	local ply = Bot:GetPlayer( nStyle )
	local info = BotInfo[ nStyle ]
	local bEmpty = false

	if IsValid( ply ) and not info then
		bEmpty = true
	elseif not info or not info.Start or not IsValid( ply ) then
		return false
	end

	local tab, Watchers = { "Timer", true, nil, "Idle Bot", nil, ct(), "Save" }, {}
	for _,p in pairs( player.GetHumans() ) do
		if not p.Spectating then continue end
		local ob = p:GetObserverTarget()
		if IsValid( ob ) and ob:IsBot() and ob == ply then
			table.insert( Watchers, p )
		end
	end

	if not bEmpty then
		tab = { "Timer", true, info.Start, info.Name, info.Time, ct(), "Save" }
	end

	Core:Send( Watchers, "Spectate", tab )
end

function Bot:GenerateNotify( nStyle, varList )
	if not BotInfo[ nStyle ] or not BotInfo[ nStyle ].Start then return end
	return { "Timer", true, BotInfo[ nStyle ].Start, BotInfo[ nStyle ].Name, BotInfo[ nStyle ].Time, ct(), varList }
end

function Bot:GetPlayer( nStyle )
	for _,ply in pairs( player.GetBots() ) do
		if ply.Style == nStyle and IsValid( ply ) then
			return ply
		end
	end
end

function Bot:SIDToProfile( sid )
	return util.SteamIDTo64( sid )
end

function Bot:GetInfo( nStyle )
	return BotInfo[ nStyle ]
end

function Bot:SetInfoData( nStyle, varData )
	BotInfo[ nStyle ] = varData
end

function Bot:SetInfo( ply, nStyle, bSet )
	local info = BotInfo[ nStyle ]
	if not info then
		ply:SetNWString( "BotName", "Awaiting playback..." )
		ply:SetNWInt( "Style", 0 )
		ply:SetNWString( "RunDate", "N/A")
		return false
	elseif info.Style then
		Bot:SetFramePosition( info.Style, 0 )
	end

	if info.Start then
		ply:SetNWString( "BotName", info.Name )
		ply:SetNWString( "ProfileURI", Bot:SIDToProfile( info.SteamID ) )
		ply:SetNWFloat( "Record", info.Time )
		ply:SetNWInt( "Style", info.Style )
		ply:SetNWInt( "Rank", -2 )
		ply:SetNWString( "RunDate", info.Date )

		-- Make the bot display stage info, doesn't matter what style as the client handles this already --
		Stage.GetBest( ply, info.SteamID )

		local pos = Timer:GetRecordID( info.Time, info.Style )
		if pos > 0 then
			ply:SetNWInt( "WRPos", pos )
		else
			ply:SetNWInt( "WRPos", 0 )
		end

		Bot.PerStyle[ info.Style ] = pos
	end

	if bSet then
		BotInfo[ nStyle ].Start = ct()
		Bot.Initialized = true
		BotPlayer[ ply ] = nStyle
	end
end

function Bot:SetWRPosition( nStyle )
	local ply = Bot:GetPlayer( nStyle )
	if not IsValid( ply ) then return end

	local info = BotInfo[ nStyle ]
	if not info then
		ply:SetNWString( "BotName", "Awaiting playback..." )
		ply:SetNWInt( "Style", 0 )
		return false
	end

	if info.Start then
		local pos = Timer:GetRecordID( info.Time, info.Style )
		if pos > 0 then
			ply:SetNWInt( "WRPos", pos )
		else
			ply:SetNWInt( "WRPos", 0 )
		end

		Bot.PerStyle[ info.Style ] = pos
	end
end

function Bot:SetFramePosition( nStyle, nFrame )
	if IsValid( Bot:GetPlayer( nStyle ) ) and BotFrame[ nStyle ] then
		Bot:NotifyRestart( nStyle )

		if nFrame < BotFrames[ nStyle ] then
			BotFrame[ nStyle ] = nFrame
		end
	end
end

function Bot:GetFramePosition( nStyle )
	if IsValid( Bot:GetPlayer( nStyle ) ) and BotFrame[ nStyle ] and BotFrames[ nStyle ] then
		return { BotFrame[ nStyle ], BotFrames[ nStyle ] }
	end

	return { 0, 0 }
end

function Bot:ExportSpeedAtFrame( ply )
	if !(ply.TopSpeed) then
		return { 0, 0, 0 }
	end

	local currentSpeed 	= math.ceil(ply.LastSpeed)
	local topSpeed 			= math.ceil(ply.TopSpeed)

	local totalSpeed 		= ply.TotalSpeed
	local countSpeed 		= ply.CountSpeed
	local averageSpeed 	= math.ceil(totalSpeed / countSpeed)

	return { currentSpeed, topSpeed, averageSpeed }
end

-- 12/19/2020: Remove clientside velocity recorder and move it to bot code --
local tickRate = engine.TickInterval()
local function BotRecord( ply, data )
	if Players[ ply ] then
		local isPractice = ply:GetNWBool "Practice"
		local origin = data:GetOrigin()
		local eyes = data:GetAngles()
		local frame = Frame[ ply ]
		local speed = ply:GetVelocity():Length2D()

		if !Pause[ply] and frame then
			if !isPractice then
				Recording[ ply ][ 1 ][ frame ] = origin.x
				Recording[ ply ][ 2 ][ frame ] = origin.y
				Recording[ ply ][ 3 ][ frame ] = origin.z
				Recording[ ply ][ 4 ][ frame ] = eyes.p
				Recording[ ply ][ 5 ][ frame ] = eyes.y

				Frame[ ply ] = frame + 1
			end

			if (ply.CurrentSpeed) then
				ply.LastSpeed = ply.CurrentSpeed
			end
			ply.CurrentSpeed = speed or 0

			if speed > ply.TopSpeed then
				ply.TopSpeed = speed
			end

			ply.TotalSpeed = ply.TotalSpeed + speed
			ply.CountSpeed = ply.CountSpeed + 1
		end

		local stageFrame = StageFrame[ ply ]
		if !StagePause[ply] and stageFrame then
			if !isPractice then
				StageRecording[ ply ][ 1 ][ stageFrame ] = origin.x
				StageRecording[ ply ][ 2 ][ stageFrame ] = origin.y
				StageRecording[ ply ][ 3 ][ stageFrame ] = origin.z
				StageRecording[ ply ][ 4 ][ stageFrame ] = eyes.p
				StageRecording[ ply ][ 5 ][ stageFrame ] = eyes.y

				StageFrame[ ply ] = stageFrame + 1
			end

			local isStaging = ply:GetNWBool "StageTimer"
			if isStaging then
				if (ply.CurrentSpeed) then
					ply.LastSpeed = ply.CurrentSpeed
				end
				ply.CurrentSpeed = speed or 0

				if speed > ply.TopSpeed then
					ply.TopSpeed = speed
				end

				ply.TotalSpeed = ply.TotalSpeed + speed
				ply.CountSpeed = ply.CountSpeed + 1
			end
		end
	elseif BotPlayer[ ply ] then
		local style = BotPlayer[ ply ]
		local frame = BotFrame[ style ]

		if (frame % 1 != 0) then
			BotFrame[style] = BotFrame[style] + ply.PlaybackRate
		return end

		if frame >= BotFrames[ style ] then
			if !BotInfo[ style ].BotCooldown then
				BotInfo[ style ].BotCooldown = ct()
				BotInfo[ style ].Start = ct() + 4
				Bot:NotifyRestart( style )
			end

			local nDifference = ct() - BotInfo[ style ].BotCooldown

			if (nDifference > 2 and nDifference < 2.1) then
				Stage.SetBest( ply, 1 )
			end

			if nDifference >= 4 then
				BotFrame[ style ] = 1
				BotInfo[ style ].Start = ct()
				BotInfo[ style ].BotCooldown = nil
				BotInfo[ style ].CompletedRun = true

				return Bot:NotifyRestart( style )
			elseif nDifference >= 2 then
				frame = 1

				-- If the bot playback rate wasn't the default, revert it back to default and notify players --
				if (ply.PlaybackRate != 1) then
					ply.PlaybackRate = 1
					ply:SetNWFloat("Rate", ply.PlaybackRate)

					Core:SendColor( ply:GetSpectators(), "Reverted bot playback rate back to ", CL.Blue, 1, CL.White, "x" )
				end
			elseif nDifference >= 0 then
				frame = BotFrames[ style ]
			end

			local d = BotData[ style ]
			data:SetOrigin( Vector( d[ 1 ][ frame ], d[ 2 ][ frame ], d[ 3 ][ frame ] ) )
			return ply:SetEyeAngles( Angle( d[ 4 ][ frame ], d[ 5 ][ frame ], 0 ) )
		end

		local d = BotData[ style ]
		local pos = Vector( d[ 1 ][ frame ], d[ 2 ][ frame ], d[ 3 ][ frame ] )
		local angle = Angle( d[ 4 ][ frame ], d[ 5 ][ frame ], 0 )

		data:SetOrigin( pos )
		ply:SetEyeAngles( angle )

		if ply.tempRate then
			ply.PlaybackRate = ply.tempRate
			ply:SetNWFloat("Rate", ply.PlaybackRate)
			ply.tempRate = nil

			local tabData = Bot:GetFramePosition(style)
			local info = Bot:GetInfo(style)
			local current = ((tabData[1] / tabData[2]) * info.Time)
			info.Start = (CurTime() * ply.PlaybackRate) - current
			Bot:SetInfoData(style, info)
			Bot:NotifyRestart(style)
		end

		BotFrame[ style ] = frame + ply.PlaybackRate

		-- Did this so bots get applied velocity (potential fix for saveloc off of bots) --
		if ply.oldBotPos then
			local vel = pos - ply.oldBotPos
			vel:Mul(ply.PlaybackRate / tickRate)
			ply.lastVelocity = vel

			data:SetVelocity(vel)
		end

		ply.oldBotPos = pos
	end
end
hook.Add( "SetupMove", "PositionRecord", BotRecord )

local function BotButtonRecord( ply, data )
	if Players[ ply ] then
		if Frame[ply] then Recording[ ply ][ 6 ][ Frame[ ply ] ] = data:GetButtons() end
		if StageFrame[ply] then StageRecording[ ply ][ 6 ][ StageFrame[ ply ] ] = data:GetButtons() end
	elseif BotPlayer[ ply ] then
		data:ClearButtons()
		data:ClearMovement()

		local style = BotPlayer[ ply ]
		if BotData[ style ][ 6 ][ BotFrame[ style ] ] and ply:GetMoveType() == 0 then
			data:SetButtons( tonumber( BotData[ style ][ 6 ][ BotFrame[ style ] ] ) )
		end
	end
end
hook.Add( "StartCommand", "ButtonRecord", BotButtonRecord )

timer.Create( "BotController", 1, 0, function()
	for ply,_ in pairs( BotPlayer ) do
		if IsValid( ply ) then
			if ply:GetMoveType() != 0 then ply:SetMoveType( 0 ) end
			if ply:GetFOV() != 90 then ply:SetFOV( 90, 0 ) end
		end
	end

	if (#player.GetBots() <= 2) then
		Bot.EmptyTick = (Bot.EmptyTick or 0) + 1

		if Bot.EmptyTick > 5 then
			Bot.EmptyTick = nil
			Bot:CheckStatus()
		end
	end
end )
