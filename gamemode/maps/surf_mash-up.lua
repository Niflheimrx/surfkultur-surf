--removes door 

__HOOK[ "InitPostEntity" ] = function()
	for k,v in pairs(ents.FindByClass("func_movelinear")) do
		v:Remove()
	end
end