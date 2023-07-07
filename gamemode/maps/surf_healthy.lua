--cancer surf_fruits wannabees. removes jail.

__HOOK[ "InitPostEntity" ] = function()
	for k,v in pairs(ents.FindByClass("trigger_teleport")) do
		if v:GetName() == "FINTELE" then
			v:Remove()
		end
	end
end

__HOOK[ "EntityKeyValue" ] = function( ent, key, value )
	if ent:GetClass() == "trigger_teleport" then
		if key == "target" and value == "Tjail" then
			ent:Remove()
		end
	end
end
