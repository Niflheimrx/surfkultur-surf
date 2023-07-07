-- my favourite colour is purple, what is yours?

__HOOK[ "InitPostEntity" ] = function()
	for k,v in pairs(ents.FindByClass("func_rotating")) do
		v:SetKeyValue( "maxspeed", "0" )
	end
	for k,v in pairs(ents.FindByClass("logic_timer")) do
		 v:Remove()
	end
end



__HOOK[ "EntityKeyValue" ] = function( ent, key, value )
	if ent:GetClass() == "info_teleport_destination" then
		if key == "targetname" then
			if value == "jailt" or value == "jailct"  then
				ent:Remove()
			end
		end
	end
	if ent:GetClass() == "trigger_teleport" then
		if key == "targetname" then
			if value == "endroundteleknife" or value == "endroundtele" or value == "endroundtelenothing"then
				ent:Remove()
			end
		end
	end
end
