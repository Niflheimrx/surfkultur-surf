-- Harmonize my ass, fixes missing playerclips and unknown trigger type by utilizing anti-telehop triggers --

__HOOK[ "InitPostEntity" ] = function()
	-- Remove useless shit --
	for _,ent in pairs( ents.FindByClass "trigger_teleport_relative" ) do
		ent:Remove()
	end

	-- Set the correct pointer for triggers --
	local spawnPointers = {
		["stage1"] = "stage1",
		["stage2"] = "stage2",
		["stage3"] = "stage3",
		["stage4"] = "stage4",
		["stage5"] = "stage5",
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
