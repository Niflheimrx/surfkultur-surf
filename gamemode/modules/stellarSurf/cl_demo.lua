-- A clientsided Demo handler for use with SourceDemoRender --
-- It will output units on the bottom left along with stage times similar to what SDR uses for their unit display --

local fo, lp = string.format, LocalPlayer
local ts = _C.Team.Spectator

surface.CreateFont( "DemoFont", { size = 105, font = "Lato" } )

local chatHide = {["CHudChat"] = true}
hook.Add("HUDShouldDraw", "sm_demo_disablechat", function(name)
	if chatHide[name] and engine.IsPlayingDemo() then
		return false
	end
end)

hook.Add("HUDPaint", "sm_demo_velocity_export", function()
	if (!engine.IsPlayingDemo()) then return end

	local speed = LocalPlayer():GetVelocity():Length2D()
	draw.SimpleText(fo("%.0f", speed), "DemoFont", 60, ScrH() - 125, color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
end)
