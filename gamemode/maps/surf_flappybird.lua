--WOAH DUDE, DID YOU BEAT MY HIGH SCORE?!?!?! Small fix to relocate bonus teleport trigger.
--This is so people do not abuse the bonus just to beat the map quicker.

__HOOK[ "InitPostEntity" ] = function()
	for k,v in pairs(ents.FindByClass("trigger_teleport")) do
		if v:GetPos() == Vector( -12283, 206, -6353 ) then
			v:SetKeyValue( "target", "stage5tele1" )
		end
	end
end