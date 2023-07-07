--Whoppa Gangnam style!

__HOOK[ "InitPostEntity" ] = function()
	for k,v in pairs(ents.FindByClass("trigger_once")) do
		v:Remove()
	end
end