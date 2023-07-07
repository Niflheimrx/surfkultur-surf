--pretty basic map that deserves to be elected as president, disables _e and feels like hard mode. Also removes level triggers

__HOOK[ "InitPostEntity" ] = function()
	for k,v in pairs(ents.FindByClass("env_global")) do
		if v:GetName() == "hardmode_state" then
			v:Fire("TurnOn")
			v:SetName(v:GetName().."_rename")
		end
	end
	for k,v in pairs(ents.FindByClass("light")) do
		if v:GetName() == "modelight_easy" then
			v:Fire("TurnOff")
			v:SetName(v:GetName().."_rename")
		end
		if v:GetName() == "modelight_hard" then
			v:Fire("TurnOn")
			v:SetName(v:GetName().."_rename")
		end
	end
	for k,v in pairs(ents.FindByClass("func_wall_toggle")) do
		if v:GetName() == "hardmode_walltoggle_off2on" then
			v:Fire("Toggle")
			v:SetName(v:GetName().."_rename")
		end
	end
end