-- 05/07/2021: Mr. Sandman, bring me a dream. Optimized map for speedrunning --

__HOOK[ "InitPostEntity" ] = function()
	-- Remove useless shit --
	for _,ent in pairs( ents.FindByClass "func_door_rotating" ) do
		ent:Remove()
	end

	for _,ent in pairs( ents.FindByClass "func_breakable" ) do
		ent:Remove()
	end

	for _,ent in pairs( ents.FindByClass "logic_*" ) do
		ent:Remove()
	end

	for _,ent in pairs( ents.FindByClass "math_*" ) do
		ent:Remove()
	end

	for _,ent in pairs( ents.FindByClass "trigger_multiple" ) do
		ent:Remove()
	end

	-- Spawnpoints that we want to move for speedrunning reasons --
	local spawnTransport = {
		["Teleport.Top.Level1"] = Vector( -227, -6219, 3330 ),
	}

	for _,ent in pairs( ents.FindByClass "info_teleport_destination" ) do
		local name = ent:GetInternalVariable "m_iName"
		if !spawnTransport[name] then continue end

		ent:SetPos( spawnTransport[name] )
	end

	-- Set the correct pointer for triggers --
	local spawnPointers = {
		["Teleport.Top.Level1"] = "Teleport.Top.Level1",
	}

	-- Remove triggers that lead to these areas --
	local spawnRemovers = {
		["Teleport.Jail.CT.Level1"] = true,
		["Teleport.Jail.CT.Level2"] = true,
		["Teleport.Jail.CT.Level3"] = true,
		["Teleport.Jail.CT.Level4"] = true,
		["Teleport.Jail.CT.Level5"] = true,
		["Teleport.Jail.T.Level1"] = true,
		["Teleport.Jail.T.Level2"] = true,
		["Teleport.Jail.T.Level3"] = true,
		["Teleport.Jail.T.Level4"] = true,
		["Teleport.Jail.T.Level5"] = true,
		["Map.Winner.Teleport.Jail1.Winner"] = true,
		["Map.Winner.Teleport.Jail1.T"] = true,
		["Map.Winner.Teleport.Jail1.CT"] = true,
		["Teleport.Winner"] = true,
		["Teleport.Jail2.Level1"] = true,
		["Teleport.Jail2.Level2"] = true,
		["Teleport.Jail2.Level3"] = true,
		["Teleport.Jail2.Level4"] = true,
		["Teleport.Jail2.Level5"] = true,
	}

	-- Remove triggers related to a specific mechanism --
	local spawnNameRemovers = {

	}

	for _,ent in pairs( ents.FindByClass "trigger_teleport" ) do
		local name = ent:GetInternalVariable "target"
		local currentName = ent:GetInternalVariable "parentname"

		if spawnRemovers[name] or spawnNameRemovers[currentName] then
			ent:Remove()

			continue
		end

		-- Prioritize excluders first since we need to do this for the "bonuses" --
		if spawnPointers[name] then
			local pointer = spawnPointers[name]

			ent:SetKeyValue( "target", pointer )
			Zones:GenerateSpawnZone( ent )
		end
	end
end
