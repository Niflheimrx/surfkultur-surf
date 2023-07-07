--Home of the royal people. Cool stuff on this map as well. Removes jail and fixes triggers.

__HOOK[ "InitPostEntity" ] = function()
	for k,v in pairs(ents.FindByClass("func_button")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("logic_timer")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("weapon_awp")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("weapon_mp5navy")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("weapon_glock")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("weapon_fiveseven")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("weapon_scout")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("weapon_p90")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("weapon_knife")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("trigger_multiple")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("trigger_once")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("trigger_hurt")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("trigger_teleport")) do
		if v:GetName() == "jailtele" then
			v:Remove()
		elseif v:GetName() == "largeteleport" then
			v:SetKeyValue( "target", "scaztspawn" )
		elseif v:GetPos() == Vector( -1542, 13048, -8498 ) then
			v:SetKeyValue( "target", "scaztspawn" )
		else
			v:Remove()
		end
	end
end

__HOOK[ "EntityKeyValue" ] = function( ent, key, value )
	if ent:GetClass() == "trigger_teleport" then
		if ent:GetPos() == Vector( -1542, 13048, -8498 ) then
			if key == "filtername" then
				return ""
			end
		end
	end
end