-- haven't seen many moving func_doors yet, but they aint moving no more.

__HOOK[ "InitPostEntity" ] = function()
	for k,v in pairs(ents.FindByClass("func_door")) do
		v:SetKeyValue( "speed", "0" )
	end
end
