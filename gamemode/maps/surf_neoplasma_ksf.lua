-- baby goes round round and round --

local entFilter = Vector( -6784, 296, 2896 )

__HOOK[ "InitPostEntity" ] = function()
  for _,ent in pairs( ents.FindByClass("func_rotating") ) do
    local pos = ent:GetPos()
    if (pos == entFilter) then
      ent:Remove()
    end
  end
end
