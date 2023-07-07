-- Bugs bunny? Bucks bunny? --
-- 23/10/2022: Fixes trigger_teleport_relative (gosh I need to actually find a way to do this automatically) --

__HOOK[ "InitPostEntity" ] = function()
	-- Remove useless shit --
	for _,ent in pairs( ents.FindByClass "trigger_teleport_relative" ) do
		ent:Remove()
	end

	-- Set the correct pointer for triggers --
	local spawnPointers = {
		["s2"] = Vector(-3008, 0, 13464),
		["s3"] = Vector(-192, 1152, 13464),
		["s4"] = Vector(5952, 2560, 13464)
	}

	for _,ent in ipairs(ents.FindByClass "info_teleport_destination") do
		local name = ent:GetInternalVariable "m_iName"
		if !spawnPointers[name] then continue end

		ent:SetPos(spawnPointers[name])
	end

	for _,ent in ipairs( ents.FindByClass "trigger_teleport" ) do
		local name = ent:GetInternalVariable "target"

		if spawnPointers[name] then
			Zones:GenerateSpawnZone(ent)
		end
	end
end
