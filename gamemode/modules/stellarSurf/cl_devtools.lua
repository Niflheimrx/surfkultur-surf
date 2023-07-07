--[[
	Author: Niflheimrx
	Description: Trying something new here. Do stuff on SK you couldn't do before.
							 This is basically the equivilent of the easter egg that was on here before. But accessible to everyone now
--]]

DevTools = {}

DevTools.Size = { [0] = { 600, 400 }, [1] = { 800, 500 } }
DevTools.Version = 0.7

local description = {
	[1] = "Welcome to DevTools! This is an experimental feature",
	[2] = "You can enable experimental stuff by clicking on the tabs above",
	[3] = "Note that some features may not work properly",
	[5] = "-- NEW FEATURES --",
	[6] = "You can toggle between the old and new centerspeed display in the 'Client' tab",
	[7] = "You can show true player usernames in the 'Client' tab",
	[8] = "You can toggle command hints in the 'Client' tab"
}

local notifychange = {
	[1] = "This setting requires you to rejoin the server"
}

local simpleNetGraphOptions = {
	[1] = "Top Right",
	[2] = "Top Left",
	[3] = "Bottom Left",
	[4] = "Button Right"
}

local interfaceScaleOptions = {
	[1] = "Small",
	[2] = "Large"
}

local panel = nil
function DevTools:Open()
	if panel and IsValid( panel ) then panel:Remove() end
	panel = nil

	local size = DevTools.Size[Interface.Scale]
	local genSize = SMPanels.GenericSize[Interface.Scale]

	local bezel = Interface:GetBezel("Medium")
	panel = SMPanels.MultiHoverFrame( { title = "DevTools by Niflheimrx", subTitle = "ver. " .. DevTools.Version, center = true, w = size[1], h = size[2], pages = { "About", "Client", "Server" } } )

	-- Page 1 --
	do
		panel.Pages[1].Paint = function( _, w, h )
			for i,text in pairs( description ) do
				draw.SimpleText( text, Interface:GetFont(), Interface:GetBezel( "Medium" ), Interface:GetBezel( "Large" ) + ( Interface.FontHeight[Interface.Scale] * ( i - 1 ) ), color_white, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
			end
		end
	end

	-- Page 2 --
	do
		local function ToggleNotify()
			SMPanels.ContentFrame( { parent = panel, title = "Setting Notice", center = true, content = notifychange } )
		end

		function DevTools.ChangeNetgraphPosition( int )
			local netgraphValue = simpleNetGraphOptions[int]
			if !netgraphValue then return end

			simpleNetGraphButton:SetText( "Set Netgraph Position" )
			RunConsoleCommand( "sl_netgraphpos", tostring(int - 1) )

			Link:Print( "Surf Timer", "Your Netgraph Position has been moved towards the " .. netgraphValue )
		end

		function DevTools.ChangeInterfaceScaleSize(int)
			local interfaceScaleValue = interfaceScaleOptions[int]
			if !interfaceScaleValue then return end

			interfaceScaleButton:SetText("Set Interface Scale")
			Interface.Scale = math.Round(int - 1)

			Link:Print( "Surf Timer", "Your Interface Scale size has been set to " .. interfaceScaleValue )
		end

		local padSize = SMPanels.ConvarSize[Interface.Scale]

		SMPanels.SettingBox( { parent = panel.Pages[2], text = "Custom Chat", x = bezel, y = bezel, convar = "sl_customchat", tip = "Enables the custom chat box interface", func = ToggleNotify } )
		SMPanels.SettingBox( { parent = panel.Pages[2], text = "Simple Netgraph", x = bezel, y = bezel + ( padSize * 1 ), convar = "sl_netgraph", tip = "Enables the developer netgraph" } )
		SMPanels.SettingBox( { parent = panel.Pages[2], text = "Legacy Renderer", x = bezel, y = bezel + ( padSize * 2 ), convar = "sl_legacyrenderer", tip = "Enables the legacy view renderer" } )
		SMPanels.SettingBox( { parent = panel.Pages[2], text = "Hide Chat Ranks", x = bezel, y = bezel + ( padSize * 3 ), convar = "sl_hiderank", tip = "Disables the visibility of ranks in chat" } )
		SMPanels.SettingBox( { parent = panel.Pages[2], text = "Solid Zone Boxes", x = bezel, y = bezel + ( padSize * 4 ), convar = "sl_solidzone", tip = "Enables rendering of solid zone boxes" } )
		SMPanels.SettingBox( { parent = panel.Pages[2], text = "Custom SMPanel Schemes", x = bezel, y = bezel + ( padSize * 5 ), convar = "sl_customsurftimer", tip = "Enables Custom Colors on all SMPanel-based UIs" } )
		SMPanels.SettingBox( { parent = panel.Pages[2], text = "Smooth Noclipping", x = bezel, y = bezel + ( padSize * 6 ), convar = "sl_smoothnoclip", tip = "Enables the new smoothing noclip movement" } )
		SMPanels.SettingBox( { parent = panel.Pages[2], text = "Ultrawide Scaling", x = bezel, y = bezel + ( padSize * 7 ), convar = "sl_ultracenter", tip = "Allows the HUD to be centered on an ultrawide display", func = ToggleNotify } )
		SMPanels.SettingBox( { parent = panel.Pages[2], text = "Legacy Center Speed", x = bezel, y = bezel + ( padSize * 8 ), convar = "sl_old_centervelocity", tip = "Uses the legacy center speed module" } )
		SMPanels.SettingBox( { parent = panel.Pages[2], text = "Show True Playernames", x = bezel, y = bezel + ( padSize * 9 ), convar = "sl_displaytruename", tip = "Displays true playernames on interfaces that support this" } )
		SMPanels.SettingBox( { parent = panel.Pages[2], text = "Display Command Hints", x = bezel, y = bezel + ( padSize * 10 ), convar = "sl_command_suggest", tip = "Displays command listings and descriptions when typing out chat commands" } )

		local snSize = panel.Pages[2]:GetWide() - Interface:GetTextWidth( { "Set Netgraph Position" }, Interface:GetFont() )
		simpleNetGraphButton = SMPanels.MultiButton( { parent = panel.Pages[2], text = "Set Netgraph Position", select = simpleNetGraphOptions, func = DevTools.ChangeNetgraphPosition, x = snSize - bezel, y = bezel } )

		local inSize = panel.Pages[2]:GetWide() - Interface:GetTextWidth( { "Set Interface Scale" }, Interface:GetFont() )
		interfaceScaleButton = SMPanels.MultiButton( { parent = panel.Pages[2], text = "Set Interface Scale", select = interfaceScaleOptions, func = DevTools.ChangeInterfaceScaleSize, x = inSize - bezel, y = bezel + genSize } )
	end

	-- Page 3 --
	do
		local function ToggleTeleport()
			RunConsoleCommand( "say", "/triggersmenu" )
		end

		local function ToggleFullbright()
			RunConsoleCommand( "say", "/fullbright" )
		end

		SMPanels.Button( { parent = panel.Pages[3], text = "Toggle Fullbright Visibility", func = ToggleFullbright, scale = true, x = bezel, y = bezel } )
	end
end
