hook.Add( "InitPostEntity", "RemoveJailTrigger", function()
	if game.GetMap() == "surf_forbidden_tomb3" then
		local e = ents.FindByClass( "logic_timer" )
		for _,v in pairs(e) do if IsValid(v) then v:Remove() end end
	end
end )

__HOOK[ "EntityKeyValue" ] = function( ent, key, value )
	local index = ent:MapCreationID()
	local isIndexed = index == 1365

	if key == "speed" and isIndexed then
		return "3500"
	end
end