--decent map that's quick and short. sad it has jails. Removes jail and sets teleporters in correct position.

__HOOK[ "InitPostEntity" ] = function()
	for k,v in pairs(ents.FindByClass("trigger_teleport")) do
		if v:GetName() == "tele_loosers" then
			v:Remove()
		end
	end
	for k,v in pairs(ents.FindByClass("func_button")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("func_rot_button")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("logic_auto")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("logic_timer")) do
		v:Remove()
	end
end

__HOOK[ "EntityKeyValue" ] = function( ent, key, value )
	if ent:GetClass() == "trigger_teleport" then
		if value == "dest_prejail" then
			return "dest_spawn"
		end
		if value == "dest_bonus_fail" then
			return "dest_bonus_fail_back"
		end
	end
end
