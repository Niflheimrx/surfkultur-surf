__HOOK[ "EntityKeyValue" ] = function( ent, key, value )
	local index = ent:MapCreationID()
	local isIndexed = index == 1689

	if key == "OnStartTouch" and isIndexed then
		return "!activator,AddOutput,Basevelocity -3900 0 900,0,-1"
	end
end
