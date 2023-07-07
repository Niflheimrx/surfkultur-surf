--remember this map from the most popular ksf compilations video? same. Removes jail and re-does final teleporter.

__HOOK[ "InitPostEntity" ] = function()
	for k,v in pairs(ents.FindByClass("trigger_teleport")) do
		if v:GetName() == "Failure_teleport" then
			v:Remove()
		end
		if v:GetPos() == Vector( -1520, 4800, 1872 ) then
			v:SetKeyValue( "target", "Fire_Room_Location" )
		end
	end
end

__HOOK[ "EntityKeyValue" ] = function( ent, key, value )
	if ent:GetClass() == "trigger_teleport" then
		if key == "filtername" then
			return ""
		end
	end
		local index = ent:MapCreationID()
		local isIndexed = index == 1453 or index == 1454

	if key == "speed" and isIndexed then
		return "2400"
	end
end