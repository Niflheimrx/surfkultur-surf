--haha yea. NO JAIL BITCH. Removes jail timer?

__HOOK[ "InitPostEntity" ] = function()
	for k,v in pairs(ents.FindByClass("func_rot_button")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("func_brush")) do
		if v:GetPos() == Vector( 8712, 1600, 408 ) then
			v:Remove()
		end
	end
	for k,v in pairs(ents.FindByClass("logic_timer")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("trigger_once")) do
		if v:GetPos() == Vector( 3993.39, -12122.6, 1616 ) then
			v:Remove()
		end
		if v:GetPos() == Vector( -134.4, -13378.9, 1114 ) then
			v:Remove()
		end
		if v:GetPos() == Vector( 3896, -6368, 3116 ) then
			v:Remove()
		end
	end
	for k,v in pairs(ents.FindByClass("trigger_teleport")) do
		if v:GetName() == "TTELEPORT" then
			v:Remove()
		end
	end
end