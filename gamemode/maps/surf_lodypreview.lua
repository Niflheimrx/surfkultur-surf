--Holy kawaii desu baka map. Removes unnecessary objects and fixes some trigger problems.
--this is a re-fix if you noticed :p

__HOOK[ "InitPostEntity" ] = function()
	for k,v in pairs(ents.FindByClass("func_door_rotating")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("func_door")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("func_breakable")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("path_track")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("func_tracktrain")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("func_illusionary")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("ambient_generic")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("info_teleport_destination")) do
		if v:GetName() == "laststage_fail" then
			v:SetPos( Vector( 8179.1, 870, 3998.5 ))
		end
		if v:GetName() == "last_tele" then
			v:SetPos( Vector( 8179.1, 870, 3998.5 ))
		end
	end
	for k,v in pairs(ents.FindByClass("trigger_gravity")) do
		if v:GetName() == "laststage_fail_revertgrav" then
			v:SetPos( Vector( 8179.1, 870, 3998.5 ))
		end
		if v:GetName() == "reset_grav_last" then
			v:SetPos( Vector( 6211.1, 678.8, 1378.5 ))
		end
	end
end
