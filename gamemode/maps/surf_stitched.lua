--i thought i'd do my part and stitch a small mapfix to this map

--remove func_lod at start because it didnt behave like it is supposed to
__HOOK[ "InitPostEntity" ] = function()
	for k,v in pairs(ents.FindByClass("func_lod")) do
		v:Remove()
	end
end
