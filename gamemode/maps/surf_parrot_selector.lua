--where are the parrots? Removes _h and also fixes some brush problems. Oh, and the jail.

__HOOK[ "InitPostEntity" ] = function()
	for k,v in pairs(ents.FindByClass("func_brush")) do
		if v:GetName() == "pm_brush" then
			v:Fire("Disable")
			v:SetName(v:GetName().."_rename")
		end
	end
	for k,v in pairs(ents.FindByClass("trigger_teleport")) do
		if v:GetName() == "pm_teleport" then
			v:Fire("Disable")
			v:SetName(v:GetName().."_rename")
		end
		if v:GetName() == "rahct" then
			v:Remove()
		end
	end
	for k,v in pairs(ents.FindByClass("logic_auto")) do
		v:Remove()
	end
end