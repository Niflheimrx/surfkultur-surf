--Legend, wait for it, DARY fix
__HOOK[ "InitPostEntity" ] = function()
	for k,v in pairs(ents.FindByClass("func_tracktrain")) do
		if v:GetName() == "NoobCatcherJail3" then
			v:Remove()
		end
	end
	for k,v in pairs(ents.FindByClass("trigger_teleport")) do
		if v:GetName() == "AllToJailNOOOOOW" then
			v:Remove()
		end
	end
	for k,v in pairs(ents.FindByClass("func_rotating")) do
		v:SetKeyValue( "maxspeed", "0" )
	end
	for _,ent in pairs( ents.FindByClass( "logic_auto" ) ) do
		ent:Remove()
	end
end