--cancer surf_fruits wannabees

local remove = {
Vector( -3152, -6016, -1 ),
Vector( 0, -5882.5, -123.5 ),
Vector( 0.5, -9792, -96 ),
Vector( -10467, 0, 888 ),
Vector( -10467, 0, -984 ),
Vector( -8192, 0, 0 ),
Vector( -5752.67, 0.28, 0.16 ),
Vector( -3680, 2, -6 ),
Vector( -1256, 8, 101 ),
Vector( 759, 0, -9 ),
Vector( 3072, 0, 114 ),
Vector( 5655, -1, 124 ),
Vector( 8274, -16, 2240 ),
Vector( 11085.2, -2.5, 86 ),
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
	
	for k,v in pairs(ents.FindByClass("func_door")) do
		v:Remove()
	end
	
	for k,v in pairs(ents.FindByClass("func_door_rotating")) do
		v:Remove()
	end
	
	for k,v in pairs(ents.FindByClass("func_movelinear")) do
		v:Remove()
	end
end