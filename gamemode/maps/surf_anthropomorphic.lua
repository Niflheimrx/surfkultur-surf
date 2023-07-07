--furries!
-- 12/02/2020: cancer, effectively removes jail and some

__HOOK[ "InitPostEntity" ] = function()
	-- Remove useless shit --
	for _,ent in pairs( ents.FindByClass "env_spritetrail" ) do
		ent:Remove()
	end

	for _,ent in pairs( ents.FindByClass "func_brush" ) do
		ent:Remove()
	end

	for _,ent in pairs( ents.FindByClass "info_overlay" ) do
		ent:Remove()
	end

	for _,ent in pairs( ents.FindByClass "logic_*" ) do
		ent:Remove()
	end

	for _,ent in pairs( ents.FindByClass "point_spotlight" ) do
		ent:Remove()
	end

	for _,ent in pairs( ents.FindByClass "trigger_once" ) do
		ent:Remove()
	end

	-- Remove stupid furry images --
	local rotateRemovers = {
		["rotating_logo"] = true,
	}

	for _,ent in pairs( ents.FindByClass "func_rotating" ) do
		local currentName = ent:GetName()
		if !rotateRemovers[currentName] then
			ent:SetSaveValue( "maxspeed", "0.0" )

			continue
		end

		ent:Remove()
	end

	-- Spawnpoints that we want to move for speedrunning reasons --
	local spawnTransport = {

	}

	for _,ent in pairs( ents.FindByClass "info_teleport_destination" ) do
		local name = ent:GetInternalVariable "m_iName"
		if !spawnTransport[name] then continue end

		ent:SetPos( spawnTransport[name] )
	end

	-- Set the correct pointer for triggers --
	local spawnPointers = {
		["winner"] = "secretend",
	}

	-- Remove triggers that lead to these areas --
	local spawnRemovers = {
		["failsnake"] = true,
		["failtiger"] = true,
		["faillynx"] = true,
		["failcheetah"] = true,
		["failgiraffe"] = true,
		["failpanther"] = true,
		["failjaguar"] = true,
		["failocelot"] = true,
		["failone"] = true,
		["failcow"] = true,
	}

	-- Exclude these triggers and point them correctly --
	local spawnExcluders = {

	}

	-- Remove triggers related to a specific mechanism --
	local spawnNameRemovers = {

	}

	for _,ent in pairs( ents.FindByClass "trigger_teleport" ) do
		local name = ent:GetInternalVariable "target"
		local currentName = ent:GetInternalVariable "parentname"
		local currentPos = util.TypeToString( ent:GetPos() )

		if spawnRemovers[name] or spawnNameRemovers[currentName] then
			ent:Remove()

			continue
		end

		-- Prioritize excluders first since we need to do this for the "bonuses" --
		if spawnExcluders[currentPos] or spawnPointers[name] then
			local pointer = spawnExcluders[currentPos] or spawnPointers[name]

			ent:SetKeyValue( "target", pointer )
			ent:Fire "Enable"
			Zones:GenerateSpawnZone( ent )
		end
	end
end

__HOOK[ "EntityKeyValue" ] = function( ent, key, value )
	local isPush = (ent:GetClass() == "trigger_push")
	if !isPush then return end

	-- Readjust push amount --
	local pushAdjusters = {
		[1349] = 1000,
	}

	local currentIndex = ent:MapCreationID()
	local isSpeed = (key == "speed")

	if pushAdjusters[currentIndex] and isSpeed then
		return pushAdjusters[currentIndex]
	end
end
