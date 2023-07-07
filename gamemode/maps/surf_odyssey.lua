hook.Add( "InitPostEntity", "RemoveJailTrigger", function()
	if game.GetMap() == "surf_odyssey" then
		
		local e = ents.FindByClass( "logic_timer" )
		for _,v in pairs(e) do if IsValid(v) then v:Remove() end end
		
		e = ents.FindByClass( "logic_auto" )
		for _,v in pairs(e) do if IsValid(v) then v:Remove() end end
	end
end )

