--The orange box. Fixes teleport values.
-- 11/26/2020: really clean up this map and make it speedrunable, did the following:
-- Redo all trigger teleports to point to the correct location
-- Make transition from s1 -> s2 much easier by pushing the trigger outwards very slightly
-- Move stage 2 spawnpoint to be closer to the ramp, always teleport to the upmost floor at the center
-- Move stage 3 spawnpoint to be closer to the ramp, always teleport to the left side
-- Remove telehops for every stage

__HOOK[ "InitPostEntity" ] = function()
	-- Remove stupid trigger_push at the start of the map --
	local pushRemovers = {
		["-12802.50 8853.00 1531.00"] = true,
		["-12802.50 11739.00 1531.00"] = true,
	}

	for _,ent in pairs( ents.FindByClass "trigger_push" ) do
		local currentPos = util.TypeToString( ent:GetPos() )
		if !pushRemovers[currentPos] then continue end

		ent:Remove()
	end

	-- Remove useless shit --
	for _,ent in pairs( ents.FindByClass "info_target" ) do
		ent:Remove()
	end

	for _,ent in pairs( ents.FindByClass "trigger_multiple" ) do
		ent:Remove()
	end

	for _,ent in pairs( ents.FindByClass "logic_case" ) do
		ent:Remove()
	end

	for _,ent in pairs( ents.FindByClass "func_rotating" ) do
		ent:Remove()
	end

	-- Spawnpoints that we want to move for speedrunning reasons --
	local spawnTransport = {
		["TstartPART2"] = Vector( -12733, 8921, 1512 ),
		["stuckteleport1"] = Vector( -608, 606.5, 1388 ),
		["3dpartctside"] = Vector( 11295.5, -13054.5, 102 ),
	}

	for _,ent in pairs( ents.FindByClass "info_teleport_destination" ) do
		local name = ent:GetInternalVariable "m_iName"
		if !spawnTransport[name] then continue end

		ent:SetPos( spawnTransport[name] )
	end

	-- Set the correct pointer for triggers --
	local spawnPointers = {
		["targ1"] = "TstartPART2",
		["floor1"] = "stuckteleport1",
		["3dpartctside"] = "3dpartctside",
		["3dpartTside"] = "3dpartctside",
	}

	-- Triggers that we want to move for speedrunning reasons --
	local spawnMovers = {
		["-9321.00 15729.50 -2036.00"] = Vector( -9312, 15760.5, -2036 )
	}

	-- Exclude these triggers and point them correctly --
	local spawnExcluders = {
		["1127.50 1392.00 -945.50"] = "stuckteleport1",
		["1142.50 -192.50 -945.50"] = "stuckteleport1",
		["13292.50 -13142.00 -1059.50"] = "3dpartctside",
		["13299.50 -11929.50 -2381.00"] = "3dpartctside",
		["9190.50 -11401.50 -3323.50"] = "3dpartctside",
		["8930.00 -10273.50 -3305.00"] = "3dpartctside",
		["8111.00 -7962.50 -4532.50"] = "3dpartctside",
		["7007.50 -4225.50 -5488.50"] = "3dpartctside",
		["8112.97 -3816.97 -4453.50"] = "3dpartctside",
		["4018.00 -3738.00 -6643.00"] = "3dpartctside",
		["1088.00 -3715.00 -7194.50"] = "3dpartctside",
		["-53.50 -4770.50 -7763.50"] = "3dpartctside",
		["2930.93 -4815.50 -12779.90"] = "3dpartctside",
		["5988.50 -4841.50 -13999.50"] = "3dpartctside",
		["9158.50 -3261.50 -14857.50"] = "3dpartctside",
		["9832.50 2093.50 -16308.00"] = "3dpartctside",
	}

	-- Remove triggers that lead to these areas --
	local spawnRemovers = {
		["TfloorTELEPORT"] = true,
		["jail1stfloor"] = true,
		["CTfloorTELEPORT"] = true,
		["aboveCTspawn"] = true,
		["aboveTspawn"] = true,
		["jailtop"] = true,
		["jail2ndfloor"] = true,
		["4way part 1"] = true,
		["4way part 2"] = true,
		["4way part 3"] = true,
		["4way part 4"] = true,
		["guyonblock"] = true,
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

		-- Prioritize excluders first since we need to do this for last stage --
		if spawnExcluders[currentPos] or spawnPointers[name] then
			local pointer = spawnExcluders[currentPos] or spawnPointers[name]

			ent:SetKeyValue( "target", pointer )
			Zones:GenerateSpawnZone( ent )
		end
	end
end
