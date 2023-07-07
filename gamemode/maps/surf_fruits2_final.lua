--Fix this fucking map

local remove = {
Vector( -11972, 11844, 11540 ),
Vector( -4489, 8593, 8542 ),
Vector( -9354, 10874, 11815 ),
Vector( -7287, 12994.5, 9545 ),
Vector( -1401.5, 12690, 8248 ),
Vector( -2306, 10903, 31 ),
Vector( -7297, 6543, 10473 ),
Vector( -12655, 5094, 10324 ),
Vector( -4366, 2692.55, 10172 ),
Vector( -1344, 2456, 10706 ),
Vector( 7293, 3896, 4388 ),
Vector( -20, 10900, -874 ),
Vector( 1685, 5694.5, -7888.5 ),
Vector( -11112, -94, 11725 ),
Vector( -8529, 3378, 32 ),
Vector( -6457, -5064, 4199 ),
Vector( -5709, -1350, -1164 ),
Vector( -1787.5, -8612.5, 11310 ),
Vector( 10729, -2699, 8410 ),
Vector( 5787, -984, -3727 ),
Vector( 11151, -6194, 116.8 ),
Vector( 8728.98, -8135, 31 ),
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