--a map with a rainy mood, great for depressed people. First Tier 5 map that Stellar beat! Fixes some problems related to teleporters and doors.

__HOOK[ "EntityKeyValue" ] = function( ent, key, value )
	if ent:GetClass() == "trigger_teleport" then
		if key == "filtername" and value == "teleport_filter" then
			ent:Remove()
		end
		if key == "filtername" and value == "noboostlaststage" then
			ent:Remove()
		end
	end
end

__HOOK[ "InitPostEntity" ] = function()
	for k,v in pairs(ents.FindByClass("func_door")) do
		v:Remove()
	end
end