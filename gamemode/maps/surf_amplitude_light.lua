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
	for k,v in pairs(ents.FindByClass("trigger_multiple")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("trigger_push")) do
		if v:GetPos() == Vector( 1376, -15520, -11440 ) then
			v:Remove()
		end
		if v:GetPos() == Vector( 13964, -9340, 12087 ) then
			v:Remove()
		end
		if v:GetPos() == Vector( 13964, -9604, 12087 ) then
			v:Remove()
		end
	end
	for k,v in pairs(ents.FindByClass("trigger_teleport")) do
		v:SetKeyValue( "target", "spawn_t" )
	end
end