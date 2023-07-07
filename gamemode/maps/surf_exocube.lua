--whatever, disables _m and _h along with _mh

__HOOK[ "InitPostEntity" ] = function()
	for k,v in pairs(ents.FindByClass("func_brush")) do
		if v:GetName() == "lvl1_ha_me_e" then
			v:Fire("Disable")
			v:SetName(v:GetName().."_rename")
		end
		if v:GetName() == "lvl1_ha_e" then
			v:Fire("Disable")
			v:SetName(v:GetName().."_rename")
		end
		if v:GetName() == "lvl1_me_e" then
			v:Fire("Disable")
			v:SetName(v:GetName().."_rename")
		end
		if v:GetName() == "lvl5_ha_e" then
			v:Fire("Disable")
			v:SetName(v:GetName().."_rename")
		end
		if v:GetName() == "lvl5_me_e" then
			v:Fire("Disable")
			v:SetName(v:GetName().."_rename")
		end
		if v:GetName() == "lvl5_ha_me_e" then
			v:Fire("Disable")
			v:SetName(v:GetName().."_rename")
		end
	end
	for k,v in pairs(ents.FindByClass("func_breakable")) do
		if v:GetName() == "break_1lvl_ha_me" then
			v:Fire("Break")
			v:SetName(v:GetName().."_rename")
		end
	end
	for k,v in pairs(ents.FindByClass("trigger_teleport")) do
		if v:GetName() == "lvl5_ha_me_e" then
			v:Remove()
		end
		if v:GetName() == "lvl1_ha_me_e" then
			v:Remove()
		end
		if v:GetName() == "lvl1_ha_e" then
			v:Remove()
		end
		if v:GetName() == "lvl1_me_e" then
			v:Remove()
		end
	end
end