--and the jails waddled away

--2020 update stopped the ramps from waddling away
local remove = {
Vector( -3280.55, -3273, 832 ),
Vector( -3283.19, -3274.65, 832.06 ),
Vector( -9507.06, -2767.37, 1344.05 ),
Vector( -9504.49, -2766, 1344 ),
Vector( 296.65, 6864, -5552 ),
Vector( 264.65, 6800, -5584 ),
Vector( 252.42, 6863.05, -5632.62 ),
Vector( 1255.6, -2176.97, 3040.02 ),
Vector( 1256.65, -2176, 3040 ),
Vector( 7339.85, -11021.6, 1752.05 ),
Vector( 7344.05, -11020, 1752 ),
Vector( 5192.65, -7824, 6352 ),
Vector( 5191.69, -7826.94, 6352.03 ),
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
		if v:GetName() == "platform_lvl1" then
			v:Fire("Toggle")
			v:SetName(v:GetName().."_rename")
		end
	end
end

__HOOK[ "EntityKeyValue" ] = function( ent, key, value )
	if ent:GetClass() == "func_lod" and key == "DisappearDist" then
		print( key .. " | " .. value )
		return "10000000"
	end
end