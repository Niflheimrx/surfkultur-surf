--Fix this fucking map

local remove = {
Vector( -6620, -3416, -5072 ),
Vector( -7703, -9016, -5975 ),
Vector( -7280, -652, -5036 ),
Vector( -4424, 2269.5, -1128 ),
Vector( -8424, 5204.5, -5212 ),
Vector( -3366, -5504, -4240 ),
Vector( -5071.5, -9016, -2720 ),
Vector( -1704, -2532, -2604 ),
Vector( 2008, -3336, -6736 ),
Vector( -1056, -1872, -1863.5 ),
Vector( -1608, -28, 448 ),
Vector( 1572, -1940.5, -424.5 ),
Vector( -1224, 4924, -1000 ),
Vector( -3288, -2644, -1940 ),
Vector( 2022.38, 4783, -672 ),
Vector( 2022.38, 5315, -1244 ),
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
	
	for k,v in pairs(ents.FindByClass("func_door")) do
		v:Remove()
	end

end
