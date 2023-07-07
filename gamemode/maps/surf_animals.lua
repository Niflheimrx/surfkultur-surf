--What did the fox sa- oh wait that's not the right one. #RIP Harambe. Removes jails and unnecessary animal cruelty.
-- 12/01/2020: this was a pain in the ass to optimize, also what the fuck did I write up there

__HOOK[ "InitPostEntity" ] = function()

	-- Remove useless shit --
	for _,ent in pairs( ents.FindByClass "ambient_generic" ) do
		ent:Remove()
	end

	for _,ent in pairs( ents.FindByClass "func_illusionary" ) do
		ent:Remove()
	end

	for _,ent in pairs( ents.FindByClass "func_rotating" ) do
		ent:Remove()
	end

	for _,ent in pairs( ents.FindByClass "func_tracktrain" ) do
		ent:Remove()
	end

	for _,ent in pairs( ents.FindByClass "path_track" ) do
		ent:Remove()
	end

	for _,ent in pairs( ents.FindByClass "phys_motor" ) do
		ent:Remove()
	end

	for _,ent in pairs( ents.FindByClass "point_spotlight" ) do
		ent:Remove()
	end

	for _,ent in pairs( ents.FindByClass "prop_physics_multiplayer" ) do
		ent:Remove()
	end

	for _,ent in pairs( ents.FindByClass "prop_static" ) do
		ent:PhysicsDestroy()
	end

	for _,ent in pairs( ents.FindByClass "trigger_multiple" ) do
		ent:Remove()
	end

	-- Remove stupid doors --
	for _,ent in pairs( ents.FindByClass "func_door" ) do
		ent:Remove()
	end

	-- Spawnpoints that we want to move for speedrunning reasons --
	local spawnTransport = {
		["dog"] = Vector( 3184.5, -3118.5, 1949 ),
		["stage1"] = Vector( -2598, 7149.5, 1384 ),
		["Kitty"] = Vector( -12110.5, 12387.5, 400 ),
		["bonus_tele"] = Vector( -453, -1478, -25 ),
	}

	for _,ent in pairs( ents.FindByClass "info_teleport_destination" ) do
		local name = ent:GetInternalVariable "m_iName"
		if !spawnTransport[name] then continue end

		ent:SetPos( spawnTransport[name] )
	end

	-- Set the correct pointer for triggers --
	local spawnPointers = {
		["penguin_11"] = "penguin_1",
		["dog"] = "dog",
		["stage1"] = "stage1",
		["Spawn_Zebra_poco"] = "Spawn_Zebra",
		["Kitty"] = "Kitty",
		["poco1"] = "bonus_tele",
	}

	-- Remove triggers that lead to these areas --
	local spawnRemovers = {
		["cola_cola"] = true,
		["fight_tele"] = true,
		["t_m4a1"] = true,
		["ct_m4a1"] = true,
		["t_glock"] = true,
		["ct_glock"] = true,
		["shark_tele"] = true,
		["shark_tele1"] = true,
		["poco"] = true,
	}

	-- Exclude these triggers and point them correctly --
	local spawnExcluders = {
		["-11160.00 -9145.00 -217.50"] = "penguin_11",
	}

	-- Remove triggers related to a specific mechanism --
	local spawnNameRemovers = {
		["dog_rota"] = true,
		["dog_rota1"] = true,
		["dog_rota2"] = true,
		["easy-hard-1"] = true,
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

__HOOK[ "EntityKeyValue" ] = function( ent, key, value )
	local isPush = (ent:GetClass() == "trigger_push")
	if !isPush then return end

	-- Remove specific trigger_push entities because gay --
	local pushRemovers = {
		[1824] = true,
	}

	local pushAdjusters = {
		[1509] = 300,
	}

	local currentIndex = ent:MapCreationID()
	local isSpeed = (key == "speed")

	if pushAdjusters[currentIndex] and isSpeed then
		return pushAdjusters[currentIndex]
	end

	if !pushRemovers[currentIndex] then return end

	ent:Remove()
end
