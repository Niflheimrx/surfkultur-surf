hook.Add( "InitPostEntity", "RemoveJailTrigger", function()
	for _,ent in pairs( ents.FindByClass( "trigger_push" ) ) do
    if ent:GetPos() == Vector( 1328, 13936, 11504 ) then
      ent:SetKeyValue( "pushdir", "0, 0.01, 0.0000001")
    end
  end
end )
