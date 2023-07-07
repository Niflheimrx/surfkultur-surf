--takes skill?!?!, enables _e

__HOOK[ "InitPostEntity" ] = function()
	for k,v in pairs(ents.FindByClass("func_brush")) do
		if v:GetName() == "hard_stuff" then
			v:Fire("Disable")
			v:SetName(v:GetName().."_rename")
		end
		if v:GetName() == "hard_stuff2" then
			v:Fire("Enable")
			v:SetName(v:GetName().."_rename")
		end
		if v:GetName() == "spiral1" then
			v:Fire("Disable")
			v:SetName(v:GetName().."_rename")
		end
		if v:GetName() == "ramp2_easy" then
			v:Fire("Enable")
			v:SetName(v:GetName().."_rename")
		end
		if v:GetName() == "ramp1_easy" then
			v:Fire("Disable")
			v:SetName(v:GetName().."_rename")
		end
		if v:GetName() == "med_sign" then
			v:Fire("Disable")
			v:SetName(v:GetName().."_rename")
		end
		if v:GetName() == "hard_sign" then
			v:Fire("Disable")
			v:SetName(v:GetName().."_rename")
		end
		if v:GetName() == "glass_easy1" then
			v:Fire("Disable")
			v:SetName(v:GetName().."_rename")
		end
		if v:GetName() == "easy_sign" then
			v:Fire("Enable")
			v:SetName(v:GetName().."_rename")
		end
	end
	for k,v in pairs(ents.FindByClass("trigger_teleport")) do
		if v:GetName() == "spiral1" then
			v:Remove()
		end
		if v:GetName() == "glass_easy1" then
			v:Remove()
		end
		if v:GetName() == "ramp1_easy" then
			v:Remove()
		end
		if v:GetName() == "hard_stuff" then
			v:Remove()
		end
	end
end