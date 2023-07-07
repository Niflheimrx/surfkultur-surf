--Fix this fucking map

local remove = {
Vector( 16016, -14346, -982 ),
Vector( 12192, -14346, -982 ),
Vector( 15816, -15502, -722 ),
Vector( 15816, -15502, -767 ),
Vector( 15816, -15502, -796 ),
Vector( 15816, -15502, -813 ),
Vector( 15816, -15066, -722 ),
Vector( 15816, -15066, -797 ),
Vector( 15889, -14790, -697 ),
Vector( 15882, -14790, -982 ),
Vector( 15882, -14790, -982 )
}

__HOOK[ "InitPostEntity" ] = function()
	for k,v in pairs(ents.FindByClass("trigger_teleport")) do
		if(table.HasValue(remove,v:GetPos())) then
			v:Remove()
		end
	end

--Remove the logic timer teleporting you to a jail
	for _,ent in pairs( ents.FindByClass( "logic_timer" ) ) do
			ent:Remove()
		end
	for _,ent in pairs( ents.FindByClass( "logic_auto" ) ) do
			ent:Remove()
		end
end