--2020 changed startboost to be non-cboostable and give cboost speed

hook.Add( "InitPostEntity", "RemoveJailTrigger", function()
	if game.GetMap() == "surf_retroartz" then
		local e = ents.FindByClass( "trigger_once" )
		for _,v in pairs(e) do if IsValid(v) then v:Remove() end end
   
		e = ents.FindByClass( "trigger_multiple" )
		for _,v in pairs(e) do if IsValid(v) then v:Remove() end end
		
		e = ents.FindByClass( "logic_timer" )
		for _,v in pairs(e) do if IsValid(v) then v:Remove() end end
		
		e = ents.FindByClass( "logic_auto" )
		for _,v in pairs(e) do if IsValid(v) then v:Remove() end end
	end
end )

__HOOK[ "EntityKeyValue" ] = function( ent, key, value )
	local index = ent:MapCreationID()
	local isIndexed = index == 1444

	if key == "speed" and isIndexed then
		return "2000"
	end
end