--Razer, the leading manufacturer of premium laptops, accessories, and the owner of that spicy logo. Removes jails and fixes some trigger dependencies.

__HOOK[ "InitPostEntity" ] = function()
	for k,v in pairs(ents.FindByClass("logic_timer")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("trigger_multiple")) do
		if v:GetName() == "eajejhbbbbbbbdfdfktzsz" then
			v:Remove()
		end
		if v:GetName() == "forthewholemaptz" then
			v:Remove()
		end
	end
	for k,v in pairs(ents.FindByClass("trigger_teleport")) do
		if v:GetName() == "fromspzojai" then
			v:Remove()
		end
		if v:GetName() == "fromspzojai" then
			v:Remove()
		end
		if v:GetName() == "telezupara1" then
			v:Remove()
		end
		if v:GetName() == "telezuknct" then
			v:Remove()
		end
		if v:GetName() == "telezuknt" then
			v:Remove()
		end
		if v:GetName() == "telezump2" then
			v:Remove()
		end
		if v:GetName() == "telezump1" then
			v:Remove()
		end
		if v:GetName() == "telezum32" then
			v:Remove()
		end
		if v:GetName() == "telezum31" then
			v:Remove()
		end
		if v:GetName() == "wenndudurchbisch" then
			v:Remove()
		end
	end
end
