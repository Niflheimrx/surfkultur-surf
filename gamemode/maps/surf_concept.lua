hook.Add( "InitPostEntity", "RemoveJailTrigger", function()
	if game.GetMap() == "surf_concept" then
		local e = ents.FindByClass( "trigger_once" )
		for _,v in pairs(e) do if IsValid(v) then v:Remove() end end
   
		e = ents.FindByClass( "trigger_multiple" )
		for _,v in pairs(e) do if IsValid(v) then v:Remove() end end
		
		e = ents.FindByClass( "logic_timer" )
		for _,v in pairs(e) do if IsValid(v) then v:Remove() end end
	end
end )

__HOOK[ "InitPostEntity" ] = function()
	for k,v in pairs(ents.FindByClass("func_breakable")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("func_button")) do
		v:Remove()
	end
end

