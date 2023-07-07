-- imagine a world without mapfixes, such a cruel and heartless world may never exist

-- list jailtriggers
	local jailRemovers = {
		["send_tele1_t"] = true,
		["send_tele1_ct"] = true,
		["send_tele2_t"] = true,
		["send_tele2_ct"] = true,
		["send_tele3_t"] = true,
		["send_tele3_ct"] = true,
		["send_tele4_t"] = true,
		["send_tele4_ct"] = true,
		["send_tele5_t"] = true,
		["send_tele5_ct"] = true,
		["send_tele_6_ct"] = true,
		["send_tele_6_t"] = true,
		["send_tele_7_ct"] = true,
		["send_tele_7_t"] = true,
		["send_tele_7_t"] = true,
		["lose_tele"] = true,
		["end_tele_spawn_ct"] = true,
		["end_tele_spawn_t"] = true,
	}

__HOOK[ "InitPostEntity" ] = function()
	--remove jails
	for k,v in pairs(ents.FindByClass("trigger_teleport")) do
		if jailRemovers[v:GetName()] then
			v:Remove()
		end
	--rename trigger so it can be used more than once
		if v:GetName() == "win_tele" then
			v:SetName(v:GetName().."_rename")
		end
	end
	--remove useless shit
	for k,v in pairs(ents.FindByClass("func_button")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("trigger_multiple")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("trigger_gravity")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("logic_timer")) do
		v:Remove()
	end
end
