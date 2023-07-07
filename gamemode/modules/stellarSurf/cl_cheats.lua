--[[
	Author: Niflheimrx
	Description: Use specific cheat commands without the need of sv_cheats
--]]

Cheats = {}

-- Fullbright Controller and Toggle --
do
	Cheats.Fullbright = false

	function Cheats.ToggleFullbright(supress)
		Cheats.Fullbright = !Cheats.Fullbright

		if !supress then
			Link:Print( "Surf Timer", {"Fullbright state: ", CL.Yellow, Cheats.Fullbright and "ON" or "OFF"})
		end
	end

	-- These hooks control most of the fullbright work, it prevents flickering when enabled --
	hook.Add("PreRender", "sm_fullbright", function()
		if !Cheats.Fullbright then
			render.SetLightingMode(0)
		return end

		render.SetLightingMode(1)
		render.SuppressEngineLighting(false)
	end)

	hook.Add("PostRender", "sm_fullbright", function()
		render.SetLightingMode(0)
		render.SuppressEngineLighting(false)
	end)

	hook.Add("PreDrawHUD", "sm_fullbright_hudfix", function()
		render.SetLightingMode(0)
	end)

	hook.Add("PreDrawEffects", "sm_fullbright_effectfix", function()
		if !Cheats.Fullbright then return end

		render.SetLightingMode(0)
	end)

	hook.Add("PostDrawEffects", "sm_fullbright_effectfix", function()
		if !Cheats.Fullbright then return end

		render.SetLightingMode(0)
	end)

	hook.Add("PreDrawOpaqueRenderables", "sm_fullbright_opaquefix", function()
		if !Cheats.Fullbright then return end

		render.SetLightingMode(0)
	end)

	hook.Add("PostDrawTranslucentRenderables", "sm_fullbright_transluscentfix", function()
		if !Cheats.Fullbright then return end

		render.SetLightingMode(0)
	end)

	-- This one is an edge case scenario where maps with lots of water can disable fullbright --
	hook.Add("SetupWorldFog", "sm_fullbright_forcebrightworld", function()
		if !Cheats.Fullbright then return end

		render.SuppressEngineLighting(true)
		render.SetLightingMode(1)
		render.SuppressEngineLighting(false)
	end)

	-- This will allow players to toggle fullbright when they hit their flashlight key --
	hook.Add("PlayerBindPress", "sm_fullbright_flashlight", function( _, bind)
		local isValidBind = string.StartWith(bind, "impulse 100")

		if isValidBind then
			local bindingKey = input.LookupBinding(bind, true)
			local keyCode = input.GetKeyCode(bindingKey)
			local justReleased = input.WasKeyReleased(keyCode)

			if (isValidBind and !justReleased) then
				Cheats.ToggleFullbright(true)
			return true end
		end
	end)
end

-- Playerclip visibility --
-- Maps that don't work on clip visibility --
local clipDisable = {
	["surf_harmony"] = true,
}

do
	-- Don't use this module if the map has known issues --
	if clipDisable[game.GetMap()] then
		function Cheats.TogglePlayerclips() end
	return end

	Cheats.Playerclip = false

	local mappatcher_tool_font = "mappatcher_tool_font_"..os.time()
	surface.CreateFont( mappatcher_tool_font, {
			font = "Consolas",
			size = 40,
			weight = 800,
	} )

	local tool_mats_queue = {}
	hook.Add("DrawMonitors", "MapPatcher_MaterialGenerator", function()
		for k, data in pairs(tool_mats_queue) do
			local mat = data.mat
			local mat_name = data.mat_name
			local color = data.color
			local text = data.text
			local rt_tex = GetRenderTarget( mat_name, 256, 256, true )
			mat:SetTexture( "$basetexture", rt_tex )

			render.PushRenderTarget( rt_tex )

			render.SetViewPort(0, 0, 256, 256)
			render.OverrideAlphaWriteEnable( true, true )
			cam.Start2D()
					render.Clear( color.r, color.g, color.b, color.a )
					surface.SetFont( mappatcher_tool_font )
					surface.SetTextColor( 255, 255, 255, 255 )
					local txt_w, txt_h = surface.GetTextSize( text )
					surface.SetTextPos( 128 - txt_w / 2, 128 - txt_h / 2 )
					surface.DrawText( text )
					surface.SetDrawColor( 255,255,255 )
					surface.DrawOutlinedRect( 10, 10, 256-10, 256-10 )
			cam.End2D()

			render.OverrideAlphaWriteEnable( false )
			render.PopRenderTarget()
		end
		tool_mats_queue = {}
	end)

	function Cheats.GenerateToolMaterial( mat_name, color, text )
			local mat = CreateMaterial( mat_name, "UnlitGeneric", {["$vertexalpha"] = 1} )
			tool_mats_queue[#tool_mats_queue + 1] = { mat_name=mat_name, color=color, text=text, mat=mat }
			return mat
	end

	local bspData
	local function LoadInitialBSP()
		if bspData and (#bspData != 0) then return true end
		if bspData and (#bspData == 0) then return false end

		local bsp = LuaBSP.LoadMap( game.GetMap() )
		if !bsp then return false end

		bspData = bsp:GetClipBrushes()
		if bspData and (#bspData == 0) then return false end

		return true
	end

	function Cheats.TogglePlayerclips()
		if !bspData then
			Link:Print( "Surf Timer", "Reading data, this may cause your game to freeze for a moment..." )
			timer.Simple( 0.5, function()
				LoadInitialBSP()

				Cheats.TogglePlayerclips()
			end )
		return end

		local hasRan = LoadInitialBSP()
		if !hasRan then
			Link:Print( "Surf Timer", "There was an issue trying to parse the map" )
		return end

		Cheats.Playerclip = !Cheats.Playerclip
		Link:Print( "Surf Timer", "Playerclip visibility set to " .. (Cheats.Playerclip and "ON" or "OFF") )
	end

	local texHammerPlayerClip = Cheats.GenerateToolMaterial( "mappatcher_hammer_playerclip", Color(255,0,255,200), "Player Clip" )
	local function RenderPlayerClips()
		if !Cheats.Playerclip then return end

		render.SetMaterial( texHammerPlayerClip )

		for _, mesh in pairs( bspData ) do
			mesh:Draw()
		end
	end
	hook.Add( "PreDrawTranslucentRenderables", "surf_cheats.RenderPlayerClips", RenderPlayerClips )
end
