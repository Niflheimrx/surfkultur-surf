-- THERES A MAP FIX FOR THIS?!?! --
-- Creates new zones, removes other stupid stuff --

-- List of indexes we are working with --
local filterList = {
  ["Kitsecret"] = true,
}

local deleteList = {
  [1344] = true,
  [1351] = true,
  [1353] = true,
  [1355] = true,
  [1356] = true,
  [1358] = true,
  [1359] = true,
}

__HOOK[ "InitPostEntity" ] = function()
  for _,ent in pairs( ents.FindByClass "trigger_multiple" ) do
    ent:Remove()
  end

  for _,ent in pairs( ents.FindByClass "trigger_teleport" ) do
    local name = ent:GetInternalVariable "target"
    local hammerid = ent:MapCreationID()
    if filterList[name] then continue end

    if deleteList[hammerid] then
      ent:Remove()
    continue end

    Zones:GenerateSpawnZone( ent, true )
  end
end
