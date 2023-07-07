--its not even infected, fully removes _e and displays it normally as if it were the hard version. Also removes level triggers

__HOOK[ "InitPostEntity" ] = function()
	for k,v in pairs(ents.FindByClass("func_brush")) do
		if v:GetName() == "e" then
			v:Fire("Disable")
			v:SetName(v:GetName().."_rename")
		end
		if v:GetName() == "left" then
			v:Fire("Open")
			v:SetName(v:GetName().."_rename")
		end
		if v:GetName() == "right" then
			v:Fire("Open")
			v:SetName(v:GetName().."_rename")
		end
		if v:GetName() == "movwe" then
			v:Fire("Close")
			v:SetName(v:GetName().."_rename")
		end
		if v:GetName() == "easy" then
			v:Fire("Break")
			v:SetName(v:GetName().."_rename")
		end
		if v:GetName() == "dd" then
			v:Fire("Disable")
			v:SetName(v:GetName().."_rename")
		end
		if v:GetName() == "spawnlred" then
			v:Fire("LightOn")
			v:SetName(v:GetName().."_rename")
		end
	end
	for k,v in pairs(ents.FindByClass("func_breakable")) do
		if v:GetName() == "HARDMODE" then
			v:Fire("Enable")
			v:SetName(v:GetName().."_rename")
		end
	end
	for k,v in pairs(ents.FindByClass("trigger_teleport")) do
		if v:GetName() == "e" then
			v:Remove()
		end
		if v:GetName() == "h" then
			v:Remove()
		end
	end
	for k,v in pairs(ents.FindByClass("light")) do
		if v:GetName() == "green" then
			v:Fire("TurnOff")
			v:SetName(v:GetName().."_rename")
		end
		if v:GetName() == "red" then
			v:Fire("TurnOn")
			v:SetName(v:GetName().."_rename")
		end
	end
	for k,v in pairs(ents.FindByClass("env_laser")) do
		if v:GetName() == "laser1" then
			v:Remove()
		end
		if v:GetName() == "laser2" then
			v:Remove()
		end
		if v:GetName() == "laser3" then
			v:Remove()
		end
		if v:GetName() == "laser6" then
			v:Remove()
		end
		if v:GetName() == "laser4" then
			v:Remove()
		end
		if v:GetName() == "laser5" then
			v:Remove()
		end
		if v:GetName() == "red" then
			v:Fire("TurnOn")
			v:SetName(v:GetName().."_rename")
		end
	end
end