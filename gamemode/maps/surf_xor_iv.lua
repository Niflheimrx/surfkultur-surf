--and the jail said "haha, try fixing me now!"

local remove = {
Vector( 5152, -3104, 3744 ),
Vector( 9984, -5536, 2816 ),
Vector( 9696, -8000, 2560 ),
Vector( 4544, -3136, -1312 ),
Vector( 11584, -3104, -7232 ),
Vector( 8128, -3104, -13664 ),
Vector( 9216, -3136, -13664 ),
Vector( 6144, -3104, -14848 ),
Vector( -6144, -10304, -128 ),
Vector( -11936, -8384, -128 ),
Vector( -9024, -8352, -3296 ),
Vector( -5376, -7232, -6048 ),
Vector( -1376, -4864, -256 ),
Vector( -12032, -8352, -1408 ),
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