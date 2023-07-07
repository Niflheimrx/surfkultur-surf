__HOOK[ "InitPostEntity" ] = function()
	for k,v in pairs( ents.FindByClass("trigger_teleport") ) do
		if v:GetPos() == Vector( 10892, 753, -2348.99 ) then
			v:SetKeyValue( "target", "desty_stage5" )
		end
	end
end
