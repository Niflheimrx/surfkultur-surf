-- pros only --

local entFilter = 2553

__HOOK[ "InitPostEntity" ] = function()
  for _,ent in pairs( ents.FindByClass("trigger_multiple") ) do
    local index = ent:MapCreationID()
    if (index == entFilter) then
      ent:Remove()
    end
  end
end
