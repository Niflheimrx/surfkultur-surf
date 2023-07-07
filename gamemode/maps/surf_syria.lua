__HOOK[ "InitPostEntity" ] = function()
	for k,v in pairs(ents.FindByClass("func_button")) do
		 v:Remove()
	end
	for k,v in pairs(ents.FindByClass("trigger_teleport")) do
		if v:GetName() == "Scoutzdisabler" then
			v:Remove()
		end
	end
	for k,v in pairs(ents.FindByClass("logic_timer")) do
		 v:Remove()
	end
end
