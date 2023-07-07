--Exocube is miles better. Fixes the jail and replaces some spawn points.

__HOOK[ "InitPostEntity" ] = function()
	for k,v in pairs(ents.FindByClass("logic_timer")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("ambient_generic")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("trigger_once")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("trigger_multiple")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("func_rot_button")) do
		v:Remove()
	end
end

__HOOK[ "EntityKeyValue" ] = function( ent, key, value )
	if ent:GetClass() == "trigger_teleport" then
		if key == "target" then
			if value == "tp_nakaz" then
				return "tp"
			end
		end
	end
	if ent:GetClass() == "func_lod" and key == "DisappearDist" then
		print( key .. " | " .. value )
		return "10000000"
	end
end
