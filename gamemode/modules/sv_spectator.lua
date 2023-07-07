Spectator = {}
Spectator.Modes = {
	OBS_MODE_IN_EYE,
	OBS_MODE_CHASE,
	OBS_MODE_ROAMING
}

--[[
	Author: Niflheimrx
	Description: Enhanced AFK Extension, it will recount RTV votes and send a player to spectator if they are AFK
]]--

do
	local SMAFK = {}

	-- Easy calls --
	local ct = CurTime

	-- How long in minutes before the player is considered AFK
	local afkMinutes = 5

	-- How long in minutes before the player will get kicked for being afk (when the server is full) --
	local afkKickMinutes = 10

	-- Should admins bypass this feature? And should they be notified when a player is AFK --
	local adminBypass = false
	local adminNotify = true

	-- Do the AFK hooks --
	hook.Add("PlayerInitialSpawn", "sm_afk_playerinitialspawn", function(ply)
		ply.AFK = {
			Away = false,
			LastActivity = ct()
		}
	end)

	hook.Add("PlayerSay", "sm_afk_playersay", function(ply)
		ply.AFK.LastActivity = ct()

		if ply.AFK.Away then
			SMAFK:SetAFK(ply, false)
		end
	end)

	hook.Add("KeyPress", "sm_afk_keypress", function(ply)
		ply.AFK.LastActivity = ct()

		if ply.AFK.Away then
			SMAFK:SetAFK(ply, false)
		end
	end)

	local function IsImmune(ply)
		return adminBypass and Admin:CanAccess(ply, Admin.Level.Moderator)
	end

	-- AFK Functions --
	function SMAFK:SetAFK(ply, afk)
		ply.AFK.Away = afk
		ply:SetNWBool("sm_afk", afk)

		local name = ply:Nick()
		local admins = Admin:GetOnlineAdmins(ply)

		if adminNotify then
			Core:SendColorBase(admins, CL.Yellow, name, CL.White, afk and " has gone AFK" or " has come back from being AFK")
		else
			Core:SendColor(ply, "You have ", afk and "gone AFK" or "come back from being AFK")
		end

		Surf:Notify("Debug", "Player AFK Status Toggled [Player: " .. name .. "] [State: " .. (afk and "enabled" or "disabled") .. "]")
	end

	function SMAFK:CheckAFK()
		for _,ply in ipairs(player.GetHumans()) do
			if (!ply.AFK.Away and !IsImmune(ply) and (ct() - ply.AFK.LastActivity) > (afkMinutes * 60)) then
				SMAFK:SetAFK(ply, true)
			end
		end

		RTV:CheckVotes()
	end

	function SMAFK:KickAFK()
		if (player.GetCount() < game.MaxPlayers()) then return end -- Only kick when the server is full

		for _,ply in ipairs(player.GetHumans()) do
			if (ply.AFK.Away and !IsImmune(ply) and (ct() - ply.AFK.LastActivity) > (afkKickMinutes * 60)) then
				ply.DCReason = "Kicked for being AFK too long"
				ply:Kick "You were kicked from the server for being AFK too long"
			end
		end
	end

	local function AFKController()
		SMAFK:CheckAFK()
		SMAFK:KickAFK()
	end
	timer.Create("sm_afk_controller", 60, 0, AFKController)

	-- Get current amount of AFK players --
	function Spectator:GetAFK()
		local tab = {}

		for _,ply in ipairs(player.GetHumans()) do
			if ply.AFK.Away then
				table.insert(tab, ply)
			end
		end

		return #tab
	end
end

local function GetAlive()
	local d = {}

	for k,v in pairs( player.GetAll() ) do
		if v:Team() == _C.Team.Players and v:Alive() then
			table.insert( d, v )
		end
	end

	return d
end

local function PlayerPressKey( ply, key )
	if not IsValid( ply ) then return end
	if ply:IsBot() then return end

	if ply:Team() != TEAM_SPECTATOR then return end

	if not ply.SpectateID then ply.SpectateID = 1 end
	if not ply.SpectateType then ply.SpectateType = 1 end

	if key == IN_ATTACK then
		local ar = GetAlive()
		ply.SpectateType = 1
		ply.SpectateID = ply.SpectateID + 1
		Spectator:Mode( ply, true )
		Spectator:Change( ar, ply, true )
	elseif key == IN_ATTACK2 then
		local ar = GetAlive()
		ply.SpectateType = 1
		ply.SpectateID = ply.SpectateID - 1
		Spectator:Mode( ply, true )
		Spectator:Change( ar, ply, false )
	elseif key == IN_RELOAD then
		local ar = GetAlive()
		if #ar == 0 then
			ply.SpectateType = #Spectator.Modes
			Spectator:Mode( ply, true )
		else
			local bRespec = ply.SpectateType == #Spectator.Modes
			ply.SpectateType = ply.SpectateType + 1 > #Spectator.Modes and 1 or ply.SpectateType + 1
			Spectator:Mode( ply, nil, bRespec )
		end
	end
end
hook.Add( "KeyPress", "SpectatorKey", PlayerPressKey )

function Spectator:Change( ar, ply, forward )
	local previous = ply:GetObserverTarget()

	if #ar == 1 then
		ply.SpectateID = forward and ply.SpectateID - 1 or ply.SpectateID + 1
		return
	end

	if not ar[ ply.SpectateID ] then
		ply.SpectateID = forward and 1 or #ar
		if not ar[ ply.SpectateID ] then
			return Command.Spectate( ply )
		end
	end

	ply:SpectateEntity( ar[ ply.SpectateID ] )
	Spectator:Checks( ply, previous )
end

function Spectator:Mode( ply, cancel, respec )
	if ply.SpectateType == #Spectator.Modes and not cancel then
		Spectator:End( ply, ply:GetObserverTarget() )
	end

	ply:Spectate( Spectator.Modes[ ply.SpectateType ] )
	Core:Send( ply, "Spectate", { "Mode", ply.SpectateType } )

	if ply.SpectateType != #Spectator.Modes and respec then
		Spectator:Checks( ply )
	end
end

function Spectator:End( ply, watching )
	if not IsValid( watching ) or ply.Incognito then return end
	Spectator:Notify( watching, ply, true )
	Spectator:NotifyWatchers( watching, ply )
end

function Spectator:New( ply )
	local ar = GetAlive()
	if #ar == 0 then
		ply.SpectateType = #Spectator.Modes
		Spectator:Mode( ply, true )
	else
		ply.SpectateType = 1

		if not ply.SpectateID then ply.SpectateID = 1 end
		if not ar[ ply.SpectateID ] then ply.SpectateID = 1 end

		ply:Spectate( Spectator.Modes[ ply.SpectateType ] )
		ply:SpectateEntity( ar[ ply.SpectateID ] )
		Core:Send( ply, "Spectate", { "Mode", ply.SpectateType } )
		Spectator:Checks( ply )

		-- Check if other players are spectating this player --
		for _,obj in pairs( player.GetHumans() ) do
			if !IsValid(obj) then continue end
			if !obj.Spectating then continue end

			local target = obj:GetObserverTarget()
			if (target == ply) then
				Spectator:New( obj )
			end
		end
	end
end

function Spectator:NewById( ply, szSteam, bSwitch, szName )
	local ar = GetAlive()
	local target = { ID = nil, Ent = nil }
	local bBot = szSteam == "NULL"

	for id,p in pairs( ar ) do
		if (bBot and p:IsBot() and szName and p:Name() == szName) or (tostring( p:SteamID() ) == tostring( szSteam )) then
			target.Ent = p
			target.ID = id
			break
		end
	end

	if target.Ent then
		local previous = bSwitch and ply:GetObserverTarget() or nil

		ply.SpectateType = 1
		ply.SpectateID = target.ID
		ply:Spectate( Spectator.Modes[ ply.SpectateType ] )
		ply:SpectateEntity( target.Ent )
		Core:Send( ply, "Spectate", { "Mode", ply.SpectateType } )

		Spectator:Checks( ply, previous )

		-- Check if other players are spectating this player --
		for _,obj in pairs( player.GetHumans() ) do
			if !IsValid(obj) then continue end
			if !obj.Spectating then continue end

			local target = obj:GetObserverTarget()
			if (target == ply) then
				Spectator:NewById( obj, szSteam, bSwitch, szName )
			end
		end
	else
		Core:Send( ply, "Print", { "General", Lang:Get( "SpectateTargetInvalid" ) } )
	end
end

function Spectator:Checks( ply, previous )
	if ply.Incognito then
		local target = ply:GetObserverTarget()
		if IsValid( target ) then
			return Spectator:NotifyWatchers( target )
		else
			return false
		end
	end

	local current = ply:GetObserverTarget()
	if IsValid( current ) then
		if current:IsBot() then
			Spectator:NotifyBot( current )
		else
			Spectator:Notify( current, ply )
		end
	end

	if IsValid( previous ) then
		Spectator:Notify( previous, ply, true )
	end
end

function Spectator:Notify( target, ply, bLeave )
	if bLeave then
		Spectator:NotifyWatchers( target )
		return Core:Send( target, "Spectate", { "Viewer", true, ply:Name(), ply:SteamID() } )
	else
		Core:Send( target, "Spectate", { "Viewer", false, ply:Name(), ply:SteamID() } )
	end

	Spectator:NotifyWatchers( target )
end

function Spectator:NotifyBot( bot )
	if not Bot:Exists( bot.Style ) then
		Bot:NotifyRestart( bot.Style )
	end

	Spectator:NotifyWatchers( bot )
end

function Spectator:PlayerRestart( ply )
	local nTimer = ply.Tb or ply.Tn

	local Watchers = {}
	for _,p in pairs( player.GetHumans() ) do
		if not p.Spectating or p.Incognito then continue end
		local ob = p:GetObserverTarget()
		if IsValid( ob ) and ob == ply then
			table.insert( Watchers, p )
		end
	end

	Core:Send( Watchers, "Spectate", { "Timer", false, nTimer, (ply.Record and ply.Record > 0) and ply.Record or nil, CurTime(), "Save" } )
	ply.Watchers = Watchers
end

function Spectator:PlayerStageRestart( ply )
	local nTimer = ply.Tb or ply.Tn
	local sTimer = ply.Ts

	local Watchers = {}
	for _,p in pairs( player.GetHumans() ) do
		if not p.Spectating or p.Incognito then continue end
		local ob = p:GetObserverTarget()
		if IsValid( ob ) and ob == ply then
			table.insert( Watchers, p )
		end
	end

	Core:Send( Watchers, "Spectate", { "Timer", false, nTimer, (ply.Record and ply.Record > 0) and ply.Record or nil, CurTime(), "Save", sTimer } )
	ply.Watchers = Watchers
end

function Spectator:NotifyWatchers( ply, ending )
	local SpectatorList, Watchers, Incognitos = {}, {}, {}
	for _, p in pairs( player.GetHumans() ) do
		if not p.Spectating then continue end
		if IsValid( ending ) and p == ending then continue end

		local ob = p:GetObserverTarget()
		if IsValid( ob ) and ob == ply then
			if p.Incognito then
				table.insert( Incognitos, p )
			else
				table.insert( Watchers, p )
				table.insert( SpectatorList, p:Name() )
			end
		end
	end

	if #SpectatorList == 0 then
		SpectatorList = nil
	end

	local nTimer = ply.Tb or ply.Tn
	local sTimer = ply.Ts
	local data = {}

	if ply:IsBot() then
		data = Bot:GenerateNotify( ply.Style, SpectatorList )
		if not data then return end
	else
		data = { "Timer", false, nTimer, (ply.Record and ply.Record > 0) and ply.Record or nil, CurTime(), SpectatorList, sTimer }
	end

	if #Watchers > 0 then
		Core:Send( Watchers, "Spectate", data )
	end

	if #Incognitos > 0 then
		Core:Send( Incognitos, "Spectate", data )
	end

	ply.Watchers = Watchers
end

-- 05/07/2021: Add metamethod to get all spectators, even those in Incognito
local PLAYER = FindMetaTable "Player"
function PLAYER:GetSpectating()
	return self:GetObserverTarget()
end

function PLAYER:GetSpectators(addself)
	local spectators = player.GetAll()

	for i = #spectators, 1, -1 do
		if spectators[i]:GetSpectating() != self then
			table.remove(spectators, i)
		end
	end

	if addself then
		table.insert(spectators, self)
	end

	return spectators
end

function Spectator:GetAlive() return GetAlive() end
