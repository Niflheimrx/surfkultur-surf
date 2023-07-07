include( "core.lua" )
include( "core_lang.lua" )
include( "core_data.lua" )
include( "sv_player.lua" )
include( "sv_command.lua" )
include( "sv_timer.lua" )
include( "sv_zones.lua" )
include( "modules/sv_rtv.lua" )
include( "modules/sv_admin.lua" )
include( "modules/sv_bot.lua" )
include( "modules/sv_spectator.lua" )
include( "modules/sv_stages.lua" )

-- SMGRAPI --
AddCSLuaFile( "cl_smgrapi.lua" )
include( "sv_smgrapi.lua" )

-- STELLAR MOD --
AddCSLuaFile( "modules/stellarSurf/sh_init.lua" )
include( "modules/stellarSurf/sh_init.lua" )

include( "sh_paint.lua" )
gameevent.Listen( "player_connect" )
gameevent.Listen( "player_changename" )

Core:AddResources()

local function Startup()
	Core:Boot()

	local function OnComplete()
		Timer.LoadMap()
		Core:LoadZones()

		Admin:LoadAdmins()
		RTV:LoadData()
		Player:UnloadLock()
		Bot:LoadData()

		Timer:LoadRecords()
		Stage:LoadRecords()
		Player.CalcRank()
	end

	SQL:CreateObject( OnComplete )

	timer.Create("sm_mysql_check", 30, 20, function()
		if SQL.Available then
			timer.Remove "sm_mysql_check"
		return end

		if (timer.RepsLeft "sm_mysql_check" == 0) then
			RunConsoleCommand("changelevel", game.GetMap())
		return end

		SQL:CreateObject(OnComplete)

		print("MySQL Startup Repetitions Left: ", timer.RepsLeft "sm_mysql_check")
	end)
end
hook.Add( "Initialize", "Startup", Startup )

local function LoadEntities()
	Core:AwaitLoad()
end
hook.Add( "InitPostEntity", "LoadEntities", LoadEntities )

function GM:PlayerSpawn( ply )
	player_manager.SetPlayerClass( ply, "player_surf" )
	self.BaseClass:PlayerSpawn( ply )
	ply:SetupHands()

	Player:Spawn( ply )
end

function GM:PlayerInitialSpawn( ply )
	Player:Load( ply )
end

function GM:SetPlayerModel( ply )
	ply:SetModel("models/player/group01/male_01.mdl")
end

function GM:CanPlayerSuicide() return false end
function GM:PlayerShouldTakeDamage() return false end
function GM:GetFallDamage() return false end
function GM:PlayerCanHearPlayersVoice() return true end
function GM:IsSpawnpointSuitable() return true end
function GM:PlayerDeathThink( ply ) end

function GM:PlayerCanPickupWeapon( ply, weapon )
	if ply.WeaponStripped then return false end
	if ply:IsBot() then return false end
	return ply.WeaponPickup
end

function GM:EntityTakeDamage( ent, dmg )
	if ent:IsPlayer() then return false end
	return self.BaseClass:EntityTakeDamage( ent, dmg )
end
