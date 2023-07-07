--[[
	Author: Niflheimrx
	Description: Sound handler. Used mainly to play record sounds.
--]]

WRSound = {}
WRSound.Enabled = CreateClientConVar("sl_sound", 1, true, false, "Toggles the sounds in the server. Includes server record sounds, completion sounds, and improvement sounds." )
WRSound.Custom = CreateClientConVar("sl_sound_theme", 0, true, true, "Use a different kind of theme for record sounds." )

local recordCache = 0
local recordSounds = {
	["wr"] = "ambient/music/bongo.wav",
	["wr1"] = "bot/very_nice.wav",
	["top10"] = "bot/yea_baby.wav",
	["improvement"] = "bot/whos_the_man.wav",
	["generic"] = "buttons/bell1.wav",
	["bonuswr"] = "physics/glass/glass_bottle_break1.wav",
	["bonusimprovement"] = "ui/hint.wav",
	["bonusgeneric"] = "buttons/blip2.wav",
	["stagewr"] = "physics/glass/glass_bottle_break2.wav",
	["stageimprovement"] = "garrysmod/content_downloaded.wav",
	["customwr"] = "ambient/music/flamenco.wav",
	["customwr1"] = "bot/way_to_be_team.wav",
	["customtop10"] = "bot/who_wants_some_more.wav",
	["customimprovement"] = "bot/we_owned_them.wav",
	["custom2wr"] = "ambient/guit1.wav",
	["custom2wr1"] = "bot/and_thats_how_its_done.wav",
	["custom2top10"] = "bot/yesss.wav",
	["custom2improvement"] = "bot/they_will_not_escape.wav",
}

for name,dir in pairs( recordSounds ) do
	sound.Add( {
		name = name,
		channel = CHAN_STATIC,
		volume = 1.0,
		level = SNDLVL_NONE,
		pitch = 100,
		sound = dir
	} )
end

Surf:Notify( "Debug", "Registered sound files [Amount: " .. table.Count( recordSounds ) .. "]" )

function WRSound.Play( style, id, theme )
	local lpc = LocalPlayer()
	id = tonumber( id )
	theme = tonumber( theme )

	local wantsSound = WRSound.Enabled:GetBool()
	if !wantsSound then
		Surf:Notify( "Debug", "Sound module disabled, pruning event tick @" .. RealTime() )
	return end

	if !style then
		Surf:Notify( "Error", "Failed to lookup style/id variables" )
	return end

	if !theme then
		Surf:Notify( "Error", "Failed to lookup networked theme" )
	return end

	local styleName = Core:StyleName( style )
	if string.StartWith( styleName, "Bonus" ) then
		if !id then
			lpc:EmitSound "bonusgeneric"
		return end

		if (id > 1) then
			lpc:EmitSound "bonusimprovement"
		else
			lpc:EmitSound "bonuswr"
		end
	elseif (style > 14) and (style < 40) then
		if (id > 1) then
			lpc:EmitSound "stageimprovement"
		else
			lpc:EmitSound "stagewr"
		end
	else
		if !id then
			lpc:EmitSound "generic"
		return end

		if (id > 1) and (id < 11) then
			if (theme == 1) then
				lpc:EmitSound "customtop10"
			elseif (theme == 2) then
				lpc:EmitSound "custom2top10"
			else
				lpc:EmitSound "top10"
			end
		elseif (id > 10) then
			if (theme == 1) then
				lpc:EmitSound "customimprovement"
			elseif (theme == 2) then
				lpc:EmitSound "custom2improvement"
			else
				lpc:EmitSound "improvement"
			end
		else
			recordCache = CurTime()
			lpc:StopSound "wr"
			lpc:StopSound "customwr"
			lpc:StopSound "custom2wr"

			if (theme == 1) then
				lpc:EmitSound "customwr"

				timer.Simple( 6.1, function()
					if (CurTime() - recordCache) < 5.9 then return end

					lpc:StopSound "customwr"
					lpc:EmitSound "customwr1"
				end )
			elseif (theme == 2) then
				lpc:EmitSound "custom2wr"

				timer.Simple(6.5, function()
					if (CurTime() - recordCache) < 6.3 then return end

					lpc:StopSound "custom2wr"
					lpc:EmitSound "custom2wr1"
				end)
			else
				lpc:EmitSound "wr"

				timer.Simple( 4.3, function()
					if (CurTime() - recordCache) < 4.1 then return end

					lpc:StopSound "wr"
					lpc:EmitSound "wr1"
				end )
			end
		end
	end
end
