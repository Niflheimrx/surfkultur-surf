--[[
  Author: Niflheimrx
  Description: Fix ramps not always allowing you to slide
               WHAT THIS DOES FIX: Unexpected stops in ramps that are designed correctly
               WHAT THIS DOES NOT FIX: Poor ramp design by mappers
--]]

Rampfix = {}
Rampfix.Enabled = true -- Unless this module causes problems in your server, this should always be set to true

Surf:Notify( "Success", "Rampfix module initialized" )

Rampfix.LastSpeed = {}
Rampfix.Speed = {}

local iMaxVelocity = GetConVar( "sv_maxvelocity" )

hook.Add( "StartCommand", "Rampfix_Control", function( ply, cmd )
  if !Rampfix.Enabled then return end
	if ply:IsBot() then return end
  if ply.Spectating then return end
  if ply.OnGround then return end

  local maxvel = iMaxVelocity:GetInt()

  local vPos = ply:GetPos()
  local vMins = ply:OBBMins()
  local vMaxs = ply:OBBMaxs()

  Rampfix.LastSpeed[ply] = Rampfix.Speed[ply] or nil
  Rampfix.Speed[ply] = ply:GetVelocity()

  -- Fix weird stuff that made people go through the roof --
  vPos.z = vPos.z + 1
  vMaxs.z = vMaxs.z - 1

  local vEndPos = vPos * 1

  -- Take account for the client already being stuck --
  vEndPos.z = vEndPos.z - maxvel

  local tr = util.TraceHull{
    start = vPos,
    endpos = vEndPos,
    mins = vMins,
    maxs = vMaxs,
    mask = MASK_PLAYERSOLID_BRUSHONLY,
    filter = ply
  }

  if tr.Hit then
    -- Gets the normal vector of the surface under the player --
    local vPlane, vRealEndPos = tr.HitNormal, tr.HitPos

    -- Check if the client is on a surf ramp, and if they are stuck --
    if (vPlane.z < 0.7 and (vPos.z - vRealEndPos.z) < 0.975) then
      -- Player was stuck, lets put them back on the ramp --
      ply:SetPos( vRealEndPos )
      ply:SetLocalVelocity( Rampfix.LastSpeed[ply] )
    end
  end
end )
