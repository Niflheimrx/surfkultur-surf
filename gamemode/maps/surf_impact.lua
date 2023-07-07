--shoutout to Gravious for handing me this

__HOOK[ "InitPostEntity" ] = function()
	for k,v in pairs( ents.FindByClass( "math_counter" ) ) do
		v:Remove()
	end

		for k,v in pairs( ents.FindByClass( "trigger_teleport" ) ) do
		if string.find( v:GetName(), "end_round_teles" ) then
			v:Remove()
		elseif v:GetPos() == Vector( -6405.98, -5980.71, -8242.5 ) then
			v:Remove()
		end
	end

		for k,v in pairs( ents.FindByClass( "trigger_multiple" ) ) do
		if v:GetPos() == Vector( -6405.99, -5980.71, -8279.5 ) then
			v:Remove()
		end
	end

		for k,v in pairs( ents.FindByClass( "trigger_push" ) ) do
		if v:GetPos() == Vector( -6405.98, -5980.71, -8484 ) then
			v:Remove()
		end
	end
end
__HOOK[ "EntityKeyValue" ] = function( ent, key, value )
	local index = ent:MapCreationID()
	local isIndexed = index == 1705

	if key == "speed" and isIndexed then
		return "3500"
	end
end