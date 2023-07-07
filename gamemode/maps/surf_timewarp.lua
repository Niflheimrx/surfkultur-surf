--It is time to stop! (rotating)

--fixes the end of s5 rotating
__HOOK[ "InitPostEntity" ] = function()
	for k,v in pairs(ents.FindByClass("func_rotating")) do
		v:SetKeyValue( "maxspeed", "0" )
	end
end
