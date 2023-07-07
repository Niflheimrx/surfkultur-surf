--Could've called it surf_amplitude/surf_amplitude2/surf_amplitude3. Removes trigger_push and fixes teleport values.

__HOOK[ "InitPostEntity" ] = function()
	for k,v in pairs(ents.FindByClass("point_servercommand")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("logic_auto")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("logic_relay")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("trigger_push")) do
		if v:GetPos() == Vector( -10403, -4632, 9035 ) then
			v:Remove()
		end
		if v:GetPos() == Vector( -10703, -4764, 9050 ) then
			v:Remove()
		end
		if v:GetPos() == Vector( -10703, -4500, 9050 ) then
			v:Remove()
		end
		if v:GetPos() == Vector( -220, 12352, -127840 ) then
			v:Remove()
		end
	end
	for k,v in pairs(ents.FindByClass("trigger_teleport")) do
		if v:GetName() == "sendback2jail" then
			v:Remove()
		end
		if v:GetName() == "sendback2spawn" then
			v:Fire("Enable")
			v:SetName(v:GetName().."_rename")
			v:SetKeyValue( "target", "spawn_ct" )
		end
		if v:GetPos() == Vector( -1052, 12352, -12704 ) then
			v:SetKeyValue( "target", "spawn_ct" )
		end
	end
end