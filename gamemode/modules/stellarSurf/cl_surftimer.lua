--[[
	Author: Niflheimrx
	Description: SurfTimer menu. Rewritten to match the new design and essentially modernize it.
--]]

SurfTimer = {}
SurfTimer.Size = { [0] = { 625, 525 }, [1] = { 800, 700 } }
SurfTimer.CustomSize = { [0] = { 350, 250 }, [1] = { 575, 375 } }

local customText = {
	[1] = "You can change this theme's settings with !custom",
	[2] = "Colors used on this theme can also be used on the Prestige Theme",
	[3] = "You can also apply Custom SMPanels Scheme Colors inside DevTools",
}

local themeWarningText = {
	[1] = "This theme is not actively maintained anymore",
	[2] = "This means that it may be missing modern elements from other themes",
	[3] = "It may also cause issues with other plugins, proceed with caution!"
}

local themeOptions = {
	[1] = "Modern",
	[2] = "Flow",
	[3] = "Simple",
	[4] = "Stellar",
	[5] = "Prestige",
	[6] = "Custom",
	[7] = "No-Draw"
}

local enumeratorOptions = {
	[1] = "Zero",
	[2] = "One",
	[3] = "Two",
	[4] = "Three",
	[5] = "Four"
}

local comparisonOptions = {
	[1] = "None",
	[2] = "PB",
	[3] = "WR",
	[4] = "Display Both",
}

local sideTimerOptions = {
	[1] = "Left",
	[2] = "Right"
}

local showKeysOptions = {
	[1] = "Center",
	[2] = "Bottom Right"
}

local opacityOptions = {
	[1] = "0%",
	[2] = "25%",
	[3] = "50%",
	[4] = "75%",
	[5] = "100%"
}

local chatTickOptions = {
	[1] = "warning",
	[2] = "buttonclick",
	[3] = "buttonrelease",
	[4] = "buttonrollover",
	[5] = "hint",
	[6] = "bell",
	[7] = "blip",
	[8] = "click",
	[9] = "downloaded",
	[10] = "balloon",
	[11] = "lowammo",
	[12] = "beep",
	[13] = "message",
	[14] = "switch",
	[15] = "tick",
	[16] = "disable"
}

local chatTickPointer = {
	["warning"] = "resource/warning.wav",
	["buttonclick"] = "ui/buttonclick.wav",
	["buttonrelease"] = "ui/buttonclickrelease.wav",
	["buttonrollover"] = "ui/buttonrollover.wav",
	["hint"] = "ui/hint.wav",
	["bell"] = "buttons/bell1.wav",
	["blip"] = "buttons/blip2.wav",
	["click"] = "garrysmod/ui_click.wav",
	["downloaded"] = "garrysmod/content_downloaded.wav",
	["balloon"] = "garrysmod/balloon_pop_cute.wav",
	["lowammo"] = "common/warning.wav",
	["beep"] = "tools/ifm/beep.wav",
	["message"] = "friends/message.wav",
	["switch"] = "buttons/lightswitch2.wav"
}

local footstepOptions = {
	[1] = "No Footsteps",
	[2] = "All Footsteps",
	[3] = "Local Footsteps"
}

local paintOptions = {
	[1] = "red",
	[2] = "black",
	[3] = "blue",
	[4] = "brown",
	[5] = "cyan",
	[6] = "green",
	[7] = "orange",
	[8] = "pink",
	[9] = "purple",
	[10] = "white",
	[11] = "yellow"
}

local timeScaleOptions = {
	[1] = "0.25",
	[2] = "0.50",
	[3] = "0.75",
	[4] = "1.00",
	[5] = "1.50",
	[6] = "2.00",
	[7] = "2.50",
	[8] = "3.00",
	[9] = "4.00",
	[10] = "5.00"
}

local emitSoundOptions = {
	[1] = "bongo",
	[2] = "country",
	[3] = "cuban",
	[4] = "dust",
	[5] = "dusttwo",
	[6] = "dustthree",
	[7] = "flamenco",
	[8] = "latin",
	[9] = "mirame",
	[10] = "piano",
	[11] = "pianotwo",
	[12] = "radio",
	[13] = "guit",
	[14] = "bubblegum",
	[15] = "stop"
}

local chatColorPaletteOptions = {
	[1] = "Ocean",
	[2] = "Sakura",
	[3] = "Liquid",
	[4] = "Magma"
}

local recordSoundOptions = {
	[1] = "Classic",
	[2] = "Melodic",
	[3] = "Modern"
}

local panel = nil
function SurfTimer.Open()
	if panel and IsValid( panel ) then panel:Remove() end
	panel = nil

	local size = SurfTimer.Size[Interface.Scale]
	panel = SMPanels.MultiHoverFrame( { title = "SurfTimer Menu", subTitle = "Configure your SurfTimer how you want it", center = true, w = size[1], h = size[2], pages = { "Timer", "Client", "Donator", "About" } } )

	timer.Simple( 0.5, function() panel.RunAlphaTest = true end )
	panel.ThinkCompare = 0

	panel.Think = function()
		if !panel.RunAlphaTest then return end

		if panel:IsHovered() then
			if (panel.ThinkCompare == 1) then return end
			panel.ThinkCompare = 1

			panel:AlphaTo( 255, 0.2, 0, function() end )
		elseif panel:IsChildHovered() then
			if (panel.ThinkCompare == 2) then return end
			panel.ThinkCompare = 2

			panel:AlphaTo( 255, 0.2, 0, function() end )
		else
			if (panel.ThinkCompare == 3) then return end
			panel.ThinkCompare = 3

			panel:AlphaTo( 50, 0.2, 0, function() end )
		end
	end

	local bezel = Interface:GetBezel( "Medium" )
	local padSize = SMPanels.ConvarSize[Interface.Scale]
	local boxSize = SMPanels.GenericSize[Interface.Scale]
	local barSize = SMPanels.BarSize[Interface.Scale]
	local fontHeight = Interface.FontHeight[Interface.Scale]

	-- Client Tab --
	do
		local function CustomNotify()
			SMPanels.ContentFrame( { parent = panel, title = "Custom Theme Notice", center = true, content = customText } )
		end

		local function ThemeWarningNotify()
			SMPanels.ContentFrame( { parent = panel, title = "Legacy Theme Notice", center = true, content = themeWarningText } )
		end

		local panParent = panel.Pages[1]

		function SurfTimer.ChangeTheme( int )
			local themeSkin = themeOptions[int]
			if !themeSkin then return end

			if (int == 2) then
				ThemeWarningNotify()
			end

			if (int == 4) or (int == 5) or (int == 6) then
				CustomNotify()
			end

			RunConsoleCommand( "sl_theme", tostring(int - 1) )

			Link:Print( "Surf Timer", "Your theme has been changed to " .. themeSkin .. "" )
		end

		function SurfTimer.ChangeEnumerator( int )
			local enumatorValue = enumeratorOptions[int]
			if !enumatorValue then return end

			RunConsoleCommand( "sl_enumerator", tostring(int - 1) )

			Link:Print( "Surf Timer", "Your decimal count has been set to " .. enumatorValue .. " points" )
		end

		function SurfTimer.ChangeComparison( int )
			local comparisonValue = comparisonOptions[int]
			if !comparisonValue then return end

			RunConsoleCommand( "sl_comparison_type", tostring(int - 1) )

			Link:Print( "Surf Timer", "Your comparison type has been set to " .. comparisonValue )
		end

		function SurfTimer.ChangeSideTimerPosition( int )
			local sideTimerValue = sideTimerOptions[int]
			if !sideTimerValue then return end

			RunConsoleCommand( "sl_sidetimer_pos", tostring(int - 1) )

			Link:Print( "Surf Timer", "Your SideTimer Position has been set to the " .. sideTimerValue .. " side" )
		end

		function SurfTimer.ChangeShowKeysPosition( int )
			local showKeysValue = showKeysOptions[int]
			if !showKeysValue then return end

			RunConsoleCommand( "sl_showkeys_pos", tostring(int - 1) )

			Link:Print( "Surf Timer", "Your ShowKeys Position has been moved towards the " .. showKeysValue )
		end

		function SurfTimer.ChangeChatColorPalette( int )
			local paletteValue = chatColorPaletteOptions[int]
			if !paletteValue then return end

			RunConsoleCommand( "sl_chattheme", tostring(int - 1) )

			Link:Print( "Surf Timer", "Your Chat Color Palette has been set to " .. paletteValue )
			timer.Simple( 0, function()
				Link:ProcessMessage( "Your chat message will display like this:\n", "#CL.Yellow#", "A player's name ", "#CL.Blue#", "9334", #CL.White, " as a number ", "#CL.Green#", "An object"  )
			end )
		end

		function SurfTimer.ChangeRecordSound( int )
			local recordValue = recordSoundOptions[int]
			if !recordValue then return end

			RunConsoleCommand( "sl_sound_theme", tostring(int - 1) )
			WRSound.Play(1, 1, int - 1)

			Link:Print( "Surf Timer", "Your Record Soundtrack has been set to " .. recordValue )
		end

		function SurfTimer.ChangeHUDOpacity(int)
			local opacityValue = opacityOptions[int]
			if !opacityValue then return end

			local realValue = math.ceil(64 * (int - 1))
			if (realValue > 255) then
				realValue = 255
			elseif (int == 1) then
				realValue = 0
			end

			Timer:SetOpacity(realValue)
		end

		local function OpenDevTools()
			panel.RunAlphaTest = false
			panel:AlphaTo( 0, 0.4, 0, function() end )
			panel:SetMouseInputEnabled( false )
			panel:SetKeyboardInputEnabled( false )

			DevTools:Open()

			timer.Simple( 0.5, function()
				panel:Remove()
				panel = nil
			end )
		end

		SMPanels.SettingBox( { parent = panParent, x = bezel, y = bezel, text = "Show User Interface", convar = "sl_showgui", tip = "Toggles the user interface visibility" } )
		SMPanels.SettingBox( { parent = panParent, x = bezel, y = bezel + ( padSize * 1 ), text = "Show Prestrafes", convar = "sl_prestrafe", tip = "Toggles the visibility of the prestrafe value in your timer" } )
		SMPanels.SettingBox( { parent = panParent, x = bezel, y = bezel + ( padSize * 2 ), text = "Enable Record Sounds", convar = "sl_sound", tip = "Toggles the record sounds on the server" } )
		SMPanels.SettingBox( { parent = panParent, x = bezel, y = bezel + ( padSize * 3 ), text = "Use 2D Velocity", convar = "sl_velocitytype", tip = "If enabled, shows the velocity units in 2D space, otherwise it's shown as 3D" } )
		SMPanels.SettingBox( { parent = panParent, x = bezel, y = bezel + ( padSize * 4 ), text = "Show Spectators", convar = "sl_showspec", tip = "Toggles the visibility of the spectator listings" } )
		SMPanels.SettingBox( { parent = panParent, x = bezel, y = bezel + ( padSize * 5 ), text = "Show Keys", convar = "sl_showkeys", tip = "Toggles the visibility of the showkeys plugin" } )
		SMPanels.SettingBox( { parent = panParent, x = bezel, y = bezel + ( padSize * 6 ), text = "Show SideTimer", convar = "sl_sidetimer", tip = "Toggles the visibility of the SideTimer plugin" } )
		SMPanels.SettingBox( { parent = panParent, x = bezel, y = bezel + ( padSize * 7 ), text = "Show Velocity Bar", convar = "sl_velocitybar", tip = "Toggles the visibility of the velocity bar inside your unit space" } )
		SMPanels.SettingBox( { parent = panParent, x = bezel, y = bezel + ( padSize * 8 ), text = "Show Checkpoint HUD", convar = "sl_checkpoint_hud", tip = "Displays Checkpoint time and difference in the middle of the screenspace" } )
		SMPanels.SettingBox( { parent = panParent, x = bezel, y = bezel + ( padSize * 9 ), text = "Show Units in Center", convar = "sl_velocity_center", tip = "Displays the unit velocity in the middle of the screenspace" } )
		SMPanels.SettingBox( { parent = panParent, x = bezel, y = bezel + ( padSize * 10 ), text = "Show Total Time", convar = "sl_totaltime", tip = "Messages you the total time of your run when completing a stage" } )
		SMPanels.SettingBox( { parent = panParent, x = bezel, y = bezel + ( padSize * 11 ), text = "Use Global Checkpoints", convar = "sl_globalcheckpoints", tip = "Toggles the checkpoint type on the saveloc plugin" } )
		SMPanels.SettingBox( { parent = panParent, x = bezel, y = bezel + ( padSize * 12 ), text = "Show Speed Stats", convar = "sl_speedstats", tip = "Toggles the visibility of Speed Stats when completing a zone" } )
		SMPanels.SettingBox( { parent = panParent, x = bezel, y = bezel + ( padSize * 13 ), text = "Show Special Ranks", convar = "sl_special_ranks", tip = "Displays players' special ranks whenever possible" } )
		SMPanels.SettingBox( { parent = panParent, x = bezel, y = bezel + ( padSize * 14 ), text = "Enable Strafe Trainer", convar = "sm_strafetrainer", tip = "Enables the strafetrainer display" } )

		local tmSize = panParent:GetWide() - Interface:GetTextWidth( { "Change Theme" }, Interface:GetFont() )
		local emSize = panParent:GetWide() - Interface:GetTextWidth( { "Set Decimal Count" }, Interface:GetFont() )
		local cpSize = panParent:GetWide() - Interface:GetTextWidth( { "Set Comparison Type" }, Interface:GetFont() )
		local stSize = panParent:GetWide() - Interface:GetTextWidth( { "Set SideTimer Position" }, Interface:GetFont() )
		local dtSize = panParent:GetWide() - Interface:GetTextWidth( { "Open DevTools" }, Interface:GetFont() )
		local skSize = panParent:GetWide() - Interface:GetTextWidth( { "Set ShowKeys Position" }, Interface:GetFont() )
		local ctSize = panParent:GetWide() - Interface:GetTextWidth( { "Set Chat Color Palette" }, Interface:GetFont() )
		local srSize = panParent:GetWide() - Interface:GetTextWidth( { "Set Record Sound Theme" }, Interface:GetFont() )
		local hoSize = panParent:GetWide() - Interface:GetTextWidth( { "Set HUD Opacity" }, Interface:GetFont() )

		SMPanels.MultiButton( { parent = panParent, text = "Change Theme", tip = "Changes the look of your Timer/GUI menus", select = themeOptions, func = SurfTimer.ChangeTheme, x = tmSize - bezel, y = bezel, norep = true } )
		SMPanels.MultiButton( { parent = panParent, text = "Set Decimal Count", tip = "Determines what the timer will round nearest to", select = enumeratorOptions, func = SurfTimer.ChangeEnumerator, x = emSize - bezel, y = bezel + (boxSize * 1), norep = true } )
		SMPanels.MultiButton( { parent = panParent, text = "Set Comparison Type", tip = "Determines what your timer will compare to in runs", select = comparisonOptions, func = SurfTimer.ChangeComparison, x = cpSize - bezel, y = bezel + (boxSize * 2), norep = true } )
		SMPanels.MultiButton( { parent = panParent, text = "Set SideTimer Position", tip = "Changes the position of the SideTimer text", select = sideTimerOptions, func = SurfTimer.ChangeSideTimerPosition, x = stSize - bezel, y = bezel + (boxSize * 3), norep = true } )
		SMPanels.MultiButton( { parent = panParent, text = "Set ShowKeys Position", tip = "Changes the position of your ShowKeys icons/text", select = showKeysOptions, func = SurfTimer.ChangeShowKeysPosition, x = skSize - bezel, y = bezel + (boxSize * 4), norep = true } )
		SMPanels.MultiButton( { parent = panParent, text = "Set Chat Color Palette", tip = "Changes the color palette for colored server chat messages", select = chatColorPaletteOptions, func = SurfTimer.ChangeChatColorPalette, x = ctSize - bezel, y = bezel + ( boxSize * 5 ), norep = true } )
		SMPanels.MultiButton( { parent = panParent, text = "Set Record Sound Theme", tip = "Changes the record soundtrack for your runs", select = recordSoundOptions, func = SurfTimer.ChangeRecordSound, x = srSize - bezel, y = bezel + ( boxSize * 6 ), norep = true } )
		SMPanels.MultiButton( { parent = panParent, text = "Set HUD Opacity", tip = "Changes how transparent your HUD will appear", select = opacityOptions, func = SurfTimer.ChangeHUDOpacity, x = hoSize - bezel, y = bezel + ( boxSize * 7 ), norep = true } )

		SMPanels.Button( { parent = panParent, text = "Open DevTools", tip = "Opens the DevTools experimental menu", func = OpenDevTools, scale = true, x = dtSize - bezel, y = bezel + (boxSize * 8) } )
	end

	-- Timer Tab --
	do
		local panParent = panel.Pages[2]
		local chattickButton = nil
		local footstepButton = nil

		function SurfTimer.ChangeChatTick( int )
			local chatTickValue = chatTickOptions[int]
			if !chatTickValue then return end

			chattickButton:SetText( "Set Chat Tick" )
			RunConsoleCommand( "sl_chattick", chatTickValue )

			Link:Print( "Surf Timer", "Your chat tick sound is set to " .. chatTickValue )
			if chatTickPointer[chatTickValue] then
				surface.PlaySound( chatTickPointer[chatTickValue] )
			else
				if (chatTickValue == "disable") then return end

				chat.PlaySound()
			end
		end

		function SurfTimer.ChangeFootstep( int )
			local footStepValue = footstepOptions[int]
			if !footStepValue then return end

			footstepButton:SetText( "Set Footstep Preference" )
			RunConsoleCommand( "sl_footsteps", tostring(int - 1) )

			Link:Print( "Surf Timer", "Your Footstep Preference has been set to " .. footStepValue )
		end

		local function ToggleMulticore()
			local multicoreValue = GetConVar("gmod_mcore_test"):GetBool()
			if multicoreValue then
				RunConsoleCommand( "gmod_mcore_test", "0" )
				RunConsoleCommand( "cl_threaded_bone_setup", "0" )
				RunConsoleCommand( "mat_queue_mode", "1" )
			else
				RunConsoleCommand( "gmod_mcore_test", "1" )
				RunConsoleCommand( "cl_threaded_bone_setup", "1" )
				RunConsoleCommand( "mat_queue_mode", "-1" )
			end

			Link:Print( "Surf Timer", "Multicore Rendering has been " .. (not multicoreValue and "Enabled" or "Disabled" ) )
		end

		SMPanels.SettingBox( { parent = panParent, x = bezel, y = bezel, text = "Render 3D Sky", convar = "r_3dsky", tip = "Renders the 3D skybox on maps which contain them. Disabling this will drastically improve your fps under certain scenarios" } )
		SMPanels.SettingBox( { parent = panParent, x = bezel, y = bezel + ( padSize * 1 ), text = "Render Other Players", convar = "sl_showothers", tip = "Renders other players on the server. Disabling this will improve your fps if your graphics card struggles with player animations" } )
		SMPanels.SettingBox( { parent = panParent, x = bezel, y = bezel + ( padSize * 2 ), text = "Render Water Reflections", convar = "r_waterdrawreflection", tip = "Renders the water reflections. Disabling this will improve your fps on water-heavy maps" } )
		SMPanels.SettingBox( { parent = panParent, x = bezel, y = bezel + ( padSize * 3 ), text = "Render Speculars", convar = "mat_specular", tip = "Renders the specularity for perf testing. Disabling this will drastically improve your fps under heavy reflective maps" } )
		SMPanels.SettingBox( { parent = panParent, x = bezel, y = bezel + ( padSize * 4 ), text = "Use Increased Gamma", convar = "mat_monitorgamma_tv_enabled", tip = "Increases the overall brightness by increasing the gamma." } )
		SMPanels.SettingBox( { parent = panParent, x = bezel, y = bezel + ( padSize * 5 ), text = "Compress Textures", convar = "mat_compressedtextures", tip = "Compress all texture materials. This doesn't affect performance in most cases." } )
		SMPanels.SettingBox( { parent = panParent, x = bezel, y = bezel + ( padSize * 6 ), text = "Render Zones", convar = "sl_showzones", tip = "Renders the zone boxes. Disabling this might improve your fps on maps with overbuffered entities" } )
		SMPanels.SettingBox( { parent = panParent, x = bezel, y = bezel + ( padSize * 7 ), text = "Render Extra Zones", convar = "sl_showaltzones", tip = "Similar to Render Zones but adds more zones to the render list which are normally not shown by default" } )
		SMPanels.SettingBox( { parent = panParent, x = bezel, y = bezel + ( padSize * 8 ), text = "Render Target IDs", convar = "sl_targetids", tip = "Renders the targetid text when looking at a player. This is enabled by default" } )
		SMPanels.SettingBox( { parent = panParent, x = bezel, y = bezel + ( padSize * 9 ), text = "Render Derma Blurs", convar = "sl_blur", tip = "Renders the blur animation when opening a derma panel. Disabling this will improve your fps" } )
		SMPanels.SettingBox( { parent = panParent, x = bezel, y = bezel + ( padSize * 10 ), text = "Display Server Messages", convar = "sl_printchat", tip = "Shows server messages in chat. This should normally be on by default. This does not disable the chat" } )
		SMPanels.SettingBox( { parent = panParent, x = bezel, y = bezel + ( padSize * 11 ), text = "Render Developer Bloom", convar = "sl_forcebloom", tip = "DEVELOPER USE ONLY | Renders the bloom used on the sandbox engine" } )
		SMPanels.SettingBox( { parent = panParent, x = bezel, y = bezel + ( padSize * 12 ), text = "Render Developer Blur", convar = "sl_forcemotion", tip = "DEVELOPER USE ONLY | Renders the motion blur used on the sandbox engine" } )
		SMPanels.SettingBox( { parent = panParent, x = bezel, y = bezel + ( padSize * 13 ), text = "Render Developer Focus", convar = "sl_forcefocus", tip = "DEVELOPER USE ONLY | Renders the toytown vision used on the sandbox engine" } )
		SMPanels.SettingBox( { parent = panParent, x = bezel, y = bezel + ( padSize * 14 ), text = "Render Developer Bokeh", convar = "pp_bokeh", tip = "DEVELOPER USE ONLY | Renders the bokeh effect used on the sandbox engine" } )

		local mcSize = panParent:GetWide() - Interface:GetTextWidth( { "Toggle Multicore Rendering" }, Interface:GetFont() )
		local ctSize = panParent:GetWide() - Interface:GetTextWidth( { "Set Chat Tick" }, Interface:GetFont() )
		local fsSize = panParent:GetWide() - Interface:GetTextWidth( { "Set Footstep Preference" }, Interface:GetFont() )

		SMPanels.Button( { parent = panParent, text = "Toggle Multicore Rendering", tip = "Enables/Disables the new multicore rendering engine", func = ToggleMulticore, scale = true, x = mcSize - bezel, y = bezel } )
		chattickButton = SMPanels.MultiButton( { parent = panParent, text = "Set Chat Tick", tip = "Changes the sound that is played when a new chat message appears", select = chatTickOptions, func = SurfTimer.ChangeChatTick, x = ctSize - bezel, y = bezel + (boxSize * 1) } )
		footstepButton = SMPanels.MultiButton( { parent = panParent, text = "Set Footstep Preference", tip = "Determines when player footsteps should be played", select = footstepOptions, func = SurfTimer.ChangeFootstep, x = fsSize - bezel, y = bezel + (boxSize * 2) } )
	end


	-- Donator Tab --
	do
		local panParent = panel.Pages[3]

		local paintColorButton = nil
		local timeScaleButton = nil
		local emitSoundButton = nil

		function SurfTimer.ChangePaintColor( int )
			local paintColor = paintOptions[int]
			if !paintColor then return end

			paintColorButton:SetText( "Paint Color" )
			RunConsoleCommand( "say", "/paintcolor " .. paintColor )
		end

		function SurfTimer.ChangeTimescale( int )
			local timeScale = timeScaleOptions[int]
			if !timeScale then return end

			timeScaleButton:SetText( "Timescale Value" )
			RunConsoleCommand( "say", "/timescale " .. timeScale )
		end

		function SurfTimer.DoEmitSound( int )
			local emitSound = emitSoundOptions[int]
			if !emitSound then return end

			emitSoundButton:SetText( "Emit Sound" )
			RunConsoleCommand( "say", "/emitsound " .. emitSound )
		end

		local function OpenVIPMenu()
			panel.RunAlphaTest = false
			panel:AlphaTo( 0, 0.4, 0, function() end )
			panel:SetMouseInputEnabled( false )
			panel:SetKeyboardInputEnabled( false )

			RunConsoleCommand( "say", "/vip" )

			timer.Simple( 0.5, function()
				panel:Remove()
				panel = nil
			end )
		end

		local function ToggleVIP()
			Link:Send( "Admin", { -2, 34, nil } )
		end

		local isVIP = LocalPlayer():GetNWBool( "VIPStatus" )
		if !isVIP then
			panParent.Paint = function( self, w, h )
				draw.SimpleText( "This requires a donator subscription running", Interface:GetFont(), bezel, bezel, color_white )
				draw.SimpleText( "You can donate to the server by using !donate", Interface:GetFont(), bezel, bezel + (fontHeight * 1), color_white )

				draw.SimpleText( "Cool benefits include:", Interface:GetFont(), bezel, bezel + (fontHeight * 3), color_white )
				draw.SimpleText( "• Custom Name/Rank with Custom Colors", Interface:GetFont(), bezel, bezel + (fontHeight * 4), color_white )
				draw.SimpleText( "• Paint Functionality", Interface:GetFont(), bezel, bezel + (fontHeight * 5), color_white )
				draw.SimpleText( "• Server Join Priority", Interface:GetFont(), bezel, bezel + (fontHeight * 6), color_white )
				draw.SimpleText( "• Early access to new features", Interface:GetFont(), bezel, bezel + (fontHeight * 7), color_white )
				draw.SimpleText( "• The feeling that you helped this server running", Interface:GetFont(), bezel, bezel + (fontHeight * 8), color_white )
			end
		else
			local tsSize = panParent:GetWide() - Interface:GetTextWidth( { "Timescale Value" }, Interface:GetFont() )
			local esSize = panParent:GetWide() - Interface:GetTextWidth( { "Emit Sound" }, Interface:GetFont() )

			paintColorButton = SMPanels.MultiButton( { parent = panParent, text = "Paint Color", tip = "Determines what paint color will be used when using sm_paint in console", select = paintOptions, func = SurfTimer.ChangePaintColor, x = bezel, y = bezel } )

			timeScaleButton = SMPanels.MultiButton( { parent = panParent, text = "Timescale Value", tip = "Changes how long the engine processes your movement", select = timeScaleOptions, func = SurfTimer.ChangeTimescale, x = tsSize - bezel, y = bezel } )
			emitSoundButton = SMPanels.MultiButton( { parent = panParent, text = "Emit Sound", tip = "Plays a sound that nearby players can hear", select = emitSoundOptions, func = SurfTimer.DoEmitSound, x = esSize - bezel, y = bezel + (boxSize * 1) } )

			SMPanels.Button( { parent = panParent, text = "Open VIP Menu", tip = "Opens the donator menu", func = OpenVIPMenu, scale = true, x = bezel, y = bezel + (boxSize * 1) } )
			SMPanels.Button( { parent = panParent, text = "Toggle VIP Visibility", tip = "Determines if your VIP status (such as name/color/rank) should be displayed to everyone", func = ToggleVIP, scale = true, x = bezel, y = bezel + (boxSize * 2) } )
			SMPanels.Button( { parent = panParent, text = "Open Custom Scheme Menu", tip = "Opens the customization menu for your HUD", func = SurfTimer.OpenCustomMenu, scale = true, x = bezel, y = bezel + (boxSize * 3) } )
		end
	end

	-- About Tab --
	do
		local panParent = panel.Pages[4]
		local function openNifsProfile()
			gui.OpenURL( "https://steamcommunity.com/profiles/76561198089794192" )
		end

		local function openHelp()
			panel.RunAlphaTest = false
			panel:AlphaTo( 0, 0.4, 0, function() end )
			panel:SetMouseInputEnabled( false )
			panel:SetKeyboardInputEnabled( false )

			Help:Open()

			timer.Simple( 0.5, function()
				panel:Remove()
				panel = nil
			end )
		end

		local pcSize = panParent:GetWide() - Interface:GetTextWidth( { "Print Commands" }, Interface:GetFont() )

		panParent.Paint = function( self, w, h )
			draw.SimpleText( "This server runs the latest version of Flow Network (ver. " .. tostring( _C.Version ) .. ")", Interface:GetFont(), bezel, bezel, color_white )
			draw.SimpleText( "Niflheimrx is the maintainer of this gamemode, their profile is listed below", Interface:GetFont(), bezel, bezel + (fontHeight * 1), color_white )
			draw.SimpleText( "Big thanks to those who have supported this project since the beginning", Interface:GetFont(), bezel, bezel + (fontHeight * 2), color_white )

			draw.SimpleText( "Quick command list (most commonly used):", Interface:GetFont(), bezel, bezel + (fontHeight * 4), color_white )
			draw.SimpleText( "• !restart - Takes you to the start of the map", Interface:GetFont(), bezel, bezel + (fontHeight * 5), color_white )
			draw.SimpleText( "• !tele - Takes you to the start of the stage or map", Interface:GetFont(), bezel, bezel + (fontHeight * 6), color_white )
			draw.SimpleText( "• !styles - Gives you a list of styles to select from", Interface:GetFont(), bezel, bezel + (fontHeight * 7), color_white )
			draw.SimpleText( "• !nominate - Gives you a list of maps available on the server", Interface:GetFont(), bezel, bezel + (fontHeight * 8), color_white )
			draw.SimpleText( "• !mapinfo - Gives you a quick information about the current map", Interface:GetFont(), bezel, bezel + (fontHeight * 9), color_white )
			draw.SimpleText( "• !wr - Displays the current record holder on the current map in chat", Interface:GetFont(), bezel, bezel + (fontHeight * 10), color_white )
			draw.SimpleText( "• !mrank - Displays the rank you have on the current map", Interface:GetFont(), bezel, bezel + (fontHeight * 11), color_white )
			draw.SimpleText( "• !rtv - Places your vote to change the current map to something else", Interface:GetFont(), bezel, bezel + (fontHeight * 12), color_white )
			draw.SimpleText( "• !profile - Opens a panel that contains your surf profile stats", Interface:GetFont(), bezel, bezel + (fontHeight * 13), color_white )
		end

		SMPanels.Button( { parent = panParent, text = "Open maintainer's profile", tip = "Opens the developer's Steam Community Profile", func = openNifsProfile, scale = true, x = bezel, y = panParent:GetTall() - boxSize } )
		SMPanels.Button( { parent = panParent, text = "Open Help Menu", tip = "Opens the help menu that is displayed on a new player's join", func = openHelp, scale = true, x = pcSize - bezel, y = panParent:GetTall() - boxSize } )
	end
end

function SurfTimer.OpenCustomMenu()
	if panel and IsValid( panel ) then panel:Remove() end
	panel = nil

	local size = SurfTimer.CustomSize[Interface.Scale]
	panel = SMPanels.HoverFrame( { title = "Custom Scheme Menu", subTitle = "Customize your SurfTimer Experience", center = true, w = size[1], h = size[2] } )

	local writeable = panel.Page
	local bezel = Interface:GetBezel( "Medium" )
	local padSize = SMPanels.ConvarSize[Interface.Scale]

	local currentColor = Color( GetConVar( "sl_custom_r" ):GetInt(), GetConVar( "sl_custom_g" ):GetInt(), GetConVar( "sl_custom_b" ):GetInt())
	SMPanels.ColorPalette( { parent = writeable, x = bezel, y = bezel, w = 200, h = 120, convar = "sl_custom_", default = currentColor } )

	SMPanels.SettingBox( { parent = writeable, x = bezel, y = bezel + 100 + (padSize * 1), text = "Enable Color Accents", convar = "sl_custom_accent", tip = "Fills the entire menu render with an additional color layer" } )
	SMPanels.SettingBox( { parent = writeable, x = bezel, y = bezel + 100 + (padSize * 2), text = "Enable Rainbow Mode", convar = "sl_custom_rainbow", tip = "Dynamically changes the colors to fully transition through the entire color spectrum" } )
	SMPanels.SettingBox( { parent = writeable, x = bezel, y = bezel + 100 + (padSize * 3), text = "Enable Prestige Customization", convar = "sl_custom_prestige", tip = "Allows the Prestige theme to fully take advantage of the custom colors" } )

	local CSHUDLabel = vgui.Create( "DLabel", writeable )
	CSHUDLabel:SetSize( 350, 220 )
	CSHUDLabel:SetPos( 300, bezel )
	CSHUDLabel:SetText( "Theme Preview" )
	CSHUDLabel.Paint = function( _, w, h )
		local previewColor = Color( 0, 0, 0, 110 )
		if GetConVar( "sl_custom_accent" ):GetBool() then
			previewColor = Color( Custom.r, Custom.g, Custom.b, 30 )
		end

		draw.RoundedBox( 8, 0, 0, 230, 95, previewColor )
		draw.SimpleText( "Time:", "HUDTimer", 0 + 12, 0 + 20, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		draw.SimpleText( "PB:", "HUDTimer", 0 + 12, 0 + 45, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		draw.SimpleText( Timer:Convert( LocalPlayer():GetNWFloat( "Record", 0 ) ), "HUDTimer", 0 + 64 + 12, 0 + 20, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		draw.SimpleText( Timer:Convert( LocalPlayer():GetNWFloat( "Record", 0 ) ), "HUDTimer", 0 + 64 + 12, 0 + 45, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
		draw.SimpleText( "3500 u/s", "HUDSpeed", 0 + 115, 0 + 73, Color(255, 255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		draw.RoundedBox( 0, 0 + 12, 0 + 83, 206, 1, Color( Custom.r, Custom.g, Custom.b, 255 ) )
	end
end
