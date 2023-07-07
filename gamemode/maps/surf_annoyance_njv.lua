--Is it even annoying? Tiny fixes.

__HOOK[ "InitPostEntity" ] = function()
	for k,v in pairs(ents.FindByClass("env_hudhint")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("func_button")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("game_player_equip")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("logic_timer")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("path_track")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("trigger_multiple")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("trigger_push")) do
		if v:GetPos() == Vector( 0, -13407.5, 2704.5 ) then
			v:Remove()
		end
	end
	for k,v in pairs(ents.FindByClass("trigger_teleport")) do
		if v:GetName() == "jail tele" or v:GetPos() == Vector( 11712 -6528 -1360 ) then
			v:Remove()
		end
		if v:GetPos() == Vector( 11712, -6528, -1360 ) then
			v:SetKeyValue( "target", "spawn 3" )
		end
	end
end