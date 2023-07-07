--func_rotatings are considered unclassy these days, so i though i'd help you out! thank me later

__HOOK[ "InitPostEntity" ] = function()
	for k,v in pairs(ents.FindByClass("func_rotating")) do
		 v:Remove()
	end
end
