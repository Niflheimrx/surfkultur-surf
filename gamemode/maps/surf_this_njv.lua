--removes door

__HOOK[ "InitPostEntity" ] = function()
	for k,v in pairs(ents.FindByClass("func_door")) do
		v:Remove()
	end

	-- Remove stupid trigger_push at the start of the map --
	local pushRemovers = {
		["-4052.00 -576.00 15308.00"] = true,
	}

	for _,ent in ipairs(ents.FindByClass "trigger_push") do
		local currentPos = util.TypeToString(ent:GetPos())
		if !pushRemovers[currentPos] then continue end

		ent:Remove()
	end
end
