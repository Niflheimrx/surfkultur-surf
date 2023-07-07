--[[
	Author: Niflheimrx
	Description: Creates an entity matching the current entity model to create anti-telehoppable teleport triggers
]]--

ENT.Base = "base_brush"
ENT.Type = "brush"

function ENT:Initialize()
	self:SetSolid(SOLID_BSP)
end

function ENT:SetMapEnt(ent)
	self:SetModel(ent:GetModel())
	self:SetPos(ent:GetPos())
	self:SetAngles(ent:GetAngles())

	self.Filter = ent:GetInternalVariable "filtername"

	local entTarget = string.lower( ent:GetInternalVariable "target" )
	for _,spawn in pairs( ents.FindByClass "info_teleport_destination" ) do
		local currentPos = spawn:GetPos()
		local currentAngle = spawn:GetAngles()
		local currentName = string.lower( spawn:GetInternalVariable "m_iName" )

		if (entTarget == currentName) then
			self.TargetLocation = currentPos
			self.TargetAngle = currentAngle
		break end
	end
end

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
	if !ent:IsPlayer() then return end
	if !self.TargetLocation then return end
	if (!PassesTriggerFilters(self, ent)) then return end

	ent.Teleporting = true

	local playerBonus = string.StartWith( Core:StyleName( ent.Style ), "Bonus" )
	if !self.AllowBonuses and !playerBonus then
		ent:SetLocalVelocity( Vector( 0, 0, 0 ) )

		-- The following below is really fucking stupid but unless I override the actual player's movement this likely won't get fixed --
		timer.Simple(0.015, function()
			ent:SetLocalVelocity( Vector( 0, 0, 0 ) )
		end)

		timer.Simple(0.03, function()
			ent:SetLocalVelocity( Vector( 0, 0, 0 ) )
		end)
	else
		ent:SetLocalVelocity( Vector( 0, 0, 0 ) )

		timer.Simple(0.015, function()
			ent:SetLocalVelocity( Vector( 0, 0, 0 ) )
		end)

		timer.Simple(0.03, function()
			ent:SetLocalVelocity( Vector( 0, 0, 0 ) )
		end)
	end

	ent:SetPos( self.TargetLocation )
	ent:SetEyeAngles( self.TargetAngle )
end

function ENT:EndTouch(ent)
	if !ent:IsPlayer() then return end
	if !self.TargetLocation then return end

	ent.Teleporting = false
end
