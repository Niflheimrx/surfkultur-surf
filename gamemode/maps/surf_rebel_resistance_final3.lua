
__HOOK[ "InitPostEntity" ] = function()
	for k,v in pairs(ents.FindByClass("func_breakable")) do
		v:Remove()
	end
	
	for k,v in pairs(ents.FindByClass("trigger_push")) do
		v:Remove()
	end
end
