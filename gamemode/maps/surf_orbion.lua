
__HOOK[ "InitPostEntity" ] = function()
	for k,v in pairs(ents.FindByClass("func_door")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("trigger_gravity")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("func_rotating")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("func_button")) do
		v:Remove()
	end
end
