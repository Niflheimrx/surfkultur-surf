-- 01/17/2021: apparently last trigger is clipped so low that tick predictions doesn't know if the player hit the trigger with the specified speed

__HOOK[ "InitPostEntity" ] = function()
	local triggerindex = {
		[1403] = Vector( -11088, 1592, -9068 ),
		[2082] = Vector( -3072, 1592, -9068 ),
	}

	for _,ent in pairs( ents.FindByClass "trigger_teleport" ) do
		local index = ent:MapCreationID()
		local newPos = triggerindex[index]
		if newPos then
			ent:Remove()
		end
	end
end
