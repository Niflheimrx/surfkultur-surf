-- 01/11/2021: apparently this map has missing brush entities??
-- EDIT: so a filter is in place (as expected) and it would never apply properly, this fixes that
-- Also after the first 4 triggers it purposefully put triggers for the jail instead of the map???

__HOOK[ "InitPostEntity" ] = function()
	-- Remove useless shit --
	for _,ent in pairs( ents.FindByClass "trigger_multiple" ) do
		ent:Remove()
	end

	for _,ent in pairs( ents.FindByClass "trigger_once" ) do
		ent:Remove()
	end

	for _,ent in pairs( ents.FindByClass "func_door" ) do
		ent:Remove()
	end

	for _,ent in pairs( ents.FindByClass "func_rotating" ) do
		ent:Remove()
	end

	-- Set the correct pointer for triggers --
	local spawnPointers = {
		["desty_tjail_dgl"] = "spawn_desty",
		["desty_ctjail_dgl"] = "spawn_desty",
		["desty_end"] = "spawn_desty",
	}

	for _,ent in pairs( ents.FindByClass "trigger_teleport" ) do
		local name = ent:GetInternalVariable "target"

		-- Set the correct target for jail spawns --
		if spawnPointers[name] then
			local pointer = spawnPointers[name]

			ent:SetKeyValue( "target", pointer )
			ent:SetSaveValue( "m_hFilter", nil )

			ent:Fire("Enable")
			ent:SetName(ent:GetName() .. "_rename")
		end
	end
end
