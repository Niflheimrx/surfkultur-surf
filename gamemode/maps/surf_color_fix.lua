__HOOK[ "InitPostEntity" ] = function()
	for k,v in pairs(ents.FindByClass("func_button")) do
		v:Remove()
	end

__HOOK[ "EntityKeyValue" ] = function( ent, key, value )
	if ent:GetClass() == "trigger_teleport" then
		if key == "targetname" then
			if value == "Level_hellblau" then
				ent:Remove()
			end
		end
	end
