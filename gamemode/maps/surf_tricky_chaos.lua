
__HOOK[ "InitPostEntity" ] = function()
	for k,v in pairs(ents.FindByClass("func_door_rotating")) do
			v:SetKeyValue( "speed", "0" )
	end
end
