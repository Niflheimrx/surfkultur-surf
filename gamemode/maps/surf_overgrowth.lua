--my favorite map :D

local remove = {
Vector( -6624, 12128, -11232 ),
Vector( -12864, -224, 1536 ),
Vector( -5728, -6016, -5952 ),
Vector( 6224, 3616, -5280 ),
Vector( 2976, 2336, 9504 ),
Vector( -1120, -13376, 7264 ),
Vector( 11920, 208, 160 ),
Vector( -9100, -9888, -632 ),
Vector( -5728, -6016, -8408 ),
}

__HOOK[ "InitPostEntity" ] = function()
	for k,v in pairs(ents.FindByClass("trigger_teleport")) do
		if(table.HasValue(remove,v:GetPos())) then
			v:Remove()
		end
	end
	
	for k,v in pairs(ents.FindByClass("trigger_multiple")) do
		if(table.HasValue(remove,v:GetPos())) then
			v:Remove()
		end
	end
end