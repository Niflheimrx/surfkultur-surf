--Why does this have fucking jails

--2020 update: why does this still have fucking jails

local remove = {
Vector( 1600, 3904, -704 ),
Vector( 4096, -288, -1104 ),
Vector( 7168, 5632, -2176 ),
Vector( -4096, 704, 1536 ),
Vector( -1024, -6592, -4736 ),
Vector( 6656 -9216 -6848 ),
Vector( 10240, -3200, -3696 ),
Vector( -3232, 8288, -1716 ),
}

__HOOK[ "InitPostEntity" ] = function()
	for k,v in pairs(ents.FindByClass("trigger_multiple")) do
			v:Remove()
	end
	for k,v in pairs(ents.FindByClass("logic_auto")) do
			v:Remove()
	end
	for k,v in pairs(ents.FindByClass("trigger_once")) do
			v:Remove()
	end
	for k,v in pairs(ents.FindByClass("func_button")) do
			v:Remove()
	end
	for k,v in pairs(ents.FindByClass("trigger_hurt")) do
			v:Remove()
	end
	for k,v in pairs(ents.FindByClass("trigger_teleport")) do
		if v:GetName() == "No_win_tele" or v:GetName() == "win_tele" then
			v:Remove()
		end
	end
end
