local _sub, _find, _low, _up, _gs = string.sub, string.find, string.lower, string.upper, string.gsub
local function _rep( s, pat, repl, n )
		pat = _gs( pat, '(%a)', function( v ) return '[' .. _up( v ) .. _low( v ) .. ']' end )
		if n then return _gs( s, pat, repl, n ) else return _gs( s, pat, repl ) end
end

function GM:PlayerSay( ply, text, team )
	local Prefix = _sub( text, 0, 1 )
	local szCommand = "invalid"

	if Prefix != "!" and Prefix != "/" then
		local szFilter = text
		if !team then
			return szFilter
		else
			return Admin:HandleTeamChat( ply, szFilter, text )
		end
	else
		szCommand = _low( _sub( text, 2 ) )
	end

	local szReply = Command:Trigger( ply, szCommand, text )
	if !szReply or type( szReply ) != "string" then
		return ""
	else
		return szReply
	end
end

function GM:ShowSpare1( ply )
	Player:GetProfile( ply )
end

function GM:ShowSpare2( ply )
	Timer.GenerateRecordList( ply )
end

function GM:ShowTeam( ply )
	Core:Send( ply, "GUI_Open", { "Spectate" } )
end

function GM:ShowHelp( ply )
	Core:Send( ply, "SurfTimer" )
end

Command = {}
Command.Functions = {}
Command.TimeLimit = nil
Command.Limiter = {}

local HelpData, HelpLength

function Command:Init()
	-- General timer commands
	self:Register( { "surftimer", "settings" }, function( ply, args )
		Core:Send( ply, "SurfTimer" )
	end )

	-- STUFF THAT NIFLHEIMRX ADDED, I WANT THESE ON TOP PLEASE DO NOT MOVE THEM PLEASEEEEEE --
	self:Register( { "devtools" }, function( ply )
		Core:Send( ply, "Client", { "DevTools" } )
	end )

	self:Register( { "test" }, function( ply, args )
		local num = args[2] and 1 or 0
		local seed = args[1] and args[1] != "" and args[1] or math.Round( math.random(1, 15) )

		Core:Send( ply, "Print", { "Surf Timer", "Seed: " .. seed .. ", Variant: " .. num } )
		Core:Broadcast( "Sound", { ply.Style, seed, num } )
	end )

	self:Register( { "help", "rules" }, function( ply, args )
		local baseCMD = args.Key
		if baseCMD == "rules" then
			Core:Send( ply, "Help", { true } )
		else
			Core:Send( ply, "Help" )
		end
	end )

	self:Register( { "makebot", "mbot", "replay" }, function( ply )
		Core:Send( ply, "MakeBot" )

		local data = Bot:FindReplays()
		Core:Send( ply, "MakeBot", { data } )
	end )

	self:Register( { "top", "surftop", "swtop", "hswtop", "100top", "wtop", "33top" }, function(ply, args)
		local style = Core.ShortStyleNameToID(args.Key)

		Core:Send(ply, "SurfTop")
		Player:LoadLeaderboardTop(ply, style)
	end )

	self:Register( { "rr", "recentrecords", "latestrecords", "lr", "wrcprr","cprr","srr", "brr","bsrr", "33rr" }, function( ply, args )
		local cmd = args.Key
		if (cmd == "wrcprr" or cmd == "cprr" or cmd == "srr") then
			cmd = "Stage"
		elseif (cmd == "brr" or cmd == "bsrr") then
			cmd = "Bonus"
		elseif (cmd == "33rr") then
			cmd = "33 Tick"
		else
			cmd = "Normal"
		end

		Core:Send( ply, "RecentRecords" )
		Player:GetRecentRecords( ply, cmd )
	end )

	self:Register( { "mywr", "swmywr", "hswmywr", "100mywr", "33mywr", "wmywr", "myrecords", "bmywr", "bmyrecords", "smywr", "stagemyrecords" }, function( ply, args )
		-- Rewrite 05/13/2021: Dynamically updates now --

		local cmd = args.Key
		if (cmd == "smyrecords" or cmd == "smywr") then
			cmd = "Stage"
		elseif (cmd == "bmyrecords" or cmd == "bmywr") then
			cmd = "Bonus"
		else
			cmd = "Normal"
		end

		local style = Core.ShortStyleNameToID(args.Key)
		local steamid = ply:SteamID()
		if #args > 0 then
			local tempStr = string.upper( args[1] )
			local isSteam = string.StartWith(tempStr, "STEAM_")

			local target = Player:FindByString( ply, tempStr, true, true )
			if target then
				steamid = target:SteamID()
			elseif isSteam then
				steamid = tempStr
			else
				return Core:SendColor(ply, "The provided argument, ", CL.Yellow, tempStr, CL.White, ", was not a player or a steamid")
			end
		else
			steamid = ply:SteamID()
		end

		Player:GetMapsWR( ply, steamid, cmd, style )
	end )

	self:Register( { "topwr", "toprecords", "mostrecords", "tr", "bonustoprecords", "bonustopwr", "btr", "stagetoprecords", "stagetopwr", "str", "33tr", "33toprecords", "33topwr" }, function( ply, args )
		-- Rewrite 05/13/2021: Dynamically updates now --
		local cmd = args.Key
		if (cmd == "stagetoprecords" or cmd == "stagetopwr" or cmd == "str") then
			cmd = "Stage"
		elseif (cmd == "bonustoprecords" or cmd == "bonustopwr" or cmd == "btr") then
			cmd = "Bonus"
		elseif (cmd == "33tr") then
			cmd = "33 Tick"
		else
			cmd = "Normal"
		end

		Player:GetTopRecordCount(ply, cmd)
	end )

	self:Register( { "fullbright", "togglefullbright" }, function( ply )
		if !ply.isFullbright then ply.isFullbright = false end
		ply.isFullbright = !ply.isFullbright

		-- Check for flashlight status, there's issues when using flashlight and fullbright at the same time --
		local isFLOn = ply:FlashlightIsOn()
		if isFLOn then
			ply:Flashlight( false )
			ply:AllowFlashlight( false )
		end

		ply:AllowFlashlight( !ply.isFullbright )
		Core:Send( ply, "Cheats", { "Fullbright" } )
	end )

	self:Register( { "showclips", "clips", "playerclips" }, function( ply )
		Core:Send( ply, "Cheats", { "Playerclips" } )
	end )

	self:Register( { "pr", "personalrecord", "swpr", "hswpr", "100pr", "33pr", "wpr" }, function( ply, args )
		local style = Core.ShortStyleNameToID(args.Key)
		local hasArgs = args and #args > 0

		if hasArgs then
			local plyormap = args[1]
			local isMap = string.StartWith( plyormap, "surf_" )
			if isMap then
				Timer.GeneratePRInfo( ply, nil, style, plyormap )
			else
				local tempStr = string.upper( args[1] )
				local isSteam = string.StartWith(tempStr, "STEAM_")

				local target = Player:FindByString( ply, tempStr, true, true )
				if target then
					steamid = target:SteamID()
				elseif isSteam then
					steamid = tempStr
				else
					return Core:SendColor(ply, "The provided argument, ", CL.Yellow, tempStr, CL.White, ", was not a player or a steamid")
				end

				local map = Zones:AttemptMapTranslation(args[2] or game.GetMap()) or game.GetMap()
				Timer.GeneratePRInfo( ply, steamid, style, map )
			end
		else
			Timer.GeneratePRInfo( ply, nil, style )
		end
	end )

	-- THE REST OF THIS IS NORMAL, REEEEEEEE --

	self:Register( { "custom", "customskin" }, function( ply )
		Core:Send( ply, "Client", { "CustomSkin" } )
	end )

	self:Register( { "restart", "r", "kill" }, function( ply )
		Command.Restart( ply )
	end )

	self:Register( { "specbot" }, function( ply )
		local bot = Bot:GetPlayer( _C.Style.Normal )
		if (!bot or !IsValid(bot)) then
			Core:SendColor(ply, "Failed to find any bots available for spectating")
		return end

		local target = bot:SteamID()
		local tname = bot:Nick()
		if ply.Spectating then
			return Spectator:NewById( ply, target, true, tname )
		else
			Command.Spectate( ply, nil, {target, tname} )
		end
	end )

	self:Register( { "spectate", "spec" }, function( ply, args )
		if #args > 0 then
			if args[1] == "bot" then

			return end

			local target = Player:FindByString( ply, args[1], nil, true )
			if target == ply then
				Command.Spectate( ply )
			return end

			if target then
				if ply.Spectating then
					return Spectator:NewById( ply, target, true, tname )
				else
					args[1] = target
					Command.Spectate( ply, nil, args[1] )
				end
			end
		else
			Command.Spectate( ply )
		end
	end )

	self:Register( { "noclip" }, function( ply )
		Command.NoClip( ply )
	end )

	-- RTV commands
	self:Register( { "rtv", "vote", "votemap" }, function( ply, args )
		if #args > 0 then
			if args[ 1 ] == "who" or args[ 1 ] == "list" then
				RTV:Who( ply )
			elseif args[ 1 ] == "check" or args[ 1 ] == "left" then
				RTV:Check( ply )
			elseif args[ 1 ] == "revoke" then
				RTV:Revoke( ply )
			elseif args[ 1 ] == "extend" then
				Admin.VIPProcess( ply, { "extend" } )
			else
				Core:Send( ply, "Print", { "Notification", args[ 1 ] .. " is an invalid subcommand of the rtv command. Valid: who, list, check, left, revoke, extend" } )
			end
		else
			RTV:Vote( ply )
		end
	end )

	self:Register( { "revote", "rertv", "recheck" }, function( ply, args )
		if RTV.VotePossible != true then
			Core:Send( ply, "Print", { "Notification", "A vote hasn't started yet." } )
		else
			if ply.VotedMap and ply.VotedMap > 0 then
				RTV.MapVoteList[ ply.VotedMap ] = RTV.MapVoteList[ ply.VotedMap ] - ( ply.IsVIP and ply.VIPLevel and ply.VIPLevel >= Admin.Level.Elevated and 2 or 1 )
			end

			Core:Send( ply, "RTV", { "VoteList", RTV.MapVoteList } )
			Core:Send( ply, "RTV", { "GetList", RTVSend } )
		end
	end )

	self:Register( { "nextmap" }, function( ply )
		local hasNextMap = RTV.FinalVote
		if hasNextMap then
			Core:BroadcastColor( "Next Map: ", CL.Yellow, hasNextMap )
			Command.BroadcastNotify( ply, "nextmap" )
		return end

		local timeLeft = string.NiceTime( RTV.MapEnd - CurTime() )
		Core:SendColor( ply, "The next map hasn't been chosen yet, the next vote will take place in ", CL.Yellow, timeLeft )
	end )

	self:Register( { "revoke", "revokertv" }, function( ply )
		RTV:Revoke( ply )
	end )

	self:Register( { "timeleft", "time", "remaining" }, function( ply )
		local hasNextMap = RTV.FinalVote
		if hasNextMap then
			Core:SendColor( ply, "The map will change in less than a minute, the next map will be set to ", CL.Yellow, hasNextMap )
		return end

		local timeLeft = string.NiceTime( RTV.MapEnd - CurTime() )
		Core:BroadcastColor( "Timeleft: ", CL.Yellow, timeLeft )
		Command.BroadcastNotify( ply, "timeleft" )
	end )

	self:Register( { "opacity", "hudopacity", "visibility", "hudvisibility" }, function( ply, args )
		local value = tonumber( args[1] )
		if !value then
			Core:SendColor( ply, "You must specify the opacity from 0-255, 0 being no-draw and 255 being full-draw" )
		return end

		Core:Send( ply, "Client", { "HUDOpacity", math.Clamp( value, 0, 255 ) } )
	end )

	self:Register( { "showzone", "showzones" }, function( ply )
		Core:Send( ply, "Client", { "ZoneVisibility" } )
	end )

	self:Register( { "showaltzone", "showaltzones" }, function( ply )
		Core:Send( ply, "Client", { "ZoneAltVisibility" } )
	end )

	self:Register( { "prestrafe", "toggleprestrafe" }, function( ply )
		Core:Send( ply, "Client", { "Prestrafe" } )
	end )

	self:Register( { "showkeys", "skeys", "showbuttons", "togglebuttons" }, function( ply )
		Core:Send( ply, "Client", { "ShowKeys" } )
	end )

	self:Register( { "totaltime", "tt", "totalt"}, function( ply )
		Core:Send( ply, "Client", { "TotalTime" } )
	end )

	self:Register( { "style", "mode", "styles", "modes" }, function( ply )
		Core:Send( ply, "Style" )
	end )

	self:Register( { "nominate", "rtvmap", "playmap", "addmap", "maps" }, function( ply, args )
		if #args > 0 then
			Command.Nominate( ply, nil, args )
		else
			Core:Send( ply, "GUI_Open", { "Nominate", { RTV.MapListVersion } } )
		end
	end )

	self:Register( { "wr", "swwr", "hswwr", "bwr", "100wr", "33wr", "wwr", "b1wr", "b2wr", "b3wr", "b4wr", "b5wr", "b6wr", "b7wr", "b8wr", "b9wr", "b10wr" }, function( ply, args )
		local style = Core.ShortWRToStyleID( args.Key )
		local map = (#args > 0 and args[1])
		if (args.Key == "bwr") and tonumber(map) then
			style = Core.SequenceToBonus(map)

			map = Zones:AttemptMapTranslation(args[2] or game.GetMap())
		elseif map then
			map = Zones:AttemptMapTranslation(map)
		end

		Timer:GetInitialRecords( ply, style, map )
	end )

	self:Register( { "mrank", "maprank" }, function( ply, args )
		if #args > 0 then
			local plyormap = args[1]
			local mapTemp = Zones:AttemptMapTranslation(args[1])
			local isMap = string.StartWith( plyormap, "surf_" )
			if isMap or RTV:MapExists(mapTemp) then
				Timer:GetPlayerStandings( ply, nil, mapTemp, 1 )
			else
				local target = Player:FindByString( ply, args[1], true )
				if !target or !IsValid(target) then return end

				local map = Zones:AttemptMapTranslation(args[2] or game.GetMap()) or game.GetMap()

				Timer:GetPlayerStandings( ply, target, map, 1 )
			end
		else
			Timer:GetPlayerStandings( ply, nil, nil, 1 )
		end
	end )

	self:Register( { "ranks", "ranklist" }, function( ply )
		local bAngled = Player:GetRankType( ply.Style )
		if ply.Style == _C.Style["100 Tick"] or ply.Style == _C.Style.Wicked or ply.Style == _C.Style["33 Tick"] then bAngled = 5 end

		Core:Send( ply, "GUI_Open", { "Ranks", { ply.Rank or 1, ply.RankSum or 0, bAngled, (bAngled and ( bAngled == 5 and Player.TickScalar or Player.AngledScalar ) or Player.NormalScalar) or 0.0001 } } )
	end )

	self:Register( { "rank" }, function( ply, args )
		local hasArgument = args and args[1]
		if hasArgument then
			local wantsPosition = string.StartWith( args[1], "@" )
			if wantsPosition then
				local pos = string.sub( args[1], 2 )
				Player:GetServerRank( ply, nil, pos )
			else
				local target = Player:FindByString( ply, args[1], true )
				if target then
					Player:GetServerRank( ply, target )
				end
			end
		else
			Player:GetServerRank( ply )
		end
	end )

	self:Register( { "maverage", "mapaverage", "average" }, function( ply )
		local style = ply.Style

		local average = Timer:RetrieveAverage( style )
		local best = ply.Record

		local mappts = Timer.Multiplier
		local maxpts = (mappts * 2)
		local currentpts = Timer:CalculatePoints( best, style )

		if (average == 1) then
			Core:SendColor( ply, "There are no averages or there's not enough information to retrieve averages, try again later" )
		return end

		Core:SendColor( ply, CL.Yellow, game.GetMap(), CL.White, " map average: ", CL.Yellow, Timer:Convert( average ) )

		local aboveAverage, hasMaxPoints = (best > average or best == 0), (currentpts >= maxpts )
		if aboveAverage then
			Core:SendColor( ply, "You can get more than [", CL.Blue, mappts, CL.White, "] points by beating the map average" )
		elseif hasMaxPoints then
			Core:SendColor( ply, "You have achieved the maximum amount of points [", CL.Blue, maxpts, CL.White, "] for this map" )
		else
			Core:SendColor( ply, "You can get up to [", CL.Blue, maxpts, CL.White, "] points for improving your time" )
		end
	end )

	self:Register( { "mapsbeat", "beatlist", "mapscompleted", "completed", "swmapsbeat", "hswmapsbeat", "100mapsbeat", "wmapsbeat", "33mapsbeat" }, function( ply, args )
		local style = Core.ShortStyleNameToID(args.Key)

		if #args > 0 then
			local target = Player:FindByString( ply, args[1], true, true )
			if target then
				Player:GetMapsBeat( ply, target:SteamID(), nil, style )
			else
				Player:GetMapsBeat( ply, string.upper( args[1] ), nil, style )
			end
		else
			Player:GetMapsBeat( ply, nil, nil, style )
		end
	end )

	self:Register( { "mapsleft", "left", "incomplete", "swmapsleft", "hswmapsleft", "100mapsleft", "wmapsleft", "33mapsleft" }, function( ply, args )
		local style = Core.ShortStyleNameToID(args.Key)

		if #args > 0 then
			local target = Player:FindByString( ply, args[1], true, true )
			if target then
				Player:GetMapsBeat( ply, target:SteamID(), true, style )
			else
				Player:GetMapsBeat( ply, string.upper( args[1] ), true, style )
			end
		else
			Player:GetMapsBeat( ply, nil, true, style )
		end
	end )

		self:Register( { "pc", "percentcompletion", "completionpercentage" }, function( ply, args )
		if #args > 0 then
			local target = Player:FindByString( ply, args[1], true )
			if target and !target:IsBot() then
				Player:GetPercentCompletion( ply, target )
			end
		else
			Player:GetPercentCompletion( ply, ply )
		end
	end )

	self:Register( { "profile", "playerinfo", "swprofile", "hswprofile", "100profile", "wprofile", "33profile"}, function(ply, args)
		local style = Core.ShortStyleNameToID(args.Key)

		if #args > 0 then
			local target = Player:FindByString( ply, args[1], true, true )
			if target then
				Player:GetProfile( ply, target, style )
			else
				Player:GetProfile( ply, args[1], style )
			end
		else
			Player:GetProfile( ply, nil, style )
		end
	end )

	self:Register( { "show", "hide", "showplayers", "hideplayers", "toggleplayers" }, function( ply, args )
		if string.sub( args.Key, 1, 4 ) == "show" or string.sub( args.Key, 1, 4 ) == "hide" then
			Core:Send( ply, "Client", { "PlayerVisibility", string.sub( args.Key, 1, 4 ) == "hide" and 0 or 1 } )
		else
			Core:Send( ply, "Client", { "PlayerVisibility", -1 } )
		end
	end )

	self:Register( { "showspec", "hidespec", "togglespec" }, function( ply, args )
		local key = string.sub( args.Key, 1, 1 )
		if key == "s" then Core:Send( ply, "Client", { "SpecVisibility", 1 } )
		elseif key == "h" then Core:Send( ply, "Client", { "SpecVisibility", 0 } )
		elseif key == "t" then Core:Send( ply, "Client", { "SpecVisibility", nil } )
		end
	end )

	self:Register( { "chat", "togglechat", "hidechat", "showchat" }, function( ply )
		Core:Send( ply, "Client", { "Chat" } )
	end )

	self:Register( { "sound", "wrsound", "pbsound" }, function( ply )
		Core:Send( ply, "Client", { "SurflineSound" } )
	end )

	self:Register( { "muteall", "muteplayers", "unmuteall", "unmuteplayers" }, function( ply, args )
		Core:Send( ply, "Client", { "Mute", string.sub( args.Key, 1, 2 ) == "mu" and true or nil } )
	end )

	self:Register( { "water", "fixwater", "reflection", "refraction" }, function( ply )
		Core:Send( ply, "Client", { "Water" } )
	end )

	self:Register( { "sky", "3dsky", "skybox" }, function( ply )
		Core:Send( ply, "Client", { "Sky" } )
	end )

	self:Register( { "decals", "blood", "shots", "removedecals" }, function( ply )
		Core:Send( ply, "Client", { "Decals" } )
	end )

	self:Register( { "vipnames", "disguise", "disguises", "reveal" }, function( ply )
		Core:Send( ply, "Client", { "Reveal" } )
	end )

	self:Register( { "shop", "knife", "radio" }, function( ply )
		Core:SendColor( ply, Color(255, 0, 0 ), "This feature is not available on this server" )
	end )

	-- Bot commands (not gonna fix this, pretty cancer)
	self:Register( { "bot", "wrbot" }, function( ply, args )
		if #args == 0 then
			Bot:ShowStatus( ply )
		else
			local szType = tostring( args[ 1 ] )
			if szType == "add" or szType == "record" then
				Bot:AddPlayer( ply )
			elseif szType == "remove" or szType == "stop" then
				Bot:RemovePlayer( ply )
			elseif szType == "set" or szType == "style" or szType == "play" then
				if !args[ 2 ] then
					local list = Bot:GetMultiBots()
					if #list > 0 then
						Core:Send( ply, "MakeBot" )

						local data = Bot:FindReplays()
						return Core:Send( ply, "MakeBot", { data } )
					else
						return Core:Send( ply, "Print", { "General", "There are no other bots available." } )
					end
				end

				local nStyle = tonumber( args[ 2 ] )
				if !nStyle then
					table.remove( args.Upper, 1 )
					local szStyle = string.Implode( " ", args.Upper )

					local a = Core:GetStyleID( szStyle )
					if !(string.StartWith( szStyle, "Stage" )) and !(Core:IsValidStyle( a )) then
						return Core:Send( ply, "Print", { "General", "You have entered an invalid style name. Use the exact name shown on !styles or use their respective ID." } )
					else
						if string.StartWith( szStyle, "Stage" ) then
							nStyle = tonumber( string.sub( szStyle, 7 ) )
							nStyle = nStyle + 14
						end
							nStyle = a
						end
					if string.StartWith (szStyle, "100 Tick") then
						nStyle = 44
					elseif string.StartWith(szStyle, "33 Tick") then
						nStyle = 45
					end
				end

				local isForcing = Admin:CanAccess( ply, Admin.Level.Super )
				local Change = Bot:ChangeMultiBot( nStyle, isForcing )
				if string.len( Change ) > 10 then
					Core:Send( ply, "Print", { "General", Change } )
				else
					Core:Send( ply, "Print", { "General", Lang:Get( "BotMulti" .. Change ) } )
				end
			elseif szType == "info" or szType == "details" then
				local nStyle = nil
				if !args[ 2 ] or !tonumber( args[ 2 ] ) then
					if args[ 2 ] then
						table.remove( args.Upper, 1 )
						local szStyle = string.Implode( " ", args.Upper )

						local a = Core:GetStyleID( szStyle )
						if !Core:IsValidStyle( a ) then
							return Core:Send( ply, "Print", { "General", "You have entered an invalid style name. Use the exact name shown on !styles or use their respective ID." } )
						else
							nStyle = a
						end
					else
						local ob = ply:GetObserverTarget()
						if IsValid( ob ) and ob:IsBot() then
							nStyle = ob.Style
						else
							return Core:Send( ply, "Print", { "General", "You have to either spectate a bot or use !bot " .. szType .." [STYLE ID] to use this command." } )
						end
					end
				else
					nStyle = tonumber( args[ 2 ] )
					if !Core:IsValidStyle( nStyle ) then
						return Core:Send( ply, "Print", { "General", "You have entered an invalid style id. Use !styles to see their respective IDs." } )
					end
				end

				if nStyle then
					local Info = Bot:GetInfo( nStyle )
					Core:Send( ply, "Print", { "General", Lang:Get( "BotDetails", { Info.Name, Info.SteamID, Core:StyleName( Info.Style ), Timer:Convert( Info.Time ), Info.Date } ) } )
				end
			elseif szType == "save" then
				if Admin:CanAccess( ply, Admin.Level.Super ) then
					Bot:Save()
				else
					Bot:SaveBot( ply )
				end
			elseif (szType == "rate") then
				local isVIP = (ply.VIPLevel >= Admin.Level.Base)
				if !isVIP then
					Core:SendColor( ply, "You need to have a vip subscription active in order to use this" )
				return end

				local isSpectating = ply.Spectating
				local ob = isSpectating and ply:GetObserverTarget()
				if (!ob or !IsValid(ob) or !ob:IsBot()) then
					Core:SendColor( ply, "You need to be spectating a bot in order to use this" )
				return end

				local validRates = {
					["0.5"] = true,
					["1"] = true,
					["1.5"] = true,
					["2"] = true
				}

				local playbackRate = args[2]
				if !playbackRate or !validRates[playbackRate] then
					Core:SendColor( ply, "Valid rates: 0.5, 1, 1.5, 2" )
				return end

				ob.tempRate = tonumber(playbackRate)

				Core:SendColor( ob:GetSpectators(), CL.Yellow, ply:Nick(), CL.White, " set the bot playback rate to ", CL.Blue, playbackRate, CL.White, "x" )
			else
				Core:Send( ply, "Print", { "General", "Available sub-commands of !bot: add/record, remove/stop, set/style/play, info/details, save, rate" } )
			end
		end
	end )

	self:Register( { "map", "points", "mapinfo" }, function( ply, args )
		local map = args[1] and string.lower( args[1] ) or game.GetMap()
		map = Zones:AttemptMapTranslation(map)
		local isCurrentMap = (map == game.GetMap())

		if !isCurrentMap and args[1] then
			local data = RTV:GetMapData( map )

			if !RTV:MapExists( map ) then
				Core:SendColor( ply, "The map ", CL.Yellow, map, CL.White, " does not exist." )
			else
				local multTier = {
					[1] = "200",
					[2] = "500",
					[3] = "800",
					[4] = "1100",
					[5] = "1500",
					[6] = "2000",
					[7] = "4000",
					[8] = "10000"
				}

				local tier = data[3] or 1
				local mtype = data[4] or 0
				local totalstages = 0
				local totalbonuses = 0

				local mapQuery = [[
				SELECT
					COUNT(IF((t1.nType = 2 OR t1.nType = 6 OR t1.nType = 9 OR t1.nType = 11 OR t1.nType = 13 OR t1.nType = 15 OR t1.nType = 96 OR t1.nType = 98 OR t1.nType = 100 OR t1.nType = 102), 1, NULL)) nBonusTotal,
					COUNT(IF((t1.nType > 16 AND t1.nType < 63), 1, NULL)) nStageTotal
				FROM
					(SELECT nType FROM game_zones WHERE szMap = {0} GROUP BY nType) t1
				]]

				SQL:Prepare(
					mapQuery,
					{ map }
				):Execute( function( data2, _, _ )
					totalstages = data2[1]["nStageTotal"] or 0
					totalbonuses = data2[1]["nBonusTotal"] or 0

					Core:SendColor( ply, CL.Yellow, map, CL.White, " is a ", CL.Blue, "Tier " .. tier .. " - " .. _C.MapTypes[mtype], CL.White, " map that contains ", CL.Blue,
						multTier[tier], CL.White, " points ", "(Stages: ", CL.Blue, totalstages, CL.White, ") (Bonuses: ",
						CL.Blue, totalbonuses, CL.White, ")" )
				end )
			end
		else
			local tier = Timer.Tier
			local mtype = Timer.Type
			local totalstages = Zones:GetStageAmount()
			local totalbonuses = Zones:GetBonusAmount()

			local isBonus = string.StartWith( Core:StyleName( ply.Style ), "Bonus" )

			local totalPoints = isBonus and Timer.BonusMultiplier or Timer.Multiplier
			local pointsObtained = math.floor( Timer:CalculatePoints( ply.Record, ply.Style ) )

			local hasBeaten = ply.Record != 0

			Core:SendColor( ply, CL.Yellow, map, CL.White, " is a ", CL.Blue, "Tier " .. tier .. " - " .. _C.MapTypes[mtype], CL.White, " map that contains ", CL.Blue,
				totalPoints, CL.White, " points " .. (isBonus and "for the bonus " or ""), hasBeaten and "[Obtained " or "", CL.Blue, hasBeaten and pointsObtained or "",
				CL.White, hasBeaten and "/" or "", CL.Blue, hasBeaten and totalPoints or "", CL.White, hasBeaten and " pts] " or "", "(Stages: ", CL.Blue, totalstages, CL.White, ") (Bonuses: ",
				CL.Blue, totalbonuses, CL.White, ")" )
		end
	end )

	self:Register( { "m", "mi", "minfo", "mdata" }, function( ply, args )
		local map = args[1] and string.lower( args[1] ) or game.GetMap()
		map = Zones:AttemptMapTranslation(map)
		local isCurrentMap = (map == game.GetMap())

		if !isCurrentMap and args[1] then
			local data = RTV:GetMapData( map )

			if !RTV:MapExists( map ) then
				Core:SendColor( ply, "The map ", CL.Yellow, map, CL.White, " does not exist." )
			else
				local tier = data[3] or 1
				local mtype = data[4] or 0
				local plays = data[5] or 0
				local totalstages = 0
				local totalbonuses = 0

				local mapQuery = [[
				SELECT
					COUNT(IF((t1.nType = 2 OR t1.nType = 6 OR t1.nType = 9 OR t1.nType = 11 OR t1.nType = 13 OR t1.nType = 15 OR t1.nType = 96 OR t1.nType = 98 OR t1.nType = 100 OR t1.nType = 102), 1, NULL)) nBonusTotal,
					COUNT(IF((t1.nType > 16 AND t1.nType < 63), 1, NULL)) nStageTotal
				FROM
					(SELECT nType FROM game_zones WHERE szMap = {0} GROUP BY nType) t1
				]]

				SQL:Prepare(
					mapQuery,
					{ map }
				):Execute( function( data2, _, _ )
					totalstages = data2[1]["nStageTotal"] or 0
					totalbonuses = data2[1]["nBonusTotal"] or 0

					Core:BroadcastColor( "Map: ", CL.Yellow, map, CL.White, " - ", CL.Blue, _C.MapTypes[ mtype ], CL.White, " - Tier: ", CL.Blue, tier, CL.White, mtype == 1 and " - Stages: " or "", CL.Blue,
						mtype == 1 and totalstages or "", CL.White, " - Bonuses: ", CL.Blue, totalbonuses, CL.White, " - Plays: ", CL.Blue, plays )
				end )
			end
		else
			local tier = Timer.Tier
			local mtype = Timer.Type
			local plays = Timer.PlayCount
			local totalstages = Zones:GetStageAmount()
			local totalbonuses = Zones:GetBonusAmount()

			Core:BroadcastColor( "Map: ", CL.Yellow, map, CL.White, " - ", CL.Blue, _C.MapTypes[ mtype ], CL.White, " - Tier: ", CL.Blue, tier, CL.White, mtype == 1 and " - Stages: " or "", CL.Blue,
				mtype == 1 and totalstages or "", CL.White, " - Bonuses: ", CL.Blue, totalbonuses, CL.White, " - Plays: ", CL.Blue, plays )
		end
	end )

	self:Register( { "howlong", "timeplayed" }, function( ply, args )
		local target = args[1]
		local name, playtime, actualplaytime, connections

		if target then
			target = Player:FindByString( ply, target, true )
			if !target then return end

			name = target:Name()
			playtime = string.NiceTime( (target.PlayTime * 60) + CurTime() )
			actualplaytime = target.PlayTime
			connections = target.Connections
		else
			name = ply:Name()
			playtime = string.NiceTime( (ply.PlayTime * 60) + CurTime() )
			actualplaytime = ply.PlayTime
			connections = ply.Connections
		end

		Core:BroadcastColor( CL.Yellow, name, CL.White, " has played on this server for ", CL.Blue, playtime, CL.White, " (", CL.Yellow, actualplaytime .. " minutes", CL.White,
			") and has joined the server ", CL.Blue, connections, CL.White, " times" )
	end )

	-- God damn Aart use a proper text editor --
	self:Register( { "session", "sessiontime", "uptime" }, function( ply )
		local belowOneHour = (CurTime() < 3600)
		if belowOneHour then
			local currentTime = string.NiceTime( CurTime() )
			Core:BroadcastColor( "The current map has been played for ", CL.Yellow, currentTime )
		else
			local currentTime = string.NiceTime( CurTime() )
			local minuteTime 	= string.NiceTime( math.fmod( CurTime(), 3600 ) )

			Core:BroadcastColor( "The current map has been played for ", CL.Yellow, currentTime, CL.White, " and ", CL.Yellow, minuteTime )
		end
	end )

	self:Register( { "end", "goend", "gotoend", "tpend" }, function( ply )
		local isPractice = ply:GetNWBool "Practice"
		if !isPractice then
			Core:SendColor( ply, "You need to disable your SurfTimer in order to use this" )
		return end

		local vPoint = Zones:GetCenterPoint( Zones.Type["Normal End"] )
		if vPoint then
			ply:SetPos( vPoint )
			Core:SendColor( ply, "You have teleported to Map Zone [", CL.Yellow, "Map End", CL.White, "]" )
		else
			Core:SendColor( ply, "Map Zone [", CL.Yellow, "Map End", CL.White, "] does not exist" )
		end
	end )

	self:Register( { "endbonus", "endb", "bend", "gotobonus" }, function( ply, args )
		local isPractice = ply:GetNWBool "Practice"
		if !isPractice then
			Core:SendColor( ply, "You need to disable your SurfTimer in order to use this" )
		return end

		local hasArgs = (args and #args > 0)
		if hasArgs then
			local bonusNumber = tonumber( args[1] )
			if !bonusNumber then
				Core:SendColor( ply, "You must supply a valid bonus number" )
			return end

			local vPoint = nil
			if (bonusNumber == 1) then
				vPoint = Zones:GetCenterPoint( Zones.Type["Bonus End"] )
			else
				for i = 2, 10 do
					if (bonusNumber == i) then
						vPoint = Zones:GetCenterPoint( Zones.Type["Bonus " .. i .. " End"] )
					end
				end
			end

			if !vPoint then
				Core:SendColor( ply, "This bonus either doesn't exist or isn't zoned" )
			return end

			ply:SetPos( vPoint )
			Core:SendColor( ply, "You have been moved to the following zone: [", CL.Yellow, "Bonus " .. bonusNumber .. " End", CL.White, "]" )
		else
			local vPoint = Zones:GetCenterPoint( Zones.Type["Bonus End"] )
			if !vPoint then
				Core:SendColor( ply, "This bonus either doesn't exist or isn't zoned" )
			return end

			ply:SetPos( vPoint )
			Core:SendColor( ply, "You have been moved to the following zone: [", CL.Yellow, "Bonus 1 End", CL.White, "]" )
		end
	end )

	self:Register( { "tutorial", "tut", "howto" }, function( ply )
		Core:Send( ply, "Client", { "Tutorial", Lang.TutorialLink } )
	end )

	self:Register( { "discord" }, function( ply )
		if !Lang.DiscordLink or (Lang.DiscordLink == "") then
			Core:SendColor(ply, "The server owner has not setup a Discord link yet, please advise them to create a link for their community!")
		return end

		Core:Send( ply, "Client", { "Tutorial", Lang.DiscordLink } )
	end )

	self:Register( { "donate", "donations", "sendmoney", "givemoney", "donation" }, function( ply )
		if !Lang.DonateLink or (Lang.DonateLink == "") then
			Core:SendColor(ply, "The server owner has not setup a donation link yet, please advise them to create a link for their community!")
		return end

		Core:Send( ply, "Client", { "Tutorial", Lang.DiscordLink } )
	end )

	-- Easy access commands
	self:Register( { "normal", "n" }, function( ply )
		Command.Style( ply, nil, { _C.Style.Normal } )
	end )

	self:Register( { "sideways", "sw" }, function( ply )
		Command.Style( ply, nil, { _C.Style.Sideways } )
	end )

	self:Register( { "halfsideways", "halfsw", "hsw" }, function( ply )
		Command.Style( ply, nil, { _C.Style["Half-Sideways"] } )
	end )

	self:Register( { "100tick", "100" }, function( ply )
		Command.Style( ply, nil, { _C.Style["100 Tick"] } )
	end )

	self:Register( { "33tick", "33" }, function( ply )
		Command.Style( ply, nil, { _C.Style["33 Tick"] } )
	end )

	self:Register( { "wicked", "w" }, function( ply )
		Command.Style( ply, nil, { _C.Style.Wicked } )
	end )


	self:Register( { "bonus", "b" }, function( ply, args )
		local hasArgs = (args and #args > 0)
		if hasArgs then
			local bonusNumber = tonumber( args[1] )
			if !bonusNumber then
				Core:SendColor( ply, "You must supply a valid bonus number" )
			return end

			if (bonusNumber == 1) then
				Command.Style( ply, nil, { _C.Style.Bonus } )
			else
				for i = 2, 10 do
					if (bonusNumber == i) then
						Command.Style( ply, nil, { _C.Style["Bonus " .. bonusNumber ] } )
					end
				end
			end
		else
			Command.Style( ply, nil, { _C.Style.Bonus } )
		end
	end )

	self:Register( { "unreal", "lowgravity", "jumpack" }, function( ply )
		Core:SendColor( ply, Color( 255, 0, 0 ), "This style is currently not available on this server" )
	end )

	self:Register( { "tele", "stele", "stagetele", "gostagetele" }, function( ply, args )
		if #args > 0 then
			local value = tonumber( args[1] )
			if string.StartWith( args[1], "#" ) then
				value = tonumber( string.sub( value, 2 ) )
			end

			Timer.LoadCheckpoint( ply, _, _, _, value )
		else
			local isStaged = (Timer.Type == 1)
			local isStaging = ply:GetNWBool "StageTimer"
			if !isStaged then
				Command.Restart( ply )
			return end

			local isBonus = string.StartWith( Core:StyleName( ply.Style ), "Bonus" )
			if isBonus then
				Command.Restart( ply )
			return end

			local stage = ply:GetNWInt "Stage"
			if (stage == 1) or (stage < 0) or !stage then
				ply.MovingPos = true
				ply:StageReset()
				ply:SetPos( Zones:GetSpawnPoint( Zones.StartPoint ) )
				ply:SetLocalVelocity( Vector( 0, 0, 0 ) )
				ply.MovingPos = false
			return end

			local vPoint = Zones:GetCenterPoint( Zones.Type["Stage " .. stage] )
			local stagePoint = Zones["Stage " .. stage .. " Point"]
			if (stagePoint) then
				vPoint = Zones:GetSpawnPoint(stagePoint)
			end

			if isStaging and ply.PreferredStageSpawn and ply.PreferredStageSpawn[stage] then
				vPoint = ply.PreferredStageSpawn[stage]
				ply:SetEyeAngles(ply.PreferredStageAngles[stage])
			end

			if vPoint then
				ply.MovingPos = true
				ply:StageReset()
				ply:SetPos( vPoint )
				ply:SetLocalVelocity( Vector( 0, 0, 0 ) )
				ply.MovingPos = false
			else
				Command.Restart( ply )
			end
		end
	end )

	self:Register( { "telenext" }, function( ply )
		Command.Telenext(ply)
	end )

	self:Register( { "teleprev", "teleprevious" }, function( ply )
		Command.Teleprev(ply)
	end )

	self:Register( { "gs", "gostage", "s", "stage" }, function( ply, args )
		local isStaged = (Timer.Type == 1)
		if !isStaged then
			Core:SendColor( ply, "The map must be a ", CL.Blue, "Staged", CL.White, " map in order to use this" )
		return end

		local isMovingPos = ply.MovingPos
		if isMovingPos then return end

		local isBonus = string.StartWith( Core:StyleName( ply.Style ), "Bonus" )
		if isBonus then
			Core:SendColor( ply, "You need to be outside the bonus style in order to use this" )
		return end

		local hasArgs = args and #args > 0
		if !hasArgs then
			Core:SendColor( ply, "You need to specify a valid stage number in order to use this" )
		return end

		local oldStage = ply:GetNWInt "Stage"
		local newStage = tonumber( args[1] )
		if !newStage then
			Core:SendColor( ply, "You need to specify a valid stage number in order to use this" )
		return end

		local isStaging = ply:GetNWBool "StageTimer"
		local isRepeating = ply:GetNWBool "StageRepeat"
		if !isStaging then
			ply:SetNWBool( "StageTimer", true )
			ply:ResetTimer()
			ply:StageReset()
			Core:SendColor( ply, "Your timer has reset, entering Stage Mode" )
		end

		if (newStage == 1) or (newStage < 0) then
			ply:ResetTimer()
			ply:StageReset()

			ply:SetNWInt( "Stage", newStage )
			Stage.SetInfo( ply, newStage )

			ply.MovingPos = true
			ply:SetPos( Zones:GetSpawnPoint( Zones.StartPoint ) )
			ply:SetLocalVelocity( Vector( 0, 0, 0 ) )

			if !isRepeating and (oldStage != newStage) then
				Core:SendColor( ply, "You have teleported to Stage [", CL.Yellow, "Stage " .. newStage, CL.White, "]" )
			end
		return end

		local vPoint = Zones:GetCenterPoint( Zones.Type["Stage " .. newStage] )
		local stagePoint = Zones["Stage " .. newStage .. " Point"]
		if (stagePoint) then
			vPoint = Zones:GetSpawnPoint(stagePoint)
		end

		if isStaging and ply.PreferredStageSpawn and ply.PreferredStageSpawn[newStage] then
			vPoint = ply.PreferredStageSpawn[newStage]
			ply:SetEyeAngles(ply.PreferredStageAngles[newStage])
		end

		if vPoint then
			ply:ResetTimer()
			ply:StageReset()

			ply:SetNWInt( "Stage", newStage )
			Stage.SetInfo( ply, newStage )

			ply.MovingPos = true
			ply:SetPos( vPoint )
			ply:SetLocalVelocity( Vector( 0, 0, 0 ) )

			if !isRepeating and (oldStage != newStage) then
				Core:SendColor( ply, "You have teleported to Stage [", CL.Yellow, "Stage " .. newStage, CL.White, "]" )
			end
		else
			Core:SendColor( ply, "Stage [", CL.Yellow, "Stage " .. newStage, CL.White, "] does not exist" )
		end
	end )

	self:Register( { "repeat", "repeatstage" }, function( ply )
		local isPractice = ply:GetNWBool "Practice"
		if isPractice then
			Core:SendColor( ply, "You need to enable your SurfTimer in order to use this" )
		return end

		local isBonus = string.StartWith( Core:StyleName( ply.Style ), "Bonus" )
		if isBonus then
			Core:SendColor( ply, "You need to be outside the bonus style in order to use this" )
		return end

		local isStaged = (Timer.Type == 1)
		if !isStaged then
			Core:SendColor( ply, "The map must be a ", CL.Blue, "Linear", CL.White, " map in order to use this" )
		return end

		local isRepeatEnabled = ply:GetNWBool "StageRepeat"
		if isRepeatEnabled then
			ply:SetNWBool( "StageRepeat", false )
			Core:SendColor( ply, "Stage Repeating has been disabled" )
		else
			ply:SetNWBool( "StageRepeat", true )
			Core:SendColor( ply, "Stage Repeating has been enabled" )

			local isStaging = ply:GetNWBool "StageTimer"
			if !isStaging then
				ply:SetNWBool( "StageTimer", true )
				Core:SendColor( ply, "Your timer has reset, entering Stage Mode" )
			end
		end
	end )

	self:Register( { "gb", "goback" }, function( ply )
		local isStaged = (Timer.Type == 1)
		if !isStaged then
			Core:SendColor( ply, "The map must be a ", CL.Blue, "Staged", CL.White, " map in order to use this" )
		return end

		local isBonus = string.StartWith( Core:StyleName( ply.Style ), "Bonus" )
		if isBonus then
			Core:SendColor( ply, "You need to be outside the bonus style in order to use this" )
		return end

		local isStaging = ply:GetNWBool "StageTimer"
		local isRepeating = ply:GetNWBool "StageRepeat"
		if !isStaging then
			ply.MovingPos = true
			ply:SetNWBool( "StageTimer", true )
			ply:ResetTimer()
			Core:SendColor( ply, "Your timer has reset, entering Stage Mode" )
			ply.MovingPos = false
		end

		local oldStage = ply:GetNWInt "Stage"
		local newStage = oldStage - 1

		if !isRepeating or (newStage == 1) or (newStage < 0) then
			ply.MovingPos = true
			ply:StageReset()
			ply:SetPos( Zones:GetSpawnPoint( Zones.StartPoint ) )
			ply:SetLocalVelocity( Vector( 0, 0, 0 ) )
			ply.MovingPos = false

			if !isRepeating and (oldStage != newStage) then
				Core:SendColor( ply, "You have teleported to Stage [", CL.Yellow, "Stage " .. newStage, CL.White, "]" )
			end
		return end

		local vPoint = Zones:GetCenterPoint( Zones.Type["Stage " .. newStage] )
		local stagePoint = Zones["Stage " .. newStage .. " Point"]
		if (stagePoint) then
			vPoint = Zones:GetSpawnPoint(stagePoint)
		end

		if isStaging and ply.PreferredStageSpawn and ply.PreferredStageSpawn[newStage] then
			vPoint = ply.PreferredStageSpawn[newStage]
			ply:SetEyeAngles(ply.PreferredStageAngles[newStage])
		end

		if vPoint then
			ply.MovingPos = true
			ply:StageReset()
			ply:SetPos( vPoint )
			ply:SetLocalVelocity( Vector( 0, 0, 0 ) )
			ply.MovingPos = false

			if !isRepeating and (oldStage != newStage) then
				Core:SendColor( ply, "You have teleported to Stage [", CL.Yellow, "Stage " .. newStage, CL.White, "]" )
			end
		else
			Core:SendColor( ply, "Stage [", CL.Yellow, "Stage " .. newStage, CL.White, "] does not exist" )
		end
	end )

	self:Register( { "practice", "st", "p" }, function( ply )
		local isPractice = ply:GetNWBool "Practice"
		if isPractice then
			local didSave = Command.ResumeState(ply)
			if !didSave then
				Command.Restart(ply)
			end

			ply:SetNWBool( "Practice", false )

			Core:SendColor( ply, "Your SurfTimer has been enabled" )
		else
			Command.SaveState(ply)
			Bot:CleanRecording(ply)
			ply:SetNWBool( "Practice", true )

			local isNormal = (ply.Style == 1)
			if !isNormal then
				Core:SendColor( ply, "Your SurfTimer has been disabled [", CL.Yellow, Core:StyleName( ply.Style ), CL.White, "]" )
			return end

			Core:SendColor( ply, "Your SurfTimer has been disabled" )
		end
	end )

	self:Register( { "save", "saverun", "svr" }, function( ply )
		Command.SaveState(ply)
	end )

	self:Register( { "restore", "restorerun", "rtr" }, function( ply )
		Command.ResumeState(ply)
	end )

	self:Register( { "setspawn", "sp" }, function( ply )
		local isOnGround = ply:OnGround()
		if !isOnGround then
			Core:SendColor(ply, "You must be on the ground in order to use this")
		return end

		local currentPos = ply:GetPos()
		local eyePos = ply:EyePos()
		local currentAngle = ply:EyeAngles()

		local isBonus = Core.IsBonus(ply.Style)
		local sequence = Core.BonusToSequence(ply.Style)

		local isStaging = ply:GetNWBool "StageTimer"
		local currentStage = ply:GetNWInt "Stage"
		local results
		if isBonus then
			results = Zones:GetZoneBounds(Zones.Type["Bonus " .. (sequence != 1 and sequence .. " " or "") .. "Start"])
		elseif (isStaging and currentStage > 1) then
			results = Zones:GetZoneBounds(Zones.Type["Stage " .. currentStage])
		else
			results = Zones:GetZoneBounds(Zones.Type["Normal Start"])
		end

		local isInside = false
		for _,data in pairs(results) do
			local min, max = data[1], data[2]
			local passed = currentPos:WithinAABox(min, max)
			local passedEyes = eyePos:WithinAABox(min, max)
			if passed or passedEyes then isInside = true end
		end

		if isInside and !isBonus and !isStaging then
			ply.PreferredSpawn = currentPos
			ply.PreferredAngles = currentAngle
			Core:SendColor(ply, "Your preferred spawnpoint has been set")
		return end

		if isInside and isBonus then
			if !ply.PreferredBonusSpawn then
				ply.PreferredBonusSpawn = {}
				ply.PreferredBonusAngles = {}
			end

			ply.PreferredBonusSpawn[sequence] = currentPos
			ply.PreferredBonusAngles[sequence] = currentAngle
			return Core:SendColor(ply, "Your preferred [", CL.Yellow, Core:StyleName(ply.Style), CL.White, "] spawnpoint has been set")
		elseif (isInside and isStaging) then
			if !ply.PreferredStageSpawn then
				ply.PreferredStageSpawn = {}
				ply.PreferredStageAngles = {}
			end

			ply.PreferredStageSpawn[currentStage] = currentPos
			ply.PreferredStageAngles[currentStage] = currentAngle

			return Core:SendColor(ply, "Your preferred [", CL.Yellow, "Stage " .. currentStage, CL.White, "] spawnpoint has been set")
		end

		Core:SendColor(ply, "Failed to set a spawnpoint")
	end )

	self:Register( { "mtop", "maptop", "sr" }, function( ply, args )
		local hasArgs = args and #args > 0
		if hasArgs then
			local map = args[1]
			map = Zones:AttemptMapTranslation(map)

			Timer.GenerateRecordList( ply, 1, map )
		else
			Timer.GenerateRecordList( ply )
		end
	end )

	self:Register( { "swmtop", "swmaptop", "swtopmap", "swsr" }, function( ply, args )
		local hasArgs = args and #args > 0
		if hasArgs then
			local map = args[1]
			map = Zones:AttemptMapTranslation(map)

			Timer.GenerateRecordList( ply, 2, map )
		else
			Timer.GenerateRecordList( ply, 2 )
		end
	end )

	self:Register( { "hswmtop", "hswmaptop", "hswtopmap", "hswsr" }, function( ply, args )
		local hasArgs = args and #args > 0
		if hasArgs then
			local map = args[1]
			map = Zones:AttemptMapTranslation(map)

			Timer.GenerateRecordList( ply, 3, map )
		else
			Timer.GenerateRecordList( ply, 3 )
		end
	end )

	self:Register( { "100mtop", "100maptop", "100topmap", "100sr" }, function( ply, args )
		local hasArgs = args and #args > 0
		if hasArgs then
			local map = args[1]
			map = Zones:AttemptMapTranslation(map)

			Timer.GenerateRecordList( ply, 44, map )
		else
			Timer.GenerateRecordList( ply, 44 )
		end
	end )

	self:Register( { "33mtop", "33maptop", "33topmap", "33sr" }, function( ply, args )
		local hasArgs = args and #args > 0
		if hasArgs then
			local map = args[1]
			map = Zones:AttemptMapTranslation(map)

			Timer.GenerateRecordList( ply, 45, map )
		else
			Timer.GenerateRecordList( ply, 45 )
		end
	end )

	self:Register( { "wickedtop", "wickedmtop", "wickedsr", "wsr" }, function( ply, args )
		local hasArgs = args and #args > 0
		if hasArgs then
			local map = args[1]
			map = Zones:AttemptMapTranslation(map)

			Timer.GenerateRecordList( ply, 6, map )
		else
			Timer.GenerateRecordList( ply, 6 )
		end
	end )

	self:Register( { "btop", "bonustop", "bsr" }, function( ply, args )
		local hasArgs = args and #args > 0
		if hasArgs then
			local bonusormap = args[1]
			if tonumber(bonusormap) then
				local bonus = Core.SequenceToBonus( bonusormap )
				local map = Zones:AttemptMapTranslation(args[2] or game.GetMap()) or game.GetMap()

				Timer.GenerateRecordList( ply, bonus, map )
			else
				Timer.GenerateRecordList( ply, 4, Zones:AttemptMapTranslation(bonusormap) )
			end
		else
			Timer.GenerateRecordList( ply, 4 )
		end
	end )

	self:Register( { "stop", "stagetop", "cptop", "cpr" ,"wrcp"}, function( ply, args )
		local currentStyle = ply.Style
		local currentStage = ply:GetNWInt "Stage"

		local hasArgs = args and #args > 0
		if hasArgs then
			local stageormap = args[1]
			if tonumber(stageormap) then
				local stage = tonumber(stageormap)
				local map = Zones:AttemptMapTranslation(args[2] or game.GetMap()) or game.GetMap()

				Stage.GenerateRecordList( ply, currentStyle, stage, map )
			else
				Stage.GenerateRecordList( ply, currentStyle, currentStage, Zones:AttemptMapTranslation(stageormap) )
			end
		else
			Stage.GenerateRecordList( ply, currentStyle, currentStage )
		end
	end )

	self:Register( { "hug", "ily", "iloveyou", "ifuckingloveyou" }, function( ply )
		if ply.HugRateLimit and ((ply.HugRateLimit + 30) >= CurTime()) then return end

		ply.HugRateLimit = CurTime()

		local trace = ply:GetEyeTrace()
		local pos = ply:GetPos()
		local distance = pos:Distance(trace.HitPos)
		local target = trace.Entity

		if !IsValid(target) or !target:IsPlayer() or target:IsBot() or (distance > 600) then
			Core:SendColorBase(ply, Color(255, 0, 0), "You feel so incredibly lonely and tentatively, yet with purpose put your arms around yourself.\nIt is in this moment you gently hug yourself knowing your own warmth is all you seemingly have.")
		return end

		local username = ply:Nick()
		local targetname = target:Nick()

		Core:SendColorBase(ply, Color(255, 0, 174), "You have given " .. targetname .. " a big warm hug!")
		Core:SendColorBase(target, Color(255, 0, 174), username .. " has given you a big warm hug!")
	end )

	self:Register( { "emote", "me", "say" }, function( ply, args )
		Admin.VIPProcess( ply, { "me", args.Upper }, true )
	end )

	self:Register( { "timescale" }, function( ply, args )
		local isVIP = (ply.VIPLevel >= Admin.Level.Base)
		if !isVIP then
			Core:SendColor( ply, "You need to have a vip subscription active in order to use this" )
		return end

		local hasArgs = (args and #args > 0)
		local timescale = tonumber( args[1] )
		if !hasArgs or !timescale then
			Core:SendColor( ply, "You must supply a valid scale number from 0.25-5.00" )
		return end

		local isPractice = ply:GetNWBool "Practice"
		if !isPractice then
			ply:SetNWBool( "Practice", true )
			Core:SendColor( ply, "Your SurfTimer was disabled for using ", CL.Yellow, "!timescale" )
		end

		-- Updated this so players can't potentially break the server when going super fast --
		timescale = math.Clamp(timescale, 0.25, 5)

		ply:SetLaggedMovementValue( timescale )
		Core:SendColor( ply, "Timescale: ", CL.Blue, timescale )
	end )

	local playSounds = {
		["bongo"] = "ambient/music/bongo.wav",
		["country"] = "ambient/music/country_rock_am_radio_loop.wav",
		["cuban"] = "ambient/music/cubanmusic1.wav",
		["dust"] = "ambient/music/dustmusic1.wav",
		["dusttwo"] = "ambient/music/dustmusic2.wav",
		["dustthree"] = "ambient/music/dustmusic3.wav",
		["flamenco"] = "ambient/music/flamenco.wav",
		["latin"] = "ambient/music/latin.wav",
		["mirame"] = "ambient/music/mirame_radio_thru_wall.wav",
		["piano"] = "ambient/music/piano1.wav",
		["pianotwo"] = "ambient/music/piano2.wav",
		["radio"] = "looping_radio_mix.wav",
		["guit"] = "ambient/guit1.wav",
		["bubblegum"] = "bubblegum.wav",
	}

	for name,dest in pairs(playSounds) do
		sound.Add({name = name, channel = CHAN_STATIC, volume = 1, level = 100, pitch = 100, sound = dest})
	end

	self:Register( { "playsound", "emitsound" }, function( ply, args )
		local isVIP = (ply.VIPLevel >= Admin.Level.Base)
		if !isVIP then
			Core:SendColor( ply, "You need to have a vip subscription active in order to use this" )
		return end

		local hasArgs = (args and #args > 0)
		local soundrequest = string.lower( args[1] )
		local soundfile = playSounds[soundrequest]
		if !hasArgs or (soundrequest != "stop" and !soundfile ) then
			Core:SendColor( ply, "You must supply a valid soundfile (if unsure check your SurfTimer VIP tab)" )
		return end

		-- If we never played a sound, don't try to stop it --
		if ply.EmittingSound and (soundrequest == "stop") then
			ply:StopSound( ply.EmittingSound )
			ply.EmittingSound = nil
		return end

		Command.EmitSound( ply, soundrequest )
		ply.EmittingSound = soundrequest

		Core:SendColor( ply, "You are now playing [", CL.Yellow, soundrequest, CL.White, "]" )
	end )

	-- Different handler functions
	self:Register( "admin", Admin.CommandProcess )
	self:Register( "vip", Admin.VIPProcess )

	-- Default functions
	self:Register( "invalid", function( ply, args )
		Core:Send( ply, "Print", { "General", Lang:Get( "InvalidCommand", { args.Key } ) } )
	end )
end

function Command.BroadcastNotify( user, command )
	local name = user:Name()
	local cmd  = "/" .. command
	for _,admins in pairs( player.GetHumans() ) do
		if !Admin:CanAccess( admins, Admin.Level.Moderator ) then continue end

		Core:SendColor( admins, CL.Yellow, name, CL.White, " used the ", CL.Yellow, cmd, CL.White, " command")
	end
end

-- 05/07/2021: Added pauseable/resumeable save states which will toggle Practice mode --
local saveStates = {}
function Command.SaveState(ply)
	-- This only works on Staged Maps --
	local isStaged = (Timer.Type == 1)
	if !isStaged then return end

	-- Don't allow practice mode to save --
	local isPractice = ply:GetNWBool "Practice"
	if isPractice then return end

	-- This doesn't work with Stage Timers, so don't do anything here --
	local isStaging = ply:GetNWBool "StageTimer"
	if isStaging then return end

	-- Get current time, if we don't have a timer running don't do anything --
	local currentTime = (ply.Tn and CurTime() - ply.Tn) or 0
	if (currentTime == 0) then return end

	-- Get current stage, stage 1 states are not allowed to be saved --
	local currentStage = ply:GetNWInt "Stage"
	if (currentStage == 1) then return end

	local style = ply.Style

	saveStates[ply] = {currentTime, currentStage, style}
	Core:SendColor(ply, "Your run has been saved, restore it either by using the restart key or using ", CL.Yellow, "!restore")

	ply:StopAnyTimer()
	ply:SetNWBool("Practice", true)

	-- Let the caller know we succeeded this operation --
	return true
end

function Command.ResumeState(ply)
	-- This only works on Staged Maps --
	local isStaged = (Timer.Type == 1)
	if !isStaged then return end

	-- If we don't have a save state, don't do anything --
	local savedIndice = saveStates[ply]
	if !savedIndice then return end

	-- This doesn't work with Stage Timers, so don't do anything here --
	local isStaging = ply:GetNWBool "StageTimer"
	if isStaging then return end

	-- Restore the state, and delete save state --
	local time, stage, style = unpack(savedIndice)
	saveStates[ply] = nil

	-- Get the current stage start point, if we don't have a point then this run is marked as invalid --
	local vPoint = Zones:GetCenterPoint( Zones.Type["Stage " .. stage] )
	if !vPoint then return end

	ply.MovingPos = true
	ply:ResetTimer()
	ply:StageReset()
	ply:SetPos( vPoint )
	ply:SetLaggedMovementValue(1)
	ply:SetLocalVelocity( Vector( 0, 0, 0 ) )
	ply:SetMoveType(MOVETYPE_WALK)

	Core:SendColor(ply, "Your run has been restored")

	timer.Simple(0.030, function()
		ply.Tn = (CurTime() - time)
		Core:Send( ply, "Timer", { "Map", "Start", ply.Tn } )

		ply:SetNWBool("Practice", false)

		ply.Style = style
		ply:SetNWInt("Style", style)

		ply.MovingPos = false
	end)

	-- Let the caller know we succeeded this operation --
	return true
end

function Command.IsSavedState(ply)
	return saveStates[ply]
end

function Command:Register( varCommand, varFunc )
	local MainCommand, CommandList = "undefined", { "undefined" }
	if type( varCommand ) == "table" then
		MainCommand = varCommand[ 1 ]
		CommandList = varCommand
	elseif type( varCommand ) == "string" then
		MainCommand = varCommand
		CommandList = { varCommand }
	end

	Command.Functions[ MainCommand ] = { CommandList, varFunc }
end

function Command:Trigger( ply, szCommand, szText )
	if ply.PermanentSurfTimer == 1 then
		return Core:Send( ply, "Print", { "Notification", "Command functionality has been disabled." } )
	end

	local szFunc = nil
	local mainCommand, commandArgs = szCommand, {}

	if string.find( szCommand, " ", 1, true ) then
		local splitData = string.Explode( " ", szCommand )
		mainCommand = splitData[ 1 ]

		local splitDataUpper = string.Explode( " ", szText )
		commandArgs.Upper = {}

		for i = 2, #splitData do
			table.insert( commandArgs, splitData[ i ] )
			table.insert( commandArgs.Upper, splitDataUpper[ i ] )
		end
	end

	for _, data in pairs( Command.Functions ) do
		for __, alias in pairs( data[ 1 ] ) do
			if mainCommand == alias then
				szFunc = data[ 1 ][ 1 ]
				break
			end
		end
	end

	if !szFunc then szFunc = "invalid" end
	commandArgs.Key = mainCommand

	local varFunc = Command.Functions[ szFunc ]
	if varFunc then
		varFunc = varFunc[ 2 ]
		return varFunc( ply, commandArgs )
	end

	return nil
end

function Command:GetHelp()
	if !HelpData or !HelpLength then
		local tab = {}

		for command,data in pairs( Command.Functions ) do
			if !Lang.Commands[ command ] then continue end
			table.insert( tab, { Lang.Commands[ command ], data[ 1 ] } )
		end

		HelpData = util.Compress( util.TableToJSON( tab ) )
		HelpLength = #HelpData
	end
end

function Command.Restart( ply, spAngle, spData )
	if ply:Team() != _C.Team.Spectator then
		local szWeapon = nil
		if IsValid( ply:GetActiveWeapon() ) then
			szWeapon = ply:GetActiveWeapon():GetClass() or _C.Player.DefaultWeapon
		end

		local deepWithin = (!ply.DeepWithinConfirm) and (!ply.TnF and ply.Tn and ((CurTime() - ply.Tn) > 10 * 60))
		if (deepWithin) then
			ply.DeepWithinConfirm = true
			Core:SendColor(ply, "You appear to be far in a run and so this command was blocked, if you want to restart use this command again")
		return end

		ply.DeepWithinConfirm = false
		ply.ReceiveWeapons = !!szWeapon
		ply:KillSilent()
		ply:Spawn()
		ply.ReceiveWeapons = nil
		ply:SetMoveType( MOVETYPE_WALK )
		ply:SetNWBool("Practice", false)
		ply:SetNWBool("surf_canJump", true)

		if szWeapon and ply:HasWeapon( szWeapon ) then
			ply:SelectWeapon( szWeapon )
		end

		-- Turn off Stage Timer when restarting --
		local isStaging = ply:GetNWBool "StageTimer"
		if isStaging then
			ply:SetNWBool( "StageTimer", false )
			Core:SendColor( ply, "You have exited Stage Mode" )
		end

		-- Restore savestates if one is available --
		local hasSavedState = Command.IsSavedState(ply)
		if hasSavedState then
			Command.ResumeState(ply)
		end
	end
end

function Command.Style( ply, _, varArgs )
	if ply.PermanentSurfTimer == 1 then
		return Core:Send( ply, "Print", { "Notification", "This functionality has been disabled." } )
	end

	local style = varArgs and tonumber( varArgs[1] ) or 1
	local styleName = Core:StyleName( style )
	local isBonus = string.StartWith( styleName, "Bonus" )

	local isCurrentStyle = (style == ply.Style)
	if isCurrentStyle then
		if isBonus then
			Command.Restart( ply )
		return end

		Core:SendColor( ply, "You are already playing on the ", CL.Yellow, styleName, CL.White, " style.\nTo change styles use the ", CL.Yellow, "!style", CL.White, " command." )
	return end

	if isBonus then
		if (style == _C.Style.Bonus) and !Zones.BonusPoint then
			Core:SendColor( ply, "This bonus either doesn't exist or isn't zoned" )
		return end

		for i = 2, 10 do
			if (style == _C.Style["Bonus " .. i]) and !Zones["Bonus " .. i .. " Point"] then
				Core:SendColor( ply, "This bonus either doesn't exist or isn't zoned" )
			return end
		end
	end

	if saveStates[ply] then
		saveStates[ply] = nil
		Core:SendColor( ply, "Your savestate has been removed because you switched styles" )
	end

	Player:LoadStyle( ply, style )
	Timer.SendInfo( ply )
	Stage.SendInfo( ply )
end

function Command.Spectate( ply, _, varArgs )
	if ply.Spectating and varArgs and varArgs[ 1 ] then
		return Spectator:NewById( ply, varArgs[ 1 ], true, varArgs[ 2 ] )
	elseif ply.Spectating then
		local target = ply:GetObserverTarget()
		ply:SetTeam( _C.Team.Players )

		Command.Restart( ply )
		ply.Spectating = false
		ply:SetNWInt( "Spectating", 0 )
		Core:Send( ply, "Spectate", { "Clear" } )
		Core:Send( ply, "Client", { "Display" } )
		Spectator:End( ply, target )

		if Admin:CanAccess( ply, Admin.Level.Admin ) then
			SMgrAPI:SendSyncData( ply, {} )
		end
	else
		Command.SaveState(ply)

		ply:SetNWInt( "Spectating", 1 )
		Core:Send( ply, "Spectate", { "Clear" } )
		ply.Spectating = true
		ply:KillSilent()
		ply:ResetTimer()
		GAMEMODE:PlayerSpawnAsSpectator( ply )
		ply:SetTeam( TEAM_SPECTATOR )

		if varArgs and varArgs[ 1 ] then
			return Spectator:NewById( ply, varArgs[ 1 ], nil, varArgs[ 2 ] )
		end

		Spectator:New( ply )
	end
end

function Command.Nominate( ply, _, varArgs )
	if !varArgs[ 1 ] then return end
	varArgs[1] = Zones:AttemptMapTranslation(varArgs[1])

	if !RTV:MapExists( varArgs[ 1 ] ) then return Core:Send( ply, "Print", { "Notification", Lang:Get( "MapInavailable", { varArgs[ 1 ] } ) } ) end
	if varArgs[ 1 ] == game.GetMap() then return Core:Send( ply, "Print", { "Notification", Lang:Get( "NominateOnMap" ) } ) end
	if !RTV:IsAvailable( varArgs[ 1 ] ) then return Core:Send( ply, "Print", { "Notification", "Sorry, this map isn't available on the server itself. Please contact an admin!" } ) end

	RTV:Nominate( ply, varArgs[ 1 ] )
end

function Command.NoClip( ply, _, varArgs )
	local isPractice = ply:GetNWBool "Practice"
	if !isPractice then
		ply:SetNWBool( "Practice", true )
		Core:SendColor( ply, "Your SurfTimer has been disabled for using ", CL.Yellow, "!noclip" )
	end

	ply:ConCommand "noclip"
end

-- Fuck what did I do here --

function Command.EmitSound( ply, varArgs )
	if ply.EmittingSound then
		ply:StopSound( ply.EmittingSound )
	end

	ply:EmitSound( varArgs )
end

function Command.StageTeleport( ply )
	ply:SendLua( "RunConsoleCommand( \"say\", \"/tele\" )" )
end

function Command.SurfTimer( ply )
	ply:SendLua( "RunConsoleCommand( \"say\", \"/surftimer\" )" )
end

function Command.ServerCommand( ply, szCmd, varArgs )
	local bConsole = false
	if !IsValid( ply ) and !ply.Name and !ply.Team then
		bConsole = true
	end
	if !bConsole then return end

	if szCmd == "gg" then
		Core:BroadcastColor( "The server has requested a map refresh! changing in 5 seconds." )

		timer.Simple( 5, function()
			RunConsoleCommand( "changelevel", game.GetMap() )
		end )

		Bot:Save()
	elseif szCmd == "botsave" or szCmd == "savebot" then
		Bot:Save()
	elseif szCmd == "stop" then
		RunConsoleCommand( "exit" )
	elseif szCmd == "dodebug" then
		if CommandIncomplete then
			PrintTable( CommandIncomplete )
		end
	end
end

function Command.Telenext(ply)
	local isPractice = ply:GetNWBool "Practice"
	if !isPractice then
		Core:SendColor( ply, "You need to disable your SurfTimer to use this" )
	return end

	local lastCP = ply.LastCheckPoint
	if !lastCP then
		Core:Send( ply, "Print", { "Surf Timer", "You need to teleport to a checkpoint first before using this" } )
	return end

	local wantsGlobal = (ply:GetInfo "sl_globalcheckpoints" == "1")
	if wantsGlobal then
		if (#TIMER_CHECKPOINTS == 0) then
			Core:Send( ply, "Print", { "Surf Timer", "There are no global checkpoints available" } )
		return end

		local newCP = TIMER_CHECKPOINTS[lastCP + 1]
		if !newCP then
			Core:Send( ply, "Print", { "Surf Timer", "There are no more checkpoints to move forward to" } )
		return end

		Timer.LoadCheckpoint( ply, _, _, _, lastCP + 1 )
	else
		if (!ply.Checkpoints or #ply.Checkpoints == 0) then
			Core:Send( ply, "Print", { "Surf Timer", "You haven't placed any checkpoints" } )
		return end

		local newCP = ply.Checkpoints[lastCP + 1]
		if !newCP then
			Core:Send( ply, "Print", { "Surf Timer", "There are no more checkpoints to move forward to" } )
		return end

		Timer.LoadCheckpoint( ply, _, _, _, lastCP + 1 )
	end
end

function Command.Teleprev(ply)
	local isPractice = ply:GetNWBool "Practice"
	if !isPractice then
		Core:SendColor( ply, "You need to disable your SurfTimer to use this" )
	return end

	local lastCP = ply.LastCheckPoint
	if !lastCP then
		Core:Send( ply, "Print", { "Surf Timer", "You need to teleport to a checkpoint first before using this" } )
	return end

	local wantsGlobal = (ply:GetInfo "sl_globalcheckpoints" == "1")
	if wantsGlobal then
		if (#TIMER_CHECKPOINTS == 0) then
			Core:Send( ply, "Print", { "Surf Timer", "There are no global checkpoints available" } )
		return end

		local newCP = TIMER_CHECKPOINTS[lastCP - 1]
		if !newCP then
			Core:Send( ply, "Print", { "Surf Timer", "There are no more checkpoints to move backwards to" } )
		return end

		Timer.LoadCheckpoint( ply, _, _, _, lastCP - 1 )
	else
		if (!ply.Checkpoints or #ply.Checkpoints == 0) then
			Core:Send( ply, "Print", { "Surf Timer", "You haven't placed any checkpoints" } )
		return end

		local newCP = ply.Checkpoints[lastCP - 1]
		if !newCP then
			Core:Send( ply, "Print", { "Surf Timer", "There are no more checkpoints to move backwards to" } )
		return end

		Timer.LoadCheckpoint( ply, _, _, _, lastCP - 1 )
	end
end

concommand.Add( "sm_restart", Command.Restart, nil, "Restarts the player to the start of the map." )
concommand.Add( "sm_spectate", Command.Spectate, nil, "Sends the player to the spectator team." )
concommand.Add( "sm_style", Command.Style, nil, "Changes the style of the player based on style ID." )
concommand.Add( "sm_nominate", Command.Nominate, nil, "Nominates the map that the player wants to play next." )
concommand.Add( "sm_surftimer", Command.SurfTimer, nil, "Sends the player the SurfTimer menu which gives the player options to toggle most server and client settings." )
concommand.Add( "sm_noclip", Command.NoClip, nil, "Toggles noclip for the player." )
concommand.Add( "sm_tele", Command.StageTeleport, nil, "Sends the player back to the stage they are currently on, or can teleport a player to their desired saveloc." )

concommand.Add( "gg", Command.ServerCommand, nil, "Reloads the current map." )
concommand.Add( "botsave", Command.ServerCommand, nil, "Saves the bot even if no bots are available to save." )
concommand.Add( "stop", Command.ServerCommand, nil, "Kills the server process." )
concommand.Add( "dodebug", Command.ServerCommand, nil, "Logs the server status." )

concommand.Add( "sm_telenext", Command.Telenext, nil, "Sends you to the next saveloc if created." )
concommand.Add( "sm_teleprev", Command.Teleprev, nil, "Sends you to the previous saveloc if created." )
