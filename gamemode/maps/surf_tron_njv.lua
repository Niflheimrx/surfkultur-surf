-- sets the first boost to 3500, to stop the rng crouchboost

__HOOK[ "EntityKeyValue" ] = function( ent, key, value )
	local index = ent:MapCreationID()
	local isIndexed = index == 1272

	if key == "speed" and isIndexed then
		return "3500"
	end
end
