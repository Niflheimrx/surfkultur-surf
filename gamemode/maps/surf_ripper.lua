__HOOK[ "InitPostEntity" ] = function()
-- Remove useless shit --
	for _,ent in pairs( ents.FindByClass "trigger_hurt" ) do
		ent:Remove()
	end
	for _,ent in pairs( ents.FindByClass "trigger_multiple" ) do
		ent:Remove()
	end
	for _,ent in pairs( ents.FindByClass "trigger_once" ) do
		ent:Remove()
	end
	for _,ent in pairs( ents.FindByClass "func_movelinear" ) do
		ent:Remove()
	end
	for _,ent in pairs( ents.FindByClass "func_conveyor" ) do
		ent:Remove()
	end
	for _,ent in pairs( ents.FindByClass "logic_relay" ) do
		ent:Remove()
	end
	for _,ent in pairs( ents.FindByClass "logic_timer" ) do
		ent:Remove()
	end
	for _,ent in pairs( ents.FindByClass "math_counter" ) do
		ent:Remove()
	end
	for _,ent in pairs( ents.FindByClass "logic_case" ) do
		ent:Remove()
	end

	--random shit that needs locking
	for _,ent in pairs( ents.FindByClass "func_door" ) do
		if ent:GetPos() == Vector( 6084.5, 4082, 2578.75 ) then
			ent:Fire "Lock"
		end
	end
	for _,ent in pairs( ents.FindByClass "func_button" ) do
		if ent:GetName() == "bonus_lvl3_button" then
			ent:Fire "lock"
		else
			ent:Remove()
		end
	end


	-- Spawnpoints that we want to move for speedrunning reasons --
	local spawnTransport = {
		["Spawn4"] = Vector( -12950, -1727, -3469 ),
	}

	local spawnPointers = {
		["Spawn4"] = "Spawn4",
	}

	for _,ent in pairs( ents.FindByClass "info_teleport_destination" ) do
		local name = ent:GetInternalVariable "m_iName"
		if !spawnTransport[name] then continue end

		ent:SetPos( spawnTransport[name] )
	end


-- list jail teleport triggers
	local jailRemovers = {
		["jail_end"] = true,
		["jail_end2"] = true,
		["jail_end_castle"] = true,
		["jail"] = true,
	}

	for _,ent in pairs( ents.FindByClass "trigger_teleport" ) do
		local name = ent:GetInternalVariable "target"

		if spawnPointers[name] then
			local pointer = spawnPointers[name]

			ent:SetKeyValue( "target", pointer )
			Zones:GenerateSpawnZone( ent )
		end
-- remove jail triggers
		if jailRemovers[ent:GetName()] then
			ent:Remove()
		end
	end
end

