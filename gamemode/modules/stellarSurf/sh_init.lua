--[[
  Author: Niflheimrx
  Description: Simple loader for new files so I don't have to manually keep editing files.
--]]

-- Detect refresh and notify server --
if Surf then
  Surf:Notify( "Warning", "Auto-refresh detected" )
end

-- Make a new global table, this should make things easy to work with --
Surf = {}
Surf.ServerLogging  = true -- This should always be true, unless you don't want messages showing in chat
Surf.ServerDebug    = true -- Keep this false, unless you want a bunch of blue-colored messages
Surf.ConsoleColor   = { ["error"] = Color( 255, 0, 0 ), ["warning"] = Color( 255, 255, 0 ), ["success"] = Color( 0, 255, 0 ), ["debug"] = Color( 0, 255, 255 ) } -- It is best to not change these

-- Simple console notification messages with colors --
function Surf:Notify( type, message )
  if not Surf.ServerLogging then return end

  local messageType = string.lower( type )
  if messageType == "debug" and not Surf.ServerDebug then return end

  local prefixColor = Surf.ConsoleColor[ messageType ]

  MsgC( prefixColor, "[" .. string.upper( messageType ) .. "] ", message, "\n" )

  -- Make errors more noticable while debugging in client --
  -- IMPLEMENT THIS IN THE FUTURE --
  --[[if CLIENT and Surf.ServerDebug and type == "error" then
    HUD.Notify:AddCard( 1, "There was a problem using that, check your console for details" )
  end--]]
end

-- Begin the loading process --
local clientCount, serverCount = 0, 0

-- Find files for clientside --
local clfiles, _ = file.Find("surf/gamemode/modules/stellarSurf/cl_*", "LUA")
for _, modules in ipairs(clfiles) do
  if SERVER then
    AddCSLuaFile( modules )
  else
    include( modules )
    clientCount = clientCount + 1
  end
end

-- Find files for serverside --
if SERVER then
  local svfiles, _ = file.Find("surf/gamemode/modules/stellarSurf/sv_*", "LUA")
  for _, modules in ipairs(svfiles) do
    include( modules )
    serverCount = serverCount + 1
  end
end

-- Let them know we started and how many files we loaded --
Surf:Notify( "Success", "Stellar Modules Initialized [Modules: " .. ( SERVER and serverCount or clientCount ) .. "]" )
