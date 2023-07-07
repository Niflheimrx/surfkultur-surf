--land of the free! Removes jails and related triggers. Also removes those stupid func_lod ramps and slows down the rotating entity at the end of the map to 0.00000000000000000001.

--2020 a sneaky trigger_once put people in jail, no more!
__HOOK[ "InitPostEntity" ] = function()
	for k,v in pairs(ents.FindByClass("trigger_multiple")) do
		if v:GetName() == "killablemidround" then
			v:Remove()
		end
	end
	for k,v in pairs(ents.FindByClass("trigger_teleport")) do
		if v:GetName() == "EndTele" then
			v:Remove()
		end
		if v:GetName() == "everythingfilt" then
			v:Fire("Enable")
			v:SetName(v:GetName().."_rename")
		end
	end
	for k,v in pairs(ents.FindByClass("trigger_hurt")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("trigger_once")) do
		v:Remove()
	end
end

__HOOK[ "EntityKeyValue" ] = function( ent, key, value )
	if ent:GetClass() == "func_lod" and key == "DisappearDist" then
		return "10000000"
	end

	local index = ent:MapCreationID()
	local isIndexed = index == 1589

	if key == "maxspeed" and isIndexed then
		return "0.00000000000000000001"
	end
end
