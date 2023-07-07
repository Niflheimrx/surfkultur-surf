__HOOK[ "InitPostEntity" ] = function()
	for _,ent in pairs( ents.FindByClass( "logic_timer" ) ) do
		ent:Remove()
	end
end
