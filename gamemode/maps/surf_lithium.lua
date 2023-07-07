--2020 version removed some more jails and boosted the s1 booster from 450 to 1000


__HOOK[ "InitPostEntity" ] = function()
	for k,v in pairs(ents.FindByClass("logic_timer")) do
		v:Remove()
	end
	
	for k,v in pairs(ents.FindByClass("trigger_teleport")) do
		if v:GetName() == "end_of_round_teleports" then
			v:Remove()
		end
	end
end

__HOOK[ "EntityKeyValue" ] = function( ent, key, value )
	local index = ent:MapCreationID()
	local isIndexed = index == 1356

	if key == "speed" and isIndexed then
		return "1000"
	end
end