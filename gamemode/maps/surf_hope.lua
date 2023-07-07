-- Natanskybudder8 made an interesting discovery with surf_hope's shitty teleport system --
-- Removes transitions and instead uses restart Lua triggers --

__HOOK[ "InitPostEntity" ] = function()
	-- Moves info_teleport_destination entities to the correct place --
	local spawnTransport = {
		["stage1"] = Vector( -3040, -11008, -671 ),
		["stage2"] = Vector( -352, -256, 321 ),
		["stage3"] = Vector( 9488, 9728, -447 ),
	}

	for _,ent in pairs( ents.FindByClass "info_teleport_destination" ) do
		local name = ent:GetInternalVariable "m_iName"
		if !spawnTransport[name] then continue end

		ent:SetPos( spawnTransport[name] )
	end

	-- Set the correct pointer for triggers --
	local spawnPointers = {
		["stage1"] = "stage1",
		["stage2"] = "stage2",
		["stage3"] = "stage3",
	}

	for _,ent in pairs( ents.FindByClass "trigger_teleport" ) do
		local name = ent:GetInternalVariable "target"

		if spawnPointers[name] then
			local pointer = spawnPointers[name]

			ent:SetKeyValue( "target", pointer )
			Zones:GenerateSpawnZone( ent )
		end
	end
end
