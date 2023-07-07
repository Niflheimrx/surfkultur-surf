--What do you like to play? Pokemon! Pokemon? Removes the dumb skips scattered around the map and also removes shortcuts. Bonus Door is now accessible as well.

__HOOK[ "InitPostEntity" ] = function()
	for k,v in pairs( ents.FindByClass("trigger_teleport") ) do
		if v:GetPos() == Vector( 488, 5904, -1768 ) then
			v:SetKeyValue( "target", "t5" )
		end
		if v:GetPos() == Vector( 6208, -2624, -1392 ) then
			v:SetKeyValue( "target", "t2" )
		end
		if v:GetPos() == Vector( 5891.2, -3072, -748 ) then
			v:SetKeyValue( "target", "t2" )
		end
		if v:GetPos() == Vector( 6208, -3072, -376 ) then
			v:SetKeyValue( "target", "t2" )
		end
		if v:GetPos() == Vector( -6016, 10604, -1872 ) then
			v:SetKeyValue( "target", "t4" )
		end
		if v:GetPos() == Vector( 5376, -10496, -888 ) then
			v:SetKeyValue( "target", "t16" )
		end
		if v:GetPos() == Vector( 64, -516, -672 ) then
			v:SetKeyValue( "target", "t8" )
		end
		if v:GetName() == "C1" then
			v:Remove()
		end
		if v:GetName() == "Z7" then
			v:Fire("Enable")
			v:SetName(v:GetName().."_rename")
		end
	end
	for k,v in pairs(ents.FindByClass("func_brush")) do
		if v:GetName() == "BRUSH1" then
			v:Fire("Toggle")
			v:SetName(v:GetName().."_rename")
		end
	end
	for k,v in pairs(ents.FindByClass("func_tracktrain")) do
		if v:GetName() == "E3" then
			v:SetPos( Vector( -11200, 1984, -480 ))
		end
		if v:GetName() == "E2" then
			v:SetPos( Vector( -11200, 3520, -480 ))
		end
		if v:GetName() == "E1" then
			v:SetPos( Vector( -11200, 5056, -480 ))
		end
	end
	for k,v in pairs(ents.FindByClass("trigger_gravity")) do
		if v:GetPos() == Vector( -8608, -13504, 384 ) then
			v:SetPos( Vector( 4640, 4928, 384 ))
		end
		if v:GetPos() == Vector( -2640, -13504, 384 ) then
			v:SetPos( Vector( -3920, -13504, 384 ))
		end
	end
	for k,v in pairs(ents.FindByClass("path_track")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("func_door_rotating")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("func_door")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("func_breakable")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("func_button")) do
		v:Remove()
	end
end