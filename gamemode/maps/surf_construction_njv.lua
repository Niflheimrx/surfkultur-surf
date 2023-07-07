--What are the working going to construct today? Bob the Builder? Removes the jail.

__HOOK[ "InitPostEntity" ] = function()
	for k,v in pairs(ents.FindByClass("func_button")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("logic_timer")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("trigger_teleport")) do
		if v:GetName() == "end_of_round_teleports" then
			v:Remove()
		end
		if v:GetPos() == Vector( 5632, 10240, -6996 ) then
			v:SetKeyValue( "target", "copymark1" )
		end
		if v:GetPos() == Vector( -2560, -8176, 1856 ) then
			v:Remove()
		end
	end
end