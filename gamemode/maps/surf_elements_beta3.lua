--"Water. Earth. Fire. Mapfixes. Long ago, the four nations lived together in harmony. Then, everything changed when the Mapfixes attacked.

--list of teleport triggers that need to be enabled
local spawnFire = {
		["shadow_teleport_1"] = true,
		["shadow_teleport_2"] = true,
		["shadow_teleport_3"] = true,
		["shadow_teleport_4"] = true,
		["shadow_teleport_5"] = true,
		["shadow_teleport_6"] = true,
		["shadow_teleport_7"] = true,
		["shadow_teleport_8"] = true,
		["shadow_teleport_9"] = true,
		["bonus_shadow_bounce1a"] = true,
		["bonus_shadow_bounce1b"] = true,
		["bonus_shadow_bounce1c"] = true,
		["bonus_shadow_bounce2a"] = true,
		["bonus_shadow_bounce2b"] = true,
		["bonus_shadow_bounce2c"] = true,
		["bonus_shadow_bounce3a"] = true,
		["bonus_shadow_bounce3b"] = true,
		["bonus_shadow_bounce3c"] = true,
	}
-- list of movelinears than need removing
	local removeLinear = {
		["mech_doors1a"] = true,
		["mech_doors1b"] = true,
		["mech_doors2"] = true,
		["mech_doors3a"] = true,
		["mech_doors3b"] = true,
		["mech_doors4a"] = true,
		["mech_doors4b"] = true,
		["mech_doors_5a"] = true,
		["mech_doors_5b"] = true,
		["mech_doors_5c"] = true,
		["mech_doors_5d"] = true,
		["mech_mover_1a"] = true,
		["mech_mover_1b"] = true,
		["mech_mover_1c"] = true,
		["mech_mover_1d"] = true,
		["mech_mover_1e"] = true,
		["mech_mover_1f"] = true,
		["mech_mover_1g"] = true,
	}
--list of linears that need to be stopeed
	local stopLinear = {
		["bonus_mech_mover1"] = true,
		["bonus_mech_mover2"] = true,
		["bonus_mech_mover3"] = true,
		["bonus_mech_mover4"] = true,
	}

__HOOK[ "InitPostEntity" ] = function()
-- remove func_movelinears
	for k,v in pairs(ents.FindByClass("func_movelinear")) do
		if removeLinear[v:GetName()] then
			v:Remove()
		end
	end
-- stop func_movelinear neccesary for bonus
	for k,v in pairs(ents.FindByClass("func_movelinear")) do
		if stopLinear[v:GetName()] then
			v:SetKeyValue( "maxspeed", "0" )
		end
	end
-- enable and rename teleports
	for k,v in pairs(ents.FindByClass("trigger_teleport")) do
		if spawnFire[v:GetName()] then
			v:Fire("Toggle")
			v:SetName(v:GetName().."_rename")
		end
	end
-- remove useless shit
	for k,v in pairs(ents.FindByClass("logic_auto")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("trigger_once")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("logic_case")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("func_breakable")) do
		v:Remove()
	end
end

--remove func_illusionary blocking vision
__HOOK[ "EntityKeyValue" ] = function( ent, key, value )
	if ent:GetClass() == "func_illusionary" then
		if key == "hammerid" then
			if value == "3727" or value == "3729" or value == "3733" or value == "3731" or value == "3741" or value == "3768" or value == "3778" then
				ent:Remove()
			end
		end
	end
end
