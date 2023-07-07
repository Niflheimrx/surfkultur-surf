local remove = {
Vector( 5092, 3149, -6141.5 ),
}
local remove2 = {
Vector( 4840, 4123, -5686.06 ),
Vector( 4840, 4561, -6064.06 ),
Vector( 4840, 3685, -6064.06 ),
}

__HOOK[ "InitPostEntity" ] = function()
	for k,v in pairs(ents.FindByClass("trigger_teleport")) do
		if(table.HasValue(remove,v:GetPos())) then
			v:Remove()
		end
	end
	for k,v in pairs(ents.FindByClass("trigger_multiple")) do
		if(table.HasValue(remove2,v:GetPos())) then
			v:Remove()
		end
	end
	
	for _,ent in pairs( ents.FindByClass( "logic_auto" ) ) do
			ent:Remove()
		end
	for _,ent in pairs( ents.FindByClass( "logic_timer" ) ) do
			ent:Remove()
		end
end