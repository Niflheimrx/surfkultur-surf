--hey an old pg map with a cancer bonus! fixes small things such as the consistent shaking of the map

__HOOK[ "InitPostEntity" ] = function()
	for k,v in pairs(ents.FindByClass("env_shake")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("logic_timer")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("func_button")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("logic_relay")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("trigger_teleport")) do
		if v:GetName() == "timerteleport" then
			v:Remove()
		end
	end
end