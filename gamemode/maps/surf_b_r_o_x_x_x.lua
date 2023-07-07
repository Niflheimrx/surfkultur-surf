__HOOK[ "InitPostEntity" ] = function()
	for k,v in pairs(ents.FindByClass("logic_auto")) do
			v:Remove()
	end
	for k,v in pairs(ents.FindByClass("logic_timer")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("func_rotating")) do
		if v:GetName() == "rota_holes1" then
			v:Remove()
		end
	end
	for k,v in pairs(ents.FindByClass("ambient_generic")) do
		v:Remove()
	end
end
