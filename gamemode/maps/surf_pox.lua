--nothing screams surf like old poor visibility maxvel maps with jails

Zones.Options.NoStartLimit = 1
--spawnpoints that we wanna move for speedrunning reasons
	local spawnTransport = {
		["noob_teleport_1"] = Vector( 2696, 5012, 1232 ),
		["noob_teleport_2"] = Vector( 2696, 5012, 1232 ),
		["noob_teleport_3"] = Vector( 2696, 5012, 1232 ),
		["noob_teleport_4"] = Vector( 2696, 5012, 1232 )
	}

	local spawnPointers = {
		["noob_teleport_1"] = "noob_teleport_1",
		["noob_teleport_2"] = "noob_teleport_2",
		["noob_teleport_3"] = "noob_teleport_3",
		["noob_teleport_4"] = "noob_teleport_4",
	}

__HOOK[ "InitPostEntity" ] = function()
--change the location of the teleport destination
	for _,ent in pairs( ents.FindByClass "info_teleport_destination" ) do
		local name = ent:GetInternalVariable "m_iName"
		if !spawnTransport[name] then continue end
		ent:SetPos( spawnTransport[name] )

		local newAngle =  Angle( 0, 90, 0 )
		ent:SetAngles( newAngle )
	end
--change the location of the teleport destination
	for _,ent in pairs( ents.FindByClass "info_teleport_destination" ) do
		local name = ent:GetInternalVariable "m_iName"
		if !spawnTransport[name] then continue end

		ent:SetPos( spawnTransport[name] )
	end
--create spawnzone for teleport
	for _,ent in pairs( ents.FindByClass "trigger_teleport" ) do
		local name = ent:GetInternalVariable "target"

		if spawnPointers[name] then
			local pointer = spawnPointers[name]

			ent:SetKeyValue( "target", pointer )
			Zones:GenerateSpawnZone( ent )
		end
-- remove jail triggers
		if ent:GetName() == "tele_secret" then
			ent:Remove()
		end
	end
--remove trigger multiple
	for _,ent in pairs( ents.FindByClass "trigger_multiple" ) do
		ent:Remove()
	end
end