-- haha im depressed --
-- Removes telehops and optimizes teleport destinations --

__HOOK[ "InitPostEntity" ] = function()
	-- Set the correct pointer for triggers --
	local spawnPointers = {
		["1"] = "1",
		["1.1"] = "1",
		["2"] = "2",
		["2.2"] = "2",
		["3"] = "3",
		["3.3"] = "3",
		["4"] = "4",
		["4.4"] = "4",
		["5"] = "5",
		["5.5"] = "5",
		["6"] = "6",
		["6.6"] = "6",
		["7"] = "7",
		["7.7"] = "7",
		["8"] = "8.8",
		["8.8"] = "8.8",
		["9"] = "9",
		["9.9"] = "9",
		["10"] = "10",
		["10.10"] = "10",
		["11"] = "11",
		["11.11"] = "11",
		["12"] = "12",
		["12.12"] = "12",
	}

	for _,ent in pairs( ents.FindByClass "trigger_teleport" ) do
		local name = ent:GetInternalVariable "target"
		local pointer = spawnPointers[name]

		-- Set the correct target for jail spawns --
		if pointer then
			ent:SetKeyValue( "target", pointer )
			if (name == "8") then continue end

			Zones:GenerateSpawnZone( ent, true )
		end
	end
end
