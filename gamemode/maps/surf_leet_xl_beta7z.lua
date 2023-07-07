--Elite gamers unite
__HOOK[ "EntityKeyValue" ] = function( ent, key, value )
	if ent:GetClass() == "func_conveyor" and key == "speed" then
		print( key .. " | " .. value )
		return "3500"
	end
end
