--You have encountered an unfortunate fate haven't you? Removes teleport triggers for appropriate speedrunning.

__HOOK[ "InitPostEntity" ] = function()
	for k,v in pairs( ents.FindByClass("trigger_teleport") ) do
		if v:GetName() == "Red1Jail" then
			v:SetKeyValue( "target", "BlueSpawn" )
		end
		if v:GetName() == "Red2Jail" then
			v:SetKeyValue( "target", "BlueSpawn" )
		end
		if v:GetName() == "3JailRed" then
			v:SetKeyValue( "target", "BlueSpawn" )
		end
		if v:GetName() == "Blue1Jail" then
			v:SetKeyValue( "target", "BlueSpawn" )
		end
		if v:GetName() == "Blue2Jail" then
			v:SetKeyValue( "target", "BlueSpawn" )
		end
		if v:GetName() == "3JailBlue" then
			v:SetKeyValue( "target", "BlueSpawn" )
		end
	end
end

__HOOK[ "EntityKeyValue" ] = function( ent, key, value )
	if ent:GetClass() == "trigger_teleport" then
		if key == "filtername" then
			return ""
		end
	end
end