--Sonic, hurry and get the Chaos Emeralds! Fixes triggers.

__HOOK[ "InitPostEntity" ] = function()
	for k,v in pairs(ents.FindByClass("func_door_rotating")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("game_player_equip")) do
		v:Remove()
	end

end