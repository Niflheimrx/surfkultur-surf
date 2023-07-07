--and the jails waddled away

local remove = {
Vector( -1726, 3282.5, 1054.5 ),
Vector( 13427.5, 6266.5, 7140.5 ),
Vector( -1728, -3218, 4042.5 ),
Vector( -12140, -5124, 6472 ),
Vector( -14288, 10476, 4604 ),
Vector( 6796, -15041, -3424.5 ),
Vector( -5262, -13172, 14798.5 ),
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
	
	for k,v in pairs(ents.FindByClass("func_button")) do
		if(table.HasValue(remove,v:GetPos())) then
			v:Remove()
		end
	end
end