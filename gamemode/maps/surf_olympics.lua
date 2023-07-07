--simple fix for simple jail

__HOOK[ "InitPostEntity" ] = function()
	for k,v in pairs(ents.FindByClass("trigger_multiple")) do
			v:Remove()
	end
end