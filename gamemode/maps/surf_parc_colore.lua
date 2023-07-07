--trick surf support?!?!?!?! Fixes a common issue with player trigger stats not resetting after going to the start zone.

__HOOK[ "InitPostEntity" ] = function()
	for k,v in pairs( ents.FindByClass("trigger_teleport") ) do
		if v:GetName() == "tele_nexxt2" then
			v:SetPos( Vector( -768.67, 768.89, 112.03 ) )
		end
		if v:GetPos() == Vector( -12, -6656, -1784 ) then
			v:SetPos( Vector( -1920, -6656, -1728 ) )
		end
	end
end