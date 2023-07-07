--[[
  Author: Niflheimrx
  Description: Showkeys controller and displayer.
--]]

ShowKeys = {}
ShowKeys.Enabled = CreateClientConVar( "sl_showkeys", "0", true, false, "Displays the movement keys that are being pressed by the player." )
ShowKeys.Position = CreateClientConVar( "sl_showkeys_pos", "0", true, false, "Changes the position of the showkeys module, default is 0 (center)." )
ShowKeys.Color = color_white

local fb, lp, ts = bit.band, LocalPlayer, _C.Team.Spectator
local isPressing = function( ent, bit ) return ent:KeyDown( bit ) end

local syncData, syncAxis, syncStill = "Sync: 0%", 0, 0
local spectatorBits = 0
local isSpecPressing = function( bit ) return fb( spectatorBits, bit ) > 0 end

-- For jump prediction --
local jumpTime = 0
local jumpDisplay = 0.25

function SetSyncData( data ) syncData = (data or "Sync: 0%") end
local function norm( i ) if i > 180 then i = i - 360 elseif i < -180 then i = i + 360 end return i end

local keyStrings = {
  [512] = input.LookupBinding( "+moveleft" ) or "A",
  [1024] = input.LookupBinding( "+moveright" ) or "D",
  [8] = input.LookupBinding( "+forward" ) or "W",
  [16] = input.LookupBinding( "+back" ) or "S",
  [4] = "+ DUCK",
  [2] = "+ JUMP",
  [128] = "<",
  [256] = ">",
}

local keyPositions = {
  [0] = {
    [512] = { ScrW() / 2 - 30, ScrH() / 2 },
    [1024] = { ScrW() / 2 + 30, ScrH() / 2 },
    [8] = { ScrW() / 2, ScrH() / 2 - 30 },
    [16] = { ScrW() / 2, ScrH() / 2 + 30 },
    [4] = { ScrW() / 2 - 60, ScrH() / 2 + 30 },
    [2] = { ScrW() / 2 + 60, ScrH() / 2 + 30 },
    [128] = { ScrW() / 2 - 60, ScrH() / 2 },
    [256] = { ScrW() / 2 + 60, ScrH() / 2 }
  },
  [1] = {
    [512] = { ScrW() - 120 - 30, ScrH() - 120 },
    [1024] = { ScrW() - 120 + 30, ScrH() - 120 },
    [8] = { ScrW() - 120, ScrH() - 120 - 30 },
    [16] = { ScrW() - 120, ScrH() - 120 + 30 },
    [4] = { ScrW() - 120 - 60, ScrH() - 120 + 30 },
    [2] = { ScrW() - 120 + 60, ScrH() - 120 + 30 },
    [128] = { ScrW() - 120 - 60, ScrH() - 120 },
    [256] = { ScrW() - 120 + 60, ScrH() - 120 }
  }
}

function Client:ToggleKeys()
	local nNew = 1 - ShowKeys.Enabled:GetInt()
	RunConsoleCommand( "sl_showkeys", nNew )
	Link:Print( "General", "You have " .. (nNew == 0 and "disabled" or "enabled") .. " on-screen keys." )
end

local function DisplayKeys()
  local wantsKeys = ShowKeys.Enabled:GetBool()
  if !wantsKeys then return end

  local lpc = lp()
  if !IsValid( lpc ) then return end

  local currentPos = ShowKeys.Position:GetInt()

  local isSpectating = lpc:Team() == ts
  local testSubject = lpc:GetObserverTarget()
  local isValidSpectator = isSpectating and IsValid( testSubject ) and testSubject:IsPlayer()

  if isValidSpectator then
    -- Handle Key Presses --
    for key, text in pairs( keyStrings ) do
      local willDisplay = isSpecPressing(key)
      if (key == 2) and (jumpTime > RealTime()) then
        local pos = keyPositions[currentPos][key]
        draw.SimpleText( text, "HUDHeader", pos[1], pos[2], ShowKeys.Color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

        continue
      end

      if !willDisplay then continue end

      local pos = keyPositions[currentPos][key]
      text = string.upper( text )

      if (key == 2) then
        jumpTime = RealTime() + jumpDisplay
      end

      draw.SimpleText( text, "HUDHeader", pos[1], pos[2], ShowKeys.Color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end

    -- Test for angle changes --
    local currentAngle = testSubject:EyeAngles().y
    local diff = norm( currentAngle - syncAxis )
    if diff > 0 then
      syncStill = 0

      local pos = keyPositions[currentPos][128]
      draw.SimpleText( "<", "HUDHeaderBig", pos[1], pos[2], ShowKeys.Color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    elseif diff < 0 then
      syncStill = 0

      local pos = keyPositions[currentPos][256]
      draw.SimpleText( ">", "HUDHeaderBig", pos[1], pos[2], ShowKeys.Color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    else
      syncStill = syncStill + 1
    end

    syncAxis = currentAngle
  else
    -- Handle Key Presses --
    for key, text in pairs( keyStrings ) do
      local willDisplay = isPressing(lpc, key)
      if !willDisplay then continue end

      local pos = keyPositions[currentPos][key]
      text = string.upper( text )

      draw.SimpleText( text, "HUDHeader", pos[1], pos[2], ShowKeys.Color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end

    -- Test for angle changes --
    local currentAngle = lpc:EyeAngles().y
    local diff = norm( currentAngle - syncAxis )
    if diff > 0 then
      syncStill = 0

      local pos = keyPositions[currentPos][128]
      draw.SimpleText( "<", "HUDHeaderBig", pos[1], pos[2], ShowKeys.Color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    elseif diff < 0 then
      syncStill = 0

      local pos = keyPositions[currentPos][256]
      draw.SimpleText( ">", "HUDHeaderBig", pos[1], pos[2], ShowKeys.Color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    else
      syncStill = syncStill + 1
    end

    syncAxis = currentAngle

    -- Perform Sync% Thingy --
    local pos = { ScrW() - 15, ScrH() - 15 }
    if syncData then
      draw.SimpleText( syncData, "HUDHeader", pos[1], pos[2], ShowKeys.Color, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
    end
  end
end
hook.Add( "HUDPaint", "surf.ShowKeys", DisplayKeys )

local function ReceiveSpecByte()
  spectatorBits = net.ReadUInt( 11 )
end
net.Receive( "surf_ShowKeys", ReceiveSpecByte )
