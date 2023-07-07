
__HOOK[ "InitPostEntity" ] = function()
	for k,v in pairs(ents.FindByClass("func_door_rotating")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("func_door")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("func_rotating")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("func_movelinear")) do
		v:Remove()
	end
end

__HOOK[ "EntityKeyValue" ] = function( ent, key, value )
	if ent:GetClass() == "trigger_teleport" then
		if key == "hammerid" then
			if value == "14019" or value == "34395" or value == "34398" or value == "34401" then
				ent:Remove()
			end
		end
	end
end
