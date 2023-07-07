--Woah. Removes jail, fixes func_door @ s2, and fixes bonus teleport triggers.

__HOOK[ "InitPostEntity" ] = function()
	for k,v in pairs(ents.FindByClass("trigger_teleport")) do
		if v:GetName() == "teleporter_07" then
			v:Remove()
		end
		if v:GetName() == "teleporter_06" then
			v:SetKeyValue( "target", "teleporter_knife_destination" )
		end
		if v:GetPos() == Vector( 2682, -1056, 146 ) then
			v:Remove()
		end
		if v:GetPos() == Vector( -2228, 9852, -12572 ) then
			v:SetKeyValue( "target", "teleporter_13_destination" )
		end
	end
	for k,v in pairs(ents.FindByClass("func_button")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("point_template")) do
		v:Remove()
	end
end

__HOOK[ "EntityKeyValue" ] = function( ent, key, value )
	if ent:GetClass() == "func_door" then
		if key == "speed" then
			return "1000"
		end
		if key == "wait" then
			return "1"
		end
	end
end
