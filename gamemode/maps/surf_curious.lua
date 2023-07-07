hook.Add( "InitPostEntity", "RemoveJailTrigger", function()
	if game.GetMap() == "surf_curious" then
		local e = ents.FindByClass( "trigger_once" )
		for _,v in pairs(e) do if IsValid(v) then v:Remove() end end
   
		e = ents.FindByClass( "trigger_multiple" )
		for _,v in pairs(e) do if IsValid(v) then v:Remove() end end
		
		e = ents.FindByClass( "logic_timer" )
		for _,v in pairs(e) do if IsValid(v) then v:Remove() end end
	end
		__HOOK[ "InitPostEntity" ] = function()
		for k,v in pairs(ents.FindByClass("trigger_teleport")) do
			if(table.HasValue(remove,v:GetPos())) then
				v:Remove()
			end
		end
		
		for k,v in pairs(ents.FindByClass("trigger_multiple")) do
			if(table.HasValue(remove,v:GetPos())) then
				v:Remove()
			end
		end
	end
end )

