--[[
	Author: Niflheimrx
	Description: Strafe Trainer, a display that calculates the percentage against the perfect viewangle difference
--]]

Strafetrainer = {}
Strafetrainer.Enabled = CreateClientConVar("sm_strafetrainer", "0", true, false, "Enables the strafetrainer display")

local lastAngle, clientTickCount, clientPercentages = Angle():Zero(), 1, {}
local TRAINER_TICK_INTERVAL = 10

function Strafetrainer.Toggle()
	local current = 1 - Strafetrainer.Enabled:GetInt()
	RunConsoleCommand("sl_showaltzones", current)

	Link:Print( "Surf Timer", "Strafe Trainer has been " .. ((current == 0) and "Disabled" or "Enabled") )
end

local function NormalizeAngle(ang)
	if (ang > 180) then
		ang = ang - 360
	elseif (ang < -180) then
		ang = ang + 360
	end

	return ang
end

local function PerfStrafeAngle(speed)
	return math.deg(math.atan(30 / speed))
end

local function VisualisationString(percentage)
	local str = ""

	if (0.5 <= percentage) and (percentage <= 1.5) then
		local Spaces = math.Round((percentage - 0.5) / 0.05)
		for i = 0, Spaces + 1 do
			str = str .. "  "
		end

		str = str .. "|"

		for i = 0, (21 - Spaces) do
			str = str .. "  "
		end
	else
		str = str .. (percentage < 1.0 and "|                                      " or "                                       |")
	end

	return str
end

local function GetPercentageColor(percentage)
	local offset = math.abs(1 - percentage)
	local color = Color(0, 0, 0, 0)

	if (offset < 0.05) then
		color = Color(0, 255, 0, 180)
	elseif (0.05 <= offset) and (offset < 0.1) then
		color = Color(128, 255, 0, 180)
	elseif (0.1 <= offset) and (offset < 0.25) then
		color = Color(255, 255, 0, 180)
	elseif (0.25 <= offset) and (offset < 0.5) then
		color = Color(255, 128, 0, 180)
	else
		color = Color(255, 0, 0, 180)
	end

	return color
end

local sMessage, sAverage, color, lastUpdate = "", Color(0, 0, 0, 0), nil
local function StrafeTrainer(ply, mv)
	if (LocalPlayer() != ply) or (LocalPlayer():Team() == TEAM_SPECTATOR) then return end
	if !Strafetrainer.Enabled:GetBool() then return end
	if !IsFirstTimePredicted() then return end
	if (ply:OnGround() or ply:GetMoveType() == MOVETYPE_NOCLIP or ply:GetMoveType() == MOVETYPE_LADDER) then return end

	local currentAngle = mv:GetMoveAngles().y
	local currentVelocity = mv:GetVelocity():Length2D()
	if !lastAngle then lastAngle = currentAngle end

	local AngDiff = NormalizeAngle(lastAngle - currentAngle)

	local PerfAngle = PerfStrafeAngle(currentVelocity)

	local Percentage = math.abs(AngDiff / PerfAngle) or 0

	if clientTickCount > TRAINER_TICK_INTERVAL then
		local AveragePercentage = 0.0

		for i = 1, TRAINER_TICK_INTERVAL do
			AveragePercentage = AveragePercentage + clientPercentages[i]
			clientPercentages[i] = 0.0
		end

		AveragePercentage = AveragePercentage / TRAINER_TICK_INTERVAL
		sAverage = math.Round(AveragePercentage * 100, 2)

		sMessage = VisualisationString(AveragePercentage)
		color = GetPercentageColor(AveragePercentage)
		lastUpdate = CurTime()
		clientTickCount = 1
	else
		clientPercentages[clientTickCount] = Percentage
		clientTickCount = clientTickCount + 1
	end

	lastAngle = currentAngle
end
hook.Add("FinishMove", "sm_strafetrainer", StrafeTrainer)

local function DrawStrafeTrainer()
	if !Strafetrainer.Enabled:GetBool() then return end
	if !lastUpdate then return end

	if CurTime() > (lastUpdate + 3) then
		color = ColorAlpha(color, color.a - 1)
	end

	local font = Interface:GetBigFont()
	local fontHeight = draw.GetFontHeight(font)

	local wide, tall = ScrW(), ScrH()
	draw.SimpleText(sAverage .. "%", font, wide / 2, tall / 3, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.SimpleText("════════^════════", font, wide / 2, tall / 3 + (fontHeight * 1), color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.SimpleText(sMessage, font, wide / 2, tall / 3 + (fontHeight * 2), color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	draw.SimpleText("════════^════════", font, wide / 2, tall / 3 + (fontHeight * 3), color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
end
hook.Add("HUDPaint", "sm_drawstrafetrainer", DrawStrafeTrainer)
