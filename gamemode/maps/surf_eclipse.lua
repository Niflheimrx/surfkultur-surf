--Easy map, too bad nobody bothered to fix this. Finally removes the jails.

__HOOK[ "InitPostEntity" ] = function()
	for k,v in pairs(ents.FindByClass("func_button")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("func_illusionary")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("logic_timer")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("game_player_equip")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("trigger_multiple")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("trigger_once")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("trigger_hurt")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("trigger_push")) do
		if v:GetPos() == Vector( -11882, 9873, 11953 ) then
			v:Remove()
		end
	end
	for k,v in pairs(ents.FindByClass("trigger_teleport")) do
		if v:GetName() == "stage1_tojail" then
			v:Remove()
		end
		if v:GetName() == "all_niggas_to_jail1" then
			v:Remove()
		end
		if v:GetName() == "all_niggas_to_jail2" then
			v:Remove()
		end
		if v:GetName() == "all_niggas_to_jail3" then
			v:Remove()
		end
		if v:GetPos() == Vector( 5209, -14748, -3716.5 ) or v:GetPos() == Vector( 4689, -14750, -3716.5 ) then
			v:SetKeyValue( "target", "top" )
		end
	end
end