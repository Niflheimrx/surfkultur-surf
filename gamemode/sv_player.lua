Player = {}
Player.MultiplierNormal = 0.5
Player.LadderScalar = 1
Player.TopCache = {}

function Player:Spawn( ply )
	if !IsValid( ply ) then return end
	local nAccess = Admin:GetAccess( ply )

	if ply:IsBot() then
		ply:SetModel( _C["Player"].BotModel )
	else
		ply:SetModel( _C["Player"].DefaultModel )
	end

	if ply:IsBot() then
		ply:SetPlayerColor( Vector( 0.31, 0.04, 0.35 ) )
	elseif nAccess == Admin.Level.Owner then
		ply:SetPlayerColor( Vector( 1, 0, 0.17 ) )
	elseif nAccess == Admin.Level.Developer then
		ply:SetPlayerColor( Vector( 0.42, 0.55, 0.14 ) )
	elseif nAccess == Admin.Level.Super then
		ply:SetPlayerColor( Vector( 1, 0.41, 0.71 ) )
	elseif nAccess == Admin.Level.Admin then
		ply:SetPlayerColor( Vector( 1, 0.55, 0 ) )
	elseif nAccess == Admin.Level.Moderator then
		ply:SetPlayerColor( Vector( 1, 1, 0 ) )
	end

	ply:SetTeam( _C["Team"].Players )
	ply:SetJumpPower( _C["Player"].JumpPower )
	ply:SetHull( _C["Player"].HullMin, _C["Player"].HullStand )
	ply:SetHullDuck( _C["Player"].HullMin, _C["Player"].HullDuck )
	ply:SetNoCollideWithTeammates( true )
	ply:SetAvoidPlayers( false )

	if !ply:IsBot() then
		if Core:GetStyleID( ply.Style ) == 4 or Core:GetStyleID( ply.Style ) > 9 and Core:GetStyleID( ply.Style ) < 19 then
			ply:BonusReset()
		elseif Core:GetStyleID( ply.Style ) > 18 then
			ply:StageReset()
		else
			ply:ResetTimer()
		end

		Player:SpawnChecks( ply )
	else
		ply:SetMoveType( MOVETYPE_NONE )
		ply:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		ply:SetFOV( 90, 0 )
		ply:SetGravity( 0 )
		ply:StripWeapons()

		if Zones.BotPoint then
			ply:SetPos( Zones.BotPoint )
		end
	end
end

function Player:SpawnChecks( ply )
	ply.MovingPos = true
	ply.Teleporting = true

	local isBonus = Core.IsBonus(ply.Style)
	if isBonus then
		local sequence = Core.BonusToSequence(ply.Style)
		if ply.Style == _C.Style.Bonus and Zones.BonusPoint then
			local point = Zones:GetSpawnPoint( Zones.BonusPoint )
			if ply.PreferredBonusSpawn and ply.PreferredBonusSpawn[sequence] then
				point = ply.PreferredBonusSpawn[sequence]
				ply:SetEyeAngles(ply.PreferredBonusAngles[sequence])
			end

			ply:SetPos( point )
		end

		for i = 2, 10 do
			if ply.Style == _C.Style["Bonus " .. i] and Zones["Bonus " .. i .. " Point"] then
				local point = Zones:GetSpawnPoint( Zones["Bonus " .. i .. " Point"] )
				if ply.PreferredBonusSpawn and ply.PreferredBonusSpawn[sequence] then
					point = ply.PreferredBonusSpawn[sequence]
					ply:SetEyeAngles(ply.PreferredBonusAngles[sequence])
				end

				ply:SetPos( point )
			end
		end
	elseif Zones.StartPoint then
		local point = Zones:GetSpawnPoint( Zones.StartPoint )
		if ply.PreferredSpawn then
			point = ply.PreferredSpawn
			ply:SetEyeAngles(ply.PreferredAngles)
		end

		ply:SetPos( point )
	end

	if !ply:IsBot() and ply:GetMoveType() != MOVETYPE_WALK then
		ply:SetMoveType( MOVETYPE_WALK )
	end

	ply:SetLocalVelocity( Vector( 0, 0, 0 ) )

	-- Fallback after 2 ticks just in-case --
	-- The following below is really fucking stupid but unless I override the actual player's movement this likely won't get fixed --
	timer.Simple( 0.015, function()
		ply:SetLocalVelocity( Vector( 0, 0, 0 ) )
	end )

	timer.Simple( 0.03, function()
		ply:SetLocalVelocity( Vector( 0, 0, 0 ) )

		ply.MovingPos = false
		ply.Teleporting = false
	end )
end

function Player:Load( ply )
	if Core.Locked then
		return Core:Lock( "Re-lock for player joining" )
	end

	-- Do player setup --
	ply.Style = _C.Style.Normal
	ply.Record = 0
	ply.Rank = -1

	ply:SetTeam( _C.Team.Players )
	ply:SetNWInt( "Style", ply.Style )
	ply:SetNWFloat( "Record", ply.Record )
	ply:SetNWInt( "Rank", ply.Rank )

	-- If this is a bot, do these things specifically for them --
	local isBot = ply:IsBot()
	if isBot then
		ply.Temporary = true
		ply.Rank = -2

		ply:SetMoveType( MOVETYPE_NONE )
		ply:SetFOV( 90, 0 )
		ply:SetGravity( 0 )

		ply:SetNWInt( "Rank", ply.Rank )
	return end

	-- Check if the SQL server failed to load, if so notify the player --
	if !SQL.Available then
		ply:SetNWBool( "Practice", true )
		ply.PermanentSurfTimer = 1

		Core:Send( ply, "Print", { "Surf Timer", "The database server failed to startup which means that records are currently not working." } )
		Core:Send( ply, "Print", { "Surf Timer", "The server will try to reconnect however the map will reset after 10 minutes if not successful." } )
		Core:Send( ply, "Print", { "Notification", "You have been pruned! You cannot use commands at this time." } )
	return end

	local steamid = ply:SteamID()
	local name = ply:Name()
	local date = Timer:GetDate()

	SQL:Prepare(
		"SELECT * FROM game_playerinfo WHERE szUID = {0}",
		{ steamid }
	):Execute( function( PlayerInfo )
		local index = PlayerInfo and PlayerInfo[1]
		if !index then
			ply.PlayTime = 0
			ply.Connections = 1
			ply.PlayerTitle = ""
			ply:SetNWString("PlayerTitle", ply.PlayerTitle)

			Core:BroadcastColorBase( CL.Yellow, name, CL.White, " (", CL.Green, steamid, CL.White, ") has joined the server for the first time!" )

			SQL:Prepare(
				"INSERT INTO game_playerinfo (szUID, szLastName, nPlaytime, nLastConnected, nConnections) VALUES ({0}, {1}, 0, {2}, 1)",
				{ steamid, name, date }
			):Execute( function() end )
		return end

		ply.PlayTime = index["nPlaytime"]
		ply.Connections = index["nConnections"] + 1
		ply.PlayerTitle = index["szPlayerTitle"]
		ply:SetNWString("PlayerTitle", ply.PlayerTitle)

		Core:BroadcastColorBase( CL.Yellow, name, CL.White, " (", CL.Green, steamid, CL.White, ") has joined the server ", CL.Blue, ply.Connections, CL.White, " times" )

		SQL:Prepare(
			"UPDATE game_playerinfo SET szLastName = {0}, nConnections = nConnections + 1, nLastConnected = {1} WHERE szUID = {2}",
			{ name, date, steamid }
		):Execute( function() end )
	end )

	ply.Rank = -1
	ply:SetNWInt( "Rank", ply.Rank )
	ply:SetNWInt( "Points", 0 )

	Player:LoadRank( ply )
	RTV.SendTimeLeft( ply )

	Admin:CheckPlayerStatus( ply )
	Admin:CheckVIP( ply )

	Bot:CheckStatus()
	Bot:AddPlayer( ply )

	SMgrAPI:Monitor( ply, true )
	ply.SyncDisplay = "Sync: 0%"

	ply.ConnectedAt = CurTime()
end

function Player:LoadStyle( ply, nStyle )
	ply.Style = nStyle
	ply.Record = 0

	Command.Restart( ply )
	Timer.SetBest( ply )
	Stage.SetInfo( ply )

	ply:SetNWInt( "Style", nStyle )

	Core:SendColor( ply, "You are now playing on the ", CL.Yellow, Core:StyleName( nStyle ), CL.White, " style." )
	Core:Send( ply, "Timer", { "Style", ply.Style } )
end

function Player:UnloadLock()
	for _,ply in pairs( player.GetHumans() ) do
		if ply.PermanentSurfTimer == 1 then
			Core:Send( ply, "Print", { "Surf Timer", "Database connected, you can now use timer functionality." } )
			ply.PermanentSurfTimer = 0
			Player:Load( ply )
		end
	end
end

function Player:AddScore( ply )
	ply:AddFrags( 1 )
end

function Player:GetMatchingStyles( nStyle )
	local tab = { _C.Style.Normal, _C.Style.Bonus, _C.Style["Bonus 2"], _C.Style["Bonus 3"], _C.Style["Bonus 4"], _C.Style["Bonus 5"], _C.Style["Bonus 6"], _C.Style["Bonus 7"], _C.Style["Bonus 8"], _C.Style["Bonus 9"], _C.Style["Bonus 10"] }

	if nStyle == _C.Style.Sideways or nStyle == _C.Style["Half-Sideways"] then
		tab = { _C.Style.Sideways, _C.Style["Half-Sideways"] }
	elseif nStyle == _C.Style["100 Tick"] or nStyle == _C.Style.Wicked or nStyle == _C.Style["33 Tick"] then
		tab = { _C.Style["100 Tick"], _C.Style.Wicked, _C.Style["33 Tick"] }
	end

	local t = {}
	for _,s in pairs( tab ) do
		table.insert( t, "nStyle = " .. s )
	end

	return string.Implode( " OR ", t )
end

function Player:GetMatchingStylesWithoutQuery( nStyle )
	local tab = { _C.Style.Normal, _C.Style.Bonus, _C.Style["Bonus 2"], _C.Style["Bonus 3"], _C.Style["Bonus 4"], _C.Style["Bonus 5"], _C.Style["Bonus 6"], _C.Style["Bonus 7"], _C.Style["Bonus 8"], _C.Style["Bonus 9"], _C.Style["Bonus 10"] }

	if nStyle == _C.Style.Sideways or nStyle == _C.Style["Half-Sideways"] then
		tab = { _C.Style.Sideways, _C.Style["Half-Sideways"] }
	elseif nStyle == _C.Style["100 Tick"] or nStyle == _C.Style.Wicked or nStyle == _C.Style["33 Tick"] then
		tab = { _C.Style["100 Tick"], _C.Style.Wicked, _C.Style["33 Tick"] }
	end

	return tab
end

function Player:GetRankType( nStyle, bNumber )
	if nStyle == _C.Style.Sideways or nStyle == _C.Style["Half-Sideways"] then
		if bNumber then return 4 else return true end
	elseif nStyle == _C.Style["100 Tick"] or nStyle == _C.Style.Wicked or nStyle == _C.Style["33 Tick"] then
		if bNumber then return 5 else return true end
	else
		if bNumber then return 3 else return false end
	end
end

function Player:GetOnlineVIPs()
	local tabVIP = {}

	for _,p in pairs( player.GetHumans() ) do
		if p.IsVIP then
			table.insert( tabVIP, p )
		end
	end

	return tabVIP
end

-- Ranking 2.0
function Player:SetRank( ply, rank, points )
	if !rank then
		ply.Rank = 0
		ply:SetNWInt( "Rank", ply.Rank )

		Surf:Notify( "Error", "Rank index given was invalid [On SetRank Value: " .. (rank or "nil") .. "]" )
	return end

	if _C.SpecialRanks[rank] then
		ply:SetNWInt( "SpecialRank", rank )
	else
		ply:SetNWInt( "SpecialRank", 0 )
	end

	local pRank = 1
	for crank, data in pairs( _C.Ranks ) do
		local rankPoints = data[3]
		if crank > pRank and points >= rankPoints then
			pRank = crank
		end
	end

	ply.Rank = pRank
	ply:SetNWInt( "Rank", pRank )
	ply:SetNWInt( "Points", points )

	Player:SetSubRank(ply, pRank, points)
end

function Player:SetSubRank(ply, nRank, nPoints)
	if nRank >= #_C.Ranks then
		local nTarget = 10
		if !ply.SubRank or ply.SubRank != nTarget then
			ply.SubRank = nTarget
			ply:SetNWInt( "SubRank", ply.SubRank )
		end
	else
		local nDifference = _C.Ranks[ nRank + 1 ][ 3 ] - _C.Ranks[ nRank ][ 3 ]
		local nStepSize = nDifference / 10
		local nOut, nStep = 1, 1

		for i = _C.Ranks[ nRank ][ 3 ], _C.Ranks[ nRank + 1 ][ 3 ], nStepSize do
			if nPoints >= i then
				nOut = nStep
			end

			nStep = nStep + 1
		end

		if !ply.SubRank or ply.SubRank != nOut then
			ply.SubRank = nOut
			ply:SetNWInt( "SubRank", ply.SubRank )
		end
	end
end

function Player:LoadRank( ply )
	if !Player.TopCache then
		Player:SetRank( ply )
	return end

	local steamid = ply:SteamID()
	for rank, data in pairs( Player.TopCache ) do
		local points = data[3]
		if (data[1] == steamid) then
			Player:SetRank( ply, rank, points )
		return end
	end

	Player:SetRank( ply )
end

function Player:GroupStylePrefix( style, shouldSeperate )
	local group = Player:GetRankType( style, true )
	local prefix = ""
	if !group then return prefix end

	if (group == 4) then
		prefix = "Angled"
	elseif (group == 5) then
		prefix = "Extra"
	end

	if shouldSeperate and (group != "") then
		prefix = "* " .. prefix .. " *"
	end

	return prefix
end

function Player:GroupToTab( style )
	local group = Player:GetRankType( style, true )
	if !group then return 1 end

	group = group - 2

	return group
end

function Player:LoadLeaderboardTop(ply, style)
	style = style or 1

	local styleTranslator = "(nStyle = " .. style .. ")"
	if (style == 1) then
		styleTranslator = "(nStyle = 1 OR nStyle = 4 OR nStyle = 10 OR nStyle = 11 OR nStyle = 12 OR nStyle = 13 OR nStyle = 14 OR nStyle = 40 OR nStyle = 41 OR nStyle = 42 OR nStyle = 43)"
	end

	local leaderboardQuery = [[
		SELECT
			t2.szLastName username, t1.*
		FROM
			(SELECT t1.szUID steamid, SUM(t1.nPoints) points FROM game_times t1 WHERE ]] .. styleTranslator .. [[ GROUP BY szUID ORDER BY points DESC LIMIT 50) t1
		INNER JOIN
			game_playerinfo t2
		ON
			t2.szUID = t1.steamid
	]]

	local data = {}

	SQL:Prepare(
		leaderboardQuery, {style}
	):Execute( function(TopLeaderboard, _, szError)
		if szError then
			Core:Send(ply, "SurfTop", {data, style})
		return end

		for _,info in ipairs(TopLeaderboard) do
			local steamid = info["steamid"]
			local name = info["username"]
			local points = math.floor(info["points"])

			table.insert(data, {name, points, steamid})
		end

		Core:Send(ply, "SurfTop", {data, style})
	end)
end

function Player:GetGroupQueryStyles( style )
	if !style then style = 1 end

	local group = Player:GetRankType( style, true )
	local returnQuery = "(nStyle = 1 OR nStyle = 4 OR nStyle = 10 OR nStyle = 11 OR nStyle = 12 OR nStyle = 13 OR nStyle = 14 OR nStyle = 40 OR nStyle = 41 OR nStyle = 42 OR nStyle = 43)"
	if (group == 4) then
		returnQuery = "(nStyle = 2 OR nStyle = 3)"
	elseif (group == 5) then
		returnQuery = "(nStyle = 6 OR nStyle = 44 OR nStyle = 45)"
	end

	return returnQuery
end

function Player.CalcRank()
	local getTopQuery = [[
		SELECT
			t1.szUID steamid,
			MIN( t2.szLastName ) username,
			SUM(t1.nPoints) points
		FROM
			game_times t1
		JOIN
			game_playerinfo t2
		ON
			t2.szUID = t1.szUID
		WHERE
			(nStyle = 1 OR nStyle = 4 OR nStyle = 10 OR nStyle = 11 OR nStyle = 12 OR nStyle = 13 OR nStyle = 14 OR nStyle = 40 OR nStyle = 41 OR nStyle = 42 OR nStyle = 43)
		GROUP BY steamid
		ORDER BY points DESC
	]]

	Surf:Notify( "Debug", "Calculating Top Leaderboards..." )

	local benchStart = RealTime()

	Player.TopCache = {}
	SQL:Prepare(
		getTopQuery
	):Execute( function( GetTop, _, szError )
		if szError then print( szError ) return end

		for _, data in pairs( GetTop ) do
			local steamid = data["steamid"]
			local name = data["username"]
			local points = math.floor( data["points"] )

			table.insert( Player.TopCache, { steamid, name, points } )
		end

		local benchEnd = RealTime()
		Surf:Notify( "Debug", "Calculated Top Leaderboards [Delay: " .. ( math.Round( benchEnd - benchStart, 2 ) * 10 ) .. "ms]" )

		for _,ply in pairs( player.GetHumans() ) do
			if !IsValid(ply) then continue end

			local steamid = ply:SteamID()
			for rank, data in pairs( Player.TopCache ) do
				if (data[1] == steamid) then
					Player:LoadRank( ply )
				break end
			end
		end
	end )
end

function Player:GetServerRank( ply, target, pos )
	if !target then target = ply end
	if pos then pos = tonumber(pos) end

	local steamid = target:SteamID()
	local pRank, pName, pPoints, pTotal = 0, target:Name(), 0, #Player.TopCache

	for rank, data in pairs( Player.TopCache ) do
		local validEntry = pos and (rank == pos) or !pos and (data[1] == steamid)

		if validEntry then
			pRank = rank
			pName = data[2]
			pPoints = data[3]
		break end
	end

	if (pRank == 0) then
		if pos then
			Core:SendColor( ply, "The rank index specified doesn't exist" )
		else
			Core:SendColor( ply, CL.Yellow, pName, CL.White, " is not ranked" )
		end
	return end

	Core:BroadcastColor( CL.Yellow, pName, CL.White, " is ranked ", CL.Blue, pRank, CL.White, "/", CL.Blue, pTotal, CL.White, " with ", CL.Blue, pPoints, CL.White, " points." )
end

function Player:GetProfile( ply, target, style )
	-- I finally got around to rewriting this!! --
	-- There's a new profile menu by the way, it reflects the future look of the gamemode --
	-- Due to the nature of the gamemode, this only works on the NORMAL style NOT on any OTHER style --

	-- Do checks here, this time I check if a player even has a rank which would error out on the last version
	if !ply or !ply:IsValid() then
		print( "[SM] PROFILE | A player attempted to open a playercard menu but they don't exist?!?!")
	return end

	if target and !(isstring(target)) and !(target:IsValid()) then
		Core:Send( ply, "Print", { "Surf Timer", "You are attempting to open a playercard on a player that doesn't exist." } )
	return end

	local steamid

	if isstring(target) then
		target = string.upper( target )

		if !(string.StartWith(target, "STEAM_")) then
			Core:Send( ply, "Print", { "Surf Timer", "Your argument either didn't have a player that existed with that name or the steamid wasn't valid." } )
		return end

		steamid = target
	else
		-- Do a rank check here; it just makes it very unlikely someone will break this command --
		if target and ( target.Rank == 1 ) or ply and ( ply.Rank == 1 ) then
			Core:Send( ply, "Print", { "Surf Timer", ( target and "This player needs " or "You need " ) .. "a valid rank to use this functionality." } )
		return end

		steamid = target and target:SteamID() or ply:SteamID()
	end

	-- Open the menu, it displays a loading indicator when not updated anyways
	Core:Send( ply, "Playercard" )

	-- Setup variables --
	local tab = {}

	--== Start collecting data ==--
	-- Get the player we are collecting data from, this is important for later --
	tab.Player = target or ply
	if !style then style = 1 end
	tab.Style = style

	local benchStart = RealTime()

	-- Optimized Sample (Average rate before: 16.8ms | Average rate after: 8.3ms ) --
	local recsQuery = [[
	SELECT
		COUNT(IF(t1.nStyle = ]] .. style .. [[, 1, NULL)) recs,
		COUNT(IF((t1.nStyle = 4 OR t1.nStyle = 10 OR t1.nStyle = 11 OR t1.nStyle = 12 OR t1.nStyle = 13 OR t1.nStyle = 14 OR t1.nStyle = 40 OR t1.nStyle = 41 OR t1.nStyle = 42 OR t1.nStyle = 43), 1, NULL)) bonusrecs,
		(SELECT COUNT(*) FROM game_stages WHERE szUID = {0} AND nStyle = ]] .. style .. [[) stagerecs
	FROM
		game_times t1
	WHERE
		t1.szUID = {0}
	]]

	SQL:Prepare(
		recsQuery,
		{ steamid }
	):Execute( function( Records )
		local index = Records and Records[1]
		tab.MapBeats = index.recs or 0
		tab.StageBeats = index.stagerecs or 0
		tab.BonusBeats = index.bonusrecs or 0
	end )

	local userrecsQuery = [[
	SELECT
		COUNT(IF(t1.nStyle = ]] .. style .. [[, 1, NULL)) recs,
		COUNT(IF((t1.nStyle = 4 OR t1.nStyle = 10 OR t1.nStyle = 11 OR t1.nStyle = 12 OR t1.nStyle = 13 OR t1.nStyle = 14 OR t1.nStyle = 40 OR t1.nStyle = 41 OR t1.nStyle = 42 OR t1.nStyle = 43), 1, NULL)) bonusrecs
	FROM game_times t1
		JOIN (SELECT MIN( game_times.szMap ) szMap, MIN( game_times.nStyle ) nStyle, MIN(game_times.nTime) nTime
			FROM game_times
		GROUP BY game_times.szMap, game_times.nStyle ) t2
			ON t1.szMap = t2.szMap AND t1.nTime = t2.nTime AND t1.nStyle = t2.nStyle
	WHERE
		t1.szUID = {0}
	]]

	SQL:Prepare(
		userrecsQuery,
		{ steamid }
	):Execute( function( UserRecords )
		local index = UserRecords and UserRecords[1]
		tab.MapRecords = index.recs or 0
		tab.BonusRecords = index.bonusrecs or 0
	end )

	local userstagerecsQuery = [[
			SELECT COUNT(*) stagerecs
				FROM game_stages t1
	INNER JOIN (SELECT MIN( game_stages.szMap ) szMap, MIN( game_stages.nStage ) nStage, MIN(game_stages.nTime) nTime
				FROM game_stages WHERE nStyle = ]] .. style .. [[
		GROUP BY game_stages.szMap, game_stages.nStage ) t2
					ON t1.szMap = t2.szMap AND t1.nTime = t2.nTime AND t1.nStage = t2.nStage
			 WHERE t1.szUID = {0}
	]]

	SQL:Prepare(
		userstagerecsQuery,
		{ steamid }
	):Execute( function( UserStageRecords )
		local index = UserStageRecords and UserStageRecords[1]
		tab.StageRecords = index.stagerecs or 0
	end )

	local mapQuery = [[
	SELECT
		(SELECT COUNT(*) FROM game_map) maps,
		COUNT(IF((t1.nType = 2 OR t1.nType = 6 OR t1.nType = 9 OR t1.nType = 11 OR t1.nType = 13 OR t1.nType = 15 OR t1.nType = 96 OR t1.nType = 98 OR t1.nType = 100 OR t1.nType = 102), 1, NULL)) bonusmaps,
		COUNT(IF((t1.nType > 16 AND t1.nType < 63), 1, NULL)) stagemaps
	FROM
		(SELECT szMap, nType FROM game_zones GROUP BY szMap, nType) t1
	]]

	SQL:Prepare(
		mapQuery
	):Execute( function( Maps )
		local index = Maps and Maps[1]
		tab.TotalMaps = index.maps or 0
		tab.MapPercent = tostring( math.Round( tab.MapBeats / tab.TotalMaps * 100, 2 ) ) or "0"

		tab.TotalStages = index.stagemaps or 0
		tab.StagePercent = tostring( math.Round( tab.StageBeats / tab.TotalStages * 100, 2 ) ) or "0"

		tab.TotalBonuses = index.bonusmaps or 0
		tab.BonusPercent = tostring( math.Round( tab.BonusBeats / tab.TotalBonuses * 100, 2 ) ) or "0"
	end )

	if (style != 1) then
		local whereClause = "WHERE szUID = {0}"
		local baseSelect = "SELECT *, (SELECT COUNT(*) FROM (SELECT szUID FROM game_times WHERE nStyle = {1} GROUP BY szUID) t1) rankTotal FROM ("
		local rankSelect = "SELECT s.*, @rank := @rank + 1 rank FROM ("
		local groupSelect = "SELECT szUID, SUM(nPoints) points FROM game_times WHERE nStyle = {1} GROUP BY szUID) s, (SELECT @rank := 0) init "
		local orderSelect = "ORDER BY points DESC) r " .. whereClause

		SQL:Prepare(
			baseSelect .. rankSelect .. groupSelect .. orderSelect,
			{steamid, style}
		):Execute( function(RankInfo, _, szError)
			local index = RankInfo and RankInfo[1]
			if index then
				tab.TotalRank = index.rankTotal
				tab.PlayerPoints = math.floor(index.points)
				tab.ServerRank = index.rank
			else
				tab.TotalRank = 0
				tab.PlayerPoints = 0
				tab.ServerRank = 0
			end
		end)
	end

	SQL:Prepare(
		"SELECT * FROM game_playerinfo WHERE szUID = {0}",
		{ steamid }
	):Execute( function( PlayerInfo )
		local index = PlayerInfo and PlayerInfo[1]
		if index then
			tab.GameLastJoined = isstring( tab.Player ) and "Last Connected: " .. index.nLastConnected or "Player Currently Online"
			tab.GameJoins = index.nConnections
			tab.GamePlaytime = index.nPlaytime
			tab.GameTitle = index.szPlayerTitle or "User"
			tab.GameSteam = index.szUID
			tab.PlayerName = isstring( tab.Player ) and index.szLastName or tab.Player:Nick()

			if (style == 1) then
				for rank, data in pairs( Player.TopCache ) do
					local validEntry = (data[1] == steamid)
					if validEntry then
						tab.TotalRank = #Player.TopCache
						tab.PlayerPoints = data[3]
						tab.ServerRank = rank
					break end
				end
			end
		end

		Core:Send( ply, "Playercard", { tab } )

		local benchEnd = RealTime()
		Surf:Notify( "Debug", "Loaded profile stats for player [Delay: " .. ( math.Round( benchEnd - benchStart, 2 ) * 10 ) .. "ms] [SteamID: " .. steamid .. "]" )
	end )
end

-- Find a player based on their name --
function Player:FindByString( ply, name, addSpec, noResponse )
	-- Does our base player exist? We need to send messages to them so this is important --
	if !ply or !(IsValid(ply)) then
		Surf:Notify( "Error", "Attempted to find a player based on string, but no player exists??" )
	return end

	-- Is our argument valid? This would cause errors if not used correctly --
	if !name or !(isstring(name)) then
		Core:Send( ply, "Print", { "Surf Timer", "You need to give a valid argument in order to use this" } )
		Surf:Notify( "Error", "Attempted to find a player based on string, but the string is missing" )
	return end

	-- Values we will be using --
	local haystack = 0
	local found = nil

	-- Convert the string to a lowercased string, so everything is ok for name checking --
	name = string.lower( name )

	-- Find all humans and loop through their names; if we are adding spectators, do that too --
	for _,ent in pairs( player.GetHumans() ) do
		if !addSpec and ent.Spectating then continue end
		if !IsValid(ent) then continue end

		-- Convert the string to a lowercase string, in conjunction with the haystack --
		local pName = string.lower( ent:Name() )

		-- Get the start position, end position of the string we are looking for; if we don't have anything, go to the next player --
		local nameStart, nameEnd = string.find( pName, name )
		if !(nameStart or nameEnd) then continue end

		-- Calculate the total size; if our total is lower than the haystack size, go to the next player --
		local total = (nameEnd - nameStart) + 1
		if (total <= haystack ) then continue end

		-- Use the new haystack values --
		haystack = total
		found = ent
	end

	-- If the matching string is less than or equal to 2, it's likely a false positive --
	-- Also check if the player we are trying to find is actually valid --
	if (haystack <= 2) or !found or !IsValid(found) then
		if !noResponse then
			Core:Send( ply, "Print", { "Surf Timer", "Couldn't find any player with that string, did you type the name correctly?" } )
		end
	return end

	-- We found a player, send that information back to where we checked it --
	Surf:Notify( "Debug", "Found player in haystack query [User: " .. found:Nick() .. "] [Haystack: " .. haystack .. "]" )
	return found
end

-- Efficiently gets the server rank of a user with caching --
function Player:GetServerRankEfficient( ply, style, steamid )
	-- Define our variables here, you can use either a player or only a steamid. You must define the style if done by steamid --
	local rank, points, _ = 0, 0, ""
	local index = Player:GetRankType( style or ply.Style, true )
	steamid = ( steamid or ply:SteamID() )

	-- What are our group titles for our styles? --
	local groupTitle = {
		[3] = "Normal",
		[4] = "Angled",
		[5] = "Fun"
	}

	-- Get the title for our group, rarely (or even ever) is this going to fail --
	local rankgroup = (groupTitle[index] or "Unknown")

	-- Check if our TopCache group is valid --
	if !TopCache[index] then
		Core:Send( ply, "Print", { "Surf Timer", "Failed to lookup the ranking cache table" } )
	return 0, 0, rankgroup end

	-- Search through the TopCache table and locate our data --
	for spot,data in pairs( TopCache[index] ) do
		if steamid != data[3] then continue end

		-- We found data, break the loop and retrieve that index --
		rank = spot
		points = data[2]
		break
	end

	-- If we didn't get anything, we don't get anything --
	if (rank == 0) then
		return 0, 0, rankgroup
	end

	-- Send the rank, points, and rankgroup back to the caller --
	return rank, points, rankgroup
end

-- Gather a list of top players and organize them in groups, then return it to the caller --
function Player:FindTopPlayers()
	-- Create a table that we will send data to --
	local append = {}

	-- Define what kind of ranking groups we have --
	local groups = {
		[1] = Player:GetRankType( _C.Style.Normal, true ),
		[2] = Player:GetRankType( _C.Style.Sideways, true ),
		[3] = Player:GetRankType( _C.Style["100 Tick"], true )
	}

	-- Do a small check to see if Normal has any records. This usually passes but it is in here just in-case --
	-- If we don't have any records, return an empty table. The client knows what to do with this anyways --
	local tempCheck = TopCache[groups[1]]
	if !tempCheck or (#tempCheck == 0) then return append end

	-- Create three different groups in which we will append data to --
	append = {
		[1] = {},
		[2] = {},
		[3] = {}
	}

	-- Sort through our groups and append the data, we only loop through each group 100 times so we don't load a large table --
	for id,group in ipairs(groups) do
		for i = 1, 25 do
			-- Do yet another check if our group is valid, break the loop if it isn't --
			local index = TopCache[group][i]
			if !index then break end

			-- Define what our data is --
			local pName = index[1]
			local pPoints = index[2]
			local pSteam = index[3]

			-- Append it to the table --
			table.insert( append[id], { pName, pPoints, pSteam } )
		end
	end

	-- We have data, let's send it back to the caller --
	return append
end

-- The functions below are obsolete, I don't want to remove them because there might be errors! --
function Player:GetTopPage( nPage, nStyle )
	local tab = {}
	local Index = _C.PageSize * nPage - _C.PageSize
	local Number = Player:GetRankType( nStyle, true )

	for i = 1, _C.PageSize do
		i = i + Index
		if TopCache[ Number ][ i ] then
			tab[ i ] = TopCache[ Number ][ i ]
		end
	end

	return tab
end

function Player:GetTopCount( nStyle )
	local Number = Player:GetRankType( nStyle, true )
	return #TopCache[ Number ]
end

function Player:SendTopList( ply, nPage, nType )
	local nStyle = nType == 4 and _C.Style.Sideways or _C.Style.Normal or _C.Style["100 Tick"]

	Core:Send( ply, "GUI_Update", { "Top", { 4, Player:GetTopPage( nPage, nStyle ), nPage, Player:GetTopCount( nStyle ), nType } } )
end

-- Rewriting this for new record system --
function Player:GetMapsWR( ply, steamid, index, style )
	if !steamid or !isstring(steamid) then
		Surf:Notify( "Error", "No steamid provided for GetMapsWR" )
	return end

	Core:Send( ply, "MyRecords" )

	local mywrQuery = [[
		SELECT
			t.szUID, td.szMap, td.nStyle, td.nTime, szDate, t.nPoints,
			(SELECT szLastName FROM game_playerinfo WHERE szUID = {0}) szLastName
		FROM
			game_times t
		JOIN
			(SELECT MIN(nTime) nTime, szMap, MIN(nStyle) nStyle FROM game_times WHERE ]] .. (index == "Bonus" and Zones:GetBonusStyleString() or "nStyle = " .. style) .. [[ GROUP BY szMap, nStyle) td
		ON
			td.szMap = t.szMap AND td.nTime = t.nTime AND td.nStyle = t.nStyle
		WHERE
			t.szUID = {0}
	]]

	local mywrStageQuery = [[
		SELECT
			t.szUID, td.szMap, td.nStyle, td.nStage, td.nTime, szDate,
			(SELECT szLastName FROM game_playerinfo WHERE szUID = {0}) szLastName
		FROM
			game_stages t
		JOIN
			(SELECT MIN(nTime) nTime, szMap, MIN(nStyle) nStyle, MIN(nStage) nStage FROM game_stages WHERE nStyle = 1 GROUP BY szMap, nStyle, nStage) td
		ON td.szMap = t.szMap AND td.nTime = t.nTime AND td.nStyle = t.nStyle AND td.nStage = t.nStage
		WHERE
			t.szUID = {0}
		LIMIT 500
	]]

	SQL:Prepare(
		index == "Stage" and mywrStageQuery or mywrQuery, { steamid }
	):Execute( function( data, _, szError )
		if szError or (#data == 0) then
			Core:Send( ply, "MyRecords", {data} )
		return end

		local name = data[1].szLastName or "Unknown"
		if (index == "Normal") then index = Core:StyleName(style) end
		Core:Send( ply, "MyRecords", { data, name, index } )
	end )
end

-- 01/24/2021: rewrite again to allow dynamic recent record loading --
function Player:GetRecentRecords( ply, mode )
	if !ply then
		Surf:Notify( "Error", "No player exists for query GetRecentRecords" )
	return end

	if !mode then
		mode = "Normal"
	end

	local indexTypes = {
		["Normal"] = { "game_times", "nStyle = 1", 25 },
		["Bonus"] = { "game_times", Zones:GetBonusStyleString(), 25 },
		["Stage"] = { "game_stages", "nStyle = 1", 50 },
		["33 Tick"] = {"game_times", "nStyle = 45", 25}
	}

	local mapQuery = [[
	SELECT
		r.*,
		p.szLastName
	FROM
		(SELECT
			szUID, td.nTime, td.szMap, szDate, ]] .. (mode == "Stage" and "td.nStage" or "td.nStyle") .. [[
		FROM
			]] .. indexTypes[mode][1] .. [[ t
	    INNER JOIN
	    	(SELECT szMap, ]] .. (mode == "Stage" and "MIN(nStage) nStage" or "MIN(nStyle) nStyle") .. [[, MIN(nTime) nTime FROM ]] .. indexTypes[mode][1] .. [[ WHERE ]] .. indexTypes[mode][2] .. [[ GROUP BY szMap, ]] .. (mode == "Stage" and "nStage" or "nStyle") .. [[) td ON td.szMap = t.szMap AND td.nTime = t.nTime AND ]] .. (mode == "Stage" and "td.nStage = t.nStage" or "td.nStyle = t.nStyle") .. [[
	    ORDER BY
	     szDate DESC
		LIMIT ]] .. indexTypes[mode][3] .. [[
	) r
	INNER JOIN
		game_playerinfo p
	ON
		r.szUID = p.szUID
	ORDER BY
		szDate DESC
	]]

	SQL:Prepare(
		mapQuery
	):Execute( function( data, _, szError )
		Core:Send( ply, "RecentRecords", { data, mode } )
	end )
end

-- Fetches the count of all players, and puts them into a leaderboard whoever has the most records --
function Player:GetTopRecordCount(ply, index)
	Core:Send( ply, "TopRecords" )

	local topRankQuery = [[
		SELECT
			MIN(p.szUID) as szUID,
			COUNT(*) AS recs,
			MIN(p.szLastName) as szLastName
		FROM
			(SELECT
				t.szUID, td.szMap, td.nStyle, td.nTime, szDate
			FROM
				game_times t
			JOIN
				(SELECT MIN(nTime) nTime, szMap, MIN(nStyle) nStyle FROM game_times WHERE ]] .. (index == "Bonus" and Zones:GetBonusStyleString() or (index == "33 Tick") and "nStyle = 45" or "nStyle = 1") .. [[ GROUP BY szMap, nStyle) td
			ON td.szMap = t.szMap AND td.nTime = t.nTime AND td.nStyle = t.nStyle
		) r
		INNER JOIN
			game_playerinfo p
		ON
			r.szUID = p.szUID
		GROUP BY
			r.szUID
		ORDER BY
			recs DESC
		LIMIT 50
	]]

	local topStageQuery = [[
		SELECT
			MIN(p.szUID) as szUID,
			COUNT(*) AS recs,
			MIN(p.szLastName) as szLastName
		FROM
			(SELECT
				t.szUID, td.szMap, td.nStyle, td.nStage, td.nTime, szDate
			FROM
				game_stages t
			JOIN
				(SELECT MIN(nTime) nTime, szMap, MIN(nStyle) nStyle, MIN(nStage) nStage FROM game_stages WHERE nStyle = 1 GROUP BY szMap, nStyle, nStage) td
			ON td.szMap = t.szMap AND td.nTime = t.nTime AND td.nStyle = t.nStyle AND td.nStage = t.nStage
		) r
		INNER JOIN
			game_playerinfo p
		ON
			r.szUID = p.szUID
		GROUP BY
			r.szUID
		ORDER BY
			recs DESC
		LIMIT 50
	]]

	SQL:Prepare(
		index == "Stage" and topStageQuery or topRankQuery
	):Execute( function( data, _, szError )
		if szError then
			Core:Send( ply, "TopRecords", {} )
		return end

		Core:Send( ply, "TopRecords", { data, index } )
	end )
end

function Player:GetMapsBeat( ply, steamid, Left, style )
	if !steamid then steamid = ply:SteamID() end
	if !style then style = 1 end

	SQL:Prepare(
		"SELECT szMap, nTime FROM game_times WHERE szUID = '" .. steamid .. "' AND nStyle = " .. style .. " ORDER BY szDate DESC"
	):Execute( function( data, varArg, szError )
		if (szError or (!data or #data == 0)) then
			Core:SendColor(ply, "You don't have any maps " .. (Left and "left" or "completed") .. " yet for ", CL.Yellow, Core:StyleName(style))
		elseif Core:Assert( data, "szMap" ) then
			local tab = {}
			for _,item in pairs( data ) do
				table.insert( tab, { item["szMap"], tonumber( item["nTime"] ) } )
			end

			Core:Send( ply, "GUI_Open", { "Maps", { Left and "Left" or "Completed", tab, style } } )
			Core:Send( ply, "Print", { "Surf Timer", "Showing query for player." } )
		end
	end )
end

function Player:GetPercentCompletion(ply, target)
	-- Originally implemented by Aart, fixed by Niflheimrx --
	-- Cleaned up code and added bonus support to the percent completion --

	-- Localize these variables for stuff we are about to do --
	local steamid = target and target:SteamID() or ply:SteamID()
	local name = target and target:Nick() or ply:Nick()
	local style = target and target.Style or ply.Style
	local styleName = Core:StyleName( target.Style )
	local styleString = ""

	-- Check different styles, Bonuses get grouped with Normal here --
	if style == 1 then
		styleString = "(nStyle = 1 or nStyle = 4 or nStyle = 10 or nStyle = 11 or nStyle = 12 or nStyle = 13 or nStyle = 14)"
	elseif style == 4 or ( style >= 10 and style <= 14 ) or ( style >= 40 and style <= 43 ) then
		styleString = "(nStyle = 1 or nStyle = 4 or nStyle = 10 or nStyle = 11 or nStyle = 12 or nStyle = 13 or nStyle = 14)"
		styleName = "Normal"
	else
		styleString = "nStyle = " .. style
	end

	-- Grab the maps beaten on a specific list of styles --
	SQL:Prepare( "SELECT COUNT(*) as nTotal FROM game_times WHERE " .. styleString .. " AND szUID = {0}", { steamid }
	):Execute( function( data, varArg, szError )
		-- This user likely doesn't have any record data, so just return this text notifying them that this query failed --
		if !data or data[1]["nTotal"] == 0 then
			Core:Send( ply, "Print", { "Surf Timer", "Failed to fetch account." } )
		return end

		-- Grab data from query, get the amount of maps/bonuses zoned, add it up and get the percent completion --
		local mapbeats = data[1]["nTotal"]
		local totalmaps = table.Count( sql.Query( "SELECT * FROM game_map" ) )
		local totalbonuses = table.Count( sql.Query( "SELECT * FROM game_zones WHERE (nType = 2 OR nType = 6 OR nType = 9 OR nType = 11 OR nType = 13 OR nType = 15)" ) )
		local totalamount = totalmaps + totalbonuses

		local pc = tostring( math.Round( mapbeats / totalamount * 100, 2 ) )

		-- We got data, send this to the player --
		-- To-do: Use a unique network identifier to keep things not so messy --
		Core:Broadcast("PrintPC", { name, styleName, pc } )
	end )
end

local RemoteWRCache = {}
function Player:SendRemoteWRList( ply, szMap, nStyle, nPage, bUpdate )
	if !szMap or type( szMap ) != "string" then return end
	if szMap == game.GetMap() then
		return Core:Send( ply, "GUI_Open", { "WR", { 2, Timer:GetRecordList( nStyle, nPage ), nStyle, nPage, Timer:GetRecordCount( nStyle ) } } )
	end

	if RTV:MapExists( szMap ) then
		SQL:Prepare(
			"SELECT * FROM game_times INNER JOIN game_playerinfo ON game_times.szUID = game_playerinfo.szUID WHERE szMap = '" .. szMap .. "' AND nStyle = " .. nStyle .. " ORDER BY nTime ASC"
		):Execute( function( List, varArg, szError )
			local SendData = {}
			local SendCount = 0

			local RWRC = RemoteWRCache[ szMap ]

			if !RWRC or (type( RWRC ) == "table" and !RWRC[ nStyle ]) then
				if !RWRC then
					RemoteWRCache[ szMap ] = {}
				end

				RemoteWRCache[ szMap ][ nStyle ] = {}

				if Core:Assert( List, "szUID" ) then
					for _,data in pairs( List ) do
						table.insert( RemoteWRCache[ szMap ][ nStyle ], { data["szUID"], data["szLastName"], tonumber( data["nTime"] ), Core:Null( data["szDate"] ), Core:Null( data["vData"] ) } )
					end
				end

				local a = nPage * _C.PageSize - _C.PageSize
				for i = 1, _C.PageSize do
					i = i + a
					if RemoteWRCache[ szMap ][ nStyle ][ i ] then
						SendData[ i ] = RemoteWRCache[ szMap ][ nStyle ][ i ]
					end
				end

				SendCount = #RemoteWRCache[ szMap ][ nStyle ]
			else
				local a = nPage * _C.PageSize - _C.PageSize
				for i = 1, _C.PageSize do
					i = i + a
					if RemoteWRCache[ szMap ][ nStyle ][ i ] then
						SendData[ i ] = RemoteWRCache[ szMap ][ nStyle ][ i ]
					end
				end

				SendCount = #RemoteWRCache[ szMap ][ nStyle ]
			end

			local bZero = true
			for i,data in pairs( SendData ) do
				if i and data then bZero = false break end
			end

			if bZero or SendCount == 0 then
				if bUpdate then return end
				Core:Send( ply, "Print", { "Surf Timer", "No SR data found for " .. szMap .. " on style " .. Core:StyleName( nStyle ) } )
			else
				if bUpdate then
					Core:Send( ply, "GUI_Update", { "WR", { 4, SendData, nPage, SendCount } } )
				else
					Core:Send( ply, "GUI_Open", { "WR", { 2, SendData, nStyle, nPage, SendCount, szMap } } )
				end
			end
		end )
	else
		return Core:Send( ply, "Print", { "General", Lang:Get( "MapInavailable", { szMap } ) } )
	end
end

local RemoteStageCache = {}
function Player:SendRemoteStageList( ply, szMap, nStage, nStyle, nPage, bUpdate )
	if !szMap or type( szMap ) != "string" then return end

	if RTV:MapExists( szMap ) then
		SQL:Prepare(
			"SELECT * FROM (SELECT * FROM game_stages WHERE szMap = {0} AND nStage = {1} AND nStyle = {2} ORDER BY nTime ASC LIMIT 7) t1 INNER JOIN game_playerinfo ON t1.szUID = game_playerinfo.szUID ORDER BY nTime ASC",
			{ szMap, nStage, nStyle }
		):Execute( function( List, varArg, szError )
			if Core:Assert( List, "szUID" ) then
				local SendData = {}
				local SendCount = 0

				local RSTC = RemoteStageCache[ szMap ]

				if !RSTC then
					RemoteStageCache[ szMap ] = {}
				end

				RemoteStageCache[ szMap ][ nStage ] = {}

				for _,data in pairs( List ) do
					table.insert( RemoteStageCache[ szMap ][ nStage ], { data["szUID"], data["szLastName"], tonumber( data["nTime"] ), Core:Null( data["szDate"] ) } )
				end

				local a = nPage * _C.PageSize - _C.PageSize
				for i = 1, _C.PageSize do
					i = i + a
					if RemoteStageCache[ szMap ][ nStage ][ i ] then
						SendData[ i ] = RemoteStageCache[ szMap ][ nStage ][ i ]
					end
				end

				SendCount = #RemoteStageCache[ szMap ][ nStage ]

				local bZero = true
				for i,data in pairs( SendData ) do
					if i and data then bZero = false break end
				end

				if bZero or SendCount == 0 then
					if bUpdate then return end
					Core:Send( ply, "Print", { "Surf Timer", "No CPR data found for " .. szMap .. " on Stage " .. nStage .. " [" .. Core:StyleName( nStyle ) .. "]." } )
				else
					if bUpdate then
						Core:Send( ply, "GUI_Update", { "WR", { 8, SendData, 1, SendCount } } )
					else
						Core:Send( ply, "GUI_Open", { "WR", { 6, SendData, nStage, nStyle, 1, SendCount, szMap } } )
					end
				end
			elseif szError then
				Core:Send( ply, "Print", { "Surf Timer", "Failed to query top stage records." } )
			end
		end )
	else
		return Core:Send( ply, "Print", { "General", Lang:Get( "MapInavailable", { szMap } ) } )
	end
end

-- Connection stats/somewhat ported from the new gamemode --
local META = FindMetaTable "Player"
function META:SavePlayerInfo()
	local szName, szUID = self:Name(), self:SteamID()
	local st = math.Round( (CurTime() - self.ConnectedAt) / 60 )

	SQL:Prepare(
		"UPDATE game_playerinfo SET nPlaytime = nPlaytime + {0} WHERE szUID = {1}",
		{ st, szUID }
	):Execute( function() end )

	print( "Saving playerstats for " .. szName .. ". Time Played: " .. st .. " minutes | SteamID: " .. szUID )
end

local function OnMapChange()
	for k, v in ipairs( player.GetHumans() ) do
		v:SavePlayerInfo()
	end
end
hook.Add( "ShutDown", "MapChange", OnMapChange )

local function PlayerDisconnect( ply )
	local reason = ply.DCReason or "Player overpowered the toaster"
	if !ply:IsBot() then
		ply:SavePlayerInfo()
		Core:BroadcastColorBase( CL.Yellow, ply:Name(), CL.White, " (", CL.Green, ply:SteamID(), CL.White, ") disconnected (Reason: ", CL.Yellow, reason, CL.White, ")" )
	end

	if #player.GetHumans() - 1 < 1 then
		Core:Unload()
	end

	if ply.Spectating then
		Spectator:End( ply, ply:GetObserverTarget() )
		ply.Spectating = nil
	end

	SMgrAPI:RemovePlayer( ply )

	if RTV.VotePossible then return end
	if RTV.FinalVote then return end

	if ply.Rocked then
		RTV.MapVotes = RTV.MapVotes - 1
	end

	local Count = #player.GetHumans()
	if Count > 1 then
		RTV.Required = math.ceil( (Count - 1) * ( 2 / 3 ) )
		if RTV.MapVotes >= RTV.Required then
			RTV:StartVote()
		end
	end
end
hook.Add( "PlayerDisconnected", "PlayerDisconnect", PlayerDisconnect )

local function PlayerConnect( data )
	if data.bot != 1 then
		local id = data.userid
		local steam = data.networkid

		SQL:Prepare(
			"SELECT * FROM gmod_bans WHERE szUserSteam = {0} AND szReason != {1} ORDER BY nStart DESC",
			{ steam, "UNBANNED" }
		):Execute( function( banObject, varArg, szError )
			if Core:Assert( banObject, "szUserSteam" ) then
				local nLength = banObject[ 1 ]["nLength"] * 60
				local endTime = banObject[ 1 ]["nStart"] + nLength

				if nLength == 0 then
					game.KickID( id, "You are permenantly banned from this server. Reason: " .. tostring( banObject[ 1 ]["szReason"] ) )
				else
					if endTime >= varArg then
						local banLength = math.ceil( (endTime - varArg) / 60 )
						game.KickID( id, "You are currently banned from this server. Ban will expire in " .. banLength .. " minutes. Reason: " .. tostring( banObject[ 1 ]["szReason"] ) )
					end
				end
			end
		end, os.time() )
	end
end
hook.Add( "player_connect", "PlayerConnect", PlayerConnect )

function Player.ChangeName( data, userid, vipold, vipnew, fromadmin )
	local userid 	= userid or data.userid
	local oldname = vipold or data.oldname
	local newname = vipnew or data.newname

	local ply = player.GetByID( userid )
	if (fromadmin and oldname and newname) and (oldname == newname) then return end

	Core:BroadcastColorBase( "Player ", CL.Yellow, oldname, CL.Orange, " changed name to ", CL.Yellow, newname )
end
hook.Add( "player_changename", "PlayerChangeName", Player.ChangeName )

util.AddNetworkString( "surf_ShowKeys" )
local function surf_SendShowKeys( ply, data )
	if !ply or !IsValid(ply) then return end

	local bit = data:GetButtons()
	local spectators = {}
	for _, p in pairs( player.GetHumans() ) do
		if !p.Spectating then continue end

		local ob = p:GetObserverTarget()
		if IsValid( ob ) and ob == ply then
			table.insert( spectators, p )
		end
	end

	net.Start( "surf_ShowKeys" )
		net.WriteUInt( bit, 11 )
	net.Send( spectators )
end
hook.Add( "SetupMove", "surf.SendKeyByte", surf_SendShowKeys )
