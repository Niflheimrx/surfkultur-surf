-- 31/01/2022: Removes func_physbox_multiplayer entity so rocks don't spawn in on s2, it sucks but oh well --

__HOOK["InitPostEntity"] = function()
	for _,ent in pairs(ents.FindByClass "func_physbox_multiplayer") do
		ent:Remove()
	end
end
