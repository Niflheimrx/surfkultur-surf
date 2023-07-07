-- Pain and agony, just like me irl --
-- 30/09/2022: Removes env_soundscape entities because of lag --

__HOOK[ "InitPostEntity" ] = function()
	for _,ent in pairs(ents.FindByClass "env_soundscape*") do
		ent:Remove()
	end

	for _,ent in pairs(ents.FindByClass "trigger_soundscape") do
		ent:Remove()
	end
end
