--init lad. wag1gman. dlght. Removes jail.

__HOOK[ "InitPostEntity" ] = function()
	for k,v in pairs(ents.FindByClass("trigger_teleport")) do
		if v:GetName() == "jail1" or v:GetName() == "jail2" then
			v:Remove()
		end
	end
end