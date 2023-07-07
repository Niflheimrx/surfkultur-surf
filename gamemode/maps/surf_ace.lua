--ripoff of surf_nexus (but better!), fixes for bonus not valid teleport
-- 11/24/2020: redo how bonus is fixed

__HOOK[ "InitPostEntity" ] = function()
	local bonusFilterPos = Vector( -10496, 10144, 8472.5 )
	for _,ent in pairs( ents.FindByClass "trigger_multiple" ) do
		local currentPos = ent:GetPos()
		if (currentPos == bonusFilterPos) then
			ent:SetPos( Vector( -11024, 10208, 8625 ) )
		end
	end
end
