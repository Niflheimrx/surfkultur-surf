--this maps wants to make me drink some nice and warm liquid lithium

--list of teleport triggers that need to be adjusted for speedrunning reasons
local spawnMovers = {
	["2048.00 256.00 72.00"] = Vector( 2048.00, 256.00, 85.00 )
}
-- Fix camera angle on s4 transition 
local destinationRotators = {
	["level5"] = true
}

__HOOK[ "InitPostEntity" ] = function()
	--remove junk
	for _,ent in pairs( ents.FindByClass "trigger_hurt" ) do
		ent:Remove()
	end
	for _,ent in pairs( ents.FindByClass "trigger_once" ) do
		ent:Remove()
	end
	for _,ent in pairs( ents.FindByClass "trigger_multiple" ) do
		ent:Remove()
	end
	for _,ent in pairs( ents.FindByClass "player_speedmod" ) do
		ent:Remove()
	end
	for _,ent in pairs( ents.FindByClass "env_hudhint" ) do
		ent:Remove()
	end
	for _,ent in pairs( ents.FindByClass "game_player_equip" ) do
		ent:Remove()
	end
	for _,ent in pairs( ents.FindByClass "point_hurtz" ) do
		ent:Remove()
	end
	for _,ent in pairs( ents.FindByClass "func_movelinear" ) do
		ent:Remove()
	end
	for _,ent in pairs( ents.FindByClass "func_rot_button" ) do
		ent:Remove()
	end
	for _,ent in pairs( ents.FindByClass "func_door" ) do
		ent:Remove()
	end
	for _,ent in pairs( ents.FindByClass "func_rotating" ) do
		ent:Remove()
	end
	for _,ent in pairs( ents.FindByClass "func_gravity" ) do
		ent:Remove()
	end

	--change angle on s5 teleport
	for _,ent in pairs( ents.FindByClass "info_teleport_destination" ) do
		local name = ent:GetInternalVariable "m_iName"
		if !destinationRotators[name] then continue end

		local currentAngle = ent:GetAngles()
		local newAngle = currentAngle + Angle( 90, 0, 0 )

		ent:SetAngles( newAngle )
	end


	-- remove jail teleportsz
	for _,ent in pairs( ents.FindByClass "trigger_teleport" ) do
		if ent:GetName() == "end_of_round_teleport" then
			ent:Remove()
		end

	-- Move these boosters a little higher --
		local currentPos = util.TypeToString( ent:GetPos() )
		local name = ent:GetInternalVariable "target"

		if spawnMovers[currentPos] then
			ent:SetPos( spawnMovers[currentPos] )
		end
	end
end