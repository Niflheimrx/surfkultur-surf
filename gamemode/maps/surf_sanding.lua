-- 2/23/2021: Redo fix for map, the following have changed:
-- Remove that goddamn func_dustmotes entity that causes huge lag spikes
-- Point trigger_teleport destinations to actual stage start destinations rather than a stage lobby
-- Optimize jail removal

__HOOK[ "InitPostEntity" ] = function()
	-- Remove useless shit --
	for _,ent in pairs( ents.FindByClass "func_dustmotes" ) do
		ent:Remove()
	end

	for _,ent in pairs( ents.FindByClass "path_*" ) do
		ent:Remove()
	end

	for _,ent in pairs( ents.FindByClass "trigger_multiple" ) do
		ent:Remove()
	end

	for _,ent in pairs( ents.FindByClass "trigger_once" ) do
		ent:Remove()
	end

	local functrainMovers = {
		["0.00 0.00 -1456.00"] = Vector( 0, 0, -16 )
	}

	for _,ent in pairs( ents.FindByClass "func_tanktrain" ) do
		local currentPos = util.TypeToString( ent:GetPos() )
		if (functrainMovers[currentPos]) then
			ent:SetName(ent:GetName().."_rename")
			ent:SetPos(functrainMovers[currentPos])
		end
	end

	-- Set the correct pointer for triggers --
	local spawnPointers = {
		["room1"] = "2",
		["room2"] = "1",
		["room3"] = "3",
		["room4"] = "4",
		["room5"] = "5",
		["room6"] = "6",
		["room7"] = "ksfdes",

		["6"] = "6",
	}

	-- Remove triggers that lead to these areas --
	local spawnRemovers = {
		["ct"] = true,
		["t"] = true,
		["netdurch"] = true,
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
