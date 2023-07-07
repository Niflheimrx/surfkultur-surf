--Mapnames really do write themself
	
-- list jail teleport triggers
	local jailRemovers = {
		["stage 1 t teleport"] = true,
		["stage 1 ct teleport"] = true,
		["stage 2 t teleport"] = true,
		["stage 2 ct teleport"] = true,
		["stage 3 t teleport"] = true,
		["stage 3 ct teleport"] = true,
		["stage 4 t teleport"] = true,
		["stage 4 ct teleport"] = true,
	}
-- list removeable pushtriggers	
	local pushRemovers = {
		[1281] = true,
		[1283] = true,
		[1440] = true,
	}
--spawnpoints that we wanna move for speedrunning reasons
	local spawnTransport = {
		["back 4"] = Vector( 665, -2228, -3577 ),
	}

	local spawnPointers = {
		["back 4"] = "back 4",
	}

__HOOK[ "InitPostEntity" ] = function()
--change the location of the teleport destination
	for _,ent in pairs( ents.FindByClass "info_teleport_destination" ) do
		local name = ent:GetInternalVariable "m_iName"
		if !spawnTransport[name] then continue end

		ent:SetPos( spawnTransport[name] )
	end
--create spawnzone for teleport
	for _,ent in pairs( ents.FindByClass "trigger_teleport" ) do
		local name = ent:GetInternalVariable "target"

		if spawnPointers[name] then
			local pointer = spawnPointers[name]

			ent:SetKeyValue( "target", pointer )
			Zones:GenerateSpawnZone( ent )
		end
-- remove jail triggers
		if jailRemovers[ent:GetName()] then
			ent:Remove()
		end
	end
-- if listed in pushRemovers remove
	for _,ent in pairs( ents.FindByClass "trigger_push" ) do
		local hammerid = ent:MapCreationID()
		if pushRemovers[hammerid] then
			ent:Remove()
		end
	end

-- remove useless shit
	for k,v in pairs(ents.FindByClass("func_door")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("func_button")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("trigger_once")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("func_breakable")) do
		v:Remove()
	end
end