--Morning is inspirational. Fixes gay triggers that teleport you in the wrong location after a restart.

__HOOK[ "InitPostEntity" ] = function()
	for k,v in pairs(ents.FindByClass("trigger_multiple")) do
		v:Remove()
	end
	for k,v in pairs( ents.FindByClass("trigger_teleport") ) do
		if v:GetName() == "teleport_stage1" then
			v:SetKeyValue( "target", "teleport_destinationStage1" )
		end
		if v:GetName() == "teleport_stage2" then
			v:SetKeyValue( "target", "teleport_destinationStage2" )
		end
		if v:GetName() == "teleport_stage3" then
			v:SetKeyValue( "target", "teleport_destinationStage3" )
		end
		if v:GetName() == "teleport_stage4" then
			v:SetKeyValue( "target", "teleport_destinationStage4" )
		end
		if v:GetName() == "teleport_stage5" then
			v:SetKeyValue( "target", "teleport_destinationStage5" )
		end
	end
end