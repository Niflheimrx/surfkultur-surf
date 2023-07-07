__HOOK[ "InitPostEntity" ] = function()
	for k,v in pairs(ents.FindByClass("func_movelinear")) do
		v:SetName("StoppedNow")
	end
	
	for _,ent in pairs( ents.FindByClass( "ambient_generic" ) ) do
            ent:Remove()
	end
	
	for _,ent in pairs( ents.FindByClass( "logic_timer" ) ) do
            ent:Remove()
	end
end