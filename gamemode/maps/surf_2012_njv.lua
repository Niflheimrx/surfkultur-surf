--hey an old pg map with a cancer bonus! fixes small things such as the consistent shaking of the map
-- 11/11/2020: remove annoying light at the end of the map, fixes for Stage 5 so the spawnpoint is closer to the ramp

__HOOK[ "InitPostEntity" ] = function()
	for k,v in pairs(ents.FindByClass("env_shake")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("ambient_generic")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("func_breakable")) do
		v:Remove()
	end

	for _,ent in pairs( ents.FindByClass "env_lightglow" ) do
		ent:Remove()
	end

	local stage5Spawn = "jail5"
	for _,ent in pairs( ents.FindByClass "info_teleport_destination" ) do
		local telePos = ent:GetSaveTable().m_iName
		if telePos and (telePos == stage5Spawn) then
			ent:SetPos( Vector( 8105, 8435, 9388 ) )
		end
	end

	for k,v in pairs(ents.FindByClass("trigger_teleport")) do
		if v:GetName() == "knife_equiper" then
			v:Remove()
		end
		if v:GetName() == "bonus_teleport" then
			v:Fire("Enable")
			v:SetName(v:GetName().."_rename")
		end
		if v:GetPos() == Vector( 2816, -5536, -1032 ) then
			v:SetKeyValue( "target", "2012bonus" )
		end

		local targetPos = v:GetSaveTable().target
		if (targetPos == stage5Spawn) then
			Zones:GenerateSpawnZone( v )
		end
	end
end
