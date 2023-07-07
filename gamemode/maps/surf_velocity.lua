__HOOK[ "InitPostEntity" ] = function()
	for _,v in pairs(ents.FindByClass("func_button")) do
		 v:Remove()
	end
	
	for _,ent in pairs(ents.FindByClass "trigger_teleport") do
		local pos = ent:GetPos()
		
		if pos == Vector( 2824.5, -6144, -4957 ) then
			ent:Remove()
		elseif pos == Vector( -6346, 2624, -2580.5 ) then
			ent:Remove()
		elseif pos == Vector( 5056, 6845.5, -2422 ) then
			ent:Remove()
		elseif pos == Vector( 10824, -4809.5, -3169.5 ) then
			ent:Remove()
		elseif pos == Vector( 5116.5, -512, -8893.5 ) then
			ent:Remove()
		elseif pos == Vector( -4608.5, 7072, -12654 ) then
			ent:Remove()
		elseif pos == Vector( -2232, -2456, -9336 ) then
			ent:Remove()
		end
	end
end
