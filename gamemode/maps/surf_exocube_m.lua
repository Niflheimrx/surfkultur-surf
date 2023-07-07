--whatever, disables _e and _h along with _eh

__HOOK[ "InitPostEntity" ] = function()
	for k,v in pairs(ents.FindByClass("func_brush")) do
		if v:GetName() == "lvl1_ea_e" then
			v:Fire("Toggle")
			v:SetName(v:GetName().."_rename")
		end
		if v:GetName() == "lvl1_ha_e" then
			v:Fire("Toggle")
			v:SetName(v:GetName().."_rename")
		end
		if v:GetName() == "lvl5_ea_e" then
			v:Fire("Toggle")
			v:SetName(v:GetName().."_rename")
		end
		if v:GetName() == "lvl5_ha_e" then
			v:Fire("Toggle")
			v:SetName(v:GetName().."_rename")
		end
	end
	for k,v in pairs(ents.FindByClass("func_breakable")) do
		if v:GetName() == "break_5lvl_easy" then
			v:Fire("Break")
			v:SetName(v:GetName().."_rename")
		end
	end
	for k,v in pairs(ents.FindByClass("trigger_teleport")) do
		if v:GetName() == "lvl1_ha_e" then
			v:Remove()
		end
	end
end