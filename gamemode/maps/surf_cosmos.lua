-- pwnd

__HOOK[ "InitPostEntity" ] = function()
  for _,ent in pairs( ents.FindByClass( "func_door" ) ) do
    local index = ent:MapCreationID()
    local isIndexed = index == 1237

    if isIndexed then
      ent:Remove()
    end
  end
end
