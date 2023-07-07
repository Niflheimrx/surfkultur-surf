--not even lore tastic. Removes jail and removes Stage 1 Skip.

__HOOK[ "InitPostEntity" ] = function()
	for k,v in pairs(ents.FindByClass("trigger_teleport")) do
		if v:GetName() == "timesup1" then
			v:Remove()
		end
		if v:GetName() == "someone_won_tele1" then
			v:Remove()
		end
		if v:GetName() == "secretjail1" then
			v:Remove()
		end
	end
	for k,v in pairs(ents.FindByClass("func_*")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("logic_*")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("point_servercommand")) do
		v:Remove()
	end
end

__HOOK[ "EntityKeyValue" ] = function( ent, key, value )
	if ent:GetClass() == "trigger_teleport" then
		if ent:GetName() == "noobactivator" then
			ent:Remove()
		end
	end
end
