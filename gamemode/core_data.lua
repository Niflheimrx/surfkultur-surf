if SQL then return end

SQL = {}
SQL.Use = true

require( "mysqloo" )


Core = Core or {}
Core.Protocol = "SecureTransfer"
Core.Protocol2 = "BinaryTransfer"

Core.MessageTransfer = "sm_message"
Core.MessageBaseTransfer = "sm_messagebase"

Core.Locked = false
Core.Try = 0

CL = {
	Yellow = "#CL.Yellow#",
	White = "#CL.White#",
	Blue = "#CL.Blue#",
	Purple = "#CL.Purple#",
	Green = "#CL.Green#",
	Orange = "#CL.Orange#",
}

util.AddNetworkString( Core.Protocol )
util.AddNetworkString( Core.Protocol2 )
util.AddNetworkString( Core.MessageTransfer )
util.AddNetworkString( Core.MessageBaseTransfer )

function Core:Boot()
	Command:Init()
	RTV:Init()

	if SQL.Use == false then
		Timer:LoadRecords()
		Stage:LoadRecords()
		Player:LoadRanks()
		Player:LoadTop()
		Core:LoadZones()
	end
end

function Core:Unload( bForce )
	--Bot:Save( bForce )
end


function Core:LoadZones()
	Zones.Cache = {}

	SQL:Prepare(
		"SELECT nType, vPos1, vPos2 FROM game_zones WHERE szMap = {0}",
		{ game.GetMap() }
	):Execute( function( zones )
		if !zones then return end

		Zones.Cache = {}
		for _,data in pairs( zones ) do
			table.insert( Zones.Cache, {
				Type = tonumber( data[ "nType" ] ),
				P1 = util.StringToType( tostring( data[ "vPos1" ] ), "Vector" ),
				P2 = util.StringToType( tostring( data[ "vPos2" ] ), "Vector" )
			} )
		end

		Zones:Setup()
		Surf:Notify( "Debug", "Loaded " .. (#zones or 0) .. " zones" )
	end )
end


function Core:AwaitLoad( bRetry )
	if not bRetry then
		Bot:Setup()
		Core:Optimize()

		if SQL.Use then
			if timer.Exists( "SQLCheck" ) then
				timer.Destroy( "SQLCheck" )
			end

			timer.Create( "SQLCheck", 10, 0, Core.SQLCheck )
		else
			SQL:LoadNoMySQL()
		end
	end
end

function Core.SQLCheck()
	if not SQL.Use then return end

	if (not Admin.Loaded or SQL.Error) and not Core.SQLChecking then
		SQL.Error = nil
		Core.SQLChecking = true
	end
end

local FirstLock
function Core:Lock( szMessage )
	if not FirstLock then
		FirstLock = szMessage
	end

	Core.Locked = true

	for k,v in pairs( player.GetAll() ) do
		v:Kick( Lang:Get( "AdminDataFailure", { FirstLock } ) )
	end

	for i = 1, 3 do
		print( "[LOCKING MECHANISM]", "Your server has been locked for this reason:", FirstLock )
	end

	print( "[LOCKING MECHANISM]", "Player has been locked out:", szMessage )
end

function Core:Assert( varType, szType )
	if varType and type( varType ) == "table" and varType[ 1 ] and type( varType[ 1 ] ) == "table" and varType[ 1 ][ szType ] then
		return true
	end

	return false
end

function Core:Null( varInput, varAlternate )
	if varInput and type( varInput ) == "string" and varInput != "NULL" then
		return varInput
	end

	return varAlternate or nil
end

function Core:Print( szPrefix, szText )
	print( "[" .. (szPrefix or "Core") .. "]", szText )
end


function Core:AddResources()
	resource.AddFile( "materials/" .. _C.MaterialID .. "/timer.png" )

	resource.AddFile( "resource/fonts/latoregular.ttf" )
	resource.AddFile( "sound/looping_radio_mix.wav" )
	resource.AddFile( "sound/bubblegum.wav" )

	for i = 1, 13 do
		resource.AddFile( "materials/" .. _C.MaterialID .. "/icon_rank" .. i .. ".png" )
	end

	for i = 1, 6 do
		resource.AddFile( "materials/" .. _C.MaterialID .. "/icon_special" .. i .. ".png" )
	end
end

function Core:Send( ply, szAction, varArgs )
	net.Start( Core.Protocol )
	net.WriteString( szAction )

	if varArgs and type( varArgs ) == "table" then
		net.WriteBit( true )
		net.WriteTable( varArgs )
	else
		net.WriteBit( false )
	end

	net.Send( ply )
end

function Core:SendColor( ply, ... )
	local function writeChatArguments(...)
		local function write(n, a, ...)
			if n == 0 then return end

			if IsColor(a) then
				net.WriteBool(true) net.WriteColor(a)
			else
				net.WriteBool(false) net.WriteString(tostring(a))
			end

			return write(n - 1, ...)
		end

		local count = select('#', ...)
		net.WriteUInt(count, 8)
		return write(count, ...)
	end

	net.Start( Core.MessageTransfer )
	writeChatArguments( ... )
	net.Send( ply )
end

function Core:SendColorSpec(ply, ...)
	Core:SendColor(ply:GetSpectators(true), ...)
end

function Core:SendColorBase(ply, ...)
	local function writeChatArguments(...)
		local function write(n, a, ...)
			if n == 0 then return end

			if IsColor(a) then
				net.WriteBool(true) net.WriteColor(a)
			else
				net.WriteBool(false) net.WriteString(tostring(a))
			end

			return write(n - 1, ...)
		end

		local count = select('#', ...)
		net.WriteUInt(count, 8)
		return write(count, ...)
	end

	net.Start( Core.MessageBaseTransfer )
	writeChatArguments( ... )
	net.Send( ply )
end

function Core:Broadcast( szAction, varArgs, varExclude )
	net.Start( Core.Protocol )
	net.WriteString( szAction )

	if varArgs and type( varArgs ) == "table" then
		net.WriteBit( true )
		net.WriteTable( varArgs )
	else
		net.WriteBit( false )
	end

	if varExclude and (type( varExlude ) == "table" or (IsValid( varExclude ) and varExclude:IsPlayer())) then
		net.SendOmit( varExclude )
	else
		net.Broadcast()
	end
end

function Core:BroadcastColor( ... )
	local function writeChatArguments(...)
		local function write(n, a, ...)
			if n == 0 then return end

			if IsColor(a) then
				net.WriteBool(true) net.WriteColor(a)
			else
				net.WriteBool(false) net.WriteString(tostring(a))
			end

			return write(n - 1, ...)
		end

		local count = select('#', ...)
		net.WriteUInt(count, 8)
		return write(count, ...)
	end

	net.Start( Core.MessageTransfer )
	writeChatArguments( ... )
	net.Broadcast()
end

function Core:BroadcastColorBase( ... )
	local function writeChatArguments(...)
		local function write(n, a, ...)
			if n == 0 then return end

			if IsColor(a) then
				net.WriteBool(true) net.WriteColor(a)
			else
				net.WriteBool(false) net.WriteString(tostring(a))
			end

			return write(n - 1, ...)
		end

		local count = select('#', ...)
		net.WriteUInt(count, 8)
		return write(count, ...)
	end

	net.Start( Core.MessageBaseTransfer )
	writeChatArguments( ... )
	net.Broadcast()
end

local function CoreHandle( ply, szAction, varArgs )
	if szAction == "Admin" then
		Admin:HandleClient( ply, varArgs )
	elseif szAction == "Speed" then
		Timer:AddSpeedData( ply, varArgs )
	elseif szAction == "WRList" then
		Timer:SendWRList( ply, varArgs[ 1 ], varArgs[ 2 ], varArgs[ 3 ] )
	elseif szAction == "MapList" then
		RTV:GetMapList( ply, varArgs[ 1 ] )
	elseif szAction == "Vote" then
		RTV:ReceiveVote( ply, varArgs[ 1 ], varArgs[ 2 ] )
	elseif szAction == "TopList" then
		Player:SendTopList( ply, varArgs[ 1 ], varArgs[ 2 ] )
	elseif szAction == "Checkpoints" then
		Timer:CPHandleCallback( ply, varArgs[ 1 ], varArgs[ 2 ], varArgs[ 3 ] )
	elseif szAction == "SurfTop" then
		local group = varArgs[1]
		Player:LoadLeaderboardTop( ply, group )
	end
end

local function CoreReceive( _, ply )
	local szAction = net.ReadString()
	local bTable = net.ReadBit() == 1
	local varArgs = {}

	if bTable then
		varArgs = net.ReadTable()
	end

	if IsValid( ply ) and ply:IsPlayer() then
		CoreHandle( ply, szAction, varArgs )
	end
end
net.Receive( Core.Protocol, CoreReceive )

local function BinaryReceive( l, ply )
	local length = net.ReadUInt( 32 )
	local data = net.ReadData( length )

	if IsValid( ply ) then
		local target = Admin.Screenshot[ ply ]
		if IsValid( target ) then
			net.Start( Core.Protocol2 )
			net.WriteString( "Data" )
			net.WriteUInt( length, 32 )
			net.WriteData( data, length )
			net.Send( target )

			Admin.Screenshot[ ply ] = nil
		end
	end
end
net.Receive( Core.Protocol2, BinaryReceive )


--- SQL ---

SQL.Available = false

local SQLObject
local SQLDetails = {
	Host = "localhost", Port = 3306,
	User = "root", Pass = "",
	Database = "flow_gmod"
}

local function SQL_Print( szMsg, varArg )
	print( szMsg, varArg or "" )
end

local function SQL_ConnectSuccess( fCallback )
	SQL.Available = true
	SQL.Busy = false

	SQL_Print( "[SQL Connect] Connected to " .. SQLDetails.Host .. " successfully (User: " .. SQLDetails.User .. ")" )

	fCallback()
end

local function SQL_ConnectFailure( obj, szError )
	SQL.Available = false
	SQL.Busy = false

	SQL_Print( "[SQL Connect] Failed to connect: ", szError )
end

local function SQL_Query( szQuery, fCallback, varArgs )
	if not SQLObject or not SQL.Available then
		return SQL_Print( "No valid SQLObject to execute query: ", szQuery )
	elseif not szQuery or szQuery == "" then
		return SQL_Print( "No valid SQLQuery to execute" )
	end

	local query = SQLObject:query( szQuery )
	local function fSuccess( obj, varData )
		if fCallback then
			fCallback( varData, varArgs )
		end
	end

	local function fError( obj, szError, szSQL )
		if fCallback then
			fCallback( nil, nil, szError or "" )
		end

		SQL_Print( "[SQL Error] " .. szError, "(On query: " .. szSQL .. ")" )

		if string.find( string.lower( szError ), "lost connection", 1, true ) or string.find( string.lower( szError ), "gone away", 1, true ) then
			SQL.Error = true
			return false
		end
	end

	query.onSuccess = fSuccess
	query.onError = fError
	query:start()
end

local function SQL_Execute( szQuery, fCallback, varArg )
	SQL_Query( szQuery, function( varData, varArgs, szError )
		fCallback( varData, varArgs, szError )
	end, varArg )
end

function SQL:CreateObject( SQL_ConnectCallback )
	local function SQL_SelectCallback()
		SQL_ConnectSuccess( SQL_ConnectCallback )
	end

	SQL.Busy = true

	SQLObject = mysqloo.connect( SQLDetails.Host, SQLDetails.User, SQLDetails.Pass, SQLDetails.Database, SQLDetails.Port )
	SQLObject.onConnected = SQL_SelectCallback
	SQLObject.onConnectionFailed = SQL_ConnectFailure
	SQLObject:connect()
end

function SQL:Prepare( szQuery, varArgs, bNoQuote )
	if not SQL.Use then
		return SQL:LocalPrepare( szQuery, varArgs, bNoQuote )
	end

	if not SQLObject or not SQL.Available then
		SQL_Print( "No valid SQLObject to prepare query: " .. szQuery )
		return { Execute = function() end }
	end

	if varArgs and #varArgs > 0 then
		for i = 1, #varArgs do
			local sort = type( varArgs[ i ] )
			local num = tonumber( varArgs[ i ] )
			local arg = ""

			if sort == "string" and not num then
				arg = SQLObject:escape( varArgs[ i ] )
				if not bNoQuote then
					arg = "'" .. arg .. "'"
				end
			elseif (sort == "string" and num) or (sort == "number") then
				arg = varArgs[ i ]
			else
				arg = tostring( varArgs[ i ] ) or ""
				SQL_Print( "Parameter of type " .. sort .. " was parsed to a default value on query: " .. szQuery )
			end

			szQuery = string.gsub( szQuery, "{" .. i - 1 .. "}", arg )
		end
	end

	return { Query = szQuery, Execute = function( self, fCallback, varArg ) SQL_Execute( self.Query, fCallback, varArg ) end }
end

-- No MySQL Custom Part

function SQL:LoadNoMySQL()
	SQL.Use = false

	if not sql.TableExists( "gmod_admins" ) or not sql.TableExists( "gmod_bans" ) then
		Core:Lock( "Missing SQLite tables (gmod_admins and gmod_bans) on No MySQL setup! (Use the correct sv.db or SQL queries)" )

		for i = 0, 3 do
			print( "[LOCKING ERROR]", "You aren't using the right SQLite tables. Be sure to use the correct files from the /Database folder in the release! Or use the preset sv.db" )
		end

		return false
	end

	SQL.LoadedSQLite = true
	SQL.Available = true
	SQL.Busy = false

	SQL_Print( "[SQL Connect] Connected to local SQLite server successfully" )

	local OperatorID = ""
	Admin:LoadAdmins( OperatorID )
	Admin:LoadNotifications()
end

function SQL:LocalPrepare( szQuery, varArgs, bNoQuote )
	if not SQL.LoadedSQLite then
		SQL_Print( "No valid SQLite tables to prepare query: " .. szQuery )
		return { Execute = function() end }
	end

	if varArgs and #varArgs > 0 then
		for i = 1, #varArgs do
			local sort = type( varArgs[ i ] )
			local num = tonumber( varArgs[ i ] )
			local arg = ""

			if sort == "string" and not num then
				arg = sql.SQLStr( varArgs[ i ] )
				if bNoQuote then
					arg = string.sub( arg, 2, string.len( arg ) - 1 )
				end
			elseif (sort == "string" and num) or (sort == "number") then
				arg = varArgs[ i ]
			else
				arg = tostring( varArgs[ i ] ) or ""
				SQL_Print( "Parameter of type " .. sort .. " was parsed to a default value on query: " .. szQuery )
			end

			szQuery = string.gsub( szQuery, "{" .. i - 1 .. "}", arg )
		end
	end

	local varData, szError
	local data = sql.Query( szQuery )

	if data then
		for id,item in pairs( data ) do
			for key,value in pairs( item ) do
				if tonumber( value ) then
					data[ id ][ key ] = tonumber( value )
				end
			end
		end

		varData = data
	else
		local statement = string.sub( szQuery, 1, 6 )
		if statement == "SELECT" then
			szError = sql.LastError() or "Unknown error"
		else
			varData = true
		end
	end

	return { Query = szQuery, Execute = function( self, fCallback, varArg ) fCallback( varData, varArg, szError ) end }
end
