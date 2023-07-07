--get it, map was made in 1 day xddddd. Re-does the teleport for entering bonus.
-- 11/11/2020: Fixed up Stage 11 spawnpoint, rotated spawnpoint and made default camera angle 45 degrees down

__HOOK[ "InitPostEntity" ] = function()
	for k,v in pairs(ents.FindByClass("env_shake")) do
		v:Remove()
	end

	for k,v in pairs(ents.FindByClass("trigger_teleport")) do
		if v:GetPos() == Vector( 8716, -5888, -11516 ) then
			v:SetKeyValue( "target", "tomb" )
		end
	end

	local lastStageDest = "lody_tele"
	for _,ent in pairs( ents.FindByClass "info_teleport_destination" ) do
		local telePos = ent:GetSaveTable().m_iName
		if telePos and (telePos == lastStageDest) then
			local currentAngle = ent:GetAngles()
			local newAngle = currentAngle + Angle( 45, -135, 0 )

			ent:SetAngles( newAngle )
		end
	end
end
