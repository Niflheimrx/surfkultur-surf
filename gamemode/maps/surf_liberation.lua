__HOOK[ "InitPostEntity" ] = function()
	for k,v in pairs(ents.FindByClass("trigger_multiple")) do
		if v:GetPos() == Vector( 14608, -2758, -2651 ) then
			v:Remove()
		end
	end
	
	for k,v in pairs(ents.FindByClass("trigger_once")) do
		v:Remove()
	end
	
	for k,v in pairs(ents.FindByClass("logic_auto")) do
		v:Remove()
	end
	
	for k,v in pairs(ents.FindByClass("func_movelinear")) do
		v:Remove()
	end
	
	for k,v in pairs(ents.FindByClass("func_rot_button")) do
		v:Remove()
	end
end