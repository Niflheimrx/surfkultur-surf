
__HOOK[ "InitPostEntity" ] = function()
	for k,v in pairs(ents.FindByClass("func_tanktrain")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("func_door")) do
		v:Remove()
	end
end

