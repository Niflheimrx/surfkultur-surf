--ahhhhh fuck me in the ass for these jail maps

local remove = {
Vector( 1340.5, -1788, 4805 ),
Vector( 1362, -181.5, 95.5 ),
Vector( 4630, 110, 1888.5 ),
Vector( 4630, 110, 1960.5 ),
Vector( -912.5, 257, 1879 ),
Vector( -912.5, 257, 1910 ),
Vector( -3258.5, -1710, 1687 ),
Vector( -3258.5, -1710, 2560 ),
Vector( 8143.5, -2412.5, 2456 ),
Vector( 8143.5, -2412.5, 2439 ),
Vector( 11707.5, 283.5, 2246.5 ),
Vector( 11707.5, 283.5, 2231.5 ),
Vector( 8143.5, 1838.5, 744 ),
Vector( 8143.5, 1838.5, 716 ),
Vector( 4210, 7716.5, 2719 ),
Vector( 4210, 7716.5, 2734 ),
Vector( -5761.5, -200, 2784.5 ),
Vector( -5761.5, -200, 2811.5 ),
Vector( 5952, 4672, 1497.5 ),
Vector( 5952, 4672, 1477.5 ),
Vector( 5824, 4672, 1497.5 ),
Vector( 5824, 4672, 1477.5 ),
Vector( 5696, 4672, 1497.5 ),
Vector( 5696, 4672, 1477.5 ),
Vector( 5568, 4672, 1497.5 ),
Vector( 5568, 4672, 1477.5 ),
Vector( 5440, 4672, 1497.5 ),
Vector( 5440, 4672, 1477.5 ),
Vector( 5312, 4672, 1497.5 ),
Vector( 5312, 4672, 1477.5 ),
Vector( 5184, 4672, 1497.5 ),
Vector( 5184, 4672, 1477.5 ),
Vector( 5056, 4672, 1497.5 ),
Vector( 5056, 4672, 1477.5 ),
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
	
	for k,v in pairs(ents.FindByClass("func_rotating")) do
		if(table.HasValue(remove,v:GetPos())) then
			v:Remove()
		end
	end
end
