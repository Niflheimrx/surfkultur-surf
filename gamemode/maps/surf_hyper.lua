--- fixes hyperannoying thing at s2
-- 2020: Made s4 use 3500 speed

__HOOK[ "InitPostEntity" ] = function()
	for k,v in pairs(ents.FindByClass("func_rotating")) do
		 v:Remove()
	end
end

__HOOK[ "EntityKeyValue" ] = function( ent, key, value )
	local index = ent:MapCreationID()
	local isIndexed = index == 1357

	if key == "speed" and isIndexed then
		return "3500"
	end
end
