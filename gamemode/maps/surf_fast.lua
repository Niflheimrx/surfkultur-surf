--gotta go faste. sanic. Fixes first stage teleport triggers and also enables all rings to be boosted unlimited times. Also fixes bonus because bonus is a bitch.

__HOOK[ "InitPostEntity" ] = function()
	for k,v in pairs(ents.FindByClass("trigger_teleport")) do
		if v:GetPos() == Vector( -7488, 2560, -14272 ) then
			v:SetKeyValue( "target", "spawn" )
		end
		if v:GetPos() == Vector( 3200, 7680, -13311 ) then
			v:SetKeyValue( "target", "spawn" )
		end
		if v:GetPos() == Vector( 8192, 3200, -14208 ) then
			v:SetKeyValue( "target", "spawn" )
		end
		if v:GetPos() == Vector( 1408, -11776, -15040 ) then
			v:SetKeyValue( "target", "spawn" )
		end
		if v:GetPos() == Vector( 8072, -3910, 680 ) then
			v:SetKeyValue( "target", "bonusend" )
		end
	end
	for k,v in pairs(ents.FindByClass("func_brush")) do
		if v:GetName() == "sonic_bridge1" then
			v:Fire("Toggle")
			v:SetName(v:GetName().."_rename")
			v:SetKeyValue( "target", "TstartPART2" )
		end
		if v:GetName() == "sonic_bridge2" then
			v:Fire("Toggle")
			v:SetName(v:GetName().."_rename")
			v:SetKeyValue( "target", "TstartPART2" )
		end
	end
end

__HOOK[ "EntityKeyValue" ] = function( ent, key, value )
	if ent:GetClass() == "trigger_push" then
		if ent:GetPos() == Vector( 4608, 2560, -13568 ) then
			if key == "filtername" then
				return ""
			end
		end
	end
end