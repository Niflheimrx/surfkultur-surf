-- What the fuck is this map name? --
-- 28/11/2022: Fixes trigger_teleport_relative (Again??? Holy fuck) --

__HOOK[ "InitPostEntity" ] = function()
	-- Remove useless shit --
	for _,ent in pairs( ents.FindByClass "trigger_teleport_relative" ) do
		ent:Remove()
	end

	-- Set the correct pointer for triggers --
	local spawnPointers = {
		["teleportfall1"] = Vector(-3456, 13664, 14002),
		["teleportfall2"] = Vector(-12112, 10080, 3644),
		["teleports2part2"] = Vector(-12112, 768, 6532),
		["teleportfall3"] = Vector(-4224, 15424, 7516),
		["teleports3part2"] = Vector(7677, 2358, -1139),
		["ending001"] = Vector(-11488, 10880, 12676),

		["teleportfallbonus001"] = Vector(-8544, 6528, -10236),
		["teleportfallbonus002"] = Vector(-2176, 4992, -924),
		["teleportfallbonus003"] = Vector(7688, 13728, 13956),
		["bonus001"] = Vector(-12096, 12120, -3180),
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