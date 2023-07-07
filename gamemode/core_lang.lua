Lang = {}

Lang.Default = "The message identifier '1;' does not exist in the language database!"
Lang.Generic = "1;"

function Lang:Get( szIdentifier, varArgs )
	if not Lang[ szIdentifier ] then
		varArgs = { szIdentifier }
		szIdentifier = "Default"
	end

	if not varArgs or not type( varArgs ) == "table" then
		varArgs = {}
	end

	local szText = Lang[ szIdentifier ]
	for nParamID, szArg in pairs( varArgs ) do
		szText = string.gsub( szText, nParamID .. ";", szArg )
	end

	return szText
end

Lang.TimerFinish = "1; completed 2; in 3;4;5;"
Lang.TimerPBFirst = "1; completed the map in 2; (Time: 3;) [Rank 4;]"
Lang.TimerPBNext = "1; completed the map in 2; (Time: 3;) Improved by 4; [Rank 5;]"
Lang.TimerWRFirst = "1; completed in the top 10 on the 2; style! (Time: 3;) [Rank 4;]"
Lang.TimerWRNext = "1; completed in the top 10 on the 2; style! (Time: 3;) Improved by 4; [Rank 5;]"
Lang.TimerRecord = "1; beat the 2; record! (Time: 3;) [Rank 4;]"
Lang.TimerRecordNext = "1; beat the 2; record! (Time: 3;) Improved by 4; [Rank 5;]"
Lang.StageRecord = "1; beat the 2; record! (Time: 3;) [Rank 4;]"
Lang.StageRecordNext = "1; beat the 2; record! (Time: 3;) Improved by 4; [Rank 5;]"
Lang.StageComplete = "1; completed 2; (Time: 3;) [Rank 4;]"
Lang.StageCompleteNext = "1; completed 2; (Time: 3;) Improved by 4; [Rank 5;]"
Lang.TimerStandings = "1; is ranked 2;/3; on 4; with a time of 5;."
Lang.StageFinish = "Completed Stage 1; in 2; (Time: 3;)"
Lang.CheckpointFinish = "Completed Checkpoint 1; (Time: 2;)"
Lang.TimerPoints = "You have obtained 1; / 2; points for 3;."

Lang.StyleEqual = "Your style is already set to 1;"
Lang.StyleChange = "Your style has been changed to 1;."
Lang.StageChange = "You have been sent to Stage 1;."
Lang.StyleNoclip = "You can only use noclip in the practice style."
Lang.StyleBonusNone = "There are no available bonus to play."
Lang.StageFinish = "You completed Stage 1; in 2;!3;4;"
Lang.StyleTeleport = "You can only teleport while in practice style."
Lang.StyleStageNone = "The desired stage number (1;) does not exist on this map."

Lang.BotEnter = "1; style replay bot has spawned."
Lang.BotDisplay = "1;'s run (Time: 2;) on 3; has been recorded and is now set to be displayed by the server record bot!"
Lang.BotInstRecord = "You are now being recorded by the server record bot1;"
Lang.BotInstFull = "You couldn't be recorded by the bot because the list is already full!"
Lang.BotClear = "You are now no longer being recorded by the bot."
Lang.BotStatus = "You are currently 1; recorded by the bot."
Lang.BotAlready = "You are already being recorded by the server record bot."
Lang.BotStyleForce = "Your 1; run wasn't recorded because this map is forced to 2; style."
Lang.BotSaving = "The server will now save the bots, prepare for some lag!"
Lang.BotMultiWait = "The bot must have at least finished playback once before it can be changed."
Lang.BotMultiInvalid = "The entered style was invalid or there are no bots for this style."
Lang.BotMultiNone = "There are no bots of different styles to display."
Lang.BotMultiError = "This style does not exist in our bot database."
Lang.BotMultiSame = "The bot is already playing this style."
Lang.BotMultiExclude = "The bot can not display the Normal style run. Check the main bot for that!"
Lang.BotMultiExcludeB = "The bot can not display the Bonus style run. Check the bonus bot for that!"
Lang.BotDetails = "The bot run was done by 1; [2;] on the 3; style in a time of 4; at this date: 5;"
Lang.BotAlways = "This server will always record any player online. Removing is not necessary."

Lang.ZoneStart = "You are now placing a zone."
Lang.ZoneFinish = "The zone has been placed."
Lang.ZoneCancel = "Zone setting has been cancelled."
Lang.ZoneNoEdit = "You are not setting any zones at the moment."
Lang.ZoneSpeed = "Max velocity exceeded. (1;)"
Lang.ZoneRestart = "You entered a restart zone so you have been set back to the start."

Lang.VotePlayer = "1; has Rocked the Vote! (2; 3; left)"
Lang.VoteStart = "A vote to change map has begun."
Lang.VoteExtend = "The vote has decided that the map is to be extended by 1; minutes!"
Lang.VoteChange = "The vote has decided that the map is to be changed to 1;! Map will change in one minute!"
Lang.VoteMissing = "The map 1; is not available on the server so it can't be played right now."
Lang.VoteLimit = "Please wait for 1; seconds before voting again."
Lang.VoteAlready = "You have already Rocked the Vote."
Lang.VotePeriod = "A map vote has already started."
Lang.VoteRevoke = "1; has revoked his Rock the Vote. (2; 3; left)"
Lang.VoteList = "1; vote(s) needed to change maps.\nVoted (2;): 3;\nHaven't voted (4;): 5;"
Lang.VoteCheck = "There are 1; 2; needed to change maps."
Lang.VoteCancelled = "The vote was cancelled by an admin, thus the map will not change."
Lang.VoteFailure = "Something went wrong while trying to change maps. Please !rtv again."
Lang.VoteVIPExtend = "The maximum number of extends (3) has been reached. You must vote for a new map."
Lang.RevokeFail = "You can not revoke your vote because you have not Rocked the Vote yet."
Lang.Nomination = "1; has nominated 2; to be played next."
Lang.NominationChange = "1; has changed his nomination from 2; to 3;"
Lang.NominationAlready = "You have already nominated this map!"
Lang.NominateOnMap = "You are currently playing this map so you can't nominate it."
Lang.MapChange = "Map changing to 1;..."

Lang.MapInfo = "The map '1;' has a weight of 2; points (3;)4; and is of type Tier 5; - 6; [Stages: 7;]"
Lang.MapAltInfo = "The map '1;' has a weight of 2; points and is a Tier 3; - 4; [Stages: 5;]"
Lang.MapInavailable = "The map '1;' is not available on the server."
Lang.MapPlayed = "1; has been played 2; times."
Lang.TimeLeft = "There are 1; left on this map."
Lang.SessionTime= "This map has been played for 1;"
Lang.SessionTime2= "This map has been played for 1; and 2;"
Lang.PublicMapInfo = "1; has 2; points (Tier 3; - 4;) [Stages: 5;]"

Lang.PlayerGunObtain = "You have obtained a 1;"
Lang.PlayerGunFound = "You already have a 1;"
Lang.PlayerSyncStatus = "Your sync is 1; being displayed."
Lang.PlayerTeleport = "You have been teleported to 1;"
Lang.PlayerStageTeleport = "You have restarted 1;."
Lang.PlayerStageSend = "Sent to 1;."
Lang.PlayerStageTimer = "Normal timer disabled: Sent to 1; | Restart to enable your timer."
Lang.PlayerSaveloc = "Successfully created saveloc #1; | Use sm_loadloc to use this location. Use /tele 1; to go back to this location."

Lang.SpectateRestart = "You have to be alive in order to reset yourself to the start."
Lang.SpectateTargetInvalid = "You are unable to spectate this player right now."
Lang.SpectateWeapon = "You can't obtain a weapon whilst in spectator mode."

Lang.AdminInvalidFormat = "The supplied value '1;' is not of the requested type (2;)"
Lang.AdminMisinterpret = "The supplied string '1;' could not be interpreted. Make sure the format is correct."
Lang.VIPMisinterpret = "The supplied string '1;' could not be interpreted. Note that Base and Elevated can only be used here."
Lang.AdminSetValue = "The 1; setting has successfully been changed to 2;"
Lang.AdminOperationComplete = "The action was successful."
Lang.AdminHierarchy = "This user has a higher/same rank as you thus you cannot perform this action."
Lang.AdminDataFailure = "Failed to load essential admin data. Reason: 1;"
Lang.AdminMissingArgument = "The 1; argument was missing. It must be of type 2; and have a format of 3;"
Lang.AdminErrorCode = "An error occurred while executing statement: 1;"
Lang.AdminFNACReport = "[FNAC] 1;"

Lang.AdminPlayerKick = "1; has been kicked. (Reason: 2;)"
Lang.AdminPlayerBan = "1; has been banned for 2; minutes. (Reason: 3;)"
Lang.AdminChat = "[1;] 2; says: 3;"

Lang.Connect = "1; (2;) has joined the server 3; times."
Lang.Disconnect = "1; (2;) has disconnected. (Reason: 3;)"
Lang.ConnectFirst = "1; (2;) has joined for the first time. Everyone say welcome!"

Lang.MissingArgument = "You have to add 1; argument to the command."
Lang.CommandLimiter = "1; Wait a bit before trying again (2;s)."
Lang.InvalidCommand = "The command '1;' is not a command."

Lang.MiscZoneNotFound = "The 1; zone has not been set yet."
Lang.MiscVIPRequired = "This requires the user to be a VIP. Ask an admin to promote you to Elevated or Base."
Lang.MiscVIPGradient = "To efficiently use space on the VIP panel we are making use of the two existing color pickers already on the panel.\nThe tag color will be the start point of your gradient\nand the name color will be the end point of your gradient.\nYou can also pick a custom name if you wish.\nTo set your gradient, press this button again when done selecting (this will close the panel)"
Lang.MiscAbout = "This gamemode, " .. GM.Name .. " v" .. tostring( _C.Version ) .. ", was developed by " .. GM.Author .. " and modified by " .. GM.Author2 .. ".\nI want to give a huge shoutout to Gravious for being an amazing man and helping me with countless numbers of stuff. Shoutouts to bigdogmat, Beast, Velkon, Cloud, Statiics, and Silver for helping me work on this gamemode and make amazing things out of it."


Lang.MiscCommandLimit = {
	"Way too spicy! Enter the chill zone.",
}

Lang.Servers = {
	-- Add your servers like this:
	--{ "74.91.119.155:27015", "=[pG]= Skill Surf (Most Recent Gamemode)" },
}


Lang.Commands = {
	-- Customization Commands --
	["surftimer"] = "Opens a menu that contains all of the gamemode settings",
	["devtools"] = "Opens an experimental menu that contains features not found in the !surftimer menu, they may have issues",
	["fullbright"] = "Toggles fullbright visibility",
	["showclips"] = "Toggles playerclip visibility on maps (might not work on every map)",
	["custom"] = "Opens a menu that allows you to customize certain elements of the HUD",
	["hudopacity"] = "Allows you to set the opacity of the HUD, valid range is 0-255",
	["showzone"] = "Displays default zones (such as Map Start/End Zones) and certain Bonus Zones",
	["showaltzone"] = "Displays non-default zones (such as Stage Zone/Extra Bonus Zones/Anticheat Zones)",
	["prestrafe"] = "Toggles the prestrafe display on the HUD",
	["showkeys"] = "Toggles the showkeys display on the HUD",
	["totaltime"] = "Toggles the Total Time message when transitioning to a new stage",
	["showchat"] = "Enables drawing other players and bots in your screen",
	["hidechat"] = "Disables drawing other players and bots in your screen",
	["showspec"] = "Displays spectators on the side of the screen",
	["hidespec"] = "Hides spectators on the side of the screen",
	["showchat"] = "Enables the chat box",
	["hidechat"] = "Disables the chat box",
	["sound"] = "Toggles the playback of timer sounds (such as WR Sounds/Completions)",
	["water"] = "Toggles the visibility of water reflections and refractions, which can improve your framerate",
	["3dsky"] = "Toggles the visibility of the 3D skybox space, which can significantly improve your framerate on maps that have them",
	["decals"] = "Removes all decals from the map (such as paint and sprays)",
	["timescale"] = "Sets your timescale in relation to the tickrate, valid range is 0.5-10",
	["emitsound"] = "Plays a sound that everyone near you can hear (view listings on your !surftimer's Donator tab)",
	["vip"] = "Opens the VIP menu that allows you to customize many different options",

	-- Timer Commands --
	["mbot"] = "Opens a menu that easily allows you to change the multi-bot replay",
	["top"] = "Opens a menu that lists the top surf players on the server",
	["recentrecords"] = "Opens a menu that displays the latest map records on the server",
	["mywr"] = "Opens a menu that lists your map records on the server",
	["toprecords"] = "Opens a menu that lists the players with the most map records on the server",
	["personalrecord"] = "Opens a menu that lists your personal record on each mode for that map",
	["restart"] = "Teleports you to the start of the map or bonus",
	["specbot"] = "Quickly allows you to spectate the normal record bot",
	["spectate"] = "Toggles spectator mode",
	["noclip"] = "Toggles noclip movement",
	["style"] = "Opens the style menu that displays all of the styles we offer on the server",
	["wr"] = "Prints out the current map record in chat",
	["mrank"] = "Prints out your current map rank on the server",
	["ranks"] = "Opens a menu that lists all of the ranks on the server, as well as the requirements to obtain it",
	["rank"] = "Prints out your current server rank on the server for Normal",
	["average"] = "Prints out the current map average for your style",
	["mapsbeat"] = "Opens a menu that lists all of the maps you have beaten for your current style",
	["mapsleft"] = "Opens a menu that lists all of the maps you haven't beaten for your current style",
	["percentcompletion"] = "Prints out your current percent completion for your current style",
	["profile"] = "Opens an interactive menu displaying your server profile statistics and records",
	["map"] = "Prints out detailed map information in chat for the current map",
	["m"] = "Prints out simplified map information in chat for the current map",
	["tele"] = "Restarts you to the current stage, bonus, saveloc, or map",
	["telenext"] = "Teleports you to the next saveloc if available",
	["teleprev"] = "Teleports you to the previous saveloc if available",
	["stage"] = "Teleports you to the provided stage number",
	["repeat"] = "Toggles Stage Repeating Mode when Stage Mode is enabled",
	["goback"] = "Teleports you back one stage from your current stage",
	["practice"] = "Toggles Practice Mode",
	["save"] = "Saves your current run. Can be restored using !restore",
	["restore"] = "Restores your current run",
	["setspawn"] = "Sets your custom spawnpoint for any mode",
	["maptop"] = "Opens a menu that lists the top map records",

	-- RTV Commands --
	["rtv"] = "Casts a vote to change the current map",
	["revote"] = "Allows you to revote after closing the rtv menu",
	["revoke"] = "Removes a vote to change the current map",
	["nextmap"] = "Displays the next map that will be played after the vote has ended",
	["timeleft"] = "Displays the amount of time left until the map changes",
	["nominate"] = "Opens a menu that displays the maps available on the server",
	["session"] = "Prints out the amount of time spent on the current map",

	-- Extra Commands --
	["rules"] = "Opens a menu displaying all of the rules for the server",
	["muteall"] = "Quickly mutes all players currently connected to the server",
	["unmuteall"] = "Quickly unmutes all players currently connected to the server",
	["howlong"] = "Prints out your connection stats",
	["end"] = "Teleports you to the end of the map",
	["bend"] = "Teleports you to the end of the bonus",
	["hop"] = "Opens a menu that allows you to connect to another server",
	["me"] = "Prints out a message that casts yourself",

	["bot"] = "Prints out the bot subcommands available in the server"
}

Lang.TutorialLink = "https://www.youtube.com/watch?v=E3tys016mwg"
Lang.DonateLink = ""
Lang.DiscordLink = ""
