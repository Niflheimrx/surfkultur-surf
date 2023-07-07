--Who thought adding _ on every character was a good idea, removes jail.
-- 28/11/2022: Redo jail fix and remove telehop on Stage 3 --

__HOOK[ "InitPostEntity" ] = function()
	-- Remove useless shit (except for a platform on s3 which is a button????) --
	for _,ent in pairs( ents.FindByClass "func_button" ) do
		if ent:GetName() != "door_3" then
			ent:Remove()
		end
	end

	for _,ent in ipairs(ents.FindByClass "logic_relay") do
		ent:Remove()
	end

	-- Remove jails --
	local spawnRemovers = {
		["ct_tele"] = true,
		["t_tele"] = true,
		["jail_ownd"] = true,
		["ef_tele"] = true,
		["start_zusammen"] = true
	}

	local spawnPointers = {
		["stage3"] = "stage3",
	}

	for _,ent in pairs( ents.FindByClass "trigger_teleport" ) do
		local name = ent:GetName()

		if spawnRemovers[name] then
			ent:Remove()

			continue
		end

		if spawnPointers[name] then
			local pointer = spawnPointers[name]

			ent:SetKeyValue("target", pointer)
			Zones:GenerateSpawnZone(ent)
		end
	end
end

__HOOK[ "EntityKeyValue" ] = function( ent, key, value )
	if ent:GetClass() == "func_door_rotating" then
		if key == "speed" then
			return "1"
		end
		if key == "distance" then
			return "0"
		end
	end
	if ent:GetClass() == "func_door" then
		if key == "speed" then
			return "0.01"
		end
		if key == "movedir" then
			return "0 0 0"
		end
	end
end
