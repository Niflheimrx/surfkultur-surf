--do you seriously control the air? Removes the models in the secret room that caused users to crash when touched. Also removes trigger_multiple to use gamemode gravity control plugin.
-- 11/25/2020: room doesn't crash anymore, remove the unnecessary fix.

__HOOK[ "InitPostEntity" ] = function()
	for k,v in pairs(ents.FindByClass("trigger_multiple")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("trigger_teleport")) do
		if v:GetPos() == Vector( 11904, 2784, -10072 ) then
			v:Remove()
		end
		if v:GetPos() == Vector( 11824, 2720, -10072 ) then
			v:Remove()
		end
		if v:GetPos() == Vector( 12000, 2720, -10072 ) then
			v:Remove()
		end
	end
end
