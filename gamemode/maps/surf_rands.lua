--lul, ur good. Removes the broken filter for the bonus 3 triggers.

__HOOK[ "EntityKeyValue" ] = function( ent, key, value )
	if ent:GetClass() == "trigger_teleport" then
		if ent:GetPos() == Vector( -6076, -12392, 11764 ) then
			if key == "filtername" then
				return ""
			end
		end
	end
end