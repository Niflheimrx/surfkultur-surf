--Dont publish maps that are still in_progress you dummy!

__HOOK[ "InitPostEntity" ] = function()
	for k,v in pairs(ents.FindByClass("trigger_hurt")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("logic_auto")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("trigger_teleport")) do
		if v:GetName() == "tojail" then
			v:Remove()
		end
	end
end 

