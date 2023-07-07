-- Harmonize my ass, fixes missing playerclips and unknown trigger type by utilizing anti-telehop triggers --

__HOOK[ "InitPostEntity" ] = function()
	-- Remove useless shit --
	for _,ent in pairs( ents.FindByClass "trigger_teleport_relative" ) do
		ent:Remove()
	end

	-- set location of teleporter
		local spawnTransport = {
		["s3_tele"] = Vector( 6144, -896, 444  ),
	}
	-- Set the correct pointer for triggers --
	local spawnPointers = {
		["s3_tele"] = "s3_tele",
	}
	for _,ent in pairs( ents.FindByClass "info_teleport_destination" ) do
		local name = ent:GetInternalVariable "m_iName"
		if !spawnTransport[name] then continue end

		ent:SetPos( spawnTransport[name] )
	end

	for _,ent in pairs( ents.FindByClass "trigger_teleport" ) do
		local name = ent:GetInternalVariable "target"

		if spawnPointers[name] then
			local pointer = spawnPointers[name]

			ent:SetKeyValue( "target", pointer )
			Zones:GenerateSpawnZone( ent )
		end
	end
end
