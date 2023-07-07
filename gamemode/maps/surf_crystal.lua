--Crystal meth? WHERE. Removes the jail.

__HOOK[ "InitPostEntity" ] = function()
	for k,v in pairs(ents.FindByClass("func_button")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("logic_timer")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("prop_physics")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("func_breakable_surf")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("func_rotating")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("trigger_teleport")) do
		if v:GetName() == "end_of_round_teleports" then
			v:Remove()
		end
		if v:GetPos() == Vector( -5970, -9972, -12800 ) then
			v:SetKeyValue( "target", "creditorend" )
		end
		if v:GetName() == "level1_helper_teleport" then
			v:Fire("Toggle")
			v:SetName(v:GetName().."_rename")
		end
	end
end
