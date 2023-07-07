--man this map was a bitch to fix, marks teleporters and uses the correct ending for best speedrunning. Also removes timers and jails/games.

__HOOK[ "InitPostEntity" ] = function()
	for k,v in pairs( ents.FindByClass("trigger_teleport") ) do
		if v:GetPos() == Vector( 2643, 2716.97, -196 ) then
			v:SetKeyValue( "target", "2" )
		end
		if v:GetPos() == Vector( -2034, -2595.03, -36 ) then
			v:SetKeyValue( "target", "3" )
		end
		if v:GetPos() == Vector( 1094.6, 2454.09, -1756 ) then
			v:SetKeyValue( "target", "4" )
		end
		if v:GetPos() == Vector( -1173.97, -596.81, 844 ) then
			v:SetKeyValue( "target", "5" )
		end
		if v:GetPos() == Vector( -257, 2867.96, -1782 ) then
			v:SetKeyValue( "target", "6" )
		end
		if v:GetName() == "domoi_trigger" or v:GetName() == "domoi_trigger2" or v:GetName() == "domoi_trigger3" or v:GetName() == "domoi_trigger4" or v:GetName() == "domoi_trigger_5" or v:GetName() == "domoi_trigger6"then
			v:Remove()
		end
		if v:GetName() == "tele" or v:GetName() == "tele2" or v:GetName() == "tele3" or v:GetName() == "tele4" or v:GetName() == "tele5" or v:GetName() == "tele6" then
			v:Fire("Enable")
			v:SetName(v:GetName().."_rename")
		end
	end
	for k,v in pairs(ents.FindByClass("trigger_once")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("env_fade")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("func_door")) do
		v:Fire("Open")
		v:SetName(v:GetName().."_rename")
	end
	for k,v in pairs(ents.FindByClass("func_door_rotating")) do
		if v:GetName() == "surf_rotate" then
			v:Fire("Open")
			v:SetName(v:GetName().."_rename")
		end
	end
	for k,v in pairs(ents.FindByClass("trigger_push")) do
		v:SetAbsVelocity( Vector ( -125, 85, 128 ))
	end
end