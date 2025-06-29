--[[
	Author: Niflheimrx
	Description: Handles stage timer related info
							 I redid this because I wanted this module to be more efficient (and make changes to the SideTimer)
]]--

-- Define global table, local metatable and settings for later use
Stage = {}

local PLAYER = FindMetaTable( "Player" )
local CT = CurTime
local CAPVEL = 380

-- Function that returns a boolean that determines if we can use the timer
local function canUseTimer( ply )
	-- Check if the map is even staged --
	local isLinear = Timer.Type == 0
	if isLinear then return end

	-- No nulls, no skynet --
	if !ply or !IsValid( ply ) then return end
	if ply:IsBot() then return end

	-- Check for eligibility based on state/styles --
	local isBonus = string.StartWith( Core:StyleName( ply.Style ), "Bonus" )
	if isBonus then return end

	-- Check if the player is teleporting --
	local isMoving = ply.MovingPos
	if isMoving then return end

	return true
end

-- Function that returns the maximum velocity a player can leave based on style
local function getVelocityCap( style )
	local returnCap = CAPVEL

	-- On average, a good prestrafe on 100 tick is 420 (unironically) --
	if (style == 44) then
		returnCap = 420
	-- On average, a good prestrafe on Wicked is 1700 (original amount) --
	elseif (style == 6) then
		returnCap = 1700
	end

	-- Return the maximum amount of units a player can leave on 2D space --
	return returnCap
end

-- Playercall that runs when a player leaves the Stage Zone
function PLAYER:StartStage()
	if !canUseTimer(self) then return end

	local vel = self:GetVelocity():Length2D()
	local style = self.Style

	local cappedVelocity = getVelocityCap( style )
	local canTelehop = Stage.AllowTelehops

	if (vel > cappedVelocity) and !canTelehop then
		-- Don't attempt to use previous data when trying to beat stages --
		self.Ts = nil
		self.TsF = nil

		-- We don't want velocity warnings to print when we are likely telehopping (like on kitsune2, omnific, etc.) --
		local probablyTelehopping = vel > 500
		if probablyTelehopping then return end

		-- We also don't want to print the warning when leaving Stage 1 (so we don't get double warnings for the same reason) --
		local currentStage = self:GetNWInt "Stage"
		if (currentStage == 1) then return end

		Core:SendColorSpec( self, "Stage max velocity exceeded! (" , CL.Yellow, math.ceil( vel ) .. " u/s", CL.White, ")" )
	return end

	-- Modify playervalues for proper timer handling --
	self.Ts = CT()
	self.TsF = nil
	self.StagePrestrafe = vel

	-- Easy functions to handle different plugins --
	Bot:CleanStageRecording( self )
	Stage:RequestPrestrafe( self )
	Spectator:PlayerStageRestart( self )

	Core:Send( self, "Timer", { "Stage", "Start", self.Ts } )
end

-- Playercall that runs when a player re-enters the same Stage Zone
function PLAYER:StageReset()
	-- Reset playervalues for proper timer handling --
	self.Ts = nil
	self.TsF = nil

	-- Reset anything that other plugins might need to know --
	Bot:PauseStageRecording( self )
	Spectator:PlayerStageRestart( self )

	-- This is really only needed when moving to a different stage, but we play it safe --
	local nStage = self:GetNWInt "Stage"
	Stage.SetInfo( self, nStage )

	Core:Send( self, "Timer", { "Stage", "Start", self.Ts } )
	self:SetNWBool( "StageOpenArea", false )
end

function PLAYER:StageStop()
	if !canUseTimer(self) then return end

	self.TsF = CT()

	-- Calculate the Stage Total, current Total Time, and fetch current Stage --
	local totalTime = (self.Tn and self.TsF - self.Tn) or 0
	local currentStage, currentStyle = self:GetNWInt "Stage", self.Style

	-- Validity checks for Total Time --
	local isRunningNormal = !self:GetNWBool "StageTimer"
	local invalidStages = (currentStage == Zones:GetStageAmount()) or (currentStage == 1)
	local wantsTotalTime = tobool( self:GetInfo "sl_totaltime" )
	if wantsTotalTime and isRunningNormal and !invalidStages then
		local prefix = currentStyle != 1 and (Core:StyleName( currentStyle ) .. " | " ) or ""
		Core:SendColorSpec( self, CL.Green, prefix, CL.White, "Current total time on Stage [", CL.Yellow, "Stage " .. currentStage, CL.White, "]: ", CL.Blue, Timer:Convert( totalTime ) )
	end

	-- Set a split for this stage regardless if there's a timer running --
	self:SetSplit(currentStage)

	-- We don't want empty stage runs to actually submit --
	if !self.Ts then return end

	local stageTotal = self.TsF - self.Ts
	Core:Send( self, "Timer", { "Stage", "Finish", self.Ts } )

	Stage:Finish( self, stageTotal )
	Bot:PauseStageRecording( self )
end

function PLAYER:ForceStageStop()
	if !canUseTimer(self) then return end
	if !self.Ts then return end

	self.TsF = CT()

	-- Calculate the Stage Total, current Total Time, and fetch current Stage --
	local totalTime = (self.Tn and self.TsF - self.Tn) or 0
	local currentStage, currentStyle = self:GetNWInt "Stage", self.Style

	-- Validity checks for Total Time --
	local isRunningNormal = !self:GetNWBool "StageTimer"
	local invalidStages = (currentStage == Zones:GetStageAmount()) or (currentStage == 1)
	local wantsTotalTime = tobool( self:GetInfo "sl_totaltime" )
	if wantsTotalTime and isRunningNormal and !invalidStages then
		local prefix = currentStyle != 1 and (Core:StyleName( currentStyle ) .. " | " ) or ""
		Core:SendColorSpec( self, CL.Green, prefix, CL.White, "Current total time on Stage [", CL.Yellow, "Stage " .. currentStage, CL.White, "]: ", CL.Blue, Timer:Convert( totalTime ) )
	end

	-- We don't want empty stage runs to actually submit --
	if !self.Ts then return end

	local stageTotal = self.TsF - self.Ts

	Stage:Finish( self, stageTotal )
	Bot:PauseStageRecording( self )

	self.Ts = nil
	self.TsF = nil

	Core:Send( self, "Timer", { "Stage", "Finish", self.Ts } )
	self:SetNWBool( "StageOpenArea", true )
end

function PLAYER:StopAnyStageTimer()
	if !canUseTimer(self) then return end

	self.Ts = nil
	self.TsF = nil

	Bot:PauseStageRecording( self )

	Core:Send( self, "Timer", { "Stage", "Start", self.Ts } )
	self:SetNWBool( "StageOpenArea", true )
end

function Stage:Finish( ply, nTime )
	if !ply.LoadedStageRecs then return end

	ply.CachedStyle = ply.Style

	local nStage, nStyle = ply:GetNWInt "Stage", ply.CachedStyle
	local currentRecord, currentBest = Stage.MapRecords[ nStyle ][ nStage ], ply.StageRecords[ nStyle ][ nStage ]
	local prespeed = math.ceil( ply.StagePrestrafe )

	-- Check for Stage Record first then check for Personal Best --
	local isPractice = ply:GetNWBool "Practice"
	if !currentRecord and !isPractice then
		Core:SendColor( ply, "Congratulations! You are the first user to set a record on Stage [", CL.Yellow, "Stage " .. nStage, CL.White, "]!" )
	elseif !currentBest and !isPractice then
		Core:SendColor( ply, "Congratulations! You have completed Stage [", CL.Yellow, "Stage " .. nStage, CL.White, "] for the first time!" )
	end

	-- Determine the difference type the player current has set --
	local difference = ""
	local differenceType = ply:GetInfoNum( "sl_comparison_type", 0 )
	if (differenceType == 3) then
		local wrDifference = "WR N/A"
		local pbDifference = " | PB N/A"

		local wrtimeDifference = currentRecord and (nTime - currentRecord[1]) or ""
		local wrdifferenceText = wrtimeDifference != "" and (wrtimeDifference >= 0 and "+" or "-" ) or ""
		wrDifference = "WR " .. wrdifferenceText .. (wrtimeDifference != "" and Timer:Convert(math.abs(wrtimeDifference)) or "N/A")

		local pbtimeDifference = currentBest and (nTime - currentBest[1]) or ""
		local pbdifferenceText = pbtimeDifference != "" and (pbtimeDifference >= 0 and "+" or "-" ) or ""
		pbDifference = " | PB " .. pbdifferenceText .. (pbtimeDifference != "" and Timer:Convert(math.abs(pbtimeDifference)) or "N/A")

		difference = wrDifference .. pbDifference
	elseif (differenceType == 2) then
		local timeDifference = currentRecord and (nTime - currentRecord[1]) or ""
		local differenceText = timeDifference != "" and (timeDifference >= 0 and "+" or "-" ) or ""
		difference = "WR " .. differenceText .. (timeDifference != "" and Timer:Convert(math.abs(timeDifference)) or "N/A")
	else
		local timeDifference = currentBest and (nTime - currentBest[1]) or ""
		local differenceText = timeDifference != "" and (timeDifference >= 0 and "+" or "-" ) or ""
		difference = "PB " .. differenceText .. (timeDifference != "" and Timer:Convert(math.abs(timeDifference)) or "N/A")
	end

	local isFirstTime = !currentBest
	local didBeat = isFirstTime or currentBest and nTime < currentBest[1]
	local improvementText = ""
	if !isFirstTime and didBeat then
		local bestDifference = nTime - currentBest[1]
		improvementText = "Improved by " .. Timer:Convert(math.abs(bestDifference))
	end

	Core:SendColorSpec( ply, "Stage [", CL.Yellow, "Stage " .. nStage, CL.White, "] ", CL.Green, nStyle != 1 and ("* " .. Core:StyleName( nStyle ) .. " * ") or "", CL.Blue, Timer:Convert( nTime ), CL.White,
		" (", CL.Yellow, difference, CL.White, "). ", CL.Purple, improvementText )

	local wantsSpeed = tobool( ply:GetInfoNum( "sl_speedstats", 0 ) )
	if wantsSpeed then
		local speedData 		= Bot:ExportSpeedAtFrame( ply )
		local currentSpeed 	= speedData[1] .. " u/s"
		local topSpeed 			= speedData[2] .. " u/s"
		local averageSpeed 	= speedData[3] .. " u/s"

		Core:SendColorSpec( ply, "Touch: [", CL.Yellow, currentSpeed, CL.White, "] Top: [", CL.Yellow, topSpeed, CL.White, "] Average: [", CL.Yellow, averageSpeed, CL.White, "]" )
	end

	if isPractice then return end

	-- If we didn't beat our time, don't proceed to print out rankings and potentially insert unintended records --
	if !didBeat then return end

	local newRank, oldRank, totalRank = Stage.GetRank( nTime, nStyle, nStage ), currentBest and Stage.GetRank( currentBest[1], nStyle, nStage ) or 1, Stage.GetTotal( nStyle, nStage ) or 0

	-- Setup variables for quick insert/update --
	local name = ply:Name()
	local steamid = ply:SteamID()
	local map = game.GetMap()
	local date = Timer:GetDate()

	if isFirstTime then
		SQL:Prepare(
	    "INSERT INTO game_stages VALUES ({0}, {1}, {2}, {3}, {4}, {5}, {6})",
			{ steamid, map, nStage, nStyle, nTime, date, prespeed }
		):Execute( function( _, _, szError )
			if szError then
				Core:Send( ply, "Print", { "Surf Timer", "Your time failed to submit, please contact an administrator for a solution!" } )
			return end

			totalRank = totalRank + 1

			if (newRank == 1) then
				local timeDifference = currentRecord and (nTime - currentRecord[1]) or ""
				local differenceText = timeDifference != "" and (timeDifference >= 0 and "+" or "-" ) or ""
				differenceText = "WR " .. differenceText .. (timeDifference != "" and Timer:Convert(math.abs(timeDifference)) or "N/A")

				Core:BroadcastColor( CL.Yellow, name, CL.White, " beat a ", CL.Green, nStyle != 1 and ("* " .. Core:StyleName( nStyle ) .. " * ") or "", CL.White, "stage record! Stage: [", CL.Yellow, "Stage " .. nStage,
			 		CL.White, "] Time: ", CL.Blue, Timer:Convert( nTime ), CL.White, " (", CL.Yellow, differenceText, CL.White, ") Rank: ", CL.Blue, "1", CL.White, "/", CL.Blue, totalRank )

				Core:Broadcast( "Sound", { nStage + 14, newRank, ply:GetInfoNum( "sl_sound_theme", 0 ) } )
				Stage:LoadRecords()
			else
				Core:SendColor( ply, "Stage [", CL.Yellow, "Stage " .. nStage, CL.White, "] finished with Rank ", CL.Blue, newRank, CL.White, "/", CL.Blue, totalRank )
				Core:Send( ply, "Sound", { nStage + 14, newRank, ply:GetInfoNum( "sl_sound_theme", 0 ) } )

				Stage:LoadRecords( ply )
			end
		end )
	else
		SQL:Prepare(
	    "UPDATE game_stages SET nTime = {0}, szDate = {1}, vPrestrafe = {2} WHERE szMap = {3} AND szUID = {4} AND nStage = {5} AND nStyle = {6}",
			{ nTime, date, prespeed, map, steamid, nStage, nStyle }
		):Execute( function( _, _, szError )
			if szError then
				Core:Send( ply, "Print", { "Surf Timer", "Your time failed to submit, please contact an administrator for a solution!" } )
			return end

			if (newRank == 1) then
				local timeDifference = currentRecord and (nTime - currentRecord[1]) or ""
				local differenceText = timeDifference != "" and (timeDifference >= 0 and "+" or "-" ) or ""
				differenceText = "WR " .. differenceText .. (timeDifference != "" and Timer:Convert(math.abs(timeDifference)) or "N/A")

				Core:BroadcastColor( CL.Yellow, name, CL.White, " beat a ", CL.Green, nStyle != 1 and ("* " .. Core:StyleName( nStyle ) .. " * ") or "", CL.White, "stage record! Stage: [", CL.Yellow, "Stage " .. nStage,
			 		CL.White, "] Time: ", CL.Blue, Timer:Convert( nTime ), CL.White, " (", CL.Yellow, differenceText, CL.White, ") Rank: ", CL.Blue, "1", CL.White, "/", CL.Blue, totalRank )

				Core:Broadcast( "Sound", { nStage + 14, newRank, ply:GetInfoNum( "sl_sound_theme", 0 ) } )
				Stage:LoadRecords()
			else
				Core:SendColor( ply, "Stage [", CL.Yellow, "Stage " .. nStage, CL.White, "] improved with Rank ", CL.Blue, newRank, CL.White, "/", CL.Blue, totalRank )
				Core:Send( ply, "Sound", { nStage + 14, newRank, ply:GetInfoNum( "sl_sound_theme", 0 ) } )

				Stage:LoadRecords( ply )
			end
		end )
	end

	-- Just like sv_timer.lua, this gets moved down the queue due to MySQL issues --
	Bot:EndStageRun(ply, nTime, nStage)

	ply.StageRecords[ nStyle ][ nStage ] = { nTime, prespeed }
end

function Stage:RequestPrestrafe( ply )
	local isStaged = (Timer.Type == 1)
	if !isStaged then return end

	local currentPrestrafe = ply.StagePrestrafe
	if !currentPrestrafe then currentPrestrafe = 0 end

	local returnMessage = "Start: " .. math.Round( currentPrestrafe ) .. " u/s"

	local currentStyle = ply.Style
	local currentStage = ply:GetNWInt "Stage"

	local prestrafeType = tonumber( ply:GetInfo "sl_comparison_type" )
	if (prestrafeType == 2) then
		local recordPrestrafe = Stage.MapRecords[ currentStyle ][ currentStage ] and Stage.MapRecords[ currentStyle ][ currentStage ][ 4 ]
		if recordPrestrafe then
			local prestrafeDifference = math.Round( currentPrestrafe - recordPrestrafe )
			local differenceText = (prestrafeDifference > 0 and "+") or ""

			returnMessage = "WR: " .. differenceText .. prestrafeDifference
		end
	elseif (prestrafeType == 1) then
		local bestPrestrafe = ply.StageRecords[ currentStyle ][ currentStage ] and ply.StageRecords[ currentStyle ][ currentStage ][ 2 ]
		if bestPrestrafe then
			local prestrafeDifference = math.Round( currentPrestrafe - bestPrestrafe )
			local differenceText = (prestrafeDifference > 0 and "+") or ""

			returnMessage = "PB: " .. differenceText .. prestrafeDifference
		end
	elseif (prestrafeType == 3) then
		local wrMessage = "Start: " .. math.Round( currentPrestrafe ) .. " u/s"
		local pbMessage = ""

		local recordPrestrafe = Stage.MapRecords[ currentStyle ][ currentStage ] and Stage.MapRecords[ currentStyle ][ currentStage ][ 4 ]
		local bestPrestrafe = ply.StageRecords[ currentStyle ][ currentStage ] and ply.StageRecords[ currentStyle ][ currentStage ][ 2 ]
		if recordPrestrafe then
			local prestrafeDifference = math.Round( currentPrestrafe - recordPrestrafe )
			local differenceText = (prestrafeDifference > 0 and "+") or ""

			wrMessage = "WR: " .. differenceText .. prestrafeDifference
		end

		if bestPrestrafe then
			local prestrafeDifference = math.Round( currentPrestrafe - bestPrestrafe )
			local differenceText = (prestrafeDifference > 0 and "+") or ""

			pbMessage = " | PB: " .. differenceText .. prestrafeDifference
		end

		returnMessage = wrMessage .. pbMessage
	end

	Core:Send( ply, "Timer", { "Prestrafe", returnMessage } )
end

function Stage.GetTotal( nStyle, nStage )
	local total = 0
	local index = Stage.MapTop[nStyle][nStage]

	if !index then return total end
	total = #Stage.MapTop[nStyle][nStage]

	return total
end

function Stage.GetRank( nTime, nStyle, nStage )
	local rank = 1
	local index = Stage.MapTop[nStyle][nStage]
	if !index then return rank end

	for i = 1, #index do
		local time = index[i][1]
		if nTime >= time then
			rank = rank + 1
		continue end

		break
	end

	return rank
end


-- Don't use this on bots, use the following functions below for bots --
function Stage.SetInfo( ply, stage )
	if (Timer.Type != 1) then return end
	if !stage then stage = 1 end

	local style = ply.Style
	local isBonus = string.StartWith( Core:StyleName( style ), "Bonus" )

	local pb = ply.StageRecords[style]
	local pbValue
	if isBonus then
		pbValue = pb and pb[1] or 0
	else
		pbValue = pb and pb[stage] and pb[stage][1] or 0
	end

	ply:SetNWInt( "Stage", stage )
	ply:SetNWFloat( "StageRecord", pbValue )
end

-- This should only be used for bots as they don't share the same metamethods as real players --
Stage.BotStore = {}
function Stage.GetBest( bot, steamid )
	if !bot or !steamid then
		Surf:Notify( "Error", "Attempted to get bot stage metadata without providing a valid bot or steamid" )
	return end

	bot.StageRecords = {}

	for _,style in pairs( _C.Style ) do
		bot.StageRecords[ style ] = {}
	end

	local query = [[
			SELECT *
				FROM game_stages
			 WHERE szMap = {0} AND szUID = {1}
	]]

	SQL:Prepare(
		query,
		{ game.GetMap(), steamid }
	):Execute( function( Rec, varArg, szError )
		if !Rec or !Rec[1] then return end

		for _,data in pairs( Rec ) do
			local nStage, nStyle = data["nStage"], data["nStyle"]
			local nTime = data["nTime"]
			local prespeed = data["vPrestrafe"]

			bot.StageRecords[nStyle][nStage] = { nTime, prespeed }
		end

		Stage.SetBest( bot, 1 )
	end )
end

function Stage.SetBest( bot, stage )
	local isStaged = (Timer.Type == 1)
	if !isStaged then return end

	if !bot or !stage then
		Surf:Notify( "Error", "Attempted to set bot stage metadata without providing a valid bot or stage" )
	return end

	if !bot.StageRecords or (#bot.StageRecords <= 0) then
		bot:SetNWFloat( "StageRecord", 0 )
	return end

	local style = bot:GetNWInt "Style"
	local isStagedStyle = (style > 14 and style < 40)
	if isStagedStyle then
		stage = (style - 14)
		style = 1
	end

	local best = bot.StageRecords[style][stage]
	bot:SetNWInt( "Stage", stage )

	if !best then
		bot:SetNWFloat( "StageRecord", 0 )
	return end

	bot:SetNWFloat( "StageRecord", best[1] )
end

-- Determine if we should distribute SideTimer data, never gets sent on Linear Maps --
local function shouldDistribute()
	local isStaged = (Timer.Type == 1)
	if !isStaged then return end

	return true
end

Stage.MapRecords = {}
Stage.MapTop = {}

for _,style in pairs( _C.Style ) do
	Stage.MapRecords[ style ] = {}
	Stage.MapTop[ style ] = {}
end

-- Added support for stage pb loading for individual players --
function Stage:LoadRecords( ply )
	local isPlayer = ply and IsValid(ply)
	if isPlayer then
		if !ply.StageRecords then
			ply.StageRecords = {}

			for _,style in pairs( _C.Style ) do
				ply.StageRecords[ style ] = {}
			end
		end

		local query = [[
				SELECT *
					FROM game_stages
				 WHERE szMap = {0} AND szUID = {1}
		]]

		SQL:Prepare(
			query,
			{ game.GetMap(), ply:SteamID() }
		):Execute( function( Rec, varArg, szError )
			ply.StageRecords = {}

			for _,style in pairs( _C.Style ) do
				ply.StageRecords[ style ] = {}
			end

			ply.LoadedStageRecs = true

			if !Rec or (#Rec == 0) then return end

			for _,data in pairs( Rec ) do
				local nStage, nStyle = data["nStage"], data["nStyle"]
				local nTime = data["nTime"]
				local prespeed = data["vPrestrafe"]

				ply.StageRecords[nStyle][nStage] = { nTime, prespeed }
			end

			-- Hacky way to do this but this makes bonuses work for SideTimer stats --
			ply.StageRecords[4] = ply.Records[4]
			for i = 2, 10 do
				local styleID = Core:GetStyleID( "Bonus " .. i )
				if !styleID then continue end

				ply.StageRecords[styleID] = ply.Records[styleID]
			end

			Stage.SendInfo( ply )

			Surf:Notify( "Debug", "Loaded stage stats for user [Player: " .. ply:Name() .. "]" )
		end )
	else
		local query = [[
				SELECT game_stages.szUID,
							 game_stages.nStyle,
							 game_stages.nTime,
							 game_stages.vPrestrafe,
							 game_stages.nStage,
							 game_playerinfo.szLastName
					FROM game_stages
		INNER JOIN game_playerinfo
						ON game_stages.szUID = game_playerinfo.szUID
				 WHERE szMap = {0}
			ORDER BY nTime ASC
		]]

		SQL:Prepare(
			query,
			{ game.GetMap() }
		):Execute( function( Rec, _, szError )
			if !Rec or (#Rec == 0) then return end

			Stage.MapRecords = {}
			Stage.MapTop = {}

			for _,style in pairs( _C.Style ) do
				Stage.MapRecords[ style ] = {}
				Stage.MapTop[ style ] = {}
			end

			for _,data in pairs( Rec ) do
				local nStage, nStyle = data["nStage"], data["nStyle"]
				local nTime = data["nTime"]
				local name, steamid = data["szLastName"], data["szUID"]
				local prespeed = data["vPrestrafe"]

				local index = Stage.MapRecords[nStyle][nStage]
				if !index then
					Stage.MapRecords[nStyle][nStage] = { nTime, name, steamid, prespeed }

					Stage.MapTop[nStyle][nStage] = {}
					table.insert( Stage.MapTop[nStyle][nStage], { nTime, name, steamid, prespeed } )
				else
					table.insert( Stage.MapTop[nStyle][nStage], { nTime, name, steamid, prespeed } )
				end
			end

			-- Hacky way to do this but this makes bonuses work for SideTimer stats --
			local td = Timer.MapRecords[4]
			if td then
				Stage.MapRecords[4] = { td[3], td[2], td[1], td[6] }
			end

			for i = 2, 10 do
				local styleID = Core:GetStyleID( "Bonus " .. i )
				if !styleID then continue end

				td = Timer.MapRecords[styleID]
				if td then
					Stage.MapRecords[styleID] = { td[3], td[2], td[1], td[6] }
				end
			end
		end )
	end
end

function Stage.GenerateRecordList( ply, style, stage, map )
	if !ply or !IsValid(ply) then return end

	if !style then style = 1 end
	if !stage or (stage == 0) then stage = 1 end
	if !map then map = game.GetMap() end
	map = string.lower( map )

	local isValidMap = RTV:MapExists( map )
	if !isValidMap then
		Core:SendColor( ply, "The map ", CL.Yellow, map, CL.White, " does not exist." )
	return end

	local styleName = Core:StyleName( style )
	local isBonus = string.StartWith( styleName, "Bonus" )
	if isBonus then
		style = 1
	end

	local title = "Top 100 | Stage " .. stage .. " | " .. map
	if (style != 1) then
		title = styleName .. " | " .. title
	end

	local tab = {}
	tab[0] = title

	SQL:Prepare(
		"SELECT * FROM (SELECT * FROM game_stages WHERE nStyle = {0} AND nStage = {1} AND szMap = {2} ORDER BY nTime ASC LIMIT 100) t1 INNER JOIN game_playerinfo ON t1.szUID = game_playerinfo.szUID ORDER BY nTime ASC",
		{ style, stage, map }
	):Execute( function( StageInfo )
		local stageRecords = StageInfo
		if !stageRecords or (#stageRecords == 0) then
			Core:SendColor( ply, "No stage records exist for map ", CL.Yellow, map )
		return end

		local stageRecord = 0
		for i = 1, #stageRecords do
			local index = stageRecords[i]
			if !index then break end

			local time, name, difference = index.nTime, index.szLastName, ""
			local steam, date = index.szUID, index.szDate

			if (i == 1) then
				stageRecord = time
				difference = "+" .. Timer:Convert( 0 )
			else
				difference = "+" .. Timer:Convert( time - stageRecord )
			end

			time = Timer:Convert( time )

			table.insert( tab, { time, difference, name, steam, date } )
		end

		Core:Send( ply, "GUI_Open", { "MapTop", tab } )
	end )
end

-- Send info to the client for SideTimer
function Stage.BroadcastInfo()
	if !shouldDistribute() then return end
	local records = Stage.MapRecords

	Core:Broadcast( "SideTimer", { nil, records } )
end

function Stage.SendInfo( ply )
	if !shouldDistribute() then return end

	local map = { Timer.Tier, Timer.Type }
	local records = Stage.MapRecords
	local personal = ply.StageRecords
	local stages = Zones:GetStageAmount()

	Core:Send( ply, "SideTimer", { map, records, personal, stages } )
end

local function SendClientRecords( ply )
	if !IsValid( ply ) then return end
	if ply:IsBot() then return end

	Stage:LoadRecords( ply )
	Stage.SendInfo( ply )
end
hook.Add( "PlayerInitialSpawn", "surf_stages.SendClientRecords", SendClientRecords )
