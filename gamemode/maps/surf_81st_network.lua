--network? Give me fiber man. Removes jail and adjusts teleporters.
-- 11/26/2020: holy fuck what is this map, changes are as follows:
-- Jail removal completely redone and more easier to manage

__HOOK[ "InitPostEntity" ] = function()
	-- Move these boosters a little higher --
	local pushMovers = {
		["284.00 0.00 8.00"] = Vector( 284, 0, 56 ),
		["0.00 284.00 8.00"] = Vector( 0, 284, 56 )
	}

	for _,ent in pairs( ents.FindByClass "trigger_push" ) do
		local currentPos = util.TypeToString( ent:GetPos() )

		if pushMovers[currentPos] then
			ent:SetPos( pushMovers[currentPos] )
		end
	end

	-- Fix camera angle on s4 transition, same with s5 --
	local destinationRotators = {
		["4"] = true,
		["5go"] = true
	}

	for _,ent in pairs( ents.FindByClass "info_teleport_destination" ) do
		local name = ent:GetInternalVariable "m_iName"
		if !destinationRotators[name] then continue end

		local currentAngle = ent:GetAngles()
		local newAngle = currentAngle + Angle( 90, 0, 0 )

		ent:SetAngles( newAngle )
	end

	-- Remove useless shit --
	for _,ent in pairs( ents.FindByClass "func_illusionary" ) do
		ent:Remove()
	end

	for _,ent in pairs( ents.FindByClass "func_button" ) do
		ent:Remove()
	end

	for _,ent in pairs( ents.FindByClass "trigger_once" ) do
		ent:Remove()
	end

	for _,ent in pairs( ents.FindByClass "trigger_hurt" ) do
		ent:Remove()
	end

	for _,ent in pairs( ents.FindByClass "logic_relay" ) do
		ent:Remove()
	end

	for _,ent in pairs( ents.FindByClass "logic_timer" ) do
		ent:Remove()
	end

	for _,ent in pairs( ents.FindByClass "logic_case" ) do
		ent:Remove()
	end

	-- Set the correct pointer for triggers --
	local spawnPointers = {
		["1_a"] = "spawn",
		["1_b"] = "spawn",
		["2"] = "spawn",
		["3"] = "spawn",
		["4"] = "spawn",
		["5"] = "spawn",
	}

	-- Triggers that we want to move for speedrunning reasons --
	local spawnMovers = {
		["4832.00 -3328.00 -5456.00"] = Vector( 5104, -3328, -5456 ),
		["3072.00 -1344.00 -7032.00"] = Vector( 3072, -1380, -6992 )
	}

	-- Exclude these triggers and point them correctly --
	local spawnExcluders = {
		["1792.00 1792.00 -2544.00"] = "2",
		["3072.00 -1344.00 -7032.00"] = "4",
		["1280.00 1280.00 -4404.00"] = "4",
		["8704.03 -4224.00 -2976.00"] = "5",
		["5104.00 -3328.00 -5456.00"] = "5go",
		["6784.00 8704.00 -248.00"] = "bonus_go",
	}

	-- Remove triggers that lead to these areas --
	local spawnRemovers = {
		["mini_game_seperate"] = true,
		["secret_dest"] = true,
		["jail1"] = true,
		["jail2"] = true,
		["jail3"] = true,
		["jail4"] = true,
		["jail5"] = true,
		["jailwin"] = true,
		[""] = true,
	}

	local spawnFire = {
		["5goTele"] = true
	}

	for _,ent in pairs( ents.FindByClass "trigger_teleport" ) do
		local currentPos = util.TypeToString( ent:GetPos() )
		local name = ent:GetInternalVariable "target"

		if spawnRemovers[name] and !spawnExcluders[currentPos] then
			ent:Remove()

			continue
		end

		if spawnMovers[currentPos] then
			ent:SetPos( spawnMovers[currentPos] )
		end

		if spawnFire[ent:GetName()] then
			ent:Fire "Enable"
		end

		-- Prioritize excluders first since we need to do this for last stage --
		if spawnExcluders[currentPos] or spawnPointers[name] then
			local pointer = spawnExcluders[currentPos] or spawnPointers[name]

			ent:SetKeyValue( "target", pointer )
		end
	end
end
