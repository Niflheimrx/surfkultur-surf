--Arblarg seriously made this? Removes that stupid ear rape music.

__HOOK[ "InitPostEntity" ] = function()
	for k,v in pairs(ents.FindByClass("env_soundscape")) do
		if v:GetName() == "ss_corn" then
			v:Remove()
		end
	end
	for k,v in pairs(ents.FindByClass("func_door_rotating")) do
			v:Remove()
	end
end