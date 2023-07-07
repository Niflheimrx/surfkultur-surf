local remove = {
Vector( 112, -8324, 11536 ),
}

local remove2 = {
Vector( 14776, -12888, 7752 ),
Vector( 12048, -13200, 7144 ),
Vector( 12048, -12976, 7144 ),
Vector( 12272, -12976, 7144 ),
Vector( 12272, -13200, 7144 ),
Vector( 14663, -5925, 2326 ),
Vector( 14663, -5925, 2294 ),
}

__HOOK[ "InitPostEntity" ] = function()
	for k,v in pairs(ents.FindByClass("trigger_multiple")) do
		if(table.HasValue(remove,v:GetPos())) then
			v:Remove()
		end
	end
	
		for k,v in pairs(ents.FindByClass("trigger_teleport")) do
		if(table.HasValue(remove2,v:GetPos())) then
			v:Remove()
		end
	end
	
	for k,v in pairs(ents.FindByClass("logic_case")) do
		if(v:GetPos() == Vector(-408, -8784, 10920)) then
			v:Remove()
		end
	end
	for k,v in pairs(ents.FindByClass("logic_timer")) do
		if(v:GetPos() == Vector(12160, -13088, 7144)) then
			v:Remove()
		end
	end
end