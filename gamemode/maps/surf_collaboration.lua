--Map was a pain in the ass to fix, like portal_game, this fixes teleporters for proper speedrunning. Also removes the jail(?)

local t = {
Vector( -579, -658, -2611 ),
Vector( -579, 272, -2611 ),
Vector( -1320, -3683, -2207 ),
Vector( -1320, -4881, -2207 ),
Vector( -1436, 4302, -1310 ),
Vector( -1437, 5291, -1310 ),
Vector( 1708, 6279, -4915 ),
Vector( 1708, 5765, -4915 ),
Vector( 532, 2291, -6665 ),
Vector( 1905, 2311, -6665 ),
Vector( 2276, 3994, 3975 ),
Vector( 2276, 4842, 3975 ),
Vector( 1802, -5077, 3412 ),
Vector( 647, -5077, 3412 ),
Vector( 2087, -6300, 802 ),
Vector( 2888, -6300, 802 ),
}

__HOOK[ "InitPostEntity" ] = function()
	for k,v in pairs( ents.FindByClass("trigger_teleport") ) do
		if v:GetPos() == Vector( 2267, -194.5, -2426 ) then
			v:SetKeyValue( "target", "stage2_hurt" )
		elseif v:GetPos() == Vector( 2031, -4288, -1928.5 ) then
			v:SetKeyValue( "target", "stage3_hurt" )
		elseif v:GetPos() == Vector( 892, 4809, -721 ) then
			v:SetKeyValue( "target", "stage4_hurt" )
		elseif v:GetPos() == Vector( 2595, 4418.5, 3317.5 ) then
			v:SetKeyValue( "target", "stage5_hurt" )
		elseif v:GetPos() == Vector( 1219.5, -6093, -6409 ) then
			v:SetKeyValue( "target", "stage6_hurt" )
		elseif v:GetPos() == Vector( 1228, -4463, 2209 ) then
			v:SetKeyValue( "target", "stage7_hurt" )
		elseif v:GetPos() == Vector( 2494, -9239, -1445 ) then
			v:SetKeyValue( "target", "stage8_hurt" )
		elseif v:GetPos() == Vector( 3081, 6022.5, -5603.5 ) then
			v:SetKeyValue( "target", "1to4" )
		elseif v:GetName() == "e" then
			v:Remove()
		elseif (table.HasValue(t,v:GetPos())) then
			v:Remove()
		end
	end
	for k,v in pairs(ents.FindByClass("trigger_multiple")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("func_breakable")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("func_button")) do
		v:Remove()
	end
end