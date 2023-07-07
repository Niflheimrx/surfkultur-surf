-- 11/26/2020: this apparently didn't have a fix message lol.
-- Removed telehop for every stage
-- Redo jail removal
-- Remove those fuckin tesla static shit

__HOOK[ "InitPostEntity" ] = function()
	-- Remove useless shit --
	for _,ent in pairs( ents.FindByClass "func_dustcloud" ) do
		ent:Remove()
	end

	for _,ent in pairs( ents.FindByClass "trigger_multiple" ) do
		ent:Remove()
	end

	-- Goddamn these are annoying
	for _,ent in pairs( ents.FindByClass "point_tesla" ) do
		ent:Remove()
	end

	for _,ent in pairs( ents.FindByClass "trigger_once" ) do
		ent:Remove()
	end

	-- Spawnpoints that we want to move for speedrunning reasons --
	local spawnTransport = {
		["stage2"] = Vector( 2048, 2800, 994 ),
		["stage3"] = Vector( -2080, -352, 222 ),
		["stage4"] = Vector( 4064, -1312, 162 ),
		["stage5"] = Vector( 6090, -1118.5, -4675 ),
		["stage_5_destenation"] = Vector( 6090, -1118.5, -4675 ),
		["stage6"] = Vector( 14088, -1536, -10 ),
		["stage7"] = Vector( 8833.5, -1067, 1116.5 ),
		["stage8"] = Vector( 11264, 2520, 882 ),
		["stage9"] = Vector( -4516.5, -1898, 406 ),
		["bonus"] = Vector( -6960, -1032, 974.5 )
	}

	for _,ent in pairs( ents.FindByClass "info_teleport_destination" ) do
		local name = ent:GetInternalVariable "m_iName"
		if !spawnTransport[name] then continue end

		ent:SetPos( spawnTransport[name] )
	end

	-- Set the correct pointer for triggers --
	local spawnPointers = {
		["Stage1"] = "Stage1",
		["stage2"] = "stage2",
		["stage3"] = "stage3",
		["stage4"] = "stage4",
		["stage5"] = "stage5",
		["stage6"] = "stage6",
		["stage7"] = "stage7",
		["stage8"] = "stage8",
		["stage9"] = "stage9",
		["bonus"] = "bonus",
	}

	-- Remove triggers that lead to these areas --
	local spawnRemovers = {
		["T_teleport"] = true,
		["bonusend noobs"] = true,
		["Ct_teleport"] = true,
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
