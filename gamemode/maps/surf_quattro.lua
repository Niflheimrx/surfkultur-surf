--We dont like spinny things

__HOOK[ "InitPostEntity" ] = function()
	for k,v in pairs(ents.FindByClass("func_door")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("func_rotating")) do
		v:SetKeyValue( "maxspeed", "0" )
	end
end

