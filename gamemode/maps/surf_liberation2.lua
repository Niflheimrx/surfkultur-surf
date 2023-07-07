--Why does this have fucking jails
--2020: liberated map from moving linears

local remove = {
Vector( -12256, 640, -11248 ),
Vector( -12256, 216, -11176 ),
Vector( -10752, 2048, -12912 ),
Vector( -7168, 3840, -8944 ),
Vector( -4096, -16, -7168 ),
Vector( -1536, 2048, -3008 ),
Vector( 1024, 11512, -2672 ),
Vector( 1024, 3584, 2096 ),
Vector( 3584, 2048, 6768 ),
Vector( 6656, -1456, 12544 ),
Vector( 9216, -6944, -4592 ),
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
	
	for k,v in pairs(ents.FindByClass("logic_auto")) do
		if(table.HasValue(remove,v:GetPos())) then
			v:Remove()
		end
	end
	for k,v in pairs(ents.FindByClass("func_movelinear")) do
			v:Remove()
	end
end