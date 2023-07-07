--remove jails because jails are like not fun yo

__HOOK[ "InitPostEntity" ] = function()
	for k,v in pairs(ents.FindByClass("trigger_teleport")) do
		if v:GetName() == "endroundtele" then
			v:Remove()
		end
	end
	for k,v in pairs(ents.FindByClass("func_button")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("trigger_once")) do
		v:Remove()
	end
end
