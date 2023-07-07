local remove = {
Vector( -6272, 7743.86, -1392 )
}

__HOOK[ "InitPostEntity" ] = function()
	for k,v in pairs(ents.FindByClass("info_teleport_destination")) do
		if(table.HasValue(remove,v:GetPos())) then
			v:Remove()
		end
	end
end