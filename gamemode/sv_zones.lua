Zones = {}
Zones.Type = {
	["Normal Start"] = 0,
	["Normal End"] = 1,
	["Bonus Start"] = 2,
	["Bonus End"] = 3,
	["Anticheat"] = 4,
	["Restart"] = 5,
	["Bonus 2 Start"] = 6,
	["Bonus 2 End"] = 7,
	["Mark"] = 8,
	["Bonus 3 Start"] = 9,
	["Bonus 3 End"] = 10,
	["Bonus 4 Start"] = 11,
	["Bonus 4 End"] = 12,
	["Bonus 5 Start"] = 13,
	["Bonus 5 End"] = 14,
	["Bonus 6 Start"] = 15,
	["Bonus 6 End"] = 16,
	["Stage 1"] = 17,
	["Stage 2"] = 19,
	["Stage 3"] = 21,
	["Stage 4"] = 23,
	["Stage 5"] = 25,
	["Stage 6"] = 27,
	["Stage 7"] = 29,
	["Stage 8"] = 31,
	["Stage 9"] = 33,
	["Stage 10"] = 35,
	["Stage 11"] = 37,
	["Stage 12"] = 39,
	["Stage 13"] = 41,
	["Stage 14"] = 43,
	["Stage 15"] = 45,
	["Stage 16"] = 47,
	["Stage 17"] = 49,
	["Stage 18"] = 51,
	["Stage 19"] = 53,
	["Stage 20"] = 55,
	["Stage 21"] = 57,
	["Stage 22"] = 59,
	["Stage 23"] = 61,
	["Stage 24"] = 63,
	["Stage End"] = 70,
	["Stage Anticheat"] = 71,
	["Checkpoint 1"] = 83,
	["Checkpoint 2"] = 84,
	["Checkpoint 3"] = 85,
	["Checkpoint 4"] = 86,
	["Checkpoint 5"] = 87,
	["Checkpoint 6"] = 88,
	["Checkpoint 7"] = 89,
	["Checkpoint 8"] = 90,
	["Checkpoint 9"] = 91,
	["Flags"] = 92,
	["Stage Reset"] = 93,
	["Anti Telehop"] = 94,
	["Anti Bhop"] = 95,
	["Bonus 7 Start"] = 96,
	["Bonus 7 End"] = 97,
	["Bonus 8 Start"] = 98,
	["Bonus 8 End"] = 99,
	["Bonus 9 Start"] = 100,
	["Bonus 9 End"] = 101,
	["Bonus 10 Start"] = 102,
	["Bonus 10 End"] = 103,
	["No Jump"] = 104,
	["Bonus Anticheat"] = 105,
}

Zones.Options = {
	NoStartLimit = 1,
	NoSpeedLimit = 2,
	NoStageLimit = 4,
	NoPrehopLimit = 8,
	NoSpeedStop = 16,
	NoBoosterfix = 32,
}

Zones.StartPoint = nil
Zones.BonusPoint = nil

for i = 2, 10 do
	Zones["Bonus " .. i .. "Point"] = nil
end

for i = 1, 24 do
	Zones["Stage " .. i .. "Point"] = nil
end

Zones.Cache = {}
Zones.Entities = {}

function Zones:Setup()
	for _,zone in pairs( Zones.Cache ) do
		local ent = ents.Create( "game_timer" )
		ent:SetPos( (zone.P1 + zone.P2) / 2 )
		ent.min = zone.P1
		ent.max = zone.P2
		ent.zonetype = zone.Type

		if zone.Type == Zones.Type["Normal Start"] then
			Zones.StartPoint = { zone.P1, zone.P2, (zone.P1 + zone.P2) / 2 }
			Zones.BotPoint = Vector( Zones.StartPoint[ 3 ].x, Zones.StartPoint[ 3 ].y, Zones.StartPoint[ 1 ].z )
		elseif zone.Type == Zones.Type["Bonus Start"] then
			Zones.BonusPoint = { zone.P1, zone.P2, (zone.P1 + zone.P2) / 2 }
		end

		for i = 2, 10 do
			if zone.Type == Zones.Type["Bonus " .. i .. " Start"] then
				Zones["Bonus " .. i .. " Point"] = { zone.P1, zone.P2, (zone.P1 + zone.P2) / 2 }
			end
		end

		ent:Spawn()
		table.insert( Zones.Entities, ent )
	end

	Timer.VerifyInfo()
end

function Zones:Reload()
	for _,zone in pairs( Zones.Entities ) do
		if IsValid( zone ) then
			zone:Remove()
			zone = nil
		end
	end

	Zones.Entities = {}

	Core:LoadZones()
end

function Zones:CheckOptions()
	local maxSpeed = 3500
	Stage.AllowTelehops = false

	if bit.band( Timer.Options, Zones.Options.NoSpeedLimit ) > 0 then
		maxSpeed = 10000
		Surf:Notify( "Debug", "Allowing higher maxvelocity due to map options [Maxvel: " .. maxSpeed .. "]" )
	end

	if bit.band( Timer.Options, Zones.Options.NoStageLimit ) > 0 then
		Stage.AllowTelehops = true
		Surf:Notify( "Debug", "Allowing stage telehops to be recorded due to map options" )
	end

	RunConsoleCommand( "sv_maxvelocity", maxSpeed )
	RunConsoleCommand( "sv_noclipspeed", 15 )

	Zones:HookTriggerPush()
end

function Zones:GetName( nID )
	for name,id in pairs( Zones.Type ) do
		if id == nID then
			return name
		end
	end

	return "Unknown"
end

function Zones:GetCenterPoint( nType )
	for _,zone in pairs( Zones.Entities ) do
		if IsValid( zone ) and zone.zonetype == nType then
			local pos = zone:GetPos()
			local height = zone.max.z - zone.min.z

			pos.z = pos.z - (height / 2)
			return pos
		end
	end
end

function Zones:GetSpawnPoint( data )
	local dx, dy, dz = data[ 2 ].x - data[ 1 ].x, data[ 2 ].y - data[ 1 ].y, data[ 2 ].z - data[ 1 ].z

	if dx > 96 then vx = dx - 32 - ((data[ 2 ].x - data[ 1 ].x) / 2) end
	if dy > 96 then vy = dy - 32 - ((data[ 2 ].y - data[ 1 ].y) / 2) end
	if dz > 32 then vz = 16 end

	local center = Vector( data[ 3 ].x, data[ 3 ].y, data[ 1 ].z )
	local out = center

	return out
end

function Zones:GetZoneBounds(nType)
	local results = {}
	for _,zone in pairs( Zones.Entities ) do
		if IsValid( zone ) and zone.zonetype == nType then
			local min, max = zone.min, zone.max
			local height = math.Round( max.z - min.z )
			if height < 5 and height > -5 then continue end

			table.insert(results, {min, max})
		end
	end

	return results
end


-- Editor
Zones.Editor = {}
Zones.Extra = {
	[4] = "Anticheat",
	[5] = "Restart",
	[8] = "Mark",
	[60] = "Stage End",
	[61] = "Stage Anticheat",
	[92] = "Flags",
	[93] = "Stage Reset",
	[94] = "Anti Telehop",
	[95] = "Anti Bhop",
	[104] = "No Jump",
	[105] = "Bonus Anticheat",
}

function Zones:StartSet( ply, ID )
	ply:SetNWBool( "Editor", true )

	if Zones.Extra[ ID ] and !ply.ZoneExtra then
		ply.ZoneExtra = true
	end

	if ID == 4 then
		Core:Send( ply, "Print", { "Admin", "The anticheat zone stops the timer. Use this to block unnecessary parts of the map." } )
	elseif ID == 5 then
		Core:Send( ply, "Print", { "Admin", "The restart zone teleports the player back to the style point. Use this to send players back to their appropiate start point." } )
	elseif ID == 8 then
		Core:Send( ply, "Print", { "Admin", "The mark zone draws a beam to highlight specific parts of the map. Use this to mark things such as restart triggers." } )
	elseif ID == 60 then
		Core:Send( ply, "Print", { "Admin", "The stage end zone allows any stage to be completed on touch. Use this if maps are designed to allow random stages." } )
	elseif ID == 71 then
		Core:Send( ply, "Print", { "Admin", "The stage anticheat zone stops the stage timer. Use this to block parts of a stage but don't want to stop the normal timer." } )
	elseif ID == 92 then
		Core:Send( ply, "Print", { "Admin", "The flag zone is coded into the gamemode to call functions. Use this zone for entity flag checks." } )
	elseif ID == 93 then
		Core:Send( ply, "Print", { "Admin", "The stage reset zone teleports the player back to their current stage. Use this to create triggers for maps that do not have it." } )
	elseif ID == 94 then
		Core:Send( ply, "Print", { "Admin", "The anti telehop zone prevents the player from jumping through stages keeping their speed. Use this to block that." } )
	elseif ID == 95 then
		Core:Send( ply, "Print", { "Admin", "The anti bhop zone prevents the player from autohoping a specific part of the map. Use this to block unnecessary jumps." } )
	elseif ID == 104 then
		Core:Send( ply, "Print", { "Admin", "The no jump zone prevents the player from jumping at all. Use this to block specific jump routes." } )
	elseif ID == 105 then
		Core:Send( ply, "Print", { "Admin", "The bonus anticheat zone stops bonus timers. Use this to block sections on bonuses only" } )
	end

	Zones.Editor[ ply ] = {
		Active = true,
		Start = ply:GetPos(),
		Type = ID
	}

	Core:Send( ply, "Admin", { "EditZone", Zones.Editor[ ply ] } )
	Core:Send( ply, "Print", { "Admin", Lang:Get( "ZoneStart" ) } )
end

function Zones:CheckSet( ply, finish, extra )
	if Zones.Editor[ ply ] then
		if finish then
			if extra then
				ply.ZoneExtra = nil
			end

			Zones:FinishSet( ply, extra )
		end

		return true
	end
end

function Zones:CancelSet( ply, force )
	Zones.Editor[ ply ] = nil
	Core:Send( ply, "Admin", { "EditZone", Zones.Editor[ ply ] } )
	Core:Send( ply, "Print", { "Admin", Lang:Get( force and "ZoneCancel" or "ZoneFinish" ) } )
end

function Zones:FinishSet( ply, extra )
	ply:SetNWBool( "Editor", false )

	local editor = Zones.Editor[ ply ]
	if !editor.End then editor.End = ply:GetPos() end

	local Start, End = editor.Start, editor.End
	local Min = util.TypeToString( Vector( math.min(Start.x, End.x), math.min(Start.y, End.y), math.min(Start.z, End.z) ) )
	local Max = util.TypeToString( Vector( math.max(Start.x, End.x), math.max(Start.y, End.y), math.max(Start.z + 128, End.z + 128) ) )

	SQL:Prepare(
		"SELECT nType FROM game_zones WHERE szMap = {0} AND nType = {1}",
		{ game.GetMap(), editor.Type }
	):Execute( function( zones )
		if zones and zones[1] and !extra then
			SQL:Prepare(
				"UPDATE game_zones SET vPos1 = {0}, vPos2 = {1} WHERE szMap = {2} AND nType = {3}",
				{ Min, Max, game.GetMap(), editor.Type }
			):Execute( function()
				Zones:CancelSet( ply )
				Zones:Reload()
			end )
		else
			SQL:Prepare(
				"INSERT INTO game_zones VALUES ({0}, {1}, {2}, {3})",
				{ game.GetMap(), editor.Type, Min, Max }
			):Execute( function()
				Zones:CancelSet( ply )
				Zones:Reload()
			end )
		end
	end )
end

-- Parse current zone data for ease of access when fetching data
function Zones:GetStageAmount()
	local int = 0
	local vPoint

	for i = 1, 24 do
		vPoint = Zones:GetCenterPoint( Zones.Type["Stage " .. i] )
		if vPoint then
			int = i
		end
	end

	return int
end

function Zones:GetBonusAmount()
	local int = 0
	local vPoint = Zones:GetCenterPoint( Zones.Type["Bonus End"] )
	if vPoint then int = 1 end

	for i = 2, 10 do
		vPoint = Zones:GetCenterPoint( Zones.Type["Bonus " .. i .. " End"] )
		if vPoint then
			int = i
		end
	end

	return int
end

-- Ported from smmod lol --
function Zones:AttemptMapTranslation(name)
	if !string.StartWith(name, "surf_") then
		return "surf_" .. name
	end

	return name
end


-- Style fetching for queryies, this is in the wrong spot but whatever
function Zones:GetBonusStyleString()
	local db = "(nStyle = 4 OR nStyle = 10 OR nStyle = 11 OR nStyle = 12 OR nStyle = 13 OR nStyle = 14 OR nStyle = 40 OR nStyle = 41 OR nStyle = 42 OR nStyle = 43)"
	return db
end

-- Zone fetching for queries, simple and out of the way
function Zones:GetBonusZoneString()
	local db = "(nType = 2 OR nType = 6 OR nType = 9 OR nType = 11 OR nType = 13 OR nType = 15 OR nType = 96 OR nType = 98 OR nType = 100 OR nType = 102)"
	return db
end

function Zones:GetStageZoneString()
	local db = "(nType > 16 AND nType < 63)"
	return db
end

function Zones:PermanentFixes()
	for _,ent in pairs( ents.GetAll() ) do
		if ent:GetRenderFX() != 0 and ent:GetRenderMode() == 0 then
			ent:SetRenderMode( RENDERMODE_TRANSALPHA )
		end
	end
end

-- Give it an entity and the gamemode will automatically generate an anti-telehoppable teleport trigger --
function Zones:GenerateSpawnZone( trigger, allowBonus )
	if !IsValid( trigger ) then return end

	local ent = ents.Create "ResetVelZone"
	ent:SetNoDraw( true )
	ent:SetMapEnt( trigger )

	ent.AllowBonuses = allowBonus

	trigger:SetSaveValue( "target", "" )

	ent:Spawn()
end

function Zones:GenerateBooster(trigger)
	if !IsValid( trigger ) then return end

	local ent = ents.Create "BoosterZone"
	ent:SetNoDraw( true )
	ent:SetMapEnt( trigger )

	ent:Spawn()
end

if file.Exists( _C.GameType .. "/gamemode/maps/" .. game.GetMap() .. ".lua", "LUA" ) then
	__HOOK = {}
	include( _C.GameType .. "/gamemode/maps/" .. game.GetMap() .. ".lua" )

	for identifier,func in pairs( __HOOK ) do
		hook.Add( identifier, identifier .. "_" .. game.GetMap(), func )
	end
end

local function RemoveGameScore()
	for _,ent in pairs( ents.FindByClass "game_score" ) do
		ent:Remove()
	end

	for _,ent in pairs( ents.FindByClass "game_player_equip" ) do
		ent:Remove()
	end
end
hook.Add( "InitPostEntity", "surf_removegamescore", RemoveGameScore )

function Zones:HookTriggerPush()
	for _,trigger in ipairs(ents.FindByClass "boosterzone") do
		trigger:Remove()
	end

	local disabled = (bit.band(Timer.Options, Zones.Options.NoBoosterfix) > 0)
	if !disabled then
		Surf:Notify("Debug", "Boosterfix is enabled")
	end

	for _,trigger in ipairs(ents.FindByClass "trigger_push") do
		if !disabled then
			local ent = ents.Create "boosterzone"
			ent:SetNoDraw(enabled)
			ent:SetMapEnt(trigger)

			ent:Spawn()
		end

		trigger:Fire(!disabled and "Disable" or "Enable")
	end
end
