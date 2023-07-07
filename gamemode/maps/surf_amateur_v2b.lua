--Jails on a tough map eh?
-- 11/27/2020: Fast checkup on jail removal

__HOOK[ "InitPostEntity" ] = function()
	-- Remove useless shit --
	for _,ent in pairs( ents.FindByClass "point_spotlight" ) do
		ent:Remove()
	end

	for _,ent in pairs( ents.FindByClass "trigger_multiple" ) do
		ent:Remove()
	end

	for _,ent in pairs( ents.FindByClass "trigger_hurt" ) do
		ent:Remove()
	end

	-- Spawnpoints that we want to move for speedrunning reasons --
	local spawnTransport = {
		--["stage2"] = Vector( 2048, 2800, 994 ),
	}

	for _,ent in pairs( ents.FindByClass "info_teleport_destination" ) do
		local name = ent:GetInternalVariable "m_iName"
		if !spawnTransport[name] then continue end

		ent:SetPos( spawnTransport[name] )
	end

	-- Set the correct pointer for triggers --
	local spawnPointers = {
		--["Stage1"] = "Stage1",
	}

	-- Remove triggers that lead to these areas --
	local spawnRemovers = {
		["PLAYER_CHICKEN"] = true,
		["PLAYER_GUN"] = true,
		["Jail_x_o_ct"] = true,
		["jail_x_o_t"] = true,
		["jail_winner_ct"] = true,
		["jail_winner_t"] = true,
		["jail_luser_t"] = true,
		["jail_luser_ct"] = true,
		["GOD"] = true,
		["GOD_WAY"] = true,
		["T_GOD"] = true,
		["CT_GOD"] = true,
		["trig_way_god"] = true,
	}

	for _,ent in pairs( ents.FindByClass "trigger_teleport" ) do
		local name = ent:GetInternalVariable "target"

		if spawnRemovers[name] then
			ent:Remove()

			continue
		end

		if spawnPointers[name] then
			local pointer = spawnPointers[name]

			ent:SetKeyValue( "target", pointer )
			Zones:GenerateSpawnZone( ent )
		end
	end
end
