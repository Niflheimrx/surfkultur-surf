local Zone = {
	MStart = 0,
	MEnd = 1,
	BStart = 2,
	BEnd = 3,
	AC = 4,
	Restart = 5,
	B2Start = 6,
	B2End = 7,
	Mark = 8,
	B3Start = 9,
	B3End = 10,
	B4Start = 11,
	B4End = 12,
	B5Start = 13,
	B5End = 14,
	B6Start = 15,
	B6End = 16,
	Stage1 = 17,
	Stage2 = 19,
	Stage3 = 21,
	Stage4 = 23,
	Stage5 = 25,
	Stage6 = 27,
	Stage7 = 29,
	Stage8 = 31,
	Stage9 = 33,
	Stage10 = 35,
	Stage11 = 37,
	Stage12 = 39,
	Stage13 = 41,
	Stage14 = 43,
	Stage15 = 45,
	Stage16 = 47,
	Stage17 = 49,
	Stage18 = 51,
	Stage19 = 53,
	Stage20 = 55,
	Stage21 = 57,
	Stage22 = 59,
	Stage23 = 61,
	Stage24 = 63,
	SEnd = 70,
	StageReset = 93,
	Telehop = 94,
	NoBhop = 95,
	B7Start = 96,
	B7End = 97,
	B8Start = 98,
	B8End = 99,
	B9Start = 100,
	B9End = 101,
	B10Start = 102,
	B10End = 103,
	NoJump = 104,
	BonusAnticheat = 105,
}

local DrawArea = {
	[Zone.MStart] = Color( 0, 255, 0, 255 ),
	[Zone.MEnd] = Color( 255, 0, 0, 255 ),
	[Zone.BStart] = Color( 127, 140, 141 ),
	[Zone.BEnd] = Color( 52, 73, 118 ),
	[Zone.B2Start] = Color( 127, 140, 141 ),
	[Zone.B2End] = Color( 52, 73, 118 ),
	[Zone.Mark] = Color( 0, 255, 255, 255 ),
	[Zone.B3Start] = Color( 127, 140, 141 ),
	[Zone.B3End] = Color( 52, 73, 118 ),
	[Zone.B4Start] = Color( 127, 140, 141 ),
	[Zone.B4End] = Color( 52, 73, 118 ),
	[Zone.B5Start] = Color( 127, 140, 141 ),
	[Zone.B5End] = Color( 52, 73, 118 ),
	[Zone.B6Start] = Color( 127, 140, 141 ),
	[Zone.B6End] = Color( 52, 73, 118 ),
	[Zone.B7Start] = Color( 127, 140, 141 ),
	[Zone.B7End] = Color( 52, 73, 118 ),
	[Zone.B8Start] = Color( 127, 140, 141 ),
	[Zone.B8End] = Color( 52, 73, 118 ),
	[Zone.B9Start] = Color( 127, 140, 141 ),
	[Zone.B9End] = Color( 52, 73, 118 ),
	[Zone.B10Start] = Color( 127, 140, 141 ),
	[Zone.B10End] = Color( 52, 73, 118 ),
}

local DrawAltArea = {
	[Zone.MStart] = Color( 0, 255, 0, 255 ),
	[Zone.MEnd] = Color( 255, 0, 0, 255 ),
	[Zone.BStart] = Color( 127, 140, 141 ),
	[Zone.BEnd] = Color( 52, 73, 118 ),
	[Zone.B2Start] = Color( 127, 140, 141 ),
	[Zone.B2End] = Color( 52, 73, 118 ),
	[Zone.Mark] = Color( 0, 255, 255, 255 ),
	[Zone.B3Start] = Color( 127, 140, 141 ),
	[Zone.B3End] = Color( 52, 73, 118 ),
	[Zone.B4Start] = Color( 127, 140, 141 ),
	[Zone.B4End] = Color( 52, 73, 118 ),
	[Zone.B5Start] = Color( 127, 140, 141 ),
	[Zone.B5End] = Color( 52, 73, 118 ),
	[Zone.B6Start] = Color( 127, 140, 141 ),
	[Zone.B6End] = Color( 52, 73, 118 ),
	[Zone.B7Start] = Color( 127, 140, 141 ),
	[Zone.B7End] = Color( 52, 73, 118 ),
	[Zone.B8Start] = Color( 127, 140, 141 ),
	[Zone.B8End] = Color( 52, 73, 118 ),
	[Zone.B9Start] = Color( 127, 140, 141 ),
	[Zone.B9End] = Color( 52, 73, 118 ),
	[Zone.B10Start] = Color( 127, 140, 141 ),
	[Zone.B10End] = Color( 52, 73, 118 ),
	[Zone.AC] = Color( 255, 255, 255, 200 ),
	[Zone.Restart] = Color( 255, 255, 255, 200 ),
	[Zone.Stage1] = Color( 255, 255, 255, 200 ),
	[Zone.Stage2] = Color( 255, 255, 255, 200 ),
	[Zone.Stage3] = Color( 255, 255, 255, 200 ),
	[Zone.Stage4] = Color( 255, 255, 255, 200 ),
	[Zone.Stage5] = Color( 255, 255, 255, 200 ),
	[Zone.Stage6] = Color( 255, 255, 255, 200 ),
	[Zone.Stage7] = Color( 255, 255, 255, 200 ),
	[Zone.Stage8] = Color( 255, 255, 255, 200 ),
	[Zone.Stage9] = Color( 255, 255, 255, 200 ),
	[Zone.Stage10] = Color( 255, 255, 255, 200 ),
	[Zone.Stage11] = Color( 255, 255, 255, 200 ),
	[Zone.Stage12] = Color( 255, 255, 255, 200 ),
	[Zone.Stage13] = Color( 255, 255, 255, 200 ),
	[Zone.Stage14] = Color( 255, 255, 255, 200 ),
	[Zone.Stage15] = Color( 255, 255, 255, 200 ),
	[Zone.Stage16] = Color( 255, 255, 255, 200 ),
	[Zone.Stage17] = Color( 255, 255, 255, 200 ),
	[Zone.Stage18] = Color( 255, 255, 255, 200 ),
	[Zone.Stage19] = Color( 255, 255, 255, 200 ),
	[Zone.Stage20] = Color( 255, 255, 255, 200 ),
	[Zone.Stage21] = Color( 255, 255, 255, 200 ),
	[Zone.Stage22] = Color( 255, 255, 255, 200 ),
	[Zone.Stage23] = Color( 255, 255, 255, 200 ),
	[Zone.Stage24] = Color( 255, 255, 255, 200 ),
	[Zone.SEnd] = Color( 255, 255, 255, 200 ),
	[Zone.NoJump] = Color( 255, 255, 255, 200 ),
	[Zone.BonusAnticheat] = Color( 91, 91, 91, 200),
}

local SolidBox = CreateClientConVar( "sl_solidzone", "0", true, true, "Toggles the visiblity of solid zone boxes. By default this is disabled for visibility reasons." )
local DrawMaterial = Material( "sprites/tp_beam001" )
local DrawSolidMaterial = Material( "flow/timer.png" )

function ENT:Initialize() end

function ENT:Think()
	local Min, Max = self:GetCollisionBounds()
	self:SetRenderBounds( Min, Max )
end

function ENT:Draw()
	local showZones = GetConVar("sl_showzones"):GetBool()
	local showAltZones = GetConVar("sl_showaltzones"):GetBool()
	local showSolidBox = SolidBox:GetBool()
	if !showZones then return end

	if showAltZones then
		if !DrawAltArea[ self:GetZoneType() ] then return end
	else
		if !DrawArea[ self:GetZoneType() ] then return end
	end

	local colObject = ( DrawArea[self:GetZoneType()] or DrawAltArea[self:GetZoneType()] )
	local Min, Max = self:GetCollisionBounds()
	Min = self:GetPos() + Min
	Max = self:GetPos() + Max

	local Col, Width = colObject, 10
	local B1, B2, B3, B4 = Vector(Min.x, Min.y, Min.z), Vector(Min.x, Max.y, Min.z), Vector(Max.x, Max.y, Min.z), Vector(Max.x, Min.y, Min.z)
	local T1, T2, T3, T4 = Vector(Min.x, Min.y, Max.z), Vector(Min.x, Max.y, Max.z), Vector(Max.x, Max.y, Max.z), Vector(Max.x, Min.y, Max.z)

	-- Check if a player is standing inside the box, for solidbox improvements --
	local plyPos = LocalPlayer():EyePos()
	local isInside = plyPos:WithinAABox( Min, Max )

	local spawnBox = (B1:DistToSqr( B3 ) <= 20)

	if (showSolidBox and !isInside and !spawnBox) then
		local pos = self:GetPos()
		local angle = Angle( 0, 0, 0 )
		local colour = Color( Col.r, Col.g, Col.b, 20 )

		local min, max = self:GetCollisionBounds()

		render.SetMaterial( DrawSolidMaterial )
		render.DrawBox( pos, angle, min, max, colour )
	else
		if showSolidBox then
			render.SetMaterial( DrawSolidMaterial )
			Width = 2
		else
			render.SetMaterial( DrawMaterial )
		end

		render.DrawBeam( B1, B2, Width, 0, 1, Col )
		render.DrawBeam( B2, B3, Width, 0, 1, Col )
		render.DrawBeam( B3, B4, Width, 0, 1, Col )
		render.DrawBeam( B4, B1, Width, 0, 1, Col )

		render.DrawBeam( T1, T2, Width, 0, 1, Col )
		render.DrawBeam( T2, T3, Width, 0, 1, Col )
		render.DrawBeam( T3, T4, Width, 0, 1, Col )
		render.DrawBeam( T4, T1, Width, 0, 1, Col )

		render.DrawBeam( B1, T1, Width, 0, 1, Col )
		render.DrawBeam( B2, T2, Width, 0, 1, Col )
		render.DrawBeam( B3, T3, Width, 0, 1, Col )
		render.DrawBeam( B4, T4, Width, 0, 1, Col )
	end
end
