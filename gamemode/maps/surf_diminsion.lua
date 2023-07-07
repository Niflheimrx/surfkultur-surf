--Why does this have fucking jails

local remove = {
Vector(8672, 1440, -10464)
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
	for k,v in pairs(ents.FindByClass("func_door")) do
			v:Remove()
	end
end