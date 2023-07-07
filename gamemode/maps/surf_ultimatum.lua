-- This map is not so ultimate anymore!! --
__HOOK[ "InitPostEntity" ] = function()
	-- Remove useless shit --
	for _,ent in ipairs(ents.FindByClass "logic_timer") do
		ent:Remove()
	end
	for _,ent in ipairs(ents.FindByClass "logic_auto") do
		ent:Remove()
	end
	for _,ent in pairs( ents.FindByClass "trigger_hurt" ) do
		ent:Remove()
	end
	for _,ent in pairs( ents.FindByClass "trigger_once" ) do
		ent:Remove()
	end
	for _,ent in pairs( ents.FindByClass "func_breakable" ) do
		ent:Remove()
	end
	for _,ent in pairs( ents.FindByClass "func_button" ) do
		ent:Remove()
	end
	for _,ent in pairs( ents.FindByClass "trigger_multiple" ) do
		ent:Remove()
	end
	for _,ent in pairs( ents.FindByClass "point_servercommand" ) do
		ent:Remove()
	end
	for _,ent in pairs( ents.FindByClass "func_doorz" ) do
		ent:Remove()
	end

	-- Remove triggers that lead to these areas --
	local spawnRemovers = {
		["jail_fail"] = true,
	}

	for _,ent in ipairs(ents.FindByClass "trigger_teleport") do
		local name = ent:GetInternalVariable "target"

		if spawnRemovers[name] then
			ent:Remove()

			continue
		end
	end
end

