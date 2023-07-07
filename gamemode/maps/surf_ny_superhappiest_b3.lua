--This really doesn't make me happy. Removes the gay jails and essentially lowers some trigger zones.

__HOOK[ "InitPostEntity" ] = function()
	for k,v in pairs(ents.FindByClass("trigger_teleport")) do
		if v:GetPos() == Vector( -96, 2755, -1970 ) then
			v:SetKeyValue( "target", "Start" )
		end
		if v:GetPos() == Vector( 4253, 4182, 1562 ) then
			v:SetKeyValue( "target", "Start" )
		end
		if v:GetPos() == Vector( 1536, -960, -6212 ) then
			v:SetKeyValue( "target", "Sand_dest" )
		end
		if v:GetPos() == Vector( 1536, 264, -6284 ) then
			v:SetKeyValue( "target", "Sand_dest" )
		end
		if v:GetPos() == Vector( 1536, 1908, -6300 ) then
			v:SetKeyValue( "target", "Sand_dest" )
		end
		if v:GetPos() == Vector( 1536, 4632, -7004 ) then
			v:SetKeyValue( "target", "Sand_dest" )
		end
		if v:GetPos() == Vector( 1534, 6130, -6712 ) then
			v:SetPos( Vector( 1536, 6088, -6712 ) )
			v:SetKeyValue( "target", "Sand_dest" )
		end
		if v:GetPos() == Vector( 1536, -3580, -2796 ) then
			v:SetKeyValue( "target", "Sand_dest" )
		end
		if v:GetPos() == Vector( 2624, 6336, -5282 ) then
			v:SetKeyValue( "target", "air" )
		end
		if v:GetPos() == Vector( 2624, 8080, -4744 ) then
			v:SetKeyValue( "target", "jungle" )
		end
		if v:GetPos() == Vector( 4400, -1888, 3065.5 ) then
			v:SetKeyValue( "target", "jungle" )
		end
		if v:GetPos() == Vector( 4400, 3566, 1342 ) then
			v:SetKeyValue( "target", "jungle" )
		end
		if v:GetPos() == Vector( 2624, 8080, -4744 ) then
			v:SetKeyValue( "target", "jungle" )
		end
	end
	for k,v in pairs(ents.FindByClass("game_zone_player")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("trigger_push")) do
		if not v:GetPos() == Vector( 2624, 5888, -4456 ) and not v:GetPos() == Vector( 4400, 2600, 1532 ) then
			v:Remove()
		end
	end
	for k,v in pairs(ents.FindByClass("func_movelinear")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("func_rotating")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("func_button")) do
		if v:GetName() != "door_3" then
			v:Remove()
		end
	end
end
