--Moves teleport destinations

__HOOK[ "InitPostEntity" ] = function()

	for k,v in pairs(ents.FindByClass("info_teleport_destination")) do
		if v:GetName() == "s2_dest" then
			v:SetPos( Vector( -3680.0, -6144.0, 2128.0 ))
		end
	end
	
	for k,v in pairs(ents.FindByClass("info_teleport_destination")) do
		if v:GetName() == "s3_dest" then
			v:SetPos( Vector( -3328.0, 4096.0, 3264.0 ))
		end
	end
	
end
