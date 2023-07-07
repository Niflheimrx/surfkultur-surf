--- i love moving things almost as much as i love removing move things
__HOOK[ "InitPostEntity" ] = function()
	for k,v in pairs(ents.FindByClass("func_rot_button")) do
		 v:Remove()
	end
end
