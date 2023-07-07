hook.Add( "InitPostEntity", "RemoveJailTrigger", function()
	if game.GetMap() == "surf_ny_momentum_v3_1" then
		local e = ents.FindByClass( "trigger_once" )
		for _,v in pairs(e) do if IsValid(v) then v:Remove() end end
   
		e = ents.FindByClass( "trigger_multiple" )
		for _,v in pairs(e) do if IsValid(v) then v:Remove() end end
		
		e = ents.FindByClass( "logic_timer" )
		for _,v in pairs(e) do if IsValid(v) then v:Remove() end end
	end
end )

