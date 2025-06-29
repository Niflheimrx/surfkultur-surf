-- Shared file containing all essential information

-- Please don't change any of this except for GM.DisplayName and GM.Website, thank you.
GM.Name = "Skill Surf"
GM.DisplayName = "Skill Surf"
GM.Author = "Gravious"
GM.Author2 = "Niflheimrx"
GM.Email = ""
GM.Website = ""
GM.TeamBased = true

DeriveGamemode( "base" )
DEFINE_BASECLASS( "gamemode_base" )

_C = _C or {}
_C["Version"] = 2.02
_C["PageSize" ] = 7
_C["GameType"] = "surf"
_C["ServerName"] = "My Skill Surf"
_C["Identifier"] = "yourservername-" .. _C.GameType -- If you want clientside caching to work (lower player join usage), set this
_C["SteamGroup"] = "" -- Set this to your group URL if you want people to see a pop-up when joining for the first time (cl_init.lua at the bottom)
_C["MaterialID"] = "flow" -- Change this to the name of the folder in content/materials/

_C["Team"] = { Players = 1, Spectator = TEAM_SPECTATOR }
_C["Style"] = { Normal = 1, Sideways = 2, ["Half-Sideways"] = 3, Bonus = 4, ["Wicked"] = 6, ["Bonus 2"] = 10, ["Bonus 3"] = 11, ["Bonus 4"] = 12, ["Bonus 5"] = 13, ["Bonus 6"] = 14, ["Bonus 7"] = 40, ["Bonus 8"] = 41, ["Bonus 9"] = 42, ["Bonus 10"] = 43, ["100 Tick"] = 44, ["33 Tick"] = 45 }

_C["Player"] = {
	DefaultModel = "models/player/group01/male_01.mdl",
	BotModel = "models/player/kleiner.mdl",
	DefaultWeapon = "weapon_glock",
	JumpPower = math.sqrt( 2 * 800 * 57.0 ),
	HullMin = Vector( -16, -16, 0 ),
	HullDuck = Vector( 16, 16, 45 ),
	HullStand = Vector( 16, 16, 62 ),
	ViewDuck = Vector( 0, 0, 47 ),
	ViewStand = Vector( 0, 0, 64 )
}

_C["Prefixes"] = {
	["Surf Timer"] = Color( 52, 73, 94 ),
	["General"] = Color( 52, 152, 219 ),
	["Admin"] = Color( 76, 60, 231 ),
	["Notification"] = Color( 231, 76, 60 ),
	[_C["ServerName"]] = Color( 46, 204, 113 ),
	["Radio"] = Color( 230, 126, 34 ),
	["VIP"] = Color( 174, 0, 255 ),
	["Tips"] = Color(0, 180, 0),
}

_C["Ranks"] = {
	{ "Astronaut", color_white, 0 },
	{ "Rookie", Color(215, 219, 221), 200 },
	{ "Beginner", Color(131, 145, 146), 1000 },
	{ "Apprentice", Color(40, 180, 99), 4000 },
	{ "Skilled", Color(82, 0, 125), 8000 },
	{ "Experienced", Color(21, 0, 125), 15000 },
	{ "Advanced", Color(0, 125, 21), 25000 },
	{ "Hotshot", Color(0, 255, 0), 40000 },
	{ "Pro", Color(0, 117, 255), 75000 },
	{ "Elite", Color(255, 255, 0), 120000 },
	{ "Veteran", Color(255, 125, 0), 180000 },
	{ "Master", Color(255, 0, 255), 250000 },
	{ "Cataclysmic", Color(255, 204, 140), 320000 },
	{ "Nightmare", Color(255, 0, 0), 410000 },
	{ "Transcendent", Color(0, 192, 255), 500000 },

	[-1] = { "Retrieving...", Color( 255, 255, 255 ) },
	[-2] = { "Record Bot", Color( 255, 0, 0 ) }
}

-- Special ranks for the top 5 players on the server --
_C["SpecialRanks"] = {
	[1] = { "Stellar", Color( 0, 255, 225 ) },
	[2] = { "Divine", Color( 255, 196, 0 ) },
	[3] = { "Mythical", Color( 255, 0, 140 ) },
	[4] = { "Anomaly", Color( 162, 0, 255 ) },
	[5] = { "Neoteric", Color( 255, 0, 140 ) }
}

_C["MapTypes"] = {
	[ 0 ] = "Linear",
	[ 1 ] = "Staged"
}

util.PrecacheModel( _C.Player.DefaultModel )

include( "core_player.lua" )
include( "core_view.lua" )

local mc, mp = math.Clamp, math.pow
local bn, ba = bit.bnot, bit.band
local sl = string.lower
local lp, ft = LocalPlayer, FrameTime

function GM:PlayerNoClip( ply, wantsTo )
	local isPracticing = ply:GetNWBool "Practice"
	if !isPracticing and wantsTo then
		if CLIENT then return true end

		local didSave = Command.SaveState(ply)
		if (!didSave) then
			ply:ResetTimer()
			ply:StageReset()
			ply:SetNWBool( "Practice", true )
		end
		Core:SendColor( ply, "Your SurfTimer has been disabled for using ", CL.Yellow, "!noclip" )
	end

	return true
end

function GM:PlayerUse( ply )
	if !ply:Alive() then return false end
	if ply:Team() == TEAM_SPECTATOR then return false end
	if ply:GetMoveType() != MOVETYPE_WALK then return false end

	return true
end

function GM:CreateTeams()
	team.SetUp( _C.Team.Players, "Players", Color( 255, 50, 50, 255 ), false )
	team.SetUp( _C.Team.Spectator, "Spectators", Color( 50, 255, 50, 255 ), true )
	team.SetSpawnPoint( _C.Team.Players, { "info_player_terrorist", "info_player_counterterrorist" } )
end

function GM:Move( ply, data )
	if !IsValid( ply ) then return end
	if lp and ply != lp() then return end
	if ply:IsOnGround() or !ply:Alive() then return end

	local moveType = ply:GetMoveType()
	local validMoveType = (moveType == MOVETYPE_NOCLIP)
	if validMoveType then return end

	local aa, mv = 150, 32.8
	local aim = data:GetMoveAngles()
	local forward, right = aim:Forward(), aim:Right()
	local fmove = data:GetForwardSpeed()
	local smove = data:GetSideSpeed()

	local st = ply.Style
	if st == 1 then
		if data:KeyDown( IN_MOVERIGHT ) then smove = smove + 500 end
		if data:KeyDown( IN_MOVELEFT ) then smove = smove - 500 end
	elseif st == 2 then
		if data:KeyDown( IN_FORWARD ) then fmove = fmove + 500 end
		if data:KeyDown( IN_BACK ) then fmove = fmove - 500 end
	elseif st == 44 then
		aa, mv = 1000,38
	elseif st == 45 then
		aa, mv = 75, 20.8
	elseif st == 6 then
		aa, mv = 50000, 1000
		if data:KeyDown( IN_MOVERIGHT ) then smove = smove + 1000 end
		if data:KeyDown( IN_MOVELEFT ) then smove = smove - 1000 end
	end

	forward.z, right.z = 0,0
	forward:Normalize()
	right:Normalize()

	local wishvel = forward * fmove + right * smove
	wishvel.z = 0

	local wishspeed = wishvel:Length()
	if wishspeed > data:GetMaxSpeed() then
		wishvel = wishvel * (data:GetMaxSpeed() / wishspeed)
		wishspeed = data:GetMaxSpeed()
	end

	local wishspd = wishspeed
	wishspd = mc( wishspd, 0, mv )

	local wishdir = wishvel:GetNormal()
	local current = data:GetVelocity():Dot( wishdir )

	local addspeed = wishspd - current
	if addspeed <= 0 then return end

	local accelspeed = aa * ft() * wishspeed
	if accelspeed > addspeed then
		accelspeed = addspeed
	end

	local vel = data:GetVelocity()
	vel = vel + (wishdir * accelspeed)

	data:SetVelocity( vel )
	return false
end

local function NoJumpHandler( ply, cmd )
	if lp and ply != lp() then return end

	local canJump = ply:GetNWBool( "surf_canJump", true )
	local JumpButton = cmd:GetButtons()
	if !canJump and ba( JumpButton, IN_JUMP ) > 0 then
		cmd:RemoveKey( IN_JUMP )
	end
end
hook.Add( "StartCommand", "surf_HandleJumpMethods", NoJumpHandler )

local function AutoHop( ply, data )
	if lp and ply != lp() then return end
	if ply:GetNWBool "Desprehop" then return end

	local ButtonData = data:GetButtons()
	local isJumping, isSurface = ba( ButtonData, IN_JUMP ) > 0, ply:WaterLevel() < 2 and !ply:IsOnGround()
	if isJumping and isSurface then
		data:SetButtons( ba( ButtonData, bn( IN_JUMP ) ) )
	end
end
hook.Add( "SetupMove", "AutoHop", AutoHop )

local function StripMovements( ply, data )
	if lp and ply != lp() then return end

	local st = ply.Style
	if st and st > 1 and st < 4 and ply:GetMoveType() != MOVETYPE_NOCLIP then
		if ply:OnGround() then return end

		if st == 2 then
			data:SetSideSpeed( 0 )
		elseif st == 3 and (data:GetForwardSpeed() == 0 or data:GetSideSpeed() == 0) then
			data:SetForwardSpeed( 0 )
			data:SetSideSpeed( 0 )
		end
	end
end
hook.Add( "SetupMove", "StripIllegal", StripMovements )


local ticksOnGround, onGround, inAir = {}, {}, {}
hook.Add("Move", "surf.FixAutohop", function(ply, data)
	if !IsFirstTimePredicted() then return end
	local hasAutohopOff = ply:GetNWBool "Desprehop"
	if hasAutohopOff then return end

	if ply:IsOnGround() then
		if ticksOnGround[ply] then
			if ticksOnGround[ply] > 12 then
				if !onGround[ply] then
					ply:SetDuckSpeed(0.4)
					ply:SetUnDuckSpeed(0.2)

					onGround[ply] = true
				end
			else
				ticksOnGround[ply] = ticksOnGround[ply] + 1

				if ticksOnGround[ply] == 1 then
					inAir[ply] = nil
				elseif ticksOnGround[ply] > 1 and data:KeyDown(IN_JUMP) then
					local vel = data:GetVelocity()
					vel.z = ply:GetJumpPower()

					ply:SetDuckSpeed(0)
					ply:SetUnDuckSpeed(0)

					ticksOnGround[ply] = 0

					data:SetVelocity(vel)
				end
			end
		else
			ticksOnGround[ply] = 0
		end
	elseif !inAir[ply] then
		ticksOnGround[ply] = 0
		onGround[ply] = nil
		inAir[ply] = true

		ply:SetDuckSpeed(0)
		ply:SetUnDuckSpeed(0)
	end
end)

hook.Add("PlayerDisconnect", "surf.RemoveFixAutohop", function(ply)
	ticksOnGround[ply] = nil
	onGround[ply] = nil
	inAir[ply] = nil
end)

-- Do smooth noclipping --
local function MoveNoclip(ply, mv)
	if !IsValid( ply ) then return end

	local wantsSmoothing = tobool(ply:GetInfoNum("sl_smoothnoclip", 0))
	if !wantsSmoothing then return end

	local moveType = ply:GetMoveType()
	local validMoveType = (moveType == MOVETYPE_NOCLIP)

	local isSpectating = (ply:Team() == TEAM_SPECTATOR)
	local spectatorMove = ply:GetObserverMode()
	local freeMove = (isSpectating and (spectatorMove == OBS_MODE_ROAMING))
	if !freeMove and !validMoveType then return end

	local deltaTime = FrameTime()

	local noclipSpeed, noclipAccelerate = GetConVar "sv_noclipspeed", GetConVar "sv_noclipaccelerate"
	local speedValue, accelValue = noclipSpeed:GetInt(), noclipAccelerate:GetInt()

	local ang = mv:GetMoveAngles()
	local acceleration = ( ang:Forward() * mv:GetForwardSpeed() ) + ( ang:Right() * mv:GetSideSpeed() ) + ( ang:Up() * mv:GetUpSpeed() )

	local accelSpeed = math.min( acceleration:Length(), ply:GetMaxSpeed() )
	local accelDir = acceleration:GetNormal()
	acceleration = accelDir * accelSpeed * speedValue

	local multiplier = 4
	local isSpeeding, isDucking = mv:KeyDown(IN_SPEED), mv:KeyDown(IN_DUCK)
	if isSpeeding then
		multiplier = 0.25
	elseif isDucking then
		multiplier = 32
	end

	local newVelocity = mv:GetVelocity() + acceleration * deltaTime * accelValue
	newVelocity = newVelocity * ( 0.95 - deltaTime * multiplier )

	mv:SetVelocity( newVelocity )

	local newOrigin = mv:GetOrigin() + newVelocity * deltaTime
	mv:SetOrigin( newOrigin )

	return true
end
hook.Add("Move", "surf.MoveNoclip", MoveNoclip)

-- Core

Core = {}

local StyleNames = {}
for name,id in pairs( _C.Style ) do
	StyleNames[ id ] = name
end

function Core:StyleName( nID )
	return StyleNames[ nID ] or "Unknown"
end

function Core:IsValidStyle( nStyle )
	return !!StyleNames[ nStyle ]
end

function Core:GetStyleID( szStyle )
	for s,id in pairs( _C.Style ) do
		if sl( s ) == sl( szStyle ) then
			return id
		end
	end

	return 0
end

function Core.IsBonus( style )
	return string.StartWith( Core:StyleName(style), "Bonus" )
end

function Core.BonusToSequence( bonus )
	local isBonus = Core.IsBonus( bonus )
	if !isBonus then return 0 end

	if (bonus == _C.Style.Bonus) then return 1 end

	local bonusNum = tonumber( string.sub( Core:StyleName( bonus ), 6 ) )
	if !bonusNum then return 0 end

	return bonusNum
end

function Core.SequenceToBonus( sequence )
	local bonusNum = tonumber( sequence )
	if !bonusNum or (bonusNum == 1) then return 4 end

	if (bonusNum > 1 and bonusNum < 7) then
		bonusNum = 8 + bonusNum
	elseif (bonusNum > 6 and bonusNum < 11) then
		bonusNum = 33 + bonusNum
	end

	return bonusNum
end

function Core.ShortWRToStyleID( name )
	local styleIDs = {
		["swwr"] = 2,
		["hswwr"] = 3,
		["bwr"] = 4,
		["100wr"] = 44,
		["33wr"] = 45,
		["wwr"] = 6,
		["b2wr"] = 10,
		["b3wr"] = 11,
		["b4wr"] = 12,
		["b5wr"] = 13,
		["b6wr"] = 14,
		["b7wr"] = 40,
		["b8wr"] = 41,
		["b9wr"] = 42,
		["b10wr"] = 43
	}

	local result = 1
	if styleIDs[name] then
		result = styleIDs[name]
	end

	return result
end

function Core.ShortPRToStyleID( name )
	local styleIDs = {
		["swpr"] = 2,
		["hswpr"] = 3,
		["100pr"] = 44,
		["33pr"] = 45,
		["wpr"] = 6,
	}

	local result = 1
	if styleIDs[name] then
		result = styleIDs[name]
	end

	return result
end

function Core.StyleIDToShortName(id)
	local styleIDs = {
		[1] = "",
		[2] = "sw",
		[3] = "hsw",
		[44] = "100",
		[45] = "33",
		[6] = "w",
	}

	local result = ""
	if styleIDs[id] then
		result = styleIDs[id]
	end

	return result
end

function Core.ShortStyleNameToID(name)
	local styleIDs = {
		["sw"] = 2,
		["hsw"] = 3,
		["100"] = 44,
		["33"] = 45,
		["w"] = 6,
	}

	local result = 1
	for key,value in pairs(styleIDs) do
		local ok = string.StartWith(name, key)
		if ok then
			result = value
		break end
	end

	return result
end

function Core:Exp( c, n )
	return c * mp( n, 2.9 )
end

function Core:Optimize()
	hook.Remove( "PlayerTick", "TickWidgets" )
	hook.Remove( "PreDrawHalos", "PropertiesHover" )
end


Core.Util = {}
function Core.Util:StringToTab( szInput )
	local tab = string.Explode( " ", szInput )
	for k,v in pairs( tab ) do
		if tonumber( v ) then
			tab[ k ] = tonumber( v )
		end
	end
	return tab
end

function Core.Util:TabToString( tab )
	for i = 1, #tab do
		if !tab[ i ] then
			tab[ i ] = 0
		end
	end
	return string.Implode( " ", tab )
end

function Core.Util:RandomColor()
	local r = math.random
	return Color( r( 0, 255 ), r( 0, 255 ), r( 0, 255 ) )
end

function Core.Util:VectorToColor( v )
	return Color( v.x, v.y, v.z )
end

function Core.Util:ColorToVector( c )
	return Color( c.r, c.g, c.b )
end

function Core.Util:ColorToRainbow( g, g2 )
	local gs = g or Vector( 127, 127, 127 )
	local ge = g2 or Vector( 128, 128, 128 )
	local frequency = g and g2 and 1 or 2

	local red = math.sin( frequency * CurTime() + 0 ) * gs.x + ge.x
	local green = math.sin( frequency * CurTime() + ( g and g2 and 0 or 2 ) ) * gs.y + ge.y
	local blue = math.sin( frequency * CurTime() + ( g and g2 and 0 or 4 ) ) * gs.z + ge.z

	return Color( red, green, blue )
end

function Core.Util:NoEmpty( tab )
	for k,v in pairs( tab ) do
		if !v or v == "" then
			table.remove( tab, k )
		end
	end

	return tab
end

-- Override Nick to follow VIP rules --
do
	if CLIENT then
		CreateClientConVar("sl_displaytruename", "0", true, true, "Bypasses VIP names on menus that support it")
	end

	local META = FindMetaTable "Player"
	local oldNick = META.Nick
	function META:Nick()
		local oldName = oldNick(self)
		if self:IsBot() then return oldName end

		local customName = self:GetNWString("VIPName", oldName)
		if (customName == "") then customName = oldName end

		if CLIENT then
			local TrueNames = GetConVar "sl_displaytruename"
			if TrueNames:GetBool() then
				customName = oldName
			end
		end

		return customName
	end
	META.Name = META.Nick
	META.GetName = META.Nick
end
