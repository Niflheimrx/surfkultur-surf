local Zone = {
	MStart = 0,
	MEnd = 1,
	BStart = 2,
	BEnd = 3,
	Anticheat = 4,
	Restart = 5,
	["Bonus 2 Start"] = 6,
	["Bonus 2 End"] = 7,
	Mark = 8,
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
	SEnd = 70,
	SAC = 71,
	["Checkpoint 1"] = 83,
	["Checkpoint 2"] = 84,
	["Checkpoint 3"] = 85,
	["Checkpoint 4"] = 86,
	["Checkpoint 5"] = 87,
	["Checkpoint 6"] = 88,
	["Checkpoint 7"] = 89,
	["Checkpoint 8"] = 90,
	["Checkpoint 9"] = 91,
	Flags = 92,
	StageReset = 93,
	Telehop = 94,
	NoBhop = 95,
	["Bonus 7 Start"] = 96,
	["Bonus 7 End"] = 97,
	["Bonus 8 Start"] = 98,
	["Bonus 8 End"] = 99,
	["Bonus 9 Start"] = 100,
	["Bonus 9 End"] = 101,
	["Bonus 10 Start"] = 102,
	["Bonus 10 End"] = 103,
	NoJump = 104,
	["Bonus Anticheat"] = 105
}

-- Mainly used for Tenacious --
local canInteract = function(ply)
	if (bit.band( Timer.Options, Zones.Options.NoSpeedStop ) == 0) then return true end

	local speed = ply:GetVelocity():Length2D()
	if (speed > 380) then return false end

	return true
end

local disablePrehop = function(ply, byte)
	if (bit.band( Timer.Options, Zones.Options.NoPrehopLimit ) > 0) then
		ply:SetNWBool( "Desprehop", false )
	return end

	local isPractice = ply:GetNWBool "Practice"
	if isPractice then
		ply:SetNWBool( "Desprehop", false )
	return end

	ply:SetNWBool( "Desprehop", byte )
end

-- We made spawnzones not interact with the timer, since they shouldn't act as one --
-- Typically we made these zones around -5 - 5 units high, so we shouldn't break too many things if we kept that up --
local isSpawnZone = function(min, max)
	local height = math.Round( max.z - min.z )
	if height < 5 and height > -5 then return true end

	return false
end

function ENT:Initialize()
	local BBOX = (self.max - self.min) / 2

	self:SetSolid( SOLID_BBOX )
	self:PhysicsInitBox( -BBOX, BBOX )
	self:SetCollisionBoundsWS( self.min, self.max )

	self:SetTrigger( true )
	self:DrawShadow( false )
	self:SetNotSolid( true )
	self:SetNoDraw( false )

	self.Phys = self:GetPhysicsObject()
	if self.Phys and self.Phys:IsValid() then
		self.Phys:Sleep()
		self.Phys:EnableCollisions( false )
	end

	self:SetZoneType( self.zonetype )
end

function ENT:StartTouch( ent )
	if IsValid( ent ) and ent:IsPlayer() and !ent:IsBot() and ent:Team() != TEAM_SPECTATOR then
		local zone = self:GetZoneType()
		if zone == Zone.MStart then
			local playerBonus = string.StartWith( Core:StyleName( ent.Style ), "Bonus" )
			if playerBonus then return end
			if !canInteract(ent) then return end

			ent:ResetTimer()
			disablePrehop(ent, true)

			if Timer.Type == 1 then
				ent:SetNWInt("Stage", 1)
				ent:StageReset()
			else
				ent:SetNWInt("Checkpoint", 1)
			end
		elseif zone == Zone.MEnd then
			if ent.Ts and !ent.TsF then
				ent:StageStop()
			end

			if ent.Tn and !ent.TnF then
				ent:StopTimer()
			end

			local isStaging = ent:GetNWBool "StageTimer"
			local isRepeating = isStaging and ent:GetNWBool "StageRepeat"
			local isMovingPos = ent.MovingPos
			if isRepeating and !isMovingPos then
				local currentStage = ent:GetNWInt "Stage"
				local newStage = currentStage

				Command:Trigger( ent, "stage " .. newStage, "!stage " .. newStage )
			end
		elseif zone == Zone.Anticheat then
			ent:StopAnyTimer()
		elseif zone == Zone.SAC then
			ent:StopAnyStageTimer()
		elseif zone == Zone.Flags then
			ent:SendFlags(ent, ent.Style)
		elseif zone == Zone.Restart then
			ent:RestartPlayer()
		elseif zone == Zone.NoBhop then
			disablePrehop(ent, true)
		elseif zone == Zone.StageReset then
			ent:StageTeleport()
		elseif zone == Zone.Telehop then
			ent:TelehopTeleport()
		elseif zone == Zone.Anticheat then
			ent:StopAnyTimer()
		elseif (zone == Zone["Bonus Anticheat"]) then
			ent:BonusReset()
		elseif (zone >= 83 and zone <= 91) then
			local playerBonus = string.StartWith( Core:StyleName( ent.Style ), "Bonus" )
			if playerBonus then return end

			local isStaging = ent:GetNWBool "StageTimer"
			if isStaging then return end

			local nCP = ent:GetNWInt "Checkpoint"
			for i = 1, 9 do
				if (zone == Zone["Checkpoint " .. i] and nCP == i) then
					ent:SetSplit(nCP)
					ent:SetNWInt("Checkpoint", i + 1)
				end
			end
		elseif string.StartWith( Core:StyleName(ent.Style), "Bonus" ) then
			local isValidEnd = (ent.Tb and !ent.TbF)
			-- Fix zone controller --
			if zone == Zone.BStart and ent.Style == _C.Style.Bonus then
				ent:BonusReset()
				disablePrehop(ent, true)
			end

			if zone == Zone.BEnd and ent.Style == _C.Style.Bonus and isValidEnd then
				ent:BonusStop()
			end

			for i = 2, 10 do
				if (zone == Zone["Bonus " .. i .. " Start"]) and (ent.Style == _C.Style["Bonus " .. i]) then
					ent:BonusReset()
					disablePrehop(ent, true)
				end

				if (zone == Zone["Bonus " .. i .. " End"]) and (ent.Style == _C.Style["Bonus " .. i]) and isValidEnd then
					ent:BonusStop()
				end
			end
		else
			local playerBonus = string.StartWith( Core:StyleName( ent.Style ), "Bonus" )
			if playerBonus then return end
			if !canInteract(ent) then return end

			local nStage = ent:GetNWInt "Stage"
			local isStaging = ent:GetNWBool "StageTimer"
			local isRepeating = isStaging and ent:GetNWBool "StageRepeat"
			local isMovingPos = ent.MovingPos

			-- Christmas2 has to go under different settings in order to work properly --
			local isChristmas2 = (game.GetMap() == "surf_christmas2")
			if isChristmas2 then
				local hasTime = ent.Ts and !ent.TsF

				-- The Stage End zone is the open area, mark as complete when entering that area if we have a time --
				if (zone == Zone.SEnd) and hasTime then
					ent:ForceStageStop()

					if isStaging and isRepeating and !isMovingPos then
						local currentStage = ent:GetNWInt "Stage"
						local newStage = tostring( currentStage )

						timer.Simple( 0, function() Command:Trigger( ent, "stage " .. newStage, "!stage " .. newStage ) end )
					end
				end

				for i = 1, 24 do
					if (zone == Zone["Stage " .. i]) then
						ent:StageReset()
						ent:SetNWInt( "Stage", i )
					end
				end
			return end

			for i = 1, 24 do
				-- Check for previous stage entrances --
				if (i != 1) and (zone == Zone["Stage " .. i] and nStage == (i - 1) ) then
					ent:StageStop()
					ent:SetNWInt( "Stage", i )
					ent:StageReset()

					if !Stage.AllowTelehops then
						disablePrehop( ent, 1 )
					end

					if isStaging and isRepeating and !isMovingPos then
						local currentStage = ent:GetNWInt "Stage"
						local newStage = currentStage - 1

						timer.Simple( 0, function() Command:Trigger( ent, "stage " .. newStage, "!stage " .. newStage ) end )
					end
				elseif (zone == Zone["Stage " .. i]) then
					ent:StageReset()
					ent:SetNWInt( "Stage", i )

					if !Stage.AllowTelehops then
						disablePrehop( ent, 1 )
					end
				end

				-- Check for force stop stage zones --
				if (zone == Zone.SEnd) and ent.Ts and !ent.TsF then
					ent:ForceStageStop()

					if isStaging and isRepeating and !isMovingPos then
						local currentStage = ent:GetNWInt "Stage"
						local newStage = tostring( currentStage )

						timer.Simple( 0, function() Command:Trigger( ent, "stage " .. newStage, "!stage " .. newStage ) end )
					end
				end

				-- Lastly, check for unintended stage increments (like in practice mode) --
				if (zone == Zone["Stage " .. i] ) and (!ent.Ts or ent.Ts == 0) then
					ent:SetNWInt( "Stage", i )
				end
			end
		end

	-- Added support for bots to display pbs and stuff, all without doing it in a hacky way --
	elseif IsValid( ent ) and ent:IsPlayer() and ent:IsBot() then
		local zone = self:GetZoneType()
		for i = 1, 24 do
			-- Check for stage re-entries --
			if (zone == Zone["Stage " .. i]) then
				-- Handles bot info here, get it out of the way from everything else --
				Stage.SetBest( ent, i )
			end
		end
	end
end

function ENT:EndTouch( ent )
	if isSpawnZone(self.min, self.max) then return end
	if IsValid( ent ) and ent:IsPlayer() and ent:Team() != TEAM_SPECTATOR then
		if ent.MovingPos then
			timer.Simple( 0, function() ent.MovingPos = false end )
		return end

		local zone = self:GetZoneType()
		if zone == Zone.MStart then
			if !canInteract(ent) then return end

			ent:StartTimer()
			disablePrehop(ent, false)

			if Timer.Type == 1 then
				local vPoint = Zones:GetCenterPoint( Zones.Type["Stage 1"] )
				if !vPoint then
					ent:StartStage()
				end
			end
		elseif zone == Zone.BStart and ent.Style == _C.Style.Bonus then
			ent:BonusStart()
			disablePrehop(ent, false)
		elseif zone == Zone.NoBhop then
			disablePrehop(ent, false)
		elseif zone == Zone.NoJump then
			ent:SetNWBool( "surf_canJump", true )
		else
			for i = 2, 10 do
				if (zone == Zone["Bonus " .. i .. " Start"]) and (ent.Style == _C.Style["Bonus " .. i]) then
					ent:BonusStart()
					disablePrehop(ent, false)
				end
			end

			local playerBonus = string.StartWith( Core:StyleName( ent.Style ), "Bonus" )
			if playerBonus then return end

			for i = 1, 24 do
				if zone == Zone["Stage " .. i] then
					local stage = ent:GetNWInt "Stage"
					if (stage != i) then return end

					ent:StartStage()
					disablePrehop(ent, false)
				end
			end
		end
	end
end

function ENT:Touch(ent)
	if IsValid( ent ) and ent:IsPlayer() and ent:Team() != TEAM_SPECTATOR then
		local zone = self:GetZoneType()
		if zone == Zone.NoJump then
			ent:SetNWBool( "surf_canJump", false )
		elseif zone == Zone.MStart then
			disablePrehop(ent, true)
		end
	end
end
