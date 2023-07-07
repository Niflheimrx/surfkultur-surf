--like what the literal fuck does this map have moving balls and shit, removes path_track and jail triggers. Also removes that horrific map shake upon completion and other unnecessary stuff

__HOOK[ "InitPostEntity" ] = function()
	for k,v in pairs(ents.FindByClass("trigger_teleport")) do
		if v:GetName() == "failerteleport" then
			v:Remove()
		end
		if v:GetName() == "winnerteleport" then
			v:Remove()
		end
	end
	for k,v in pairs(ents.FindByClass("trigger_once")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("trigger_multiple")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("func_door_rotating")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("func_breakable")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("func_button")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("func_tracktrain")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("path_track")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("phys_motor")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("env_shake")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("ambient_generic")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("logic_timer")) do
		v:Remove()
	end
end