--Not necessarily flying if you basically go through tight obsticles throughout the map. FIXES PANDA'S BROKEN TELEPORT TRIGGERS

__HOOK[ "InitPostEntity" ] = function()
	for k,v in pairs(ents.FindByClass("trigger_teleport")) do
		if v:GetPos() != Vector( 3624, -5030, 4704 ) and v:GetPos() != Vector( -4136, -5030, 4704 ) then
			v:SetKeyValue( "target", "spawn" )
		end
		if v:GetPos() == Vector( 3624, -5030, 4704 ) or v:GetPos() == Vector( -4136, -5030, 4704 ) then
			v:SetKeyValue( "target", "prosection" )
		end
		if v:GetPos() == Vector( -253, -1632, -7600 ) or v:GetPos() == Vector( -253, 288, -8767.5 ) or v:GetPos() == Vector( -253, 784, -9456 ) then
			v:SetKeyValue( "target", "prosection" )
		end
	end
end