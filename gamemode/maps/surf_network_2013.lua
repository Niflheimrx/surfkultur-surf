--removes a lot of useless shit
--also sets the teleport destination for the fail triggers to avoid the jails
	local spawnTransport = {
		["spawn_retry"] = Vector( -863, -644, 576 ),
		["jail_seperate"] = Vector( -863, -644, 576 ),
	}

	local spawnPointers = {
		["spawn_retry"] = "spawn_retry",
		["jail_seperate"] = "jail_seperate",
	}

__HOOK[ "InitPostEntity" ] = function()
--change the location of the teleport destination
	for _,ent in pairs( ents.FindByClass "info_teleport_destination" ) do
		local name = ent:GetInternalVariable "m_iName"
		if !spawnTransport[name] then continue end

		ent:SetPos( spawnTransport[name] )
		local currentAngle = ent:GetAngles()
		local newAngle = currentAngle + Angle( 0, 90, 0 )

		ent:SetAngles( newAngle )
	end
--create spawnzone for teleport
	for _,ent in pairs( ents.FindByClass "trigger_teleport" ) do
		local name = ent:GetInternalVariable "target"

		if spawnPointers[name] then
			local pointer = spawnPointers[name]

			ent:SetKeyValue( "target", pointer )
			Zones:GenerateSpawnZone( ent )
		end
	end

	-- Remove useless shit --
	for _,ent in pairs( ents.FindByClass "func_movelinear" ) do
		ent:Remove()
	end
	for _,ent in pairs( ents.FindByClass "func_button" ) do
		ent:Remove()
	end
	for _,ent in pairs( ents.FindByClass "trigger_hurt" ) do
		ent:Remove()
	end
	for _,ent in pairs( ents.FindByClass "logic_relay" ) do
		ent:Remove()
	end
	for _,ent in pairs( ents.FindByClass "logic_case" ) do
		ent:Remove()
	end
	for _,ent in pairs( ents.FindByClass "point_servercommand" ) do
		ent:Remove()
	end
	for _,ent in pairs( ents.FindByClass "game_player_equip" ) do
		ent:Remove()
	end
	for _,ent in pairs( ents.FindByClass "trigger_multiple" ) do
		ent:Remove()
	end
	for _,ent in pairs( ents.FindByClass "filter_activator_team" ) do
		ent:Remove()
	end
end
