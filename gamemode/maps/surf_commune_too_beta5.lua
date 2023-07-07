--Removes jails.

__HOOK[ "InitPostEntity" ] = function()
	for k,v in pairs(ents.FindByClass("trigger_once")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("trigger_multiple")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("logic_timer")) do
		v:Remove()
	end
	for k,v in pairs(ents.FindByClass("func_brush")) do
		v:GetMaterials()
	end
end