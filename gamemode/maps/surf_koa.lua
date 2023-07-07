
__HOOK[ "EntityKeyValue" ] = function( ent, key, value )
	local index = ent:MapCreationID()
	local isIndexed = index == 1797

	if key == "speed" and isIndexed then
		return "3500"
	end
end