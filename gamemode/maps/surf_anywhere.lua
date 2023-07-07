-- 12/06/2020: completely redo fix file, removes jail and other minor fixes

__HOOK[ "InitPostEntity" ] = function()
	-- Remove useless shit --
	for _,ent in pairs( ents.FindByClass "point_spotlight" ) do
		ent:Remove()
	end

	for _,ent in pairs( ents.FindByClass "trigger_multiple" ) do
		ent:Remove()
	end

	for _,ent in pairs( ents.FindByClass "trigger_once" ) do
		ent:Remove()
	end

	-- Spawnpoints that we want to move for speedrunning reasons --
	local spawnTransport = {
		["jaden"] = Vector( -1096, 296, 401 )
	}

	for _,ent in pairs( ents.FindByClass "info_teleport_destination" ) do
		local name = ent:GetInternalVariable "m_iName"
		if !spawnTransport[name] then continue end

		ent:SetPos( spawnTransport[name] )
	end

	-- Set the correct pointer for triggers --
	local spawnPointers = {
		["jaden"] = "jaden",
	}

	-- Remove triggers that lead to these areas --
	local spawnRemovers = {
		["tojail1"] = true,
		["tojail2"] = true,
		["stripit"] = true,
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
			Zones:GenerateSpawnZone( ent )
		end
	end
end
