--[[
	Author: Niflheimrx
	Description: Copies a trigger_push brush and overrides the functionality for consistent results
]]--

ENT.Base = "base_brush"
ENT.Type = "brush"

function ENT:Initialize()
	self:SetSolid(SOLID_BSP)
end

function ENT:SetMapEnt(ent)
	local model = ent:GetModel()
	if !model or !IsValid(model) then
		self:Remove()

		timer.Simple(0.030, function()
			if !IsValid(ent) then return end

			ent:Fire "Enable"
		end)
	return end

	self:SetModel(ent:GetModel())
	self:SetPos(ent:GetPos())
	self:SetAngles(ent:GetAngles())

	self.PushDir = ent:GetInternalVariable "pushdir"
	self.PushSpeed = ent:GetInternalVariable "speed"
	self.Filter = ent:GetInternalVariable "filtername"
	self.ID = ent:MapCreationID()
	self.SpawnFlags = ent:GetSpawnFlags()

	local angRotate = ent:GetInternalVariable "m_angRotation"
	angRotate = Angle(angRotate.x, angRotate.y, angRotate.z)
	self.PushDir:Rotate(angRotate)
end

-- Check out this repo for port implementation --
-- https://github.com/ValveSoftware/source-sdk-2013/blob/master/sp/src/game/server/triggers.cpp

local function RetrieveFilterName(name)
	for _,ent in pairs(ents.FindByClass "filter_activator_name") do
		local entname = ent:GetName()
		local filtername = ent:GetInternalVariable "m_iFilterName"
		local filtertype = ent:GetInternalVariable "Negated"

		if (entname == name) then	return filtername, filtertype end
	end

	return "", true
end

local function PassesTriggerFilters(ent, ply)
	local targetname = ply:GetInternalVariable "m_iName"
	local filtername, filternegated = RetrieveFilterName(ent.Filter)

	if (filtername == "") then return true end
	if filternegated then return filtername != targetname end
	if !filternegated then return filtername == targetname end
end

function ENT:StartTouch(ent)
	if ent.CBEntity and ent.CBEntity != self.ID then
		ent.CBoostPrevent = false
	end
end

function ENT:EndTouch(ent)
	if ent.CBoostPrevent then return end

	ent.CBEntity = self.ID
	ent.CBoostPrevent = true

	timer.Simple(0.3, function()
		if ent.CBEntity != self.ID then return end

		ent.CBoostPrevent = false
	end)
end

function ENT:Touch(ent)
	local movetype = ent:GetMoveType()
	if (!ent:IsSolid() or movetype == MOVETYPE_PUSH or movetype == MOVETYPE_NONE) then return end

	if (!PassesTriggerFilters(self, ent)) then return end

	if ent.CBoostPrevent then return end

	local vecAbsDir = self.PushDir

	if (movetype == MOVETYPE_NOCLIP) then return end
	if (movetype == MOVETYPE_VPHYSICS) then
		local phys = ent:GetPhysicsObject()
		if (phys) then
			phys:ApplyForceCenter(self.PushSpeed * vecAbsDir * 100 * FrameTime())
		end
	return end

	local vecPush = (self.PushSpeed * vecAbsDir)
	if (ent:IsFlagSet(FL_BASEVELOCITY)) then
		vecPush = vecPush + ent:GetBaseVelocity()
	end
	if (vecPush.z > 0 and ent:IsFlagSet(FL_ONGROUND)) then
		ent:SetGroundEntity()
		local origin = ent:GetPos()
		origin.z = origin.z + 1
		ent:SetPos(origin)
	end

	ent:SetVelocity(vecPush)
	ent:AddFlags(FL_BASEVELOCITY)
end
