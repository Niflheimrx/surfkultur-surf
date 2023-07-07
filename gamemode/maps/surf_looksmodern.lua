-- This map is really cool when it actually works --
-- 01/04/22: Hooked engine triggers to zone triggers, the map itself should never be zoned --
-- NOTE: Don't touch this file unless you know what you are doing --

-- The following is an array of targetnames, the key is the targetname and the value is the zonetype --
local triggerList = {
	["stage1_trigger"] = 0,
	["stage2_trigger"] = 19,
	["stage3_trigger"] = 21,
	["stage4_trigger"] = 23,
	["stage5_trigger"] = 25,
	["end_trigger"] = 1
}

-- This is a handler that mimics writing a zonetable when creating a zone, except we use model bounds to setup our zones --
local function WriteCache(ent, zonetype)
	if (!ent or !IsValid(ent)) then return end
	if (!zonetype or !isnumber(zonetype)) then return end

	local p1, p2 = util.LocalToWorld(ent, ent:OBBMins()), util.LocalToWorld(ent, ent:OBBMaxs())
	table.insert(Zones.Cache, {Type = zonetype, P1 = p1, P2 = p2})
end

__HOOK[ "InitPostEntity" ] = function()
	-- Before we start doing anything we must clear the cache, this may be called more than one time! --
	Zones.Cache = {}

	-- The startpoint is always the decider target, this decides where the player needs to go when completing/restarting a stage --
	-- We handle the different scenarios below, so we don't worry about putting them in the wrong spot --
	local startPoint, startMin, startMax = Vector(), Vector(), Vector()
	local stagePoint, stageMin, stageMax = {}, {}, {}
	for _,info in pairs(ents.FindByClass "info_teleport_destination") do
		local name = IsValid(info) and info:GetName()
		if (!name) then continue end

		-- I never added sequence extract for stages, so this looks kinda bad --
		if (name == "surftimer_stage1") then
			startPoint = info:GetPos()
			startMin = util.LocalToWorld(info, info:OBBMins())
			startMax = util.LocalToWorld(info, info:OBBMaxs())
		elseif (name == "surftimer_stage2") then
			stagePoint[2] = info:GetPos()
			stageMin[2] = util.LocalToWorld(info, info:OBBMins())
			stageMax[2] = util.LocalToWorld(info, info:OBBMaxs())
		elseif (name == "surftimer_stage3") then
			stagePoint[3] = info:GetPos()
			stageMin[3] = util.LocalToWorld(info, info:OBBMins())
			stageMax[3] = util.LocalToWorld(info, info:OBBMaxs())
		elseif (name == "surftimer_stage4") then
			stagePoint[4] = info:GetPos()
			stageMin[4] = util.LocalToWorld(info, info:OBBMins())
			stageMax[4] = util.LocalToWorld(info, info:OBBMaxs())
		elseif (name == "surftimer_stage5") then
			stagePoint[5] = info:GetPos()
			stageMin[5] = util.LocalToWorld(info, info:OBBMins())
			stageMax[5] = util.LocalToWorld(info, info:OBBMaxs())
		end
	end

	-- If we couldn't find a spawnpoint we are prone to having issues, so don't try to fix it --
	if (startPoint:IsZero()) then return end

	for _,trigger in pairs(ents.FindByClass "trigger_multiple") do
		local name = IsValid(trigger) and trigger:GetName()
		if (!name) then continue end

		local index = triggerList[name]
		if (index) then
			WriteCache(trigger, index)
		end
	end

	-- When we are ready to setup this map, go ahead and spawn in the zones --
	Zones:Setup()

	-- The function above overrides some important values, we need to manually change those back --
	Zones.StartPoint = {startMin, startMax, (startMin + startMax) / 2}
	Zones["Stage 2 Point"] = {stageMin[2], stageMax[2], (stageMin[2] + stageMax[2]) / 2}
	Zones["Stage 3 Point"] = {stageMin[3], stageMax[3], (stageMin[3] + stageMax[3]) / 2}
	Zones["Stage 4 Point"] = {stageMin[4], stageMax[4], (stageMin[4] + stageMax[4]) / 2}
	Zones["Stage 5 Point"] = {stageMin[5], stageMax[5], (stageMin[5] + stageMax[5]) / 2}
end

-- We override the LoadZones function because we don't write zonedata to MySQL for this map --
function Core:LoadZones() __HOOK["InitPostEntity"]() end
