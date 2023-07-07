--set b1 boost to 3500 and made the filters on s3 slightly less inconsistent by removing unneccesary ones
__HOOK[ "InitPostEntity" ] = function()
	for k,v in pairs(ents.FindByClass("filter_activator_name")) do
		if v:GetName() == "f_b2cp2" or v:GetName() == "f_b2cp3" then
			v:Remove()
		end
	end
end

__HOOK[ "EntityKeyValue" ] = function( ent, key, value )
	local index = ent:MapCreationID()
	local isIndexed = index == 1546

	if key == "speed" and isIndexed then
		return "3500"
	end
end