local colors = {
	["red"] = Color(255, 0, 0),
	["black"] = Color(0, 0, 0),
	["blue"] = Color(0, 0, 248),
	["brown"] = Color(104, 49, 0),
	["cyan"] = Color(0, 244, 248),
	["green"] = Color(0, 252, 0),
	["orange"] = Color(248, 148, 0),
	["pink"] = Color(248, 0, 248),
	["purple"] = Color(147, 0, 248),
	["white"] = Color(255, 255, 255),
	["yellow"] = Color(248, 252, 0),
}

for v,_ in pairs(colors) do
	-- Register decal
	game.AddDecal("paint_" .. v, "decals/paint/laser_" .. v .. "_med")

	-- Make the client download the decal
	if SERVER then
		resource.AddFile("materials/decals/paint/laser_" .. v .. ".vmt")
		resource.AddFile("materials/decals/paint/laser_" .. v .. "_med.vmt")
	end
end
Surf:Notify( "Debug", "Loaded paint registry" )

-- Server shit
if SERVER then
	-- New paint created
	util.AddNetworkString "PaintCreated"
	util.AddNetworkString "PaintHistory"

	-- Player cool down, prevent players from using paint multiple times a tick
	local cooldown_time = 0.05
	local cooldown      = {}

	-- Store temporary paint table so they can be re-created on join
	local tempCache     = {}
	local tempIndex     = 1

	Command:Register( { "paintcolor" }, function( ply, args )
		if !ply.IsVIP then
			return Core:Send( ply, "Print", { "Notification", "You need to be an Elevated VIP in order to use this." } )
		end

		if !ply.PaintColor then ply.PaintColor = "red" end
		local newColor = string.lower( args[1] )
		local isValidPaint = colors[newColor]
		if !isValidPaint then
			Core:Send( ply, "Print", { "Notification", "This is an invalid color, locate your choices in the Donators tab inside the !surftimer panel [color: " .. newColor .. "]" } )
		return end

		ply.PaintColor = newColor
		Core:Send( ply, "Print", { "Notification", "Your new paint color has changed to " .. newColor .. "." } )
	end )

	-- Paint command
	concommand.Add("sm_paint", function(ply)
		if !ply.IsVIP then return end
		if ply.Spectating then return end

		if cooldown[ply] and cooldown[ply] > RealTime() then return end
		cooldown[ply] = RealTime() + cooldown_time

		local eyePos = ply:EyePos() - Vector(0, 0, 16)
		local trace  = ply:GetEyeTrace()
		local col    = ply.PaintColor or "red"
		if !colors[col] then col = "red" end

		net.Start "PaintCreated"
			net.WriteVector(eyePos)
			net.WriteVector(trace.HitPos)
			net.WriteNormal(trace.HitNormal)
			net.WriteString(col)
		net.Broadcast()

		tempCache[tempIndex] = { trace.HitPos, trace.HitNormal, col }
		tempIndex = tempIndex + 1

		if tempIndex > 256 then
			tempIndex = 1
		end
	end)

	local function SendPaintHistory( ply )
		local cache = #tempCache
		if (cache == 0) then return end

		net.Start( "PaintHistory" )
			net.WriteUInt(cache, 8)

			for _,data in pairs(tempCache) do
				local pos, norm, col = data[1], data[2], data[3]
				net.WriteVector(pos)
				net.WriteNormal(norm)
				net.WriteString(col)
			end
		net.Send( ply )
	end

	-- have to do this because of net unreliability, https://github.com/Facepunch/garrysmod-requests/issues/718
	local function RequestPaintHistory( ply )
		hook.Add("SetupMove",ply,function(self,ply,_,cmd)
			if self == ply and !cmd:IsForced() then
				SendPaintHistory( ply )
				hook.Remove("SetupMove",self)
			end
		end )
	end
	hook.Add( "PlayerInitialSpawn", "surf_Paint.History", RequestPaintHistory )
end

-- Client shit
if CLIENT then
	-- Paint Beam Cache --
	local paintBeamCache = {}

	-- Paint decal
	net.Receive("PaintCreated", function()
		local eye  = net.ReadVector()
		local pos  = net.ReadVector()
		local norm = net.ReadNormal()
		local col  = net.ReadString()

		util.Decal("paint_" .. col, pos - norm, pos)
		table.insert(paintBeamCache, {eye, pos, norm, col, CurTime()})
	end)

	-- History decals
	net.Receive("PaintHistory", function(len, _)
		-- Redid 15/04/2021: Better at handling larger caches --

		-- Get the number of indices, and track package size --
		local indices = net.ReadUInt(8)
		local size = string.NiceSize(len)

		-- From the start index, go up until we hit the latest cache --
		for i = 1, indices do
			local pos, norm, col = net.ReadVector(), net.ReadNormal(), net.ReadString()

			util.Decal("paint_" .. col, pos - norm, pos)
		end

		Surf:Notify( "Debug", "Paint history request received [Size: " .. size .. "]" )
	end)

	local cooldown_time = 0.05
	local cooldown = 0

	local bindedKey = input.LookupBinding( "sm_paint" ) or "g"
	local keyCode   = input.GetKeyCode( bindedKey )

	local function BindTracker()
		local currentKey = input.LookupBinding( "sm_paint" ) or "g"
		if (currentKey == bindedKey) then return end

		bindedKey = currentKey
		keyCode = input.GetKeyCode( bindedKey )

		Surf:Notify( "Warning", "Paint binding changed, started new tracker!" )
	end
	timer.Create( "surf_Paint.BindTracker", 1, 0, BindTracker )

	local function PaintBeam()
		render.OverrideDepthEnable(true, true)
		render.SetColorMaterial()

		for _,data in pairs(paintBeamCache) do
			local time = CurTime()
			local deadline = (data[5] + cooldown_time)
			if (time > deadline) then
				table.remove(paintBeamCache, 1)
			continue end

			local start, finish, color = data[1], (data[2] - data[3]), colors[data[4]]
			render.DrawBeam(start, finish, 5, 0, 1, color)
		end

		render.OverrideDepthEnable(false)
	end
	hook.Add("PreDrawOpaqueRenderables", "sm_paintbeam", PaintBeam)

	local function PaintSpammer()
		if vgui.CursorVisible() then return end
		if cooldown > RealTime() then return end

		cooldown = RealTime() + cooldown_time

		local isPressing = input.IsButtonDown( keyCode )
		if !isPressing then return end

		RunConsoleCommand( "sm_paint" )
	end
	hook.Add( "Think", "surf_Paint.Spammer", PaintSpammer )
end
