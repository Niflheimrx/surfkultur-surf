--for the peeps who like to see where they are going

__HOOK[ "InitPostEntity" ] = function()
	for k,v in pairs(ents.FindByClass("func_brush")) do
		if v:GetName() == "buddy1" then
			v:Remove()
		end
	end
end