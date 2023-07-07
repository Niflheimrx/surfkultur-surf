--Lets make this map not crash on the server!
--Funny tag explains this itself.

__HOOK[ "InitPostEntity" ] = function()
	for k,v in pairs( ents.FindByClass("func_*") ) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("trigger_teleport")) do
		if v:GetName() == "lvl_all_jail" then
			v:Remove()
		end
	end
	for k,v in pairs( ents.FindByClass("trigger_*") ) do
		if v:GetClass() == "trigger_teleport" then return end
		v:Remove()
	end
	for k,v in pairs( ents.FindByClass("game_player_equip") ) do
		v:Remove()
	end
	for k,v in pairs( ents.FindByClass("point_template") ) do
		v:Remove()
	end
	for k,v in pairs( ents.FindByClass("logic_*") ) do
		v:Remove()
	end
	for k,v in pairs( ents.FindByClass("env_steam") ) do
		v:Remove()
	end
end