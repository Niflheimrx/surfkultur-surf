--[[
	Author: Niflheimrx
	Description: Handles main timer related info
							 I redid this because I wanted this module to be more efficient (and make changes to the SideTimer)
]]--


-- Define global table, local metatable and settings for later use
Timer = {}
Timer.Multiplier = 1
Timer.BonusMultiplier = 1
Timer.Tier = 1
Timer.Type = 0
Timer.Options = 0
Timer.PlayCount = 1

local PLAYER = FindMetaTable( "Player" )
local CT = CurTime
local CAPVEL = 380
local CAPVELADJUST = 300

local DISCORD_WR_WEBHOOK = file.Read("flow-surf-wr-webhook.txt", "DATA")

-- Validity checks for the Main Timer
local function canUseMainTimer( ply )
	-- No nulls, no skynet --
	if !ply or !IsValid( ply ) then return end
	if ply:IsBot() then return end

	-- Check for eligibility based on state/styles --
	local isBonus = string.StartWith( Core:StyleName( ply.Style ), "Bonus" )
	if isBonus then return end

	-- Check if the player is teleporting --
	if ply.MovePos then return end

	return true
end

-- Validity checks for the Bonus Timer
local function canUseBonusTimer( ply )
	-- No nulls, no skynet --
	if !ply or !IsValid( ply ) then return end
	if ply:IsBot() then return end

	-- Check for eligibility based on state/styles --
	local isBonus = string.StartWith( Core:StyleName( ply.Style ), "Bonus" )
	if !isBonus then return end

	-- Check if the player is teleporting --
	if ply.MovingPos then return end

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

-- Playercall that runs when a player starts their timer
function PLAYER:StartTimer()
	-- Can the client use this zone? --
	if !canUseMainTimer(self) then return end

	-- Calculate Velocity for later use --
	local vel = self:GetVelocity()
	local vel2d = vel:Length2D()
	local dir = vel:GetNormalized()
	local style = self.Style

	-- Find out the maximum velocity for this zone and determine if we are allowed to telehop --
	local cappedVelocity = getVelocityCap( style )
	local canTelehop = (bit.band( Timer.Options, Zones.Options.NoStartLimit ) > 0)

	-- If we can't telehop, adjust their speed and notify them we exceeded the speed --
	if (vel2d > cappedVelocity) and !canTelehop then
		self:SetVelocity( -vel + dir * CAPVELADJUST )
		Core:SendColorSpec( self, "Max velocity exceeded! (" , CL.Yellow, math.ceil( vel2d ) .. " u/s", CL.White, ")" )
	end

	-- Modify playervalues for proper timer handling --
	self.Tn = CT()
	self.TnF = nil
	self.tCP = {}
	self.Prestrafe = vel2d

	-- Easy functions to handle different plugins --
	Bot:CleanRecording( self )
	Timer:RequestPrestrafe( self )
	Spectator:PlayerRestart( self )
	SMgrAPI:ResetStatistics( self )

	-- Let the client know we started the timer --
	Core:Send( self, "Timer", { "Map", "Start", self.Tn } )
end

-- Playercall that runs when a player resets their timer
function PLAYER:ResetTimer()
	-- Modify playervalues for proper timer handling --
	self.Tn = nil
	self.TnF = nil
	self.tCP = {}

	-- Reset anything that other plugins might need to know --
	Bot:PauseRecording( self )
	Spectator:PlayerRestart( self )
	SMgrAPI:ResetStatistics( self )

	-- Let the client know we reset our timer --
	Core:Send( self, "Timer", { "Map", "Start", self.Tn } )
end

-- Playercall that runs when a player finishes their timer
function PLAYER:StopTimer()
	-- Can the client use this zone? --
	if !canUseMainTimer(self) then return end

	-- Did the client actually start their timer? --
	if !self.Tn then return end

	-- Modify playervalues for proper timer handling --
	self.TnF = CT()

	local mapTotal = self.TnF - self.Tn
	Core:Send( self, "Timer", { "Map", "Finish", self.TnF } )

	-- Finish anything that other plugins might need to know --
	Timer:Finish( self, mapTotal )
	Bot:PauseRecording( self )
end

-- Gonna omit comments for the following functions, they work similarly above but handle bonuses only!
function PLAYER:BonusStart()
	if !canUseBonusTimer(self) then return end

	local vel = self:GetVelocity()
	local vel2d = vel:Length2D()
	local dir = vel:GetNormalized()
	local style = self.Style

	local cappedVelocity = getVelocityCap( style )
	local canTelehop = (bit.band( Timer.Options, Zones.Options.NoStartLimit ) > 0)

	if (vel2d > cappedVelocity) and !canTelehop then
		self:SetVelocity( -vel + dir * CAPVELADJUST )
		Core:SendColor( self, "Max velocity exceeded! (" , CL.Yellow, math.ceil( vel2d ) .. " u/s", CL.White, ")" )
	end

	self.Tb = CT()
	self.TbF = nil
	self.Prestrafe = vel2d

	Bot:CleanRecording( self )
	Timer:RequestPrestrafe( self )
	Spectator:PlayerRestart( self )
	SMgrAPI:ResetStatistics( self )

	Core:Send( self, "Timer", { "Map", "Start", self.Tb } )
end

function PLAYER:BonusReset()
	self.Tb = nil
	self.TbF = nil

	Bot:PauseRecording( self )
	Spectator:PlayerRestart( self )
	SMgrAPI:ResetStatistics( self )

	Core:Send( self, "Timer", { "Map", "Start", self.Tb } )
end

function PLAYER:BonusStop()
	if !canUseBonusTimer(self) then return end
	if !self.Tb then return end

	self.TbF = CT()

	local mapTotal = self.TbF - self.Tb
	Core:Send( self, "Timer", { "Map", "Finish", self.TbF } )

	-- Finish anything that other plugins might need to know --
	Timer:Finish( self, mapTotal )
	Bot:PauseRecording( self )
end

-- Playercall that runs when a player enters a prohibited zone that resets any timer
function PLAYER:StopAnyTimer()
	-- Is this entity a player or a bot, and are they in practice? --
	local isBot = self:IsBot()
	if isBot then return end

	-- Resets all timers, there's a better way to do this but i'm very lazy to even bother --
	self.Tn = nil
	self.TnF = nil
	self.Tb = nil
	self.TbF = nil
	self.Ts = nil
	self.TsF = nil

	-- Plugins should be aware of this as well --
	Bot:PauseRecording( self )
	Core:Send( self, "Timer", { "Map", "Start", self.Tn } )
end

-- Playercall that runs when a player enters the Restart zone
function PLAYER:RestartPlayer()
	-- It literally restarts them --
	Command.Restart( self )
end

-- Playercall that runs when a player enters the Stage Restart zone
function PLAYER:StageTeleport()
	-- Derived from command "stage #" --
	local stage = self:GetNWInt "Stage"
	local vPoint = Zones:GetCenterPoint( Zones.Type["Stage " .. stage] )
	if vPoint then
		self:SetPos( vPoint )
		self:SetLocalVelocity( Vector( 0, 0, 0 ) )
	end
end

-- Playercall that runs when a player enters the Anti-Telehop zone
function PLAYER:TelehopTeleport()
	-- Removes all speed from the player --
	self:SetLocalVelocity( Vector( 0, 0, 0 ) )
end

-- Table containing specific map fixes (oo aa)
local flagControl = {
	["surf_aircontrol_ksf"] = function( ply, style )
		if style == _C.Style["Bonus 2"] then
			ply:SetGravity( 4 )
		else
			ply:SetGravity( 0 )
		end
	end,
	["surf_rands"] = function( ply, style )
		if style == _C.Style["Bonus 3"] then
			ply:SetLocalVelocity( Vector( 0, 0, 0 ) )
			ply:SetPos( Vector( -3413.89, -3861.76, 1472.02 ) )
			ply:SetEyeAngles( Angle( 0.73, 179.78, 0 ) )
		end
	end,
	["surf_corruption"] = function( ply )
		ply:SetPos( Vector( -11200, -7056, 11648 ) )
	end,
	["surf_chungus_fungus"] = function(ply, style)
		if !Core.IsBonus(style) then return end

		local filter = ply:GetInternalVariable "m_iName"
		if (filter == "cp1") and (ply:GetPos().z <= 1500) then
			ply:SetPos(Vector(-12642, -2635, 1576))
			ply:SetLocalVelocity(Vector())
		elseif (filter == "cp2") and (ply:GetPos().z > 1500) then
			ply:SetPos(Vector(-12840, -2002, 1652))
			ply:SetLocalVelocity(Vector())
		end
	end,
}

-- Playercall that runs when a player enters the Flag zone
function PLAYER:SendFlags()
	local hasControl = flagControl[game.GetMap()]
	if !hasControl then return end

	local style = self.Style
	hasControl( self, style )
end

function PLAYER:SetSplit(cp)
	if !self.tCP then
		self.tCP = {}
	end

	if !self.Tn or self.TnF then return end

	local currentStyle = self.Style
	local currentTime = (CT() - self.Tn)
	self.tCP[cp] = currentTime

	local prefix = currentStyle != 1 and (Core:StyleName( currentStyle ) .. " | " ) or ""
	local best = self.PBtCP[currentStyle] and self.PBtCP[currentStyle][cp] or 0
	local timeDifference = best and (best != 0) and (currentTime - best) or ""
	local differenceText = timeDifference != "" and (timeDifference >= 0 and "+" or "-" ) or ""
	local difference = "PB " .. differenceText .. (timeDifference != "" and Timer:Convert(math.abs(timeDifference)) or "N/A")

	Core:Send(self:GetSpectators(true), "Timer", { "Checkpoint", cp, currentTime, best} )
	Core:SendColorSpec( self, CL.Green, prefix, CL.White, "Checkpoint ", CL.Yellow, cp, CL.White, ": ", CL.Blue, Timer:Convert(currentTime), CL.White, " (", CL.Yellow, difference, CL.White, ")")
end

function Timer:Finish( ply, nTime )
	if !ply.LoadedRecs then return end

	ply.CachedStyle = ply.Style

	local nStyle = ply.CachedStyle
	local currentRecord, currentBest = Timer.MapRecords[nStyle], ply.Records[nStyle]
	local prespeed = math.ceil( ply.Prestrafe )
	local cps = ply.tCP

	local isPractice = ply:GetNWBool "Practice"
	local isBonus = string.StartWith( Core:StyleName( nStyle ), "Bonus" )
	if !currentRecord and !isPractice then
		local recordString = "Congratulations! You are the first user to set a map record!"
		if isBonus then recordString = "Congratulations! You are the first user to set a bonus record!" end

		Core:SendColor( ply, recordString )
	elseif !currentBest and !isPractice then
		local recordString = "Congratulations! You have completed the map for the first time!"
		if isBonus then recordString = "Congratulations! You have completed the bonus for the first time!" end

		Core:SendColor( ply, recordString )
	end

	local difference = ""
	local differenceType = ply:GetInfoNum( "sl_comparison_type", 0 )
	if (differenceType == 3) then
		local wrDifference = "WR N/A"
		local pbDifference = " | PB N/A"

		local wrtimeDifference = currentRecord and (nTime - currentRecord[3]) or ""
		local wrdifferenceText = wrtimeDifference != "" and (wrtimeDifference >= 0 and "+" or "-" ) or ""
		wrDifference = "WR " .. wrdifferenceText .. (wrtimeDifference != "" and Timer:Convert(math.abs(wrtimeDifference)) or "N/A")

		local pbtimeDifference = currentBest and (nTime - currentBest[1]) or ""
		local pbdifferenceText = pbtimeDifference != "" and (pbtimeDifference >= 0 and "+" or "-" ) or ""
		pbDifference = " | PB " .. pbdifferenceText .. (pbtimeDifference != "" and Timer:Convert(math.abs(pbtimeDifference)) or "N/A")

		difference = wrDifference .. pbDifference
	elseif (differenceType == 2) then
		local timeDifference = currentRecord and (nTime - currentRecord[3]) or ""
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

	if isBonus then
		Core:SendColorSpec( ply, "Bonus [", CL.Yellow, Core:StyleName( nStyle ), CL.White, "] ", CL.Blue, Timer:Convert( nTime ), CL.White, " (", CL.Yellow, difference, CL.White, "). ", CL.Purple, improvementText )
	else
		Core:SendColorSpec( ply, "Map Completed ", CL.Green, nStyle != 1 and ("* " .. Core:StyleName( nStyle ) .. " * ") or "", CL.Blue, Timer:Convert( nTime ), CL.White, " (", CL.Yellow, difference, CL.White, "). ", CL.Purple, improvementText )
	end

	local speedData 		= Bot:ExportSpeedAtFrame( ply )
	local currentSpeed 	= speedData[1] .. " u/s"
	local topSpeed 			= speedData[2] .. " u/s"
	local averageSpeed 	= speedData[3] .. " u/s"
	local sync 					= SMgrAPI:GetFinishingSync( ply ) or 0

	local wantsSpeed = tobool( ply:GetInfoNum( "sl_speedstats", 0 ) )
	if wantsSpeed and !invalidStages then
		Core:SendColorSpec( ply, "Touch: [", CL.Yellow, currentSpeed, CL.White, "] Top: [", CL.Yellow, topSpeed, CL.White, "] Average: [", CL.Yellow, averageSpeed, CL.White, "]" )
	end

	if isPractice then return end

	-- If we didn't beat our time, don't proceed to print out rankings and potentially insert unintended records --
	if !didBeat then
		Core:Send( ply, "Sound", { nStyle, nil, ply:GetInfoNum( "sl_sound_theme", 0 ) } )
	return end

	-- Add a frag for this completion, it properly tracks gametracker statistics --
	ply:AddFrags(1)

	-- Setup variables for quick insert/update --
	local name = ply:Name()
	local steamid = ply:SteamID()
	local map = game.GetMap()
	local date = Timer:GetDate()

	local speedExport = Core.Util:TabToString( { speedData[2], speedData[3], currentBest and currentBest[1] or 0, sync } )

	local insertQuery = "INSERT INTO game_times VALUES ({0}, {1}, {2}, {3}, 0, {4}, {5}, {6})"
	if !isFirstTime then
		insertQuery = "UPDATE game_times SET nTime = {3}, vData = {4}, szDate = {5}, vPrestrafe = {6} WHERE szMap = {1} AND szUID = {0} AND nStyle = {2}"
	end

	SQL:Prepare(
		insertQuery,
		{ steamid, map, nStyle, nTime, speedExport, date, prespeed }
	):Execute( function( _, _, szError )
		if szError then
			Surf:Notify( "Error", "_POST failed to process on the server. Creating log..." )
			Admin:AddLog( "Failed time _POST: Time: " .. nTime .. " (" .. prespeed .. ") | Style: " .. nStyle .. " | Map: " .. map .. " | Date: " .. date, steamid, name )
		return end

		Surf:Notify( "Success", "_POST was successfully processed by the server." )
	end )

	-- Get rank woo --
	SQL:Prepare(
		"SELECT 1 + COUNT(*) AS rank, (SELECT COUNT(*) FROM game_times WHERE nStyle = {0} AND szMap = {2}) AS total FROM game_times WHERE nStyle = {0} AND szMap = {2} AND nTime < (SELECT nTime FROM game_times WHERE szUID = {1} AND nStyle = {0} AND szMap = {2})",
		{ nStyle, steamid, game.GetMap() }
	):Execute( function( rankResult, _, szError )
		if szError or (!rankResult or #rankResult == 0) then
			Core:Send( ply, "Print", { "Surf Timer", "There was an error calculating your rank, please try again later" } )
		return end

		local index = rankResult[1]
		local rank, total = index.rank, index.total

		local timeDifference = currentRecord and (nTime - currentRecord[3]) or ""
		local differenceText = timeDifference != "" and (timeDifference >= 0 and "+" or "-" ) or ""
		differenceText = "WR " .. differenceText .. (timeDifference != "" and Timer:Convert(math.abs(timeDifference)) or "N/A")

		if (rank == 1) then
			if isBonus then
				Core:BroadcastColor( CL.Yellow, name, CL.White, " beat the Bonus [", CL.Yellow, Core:StyleName( nStyle ), CL.White, "] record! Time: ", CL.Blue, Timer:Convert( nTime ), CL.White, " (", CL.Yellow, differenceText, CL.White, ") Rank: ", CL.Blue, "1", CL.White, "/", CL.Blue, total, CL.White, ". ", CL.Purple, improvementText )
			else
				Core:BroadcastColor( CL.Yellow, name, CL.White, " beat the map ", CL.Green, nStyle != 1 and ("* " .. Core:StyleName( nStyle ) .. " * ") or "", CL.White, "record! Time: ", CL.Blue, Timer:Convert( nTime ), CL.White, " (", CL.Yellow, differenceText, CL.White, ") Rank: ", CL.Blue, "1", CL.White, "/", CL.Blue, total, CL.White, ". ", CL.Purple, improvementText )
			end

		elseif (rank >= 2 and rank <= 10) then
			if isBonus then
				Core:BroadcastColor( CL.Yellow, name, CL.White, " completed [", CL.Yellow, Core:StyleName( nStyle ), CL.White, "] in the top 10! Time: ", CL.Blue, Timer:Convert( nTime ), CL.White, " (", CL.Yellow, differenceText, CL.White, ") Rank: ", CL.Blue, rank, CL.White, "/", CL.Blue, total, CL.White, ". ", CL.Purple, improvementText )
			else
				Core:BroadcastColor( CL.Yellow, name, CL.White, " completed the map ", CL.Green, nStyle != 1 and ("* " .. Core:StyleName( nStyle ) .. " * ") or "", CL.White, "in the top 10! Time: ", CL.Blue, Timer:Convert( nTime ), CL.White, " (", CL.Yellow, differenceText, CL.White, ") Rank: ", CL.Blue, rank, CL.White, "/", CL.Blue, total, CL.White, ". ", CL.Purple, improvementText )
			end
		else
			if isBonus then
				Core:BroadcastColor( CL.Yellow, name, CL.White, " completed [", CL.Yellow, Core:StyleName( nStyle ), CL.White, "] Time: ", CL.Blue, Timer:Convert( nTime ), CL.White, " (", CL.Yellow, differenceText, CL.White, ") Rank: ", CL.Blue, rank, CL.White, "/", CL.Blue, total, CL.White, ". ", CL.Purple, improvementText )
			else
				Core:BroadcastColor( CL.Yellow, name, CL.White, " completed the map", CL.Green, nStyle != 1 and (" * " .. Core:StyleName( nStyle ) .. " *") or "", CL.White, "! Time: ", CL.Blue, Timer:Convert( nTime ), CL.White, " (", CL.Yellow, differenceText, CL.White, ") Rank: ", CL.Blue, rank, CL.White, "/", CL.Blue, total, CL.White, ". ", CL.Purple, improvementText )
			end
		end

		local ptsObtained = Timer:CalculatePoints( nTime, nStyle )
		Core:SendColor( ply, "You have obtained [", CL.Blue, ptsObtained, CL.White, "] points based on the map average" )

		Core:Broadcast( "Sound", { nStyle, rank, ply:GetInfoNum( "sl_sound_theme", 0 ) } )
		Timer.ApplyPoints( nStyle )

		if (#cps == 0) then
			Timer:LoadRecords(ply)
		end

		Timer:LoadRecords()
	end )

	-- This used to be at the top of this function, but because it caused a long delay with MySQL (and multiple SQL latency errors), this now runs after the time submits (or rather it is moved down the sql queue) --
	Bot:EndRun(ply, nTime)

	if (#cps == 0) then return end

	-- Really hacky way to fix this, but because of old zones and cp systems this has to be done in order to prevent lua errors --
	local cpAmount = #cps
	for i = 1, cpAmount do
		if !cps[i] then
			cps[i] = 0
		end
	end

	cps = table.concat(cps, " ")

	local firstTimeCP = (#ply.PBtCP == 0)
	local cpInsertQuery = "INSERT INTO game_checkpoints VALUES (0, {0}, {1}, {2}, {3})"
	if !firstTimeCP then
		cpInsertQuery = "UPDATE game_checkpoints SET szData = {3} WHERE szMap = {2} AND szUID = {0} AND nStyle = {1}"
	end

	SQL:Prepare(
		cpInsertQuery,
		{steamid, nStyle, game.GetMap(), cps}
	):Execute( function(_, _, szError)
		if szError then
			Surf:Notify( "Error", "Failed to save player checkpoints" )
		return end

		Surf:Notify( "Success", "Saved player checkpoints" )
		Timer:LoadRecords( ply )
	end )
end

-- Function that returns the total amount of records on a specific style --
function Timer.GetTotal( nStyle )
	local total = 1
	local index = Timer.MapTop[nStyle]

	if !index then return total end
	total = #Timer.MapTop[nStyle]

	return total
end

-- Function that returns a player's ranking based on time and style --
function Timer.GetRank( nTime, nStyle )
	local rank = 0
	local index = Timer.MapTop[nStyle]
	if !index then return rank end

	for i = 1, #index do
		if nTime <= index[i][3] then
			return i
		end
	end

	if (rank == 0) then
		rank = #index
	end

	return rank
end

function Timer.GetRecord( style )
	local index = Timer.MapRecords[style]
	if !index then
		return { "", 0 }
	end

	local result = { "", 0 }
	if index and index[1] then
		result = { index[1][2], index[1][3] }
	end

	return result
end

function Timer.SetBest( ply )
	local style = ply.Style
	local best = 0

	local index = ply.Records[style]
	if index then
		best = index[1] or 0
	end

	ply.Record = best
	ply:SetNWFloat( "Record", best )
	ply:SetNWInt( "MapRank", 0 )

	if (best > 0) then
		local rank = Timer.GetRank( best, style )
		ply:SetNWInt( "MapRank", rank )
	end

	Core:Send( ply, "Timer", { "Record", best } )
end

-- Figures out the map average based on data already available
function Timer:RetrieveAverage( style )
	local sum = 1
	if !Timer.MapTop[style] then return sum end

	sum = 0
	for _,data in pairs( Timer.MapTop[style] ) do
		sum = sum + data[3]
	end

	local total = Timer.GetTotal( style )
	sum = sum / total

	return sum
end

-- This only predicts the points, look for the function Timer.ApplyPoints to show where points are applied
function Timer:CalculatePoints( nTime, nStyle )
	-- If we aren't provided a time, we don't give them any points (duh!) --
	if !nTime or (nTime == 0) then return 0 end

	-- Determine what the map average is and how many points we can obtain on this map (as a base) --
	local mappts = Timer:GetMultiplier( nStyle )
	local average = Timer:RetrieveAverage( nStyle )

	-- Calculate the points based on average --
	local pts = mappts * (average / nTime)

	-- Determine what the max amount of points we can achieve, same with lowest --
	local maxpts = mappts * 2
	local minpts = mappts / 4

	-- Check if we exceeded the limit --
	local higherThan = pts > maxpts
	local lowerThan = pts < minpts

	-- Readjust for the limit --
	if higherThan then
		pts = maxpts
	elseif lowerThan then
		pts = minpts
	end

	-- Give them the points obtained --
	return math.floor( pts )
end

-- Function that sends a prestrafe comparison based on client settings, only loads on Linear maps (excluding bonuses)
function Timer:RequestPrestrafe( ply )
	local isBonus = string.StartWith( Core:StyleName( ply.Style ), "Bonus" )
	local isLinear = (Timer.Type == 0)
	if !isBonus and !isLinear then return end

	local currentPrestrafe = ply.Prestrafe
	if !currentPrestrafe then currentPrestrafe = 0 end

	local returnMessage = "Start: " .. math.Round( currentPrestrafe ) .. " u/s"

	local currentStyle = ply.Style

	local prestrafeType = tonumber( ply:GetInfo "sl_comparison_type" )
	if (prestrafeType == 2) then
		local recordPrestrafe = Timer.MapRecords[ currentStyle ] and Timer.MapRecords[ currentStyle ][ 6 ]
		if recordPrestrafe then
			local prestrafeDifference = math.Round( currentPrestrafe - recordPrestrafe )
			local differenceText = (prestrafeDifference > 0 and "+") or ""

			returnMessage = "WR: " .. differenceText .. prestrafeDifference
		end
	elseif (prestrafeType == 1) then
		local bestPrestrafe = ply.Records[ currentStyle ] and ply.Records[ currentStyle ][ 2 ]
		if bestPrestrafe then
			local prestrafeDifference = math.Round( currentPrestrafe - bestPrestrafe )
			local differenceText = (prestrafeDifference > 0 and "+") or ""

			returnMessage = "PB: " .. differenceText .. prestrafeDifference
		end
	elseif (prestrafeType == 3) then
		local wrMessage = "Start: " .. math.Round( currentPrestrafe ) .. " u/s"
		local pbMessage = ""

		local recordPrestrafe = Timer.MapRecords[ currentStyle ] and Timer.MapRecords[ currentStyle ][ 6 ]
		local bestPrestrafe = ply.Records[ currentStyle ] and ply.Records[ currentStyle ][ 2 ]
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

-- Function that generates a pr menu for player pb tracking
function Timer.GeneratePRInfo( ply, steamid, style, map )
	if !ply or !IsValid(ply) then return end

	if !style then style = 1 end
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

	local tab = {}
	steamid = steamid or ply:SteamID()
	local name = (steamid == ply:SteamID() and ply:Nick() or "Unknown Player")
	local currentAmount = 0

	SQL:Prepare(
		"SELECT szUID, nTime, (SELECT szLastName FROM game_playerinfo WHERE szUID = {2}) AS szLastName FROM game_times WHERE nStyle = {0} AND szMap = {1} ORDER BY nTime ASC",
		{ style, map, steamid }
	):Execute( function( MapInfo )
		local mapRecords = MapInfo
		if !mapRecords or (#mapRecords == 0) then
			tab[0] = { "Unknown Player", map }
			tab[1] = { "Map Time: None", "Rank: N/A" }
		else
			tab[0] = { mapRecords[1].szLastName or name, map }

			local time, rank, totalRank = nil, nil, #mapRecords

			for mrank, mdata in pairs( mapRecords ) do
				if mdata.szUID == steamid then
					time = mdata.nTime
					rank = mrank
				break end
			end

			if !time then
				time = "Map Time: None"
				rank = "Rank: N/A"
			else
				time = "Map Time: " .. Timer:Convert( time )
				rank = "Rank: " .. rank .. "/" .. totalRank
			end

			tab[1] = { time, rank }
		end

		currentAmount = 1
	end )

	SQL:Prepare(
		"SELECT szUID, nTime, nStage FROM game_stages WHERE nStyle = {0} AND szMap = {1} ORDER BY nTime ASC",
		{ style, map }
	):Execute( function( StageInfo, _, szError )
		local stageRecords = StageInfo
		if !stageRecords then return end

		local stagetime, stagerank, stagetotal = {}, {}, {}
		for _, sdata in pairs( stageRecords ) do
			local stage = sdata.nStage
			local time = sdata.nTime
			local szUID = sdata.szUID

			if !stagetotal[stage] then
				stagetotal[stage] = 0
			end

			if szUID == steamid then
				stagetime[stage] = time
				stagerank[stage] = stagetotal[stage] + 1
			end

			stagetotal[stage] = stagetotal[stage] + 1
		end

		for i = 1, #stagetotal do
			local time = stagetime[i]
			local rank, totalRank = stagerank[i], stagetotal[i]

			if !time then
				time = "Stage " .. i .. ": None"
				rank = "Rank: N/A"
			else
				time = "Stage " .. i .. ": " .. Timer:Convert( time )
				rank = "Rank: " .. rank .. "/" .. totalRank
			end

			tab[currentAmount + i] = { time, rank }
		end

		currentAmount = #tab
		if (style != 1) then
			Core:Send( ply, "GUI_Open", { "PersonalRecord", {tab, style} } )
		end
	end )

	if (style == 1) then
		SQL:Prepare(
			"SELECT szUID, nStyle, nTime FROM game_times WHERE " .. Zones:GetBonusStyleString() .. " AND szMap = {0} ORDER BY nTime ASC",
			{ map }
		):Execute( function( BonusInfo, _, szError )
			local bonusRecords = BonusInfo
			if !bonusRecords then return end

			local bonustime, bonusrank, bonustotal = {}, {}, {}
			for _, bdata in pairs( bonusRecords ) do
				local bonus = Core.BonusToSequence( bdata.nStyle )
				local time = bdata.nTime
				local szUID = bdata.szUID

				if !bonustotal[bonus] then
					bonustotal[bonus] = 0
				end

				if szUID == steamid then
					bonustime[bonus] = time
					bonusrank[bonus] = bonustotal[bonus] + 1
				end

				bonustotal[bonus] = bonustotal[bonus] + 1
			end

			for i = 1, #bonustotal do
				local time = bonustime[i]
				local rank, totalRank = bonusrank[i], bonustotal[i]

				if !time then
					time = "Bonus " .. i .. ": None"
					rank = "Rank: N/A"
				else
					time = "Bonus " .. i .. ": " .. Timer:Convert( time )
					rank = "Rank: " .. rank .. "/" .. totalRank
				end

				tab[currentAmount + i] = { time, rank }
			end

			Core:Send( ply, "GUI_Open", { "PersonalRecord", {tab, style} } )
		end )
	end
end

-- Function that generates a list of records on a specific map based on style
function Timer.GenerateRecordList( ply, style, map )
	if !ply or !IsValid(ply) then return end

	if !style then style = 1 end
	if !map then map = game.GetMap() end
	map = string.lower( map )

	local isValidMap = RTV:MapExists( map )
	if !isValidMap then
		Core:SendColor( ply, "The map ", CL.Yellow, map, CL.White, " does not exist." )
	return end

	local styleName = Core:StyleName( style )
	local title = "Top 100 | " .. map
	if (style != 1) then
		title = styleName .. " | " .. title
	end

	local tab = {}
	tab[0] = title

	SQL:Prepare(
		"SELECT game_times.szUID AS szUID, nTime, game_playerinfo.szLastName AS szLastName, szDate, vData, vPrestrafe, nPoints FROM game_times INNER JOIN game_playerinfo ON game_times.szUID = game_playerinfo.szUID WHERE nStyle = {0} AND szMap = {1} ORDER BY nTime ASC LIMIT 100",
		{ style, map }
	):Execute( function( MapInfo )
		local mapRecords = MapInfo
		if !mapRecords or (#mapRecords == 0) then
			Core:SendColor( ply, "No records exist for map ", CL.Yellow, map )
		return end

		local mapRecord = 0
		for i = 1, #mapRecords do
			local index = mapRecords[i]
			if !index then break end

			local time, name, difference = index.nTime, index.szLastName, ""
			local steam, date = index.szUID, index.szDate
			local recordpiece, prestrafe, points = index.vData, index.vPrestrafe != "" and math.floor(index.vPrestrafe or 0), math.floor(index.nPoints or 0)

			if (i == 1) then
				mapRecord = time
				difference = "+" .. Timer:Convert( 0 )
			else
				difference = "+" .. Timer:Convert( time - mapRecord )
			end

			time = Timer:Convert( time )

			table.insert( tab, { time, difference, name, steam, date, recordpiece, prestrafe, points } )
		end

		Core:Send( ply, "GUI_Open", { "MapTop", tab } )
	end )
end

-- Function that returns the player's ranking for a specific map
function Timer:GetPlayerStandings( ply, target, map, style )
	if !target or !IsValid( target ) then target = ply end
	if !style then style = target.Style end
	if !map then map = game.GetMap() end

	local name = target:Name()
	local steamid = target:SteamID()

	local isValidMap = RTV:MapExists( map )
	if !isValidMap then
		Core:SendColor( ply, "The map ", CL.Yellow, map, CL.White, " does not exist." )
	return end

	local totalquery = "(SELECT COUNT(*) nTotal FROM game_times WHERE szMap = {0} AND nStyle = {1}) mapTotal, "
	local rankquery = "(SELECT COUNT(*) + 1 FROM game_times t2 WHERE szMap = {0} AND t2.nTime < t1.nTime AND nStyle = {1}) nRank"

	SQL:Prepare(
		"SELECT t1.*, " .. totalquery .. rankquery .. " FROM game_times AS t1 WHERE t1.szUID = {2} AND t1.szMap = {0} AND t1.nStyle = {1}",
		{ map, style, steamid }
	):Execute( function( RankInfo, _, szError )
		if !RankInfo or !RankInfo[1] then
			Core:SendColor( ply, CL.Yellow, name, CL.White, " is not ranked on ", CL.Yellow, map )
		return end

		local rank, total = RankInfo[1]["nRank"], RankInfo[1]["mapTotal"]
		local pb = RankInfo[1]["nTime"]

		Core:BroadcastColor( CL.Yellow, name, CL.White, " is ranked ", CL.Blue, rank, CL.White, "/", CL.Blue, total, CL.White, " with time of ",
			CL.Blue, Timer:Convert( pb ), CL.White, " on ", CL.Yellow, map )
	end )
end

-- Function that returns the record holder for a specific map
function Timer:GetInitialRecords( ply, style, data )
	if !style then style = ply.Style end
	if !data then data = game.GetMap() end

	if !string.StartWith( data, "surf_" ) then
		Core:SendColor( ply, "This map name ", CL.Yellow, data, CL.White, " is not a valid surf map" )
	return end

	local isValidMap = RTV:MapExists( data )
	if !isValidMap then
		Core:SendColor( ply, "The map ", CL.Yellow, data, CL.White, " does not exist." )
	return end

	local prefix = ""
	local group = Player:GetRankType( style, true )
	if (group != 3) then
		prefix = "* " .. Core:StyleName( style ) .. " * "
	end

	local bonusPrefix = ""
	local styleName = Core:StyleName( style )
	local isBonus = string.StartWith( styleName, "Bonus" )
	if isBonus then
		bonusPrefix = styleName .. " "
	end

	SQL:Prepare(
		"SELECT t1.szLastName szLastName, nTime, szMap FROM (SELECT nTime, szUID, nStyle, szMap FROM game_times WHERE nStyle = {0} AND szMap = {1} ORDER BY nTime ASC LIMIT 1) tResult INNER JOIN game_playerinfo t1 ON t1.szUID = tResult.szUID",
		{ style, data }
	):Execute( function( MapRecord, _, szError )
		local index = MapRecord and MapRecord[1]
		if szError or !index then
			Core:SendColor( ply, CL.Green, prefix, CL.White, "There are no ", CL.Yellow, bonusPrefix, CL.White, "records on ", CL.Yellow, data )
		return end

		local name 		= index.szLastName
		local record 	= index.nTime
		local map 		= index.szMap

		Core:BroadcastColor( CL.Green, prefix, CL.Yellow, name, CL.White, " currently has the ", CL.Yellow, bonusPrefix, CL.White, "record on ", CL.Yellow, map, CL.White, " with a time of ", CL.Blue, Timer:Convert( record ) )
	end )
end

function Timer.LoadMap()
	local query = [[
		SELECT
			*
		FROM
			game_map
		WHERE
			szMap = {0}
	]]

	SQL:Prepare(
		query,
		{ game.GetMap() }
	):Execute( function( MapInfo, _, _ )
		if !MapInfo or !MapInfo[1] then
			Surf:Notify( "Warning", "Failed to locate entries for this map, this likely means the map isn't setup yet." )
		return end

		local index = MapInfo[1]
		Timer.Tier = index.nTier or 1
		Timer.Type = index.nType or 0
		Timer.Multiplier = index.nMultiplier or 1
		Timer.BonusMultiplier = index.nBonusMultiplier or 1
		Timer.Options = index.nOptions or 0
		Timer.PlayCount = (index.nPlays or 0) + 1

		SQL:Prepare("UPDATE game_map SET nPlays = nPlays + 1 WHERE szMap = {0}", {game.GetMap()}):Execute(function() end)

		Surf:Notify( "Success", "Succesfully loaded map entry [Map: " .. game.GetMap() .. "]" )

		Zones:CheckOptions()
	end )
end

-- Determine if we should distribute SideTimer data, bonuses always get sent --
local function shouldDistribute()
	local isLinear = (Timer.Type == 0)
	if !isLinear then return end

	return true
end

Timer.MapRecords = {}
Timer.MapTop = {}

-- Load either all records from map or a personal best by player
function Timer:LoadRecords( ply )
	local isPlayer = ply and IsValid(ply)
	if isPlayer then
		if !ply.Records then
			ply.Records = {}
			ply.PBtCP = {}
		end

		local query = [[
			SELECT
				*
			FROM
				game_times
			WHERE
				szMap = {0} and szUID = {1}
		]]

		local cpquery = [[
			SELECT
				*
			FROM
				game_checkpoints
			WHERE
				szMap = {0} and szUID = {1}
		]]

		SQL:Prepare(
			query,
			{ game.GetMap(), ply:SteamID() }
		):Execute( function( Rec, _, szError )
			ply.Records = {}
			ply.PBtCP = {}

			ply.LoadedRecs = true
			Surf:Notify( "Debug", "Loaded timer stats for user [Player: " .. ply:Name() .. "]" )

			if !Rec or (#Rec == 0) then return end

			for _,data in pairs( Rec ) do
				local nStyle = data["nStyle"]
				local nTime = data["nTime"]
				local prespeed = tonumber( data["vPrestrafe"] )

				ply.Records[nStyle] = { nTime, prespeed }
			end

			Timer.SetBest( ply )
			Timer.SendInfo( ply )
		end )

		SQL:Prepare(
			cpquery,
			{ game.GetMap(), ply:SteamID() }
		):Execute( function( Rec, _, szError )
			Surf:Notify( "Debug", "Loaded checkpoint stats for user [Player: " .. ply:Name() .. "]" )

			if !Rec or (#Rec == 0) then return end

			for _,data in pairs(Rec) do
				local nStyle = data.nStyle
				local szData = string.Explode(" ", data.szData)

				ply.PBtCP[nStyle] = szData
			end
		end )
	else
		local query = [[
			SELECT
				*
			FROM
				game_times
			INNER JOIN
				game_playerinfo
			ON
				game_times.szUID = game_playerinfo.szUID
			WHERE
				szMap = {0}
			ORDER BY nTime ASC
		]]

		SQL:Prepare(
			query,
			{ game.GetMap() }
		):Execute( function( Rec, _, szError )
			if !Rec or (#Rec == 0) then
				Surf:Notify( "Warning", "Failed to find any record entries for this map (if this is a new map, remember to complete your zone setup)" )
			return end

			Timer.MapRecords = {}
			Timer.MapTop = {}

			for _,data in pairs( Rec ) do
				local nStyle = data["nStyle"]
				local nTime, date = data["nTime"], data["szDate"]
				local name, steamid = data["szLastName"], data["szUID"]
				local vdata, prespeed = data["vData"], tonumber( data["vPrestrafe"] )

				local index = Timer.MapRecords[nStyle]
				if !index then
					Timer.MapRecords[nStyle] = { steamid, name, nTime, date, vdata, prespeed }

					Timer.MapTop[nStyle] = {}
					table.insert( Timer.MapTop[nStyle], { steamid, name, nTime, date, vdata, prespeed } )
				else
					table.insert( Timer.MapTop[nStyle], { steamid, name, nTime, date, vdata, prespeed } )
				end
			end

			Timer.BroadcastInfo()
			Timer.BroadcastRecords()
		end )
	end
end

function Timer.BroadcastInfo()
	if !shouldDistribute() then return end
	local records = Timer.MapRecords

	Core:Broadcast( "SideTimer", { nil, records } )
end

function Timer.SendInfo( ply )
	if !shouldDistribute() then return end

	local map = { Timer.Tier, Timer.Type }
	local records = Timer.MapRecords
	local personal = ply.Records
	local stages = Zones:GetStageAmount()

	Core:Send( ply, "SideTimer", { map, records, personal, stages } )
end

-- This should only be used when a new map entry is inserted --
function Timer.VerifyInfo()
	local map = { Timer.Tier, Timer.Type }
	local stages = Zones:GetStageAmount()

	Core:Broadcast( "SideTimer", { map, nil, nil, stages } )
end

function Timer.SendRecords( ply )
	if !ply or !IsValid(ply) then return end

	Core:Send( ply, "Timer", { "Initial", Timer.MapRecords } )
end

function Timer.BroadcastRecords()
	Core:Broadcast( "Timer", { "Initial", Timer.MapRecords } )
end

local function SendClientRecords( ply )
	if !IsValid( ply ) then return end
	if ply:IsBot() then return end

	Timer:LoadRecords( ply )
	Timer.SendInfo( ply )
	Timer.SendRecords( ply )
end
hook.Add( "PlayerInitialSpawn", "surf_timer.SendClientRecords", SendClientRecords )

--[[
	The following functions are basically ports for the new system so we don't get any weird errors
]]--

-- Called right after a time submits to properly adjust points obtained
function Timer.ApplyPoints( style )
	local nMult = Timer:GetMultiplier( style )
	local average = Timer:RetrieveAverage( style )

	SQL:Prepare( "UPDATE game_times SET nPoints = " .. nMult .. " * (" .. average .. " / nTime) WHERE szMap = '" .. game.GetMap() .. "' AND nStyle = " .. style ):Execute( function() end )

	local nFourth, nDouble = nMult / 4, nMult * 2
	SQL:Prepare( "UPDATE game_times SET nPoints = " .. nDouble .. " WHERE szMap = '" .. game.GetMap() .. "' AND nStyle = " .. style .. " AND nPoints > " .. nDouble ):Execute( function() end )
	SQL:Prepare( "UPDATE game_times SET nPoints = " .. nFourth .. " WHERE szMap = '" .. game.GetMap() .. "' AND nStyle = " .. style .. " AND nPoints < " .. nFourth ):Execute( function() end )
end

-- Retrieve the points obtainable for a specific rank
function Timer:GetMultiplier( style )
	local isBonus = string.StartWith( Core:StyleName( style ), "Bonus" )
	if isBonus then
		return Timer.BonusMultiplier
	end

	return Timer.Multiplier
end

-- Similar to Timer.GetRank, but specifically designed for Flow Network Bots
function Timer:GetRecordID( time, style )
	local hasRecords = Timer.MapTop and Timer.MapTop[style]
	if !hasRecords then
		return 0
	end

	for pos, data in pairs( hasRecords ) do
		if time <= data[3] then
			return pos
		end
	end

	return #hasRecords + 1
end

--[[---------------------------------------------------------------------------
	I am rewriting this because there's apparently an issue where a player can use this even when its not intended to be used
	All command functionality has been scrapped alongside the interface. You can only access this with the console variables

	Things to note here:
	Global checkpoints are implemented.
	- There's a convar for it, sl_globalcheckpoints. By default this is disabled.
	- Already toggleable in the SurfTimer menu
	- Bots might not work with global checkpoints due to how they were designed. Fix for this maybe later.
-----------------------------------------------------------------------------]]

TIMER_CHECKPOINTS = {}
function Timer.SaveCheckpoint( ply )
	if !ply or !IsValid( ply ) then return end

	if !ply.Checkpoints then
		ply.Checkpoints = {}
	end

	local mapTime, bonusTime, stageTime = (ply.Tn and CurTime() - ply.Tn), (ply.Tb and CurTime() - ply.Tb), (ply.Ts and CurTime() - ply.Ts)
	local style, stage, checkpoint = ply.Style, ply:GetNWInt "Stage", ply:GetNWInt "Checkpoint"

	local ent = ply:GetObserverTarget()
	if IsValid(ent) and ent:IsBot() then
		style = ent:GetNWInt("Style", 1)
		local info = Bot:GetInfo(style)
		if info and info.Start then
			if Core.IsBonus(style) then
				bonusTime = (info.Start and CurTime() - info.Start)
			else
				mapTime = (info.Start and CurTime() - info.Start)
			end
		end
	end

	local wantsGlobalCPs = ply:GetInfo "sl_globalcheckpoints" == "1"
	if wantsGlobalCPs then
		local count = #TIMER_CHECKPOINTS + 1

		if IsValid( ent ) then
			TIMER_CHECKPOINTS[count] = { ent:GetPos(), ent:EyeAngles(), ent:GetVelocity(), CurTime(), ent:Name(), ent:GetInternalVariable "m_iName", { mapTime, bonusTime, stageTime, style, stage, checkpoint } }
		else
			TIMER_CHECKPOINTS[count] = { ply:GetPos(), ply:EyeAngles(), ply:GetVelocity(), CurTime(), ply:Name(), ply:GetInternalVariable "m_iName", { mapTime, bonusTime, stageTime, style, stage, checkpoint } }
		end

		ply.RecentCreatedCheckpoint = count
		ply.LastCheckPoint = count
		Core:SendColor(ply, "Created Global Checkpoint #", CL.Blue, count, CL.White, ", use ", CL.Yellow, "!tele " .. count, CL.White, " to teleport to it")
	else
		local count = #ply.Checkpoints + 1
		if IsValid( ent ) then
			ply.Checkpoints[count] = { ent:GetPos(), ent:EyeAngles(), ent:GetVelocity(), CurTime(), ent:GetInternalVariable "m_iName", { mapTime, bonusTime, stageTime, style, stage, checkpoint } }
		else
			ply.Checkpoints[count] = { ply:GetPos(), ply:EyeAngles(), ply:GetVelocity(), CurTime(), ply:GetInternalVariable "m_iName", { mapTime, bonusTime, stageTime, style, stage, checkpoint } }
		end

		ply.LastCheckPoint = count
		Core:SendColor(ply, "Created Checkpoint #", CL.Blue, count, CL.White, ", use ", CL.Yellow, "!tele " .. count, CL.White, " to teleport to it")
	end
end

function Timer.LoadCheckpoint( ply, _, _, _, point )
	if !ply or !IsValid( ply ) then return end

	local isPractice = ply:GetNWBool "Practice"
	if !isPractice then
		Core:SendColor( ply, "You need to disable your SurfTimer to use this" )
	return end

	local wantsGlobal = (ply:GetInfo "sl_globalcheckpoints" == "1")
	if wantsGlobal then
		if #TIMER_CHECKPOINTS == 0 then
			Core:Send( ply, "Print", { "Surf Timer", "There are no global checkpoints available." } )
		return end

		local recent = { nil, -1 }
		for _,c in pairs( ply.Checkpoints ) do
			if c[ 4 ] > recent[ 2 ] then
				recent = { c, c[ 4 ] }
			end
		end

		if point then
			local cp = TIMER_CHECKPOINTS[point]
			if !cp then
				Core:SendColor(ply, "Global Checkpoint #", CL.Blue, point, CL.White, " does not exist")
			return end

			ply:SetPos( cp[ 1 ] )
			ply:SetEyeAngles( cp[ 2 ] )
			ply:SetLocalVelocity( cp[ 3 ] )
			ply:SetSaveValue("m_iName", cp[6] or "")

			local mapTime, bonusTime, stageTime = cp[7][1], cp[7][2], cp[7][3]
			local style, stage, checkpoint = cp[7][4], cp[7][5], cp[7][6]
			ply.Tn = mapTime and CurTime() - mapTime
			ply.Tb = bonusTime and CurTime() - bonusTime
			ply.Ts = stageTime and CurTime() - stageTime

			--ply.Style = style
			ply:SetNWInt("Stage", stage)
			ply:SetNWInt("Checkpoint", checkpoint)

			TIMER_CHECKPOINTS[point][ 4 ] = CurTime()

			-- Requested by spider. Prevents spam when using the same checkpoint --
			if ply.LastCheckPoint != point then
				Core:SendColor(ply, "Sent to Global Checkpoint #", CL.Blue, point, CL.White, " (Created by: ", CL.Yellow, cp[5], CL.White, ")")
			end

			ply.LastCheckPoint = point
		else
			if !ply.RecentCreatedCheckpoint then
				ply.RecentCreatedCheckpoint = recent[ 1 ]
				Core:SendColor(ply, "Sent to the most recent global checkpoint")
			end

			if ply.LastCheckPoint then
				ply.RecentCreatedCheckpoint = ply.LastCheckPoint
			end

			local pt = ply.RecentCreatedCheckpoint
			local cp = TIMER_CHECKPOINTS[pt]
			ply:SetPos( cp[ 1 ] )
			ply:SetEyeAngles( cp[ 2 ] )
			ply:SetLocalVelocity( cp[ 3 ] )
			ply:SetSaveValue("m_iName", cp[6] or "")

			local mapTime, bonusTime, stageTime = cp[7][1], cp[7][2], cp[7][3]
			local style, stage, checkpoint = cp[7][4], cp[7][5], cp[7][6]
			ply.Tn = mapTime and CurTime() - mapTime
			ply.Tb = bonusTime and CurTime() - bonusTime
			ply.Ts = stageTime and CurTime() - stageTime

			--ply.Style = style
			ply:SetNWInt("Stage", stage)
			ply:SetNWInt("Checkpoint", checkpoint)

			ply.LastCheckPoint = pt
		end
	else
		if !ply.Checkpoints or #ply.Checkpoints == 0 then
			Core:SendColor(ply, "You need to create a checkpoint in order to use this")
		return end

		local recent = { nil, -1 }
		for _,c in pairs( ply.Checkpoints ) do
			if c[ 4 ] > recent[ 2 ] then
				recent = { c, c[ 4 ] }
			end
		end

		if point then
			local cp = ply.Checkpoints[point]
			if !cp then
				Core:SendColor(ply, "Checkpoint #", CL.Blue, point, CL.White, " does not exist")
			return end

			ply:SetPos( cp[ 1 ] )
			ply:SetEyeAngles( cp[ 2 ] )
			ply:SetLocalVelocity( cp[ 3 ] )
			ply:SetSaveValue("m_iName", cp[5] or "")

			local mapTime, bonusTime, stageTime = cp[6][1], cp[6][2], cp[6][3]
			local style, stage, checkpoint = cp[6][4], cp[6][5], cp[6][6]
			ply.Tn = mapTime and CurTime() - mapTime
			ply.Tb = bonusTime and CurTime() - bonusTime
			ply.Ts = stageTime and CurTime() - stageTime

			--ply.Style = style
			ply:SetNWInt("Stage", stage)
			ply:SetNWInt("Checkpoint", checkpoint)

			ply.Checkpoints[point][ 4 ] = CurTime()

			-- Do that thing up there here as well --
			if ply.LastCheckPoint != point then
				Core:SendColor(ply, "Sent to Checkpoint #", CL.Blue, point)
			end

			ply.LastCheckPoint = point
		else
			local cp = recent[ 1 ]
			ply:SetPos( cp[ 1 ] )
			ply:SetEyeAngles( cp[ 2 ] )
			ply:SetLocalVelocity( cp[ 3 ] )
			ply:SetSaveValue("m_iName", cp[5] or "")

			local mapTime, bonusTime, stageTime = cp[6][1], cp[6][2], cp[6][3]
			local style, stage, checkpoint = cp[6][4], cp[6][5], cp[6][6]
			ply.Tn = mapTime and CurTime() - mapTime
			ply.Tb = bonusTime and CurTime() - bonusTime
			ply.Ts = stageTime and CurTime() - stageTime

			--ply.Style = style
			ply:SetNWInt("Stage", stage)
			ply:SetNWInt("Checkpoint", checkpoint)
		end
	end

	local isBonus = Core.IsBonus(ply.Style)
	local isStaging = ply:GetNWBool "StageTimer"
	ply.TnF = nil
	ply.TbF = nil
	ply.TSF = nil

	if isBonus then
		Core:Send( ply, "Timer", { "Map", "Start", ply.Tb } )
		Spectator:PlayerRestart( ply )
	elseif isStaging then
		Core:Send( ply, "Timer", { "Stage", "Start", ply.Ts } )
		Spectator:PlayerStageRestart( ply )
	else
		Core:Send( ply, "Timer", { "Map", "Start", ply.Tn } )
		Spectator:PlayerRestart( ply )
	end
end
concommand.Add( "sm_loadloc", Timer.LoadCheckpoint, nil, "Loads the checkpoint for the player." )
concommand.Add( "sm_saveloc", Timer.SaveCheckpoint, nil, "Saves the checkpoint for the player." )

-- Converts a time into a readable SurfTimer format
local fl, fo, od, ot = math.floor, string.format, os.date, os.time
function Timer:Convert( ns )
	if ns > 3600 then
		return fo( "%d:%.2d:%.2d.%.2d", fl( ns / 3600 ), fl( ns / 60 % 60 ), fl( ns % 60 ), fl( ns * 100 % 100 ) )
	else
		return fo( "%.2d:%.2d.%.2d", fl( ns / 60 % 60 ), fl( ns % 60 ), fl( ns * 100 % 100 ) )
	end
end

-- Converts the current time/date into a usable string format
function Timer:GetDate()
	return od( "%Y-%m-%d %H:%M:%S", ot() )
end
