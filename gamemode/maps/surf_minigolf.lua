__HOOK[ "EntityKeyValue" ] = function( ent, key, value )
	if ent:GetClass() == "trigger_teleport" then
		if key == "hammerid" then
			if value == "269342" then
				ent:Remove()
			end
		end
	end
end
