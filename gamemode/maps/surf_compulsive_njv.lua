local remove = {
Vector( -9535, 2481, 3478 ),
}

 
__HOOK[ "InitPostEntity" ] = function()
    for k,v in pairs(ents.FindByClass("trigger_teleport")) do
        if(table.HasValue(remove,v:GetPos())) then
            v:Remove()
        end
    end
end

__HOOK[ "EntityKeyValue" ] = function( ent, key, value )
	local index = ent:MapCreationID()
	local isIndexed = index == 1926

	if key == "speed" and isIndexed then
		return "2700"
	end
end