__HOOK[ "InitPostEntity" ] = function()
	for k,v in pairs(ents.FindByClass("env_fade")) do
		v:Remove()
	end
end