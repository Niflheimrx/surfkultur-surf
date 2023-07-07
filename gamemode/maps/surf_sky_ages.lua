--The sky map takes AGES HAHA XD. Removes the jail and fixes boosters along with trigger_push.
-- 2020: made s3 spinners not move and ruin my mood
-- 03/06/2021: Redo fix entirely

__HOOK[ "InitPostEntity" ] = function()
	-- Remove useless shit --
	for _,ent in pairs( ents.FindByClass "ambient_generic" ) do
		ent:Remove()
	end

	for _,ent in pairs( ents.FindByClass "env_soundscape" ) do
		ent:Remove()
	end

	for _,ent in pairs( ents.FindByClass "trigger_gravity" ) do
		ent:Remove()
	end

	-- Remove stupid doors --
	for _,ent in pairs( ents.FindByClass "func_door" ) do
		ent:Remove()
	end

	for _,ent in pairs( ents.FindByClass "func_rotating" ) do
		ent:Fire "Toggle"
	end

	-- Remove triggers related to a specific mechanism --
	local spawnNameRemovers = {
		["timeupteleswin"] = true,
		["timeupteles"] = true,
		["falldoor1"] = true,
		["falldoor2"] = true,
		["falldoor3"] = true,
		["falldoor4"] = true,
	}

	for _,ent in pairs( ents.FindByClass "trigger_teleport" ) do
		local currentName = ent:GetInternalVariable "m_iName"
		local parentName = ent:GetInternalVariable "parentname"

		if spawnNameRemovers[currentName] or spawnNameRemovers[parentName] then
			ent:Remove()
		end
	end
end
