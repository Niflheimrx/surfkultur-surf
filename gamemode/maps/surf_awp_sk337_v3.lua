--oh shit its a combat surf map, attempted to fix start triggers and also removes jails.

__HOOK[ "InitPostEntity" ] = function()
	for k,v in pairs(ents.FindByClass("func_tanktrain")) do
		if v:GetName() == "fun_rot_Spawn" then
			v:Remove()
		end
	end
	for k,v in pairs(ents.FindByClass("trigger_push")) do
		if v:GetName() == "Push_spawn1" then
			v:Fire("Enable")
			v:SetName(v:GetName().."_rename")
		end
	end
	for k,v in pairs(ents.FindByClass("trigger_teleport")) do
		if v:GetName() == "Tp_2_jail_stage1" then
			v:Remove()
		end
		if v:GetName() == "Tp_2_jail_stage2" then
			v:Remove()
		end
		if v:GetName() == "Tp_2_jail_stage3" then
			v:Remove()
		end
	end
	for k,v in pairs(ents.FindByClass("path_track")) do
		if v:GetName() == "tracktar" or v:GetName() == "tracktar2" or v:GetName() == "tracktar3" or v:GetName() == "tracktar4" then
			v:SetPos( Vector( -11520, -14080, 6080 ))
		end
	end
	for k,v in pairs(ents.FindByClass("prop_physics_multiplayer")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("ambient_generic")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("func_breakable")) do
		if v:GetName() != "break_lock" then
			v:Remove()
		end
	end
end