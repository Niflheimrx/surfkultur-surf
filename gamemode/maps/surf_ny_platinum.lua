--Pretty complicated map finally fixed, thanks to nifl for teaching me stuff

local remove = {
Vector( 1028, -6656, 3668 ),
Vector( 2944, -6656, 3328 ),
Vector( 2688, -6656, 3328 ),
Vector( 2432, -6656, 3328 ),
Vector( 2176, -6656, 3328 ),
Vector( 1920, -6656, 3328 ),
Vector( 1664, -6656, 3328 ),
Vector( 1028, -6656, 4144 ),
}

local JailTps = {
Vector( 2944, -7360, 3648 ),
Vector( 2688, -7360, 3648 ),
Vector( 2432, -7360, 3648 ),
Vector( 2176, -7360, 3648 ),
Vector( 1920, -7360, 3648 ),
Vector( 1664, -7360, 3648 ),
Vector( 1664, -6656, 3328 ),
}

local Timers = {
Vector( 2010.82, -6505, 3700.43 ),
Vector( 1033, -6643.67, 3885.62 ),
Vector( 2163.57, -6153, 3710.55 ),
Vector( 2198.57, -6153, 3710.55 ),
Vector( 2233.57, -6153, 3710.55 ),
Vector( 2268.57, -6153, 3710.55 ),
Vector( 2303.57, -6153, 3710.55 ),
Vector( 2338.57, -6153, 3710.55 ),
}

__HOOK[ "InitPostEntity" ] = function()
	for k,v in pairs(ents.FindByClass("func_movelinear")) do
		v:Remove()
	end
	
	for k,v in pairs(ents.FindByClass("trigger_teleport")) do
		if v:GetName() == "skyworld" then
			v:Fire("Toggle")
			v:SetName(v:GetName().."_rename")
		end
	end
	for k,v in pairs(ents.FindByClass("trigger_multiple")) do
		if(table.HasValue(JailTps,v:GetPos())) then
			v:Remove()
		end
	end
	
	for k,v in pairs(ents.FindByClass("logic_timer")) do
		if(table.HasValue(Timers,v:GetPos())) then
			v:Remove()
		end
	end
	
	for k,v in pairs(ents.FindByClass("logic_auto")) do
		if(table.HasValue(Timers,v:GetPos())) then
			v:Remove()
		end
	end
end