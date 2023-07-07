--What is going on? -on? -on? *MUSIC KICKS IN* Removes a simple trigger_push.

	local spawnTransport = {
		["Stage3 CT"] = Vector( 10296, -3898, 3215 ),
		["Stage2.2"] = Vector( -9042, 6158, 7047 ),
		["Spawn"] = Vector( 9876, -2302, 3500 ),
	}
	local spawnPointers = {
		["noobjail1"] = "Spawn",
		["noobjail2"] = "Spawn",
		["noobjail3"] = "Spawn",
		["noobjail4"] = "Spawn",
		["Stage2.1"] = "Stage2.2",
		["jail 1.1"] = "Stage2.2",
		["jail 1.2"] = "Stage2.2",
		["jail 1.3"] = "Stage2.2",
		["jail 1.4"] = "Stage2.2",
		["jail 2.1"] = "Stage3 CT",
		["jail 2.2"] = "Stage3 CT",
		["jail 2.3"] = "Stage3 CT",
		["jail 2.4"] = "Stage3 CT",
	}
	--remove triggers that lead to these areas
	local spawnRemovers = {
		["m4-ak"] = true,
		["secret top1"] = true,
		["secret top2"] = true,
		["secret top3"] = true,
		["secret top4"] = true,
		["jail top1"] = true,
		["jail top2"] = true,
		["jail top3"] = true,
		["jail top4"] = true,
		["Stage3 T"] = true,		
	}

__HOOK[ "InitPostEntity" ] = function()
	-- change teleport destinations
	for _,ent in pairs( ents.FindByClass "info_teleport_destination" ) do
		local name = ent:GetInternalVariable "m_iName"
		if !spawnTransport[name] then continue end

		ent:SetPos( spawnTransport[name] )
	end
	-- remove and adjust push triggers
	for k,v in pairs(ents.FindByClass("trigger_push")) do
		if v:GetPos() == Vector( 9876, -2691, 3495.5 ) then
			v:Remove()
		end
		if v:GetPos() == Vector( -8883.02, 6314.1, 6991.5 ) then
			v:SetPos( Vector( -8883.02, 6325.1, 7031.5 ) )
		end
	end

	for _,ent in pairs( ents.FindByClass "trigger_teleport" ) do
		local name = ent:GetInternalVariable "target"

		if spawnRemovers[name] or ent:GetPos() == Vector( 10620, -4115, 3159 ) then
			ent:Remove()

			continue
		end

		if spawnPointers[name] then
			local pointer = spawnPointers[name]

			ent:SetKeyValue( "target", pointer )
			Zones:GenerateSpawnZone( ent )
		end
	end
	--adjust trigger gravities to be better
	for _,ent in pairs( ents.FindByClass "trigger_gravity" ) do
		if ent:GetPos() == Vector ( 7419, -8428, 432.54) then
			ent:Remove()
		end
		if ent:GetPos() == Vector( 1982.5, -8549.5, -2399.5 ) then
			ent:SetPos( Vector( 1982.5, -8549.5, -2315 ) )
		end
	end
	-- remove additional garbage
	for k,v in pairs(ents.FindByClass("func_button")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("logic_case")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("trigger_hurt")) do
		v:Remove()
	end
end
	-- remove the filters
__HOOK[ "EntityKeyValue" ] = function( ent, key, value )
	if ent:GetClass() == "trigger_teleport" then
		if key == "filtername" then
			return ""
		end
	end
end