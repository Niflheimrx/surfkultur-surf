--This really doesn't make me happy. Removes the gay jails and essentially lowers some trigger zones.

__HOOK[ "InitPostEntity" ] = function()
	for k,v in pairs(ents.FindByClass("trigger_teleport")) do
		if v:GetName() == "endteleCT" then
			v:Remove()
		end
		if v:GetName() == "fintele" then
			v:Remove()
		end
		if v:GetName() == "endteleT" then
			v:Remove()
		end
		if v:GetPos() == Vector( 9620, -12337, 3632 ) then
			v:Remove()
		end
	end
	for k,v in pairs(ents.FindByClass("info_teleport_destination")) do
		if v:GetName() == "easyfin" then
			v:SetPos( Vector( 12544, -12032, 14040 ))
			v:SetAngles( Angle( 0, -90, 0 ) )
		end
	end
	for k,v in pairs(ents.FindByClass("func_breakable")) do
		v:Remove()
	end
end
