--Dusklord. Makes the teleporter into the bonus less apparent to the map.

__HOOK[ "InitPostEntity" ] = function()
	for k,v in pairs(ents.FindByClass("trigger_teleport")) do
		if v:GetPos() == Vector( 8611, 8900, -11734 ) then
			v:SetKeyValue( "target", "Level1" )
		end
	end
end