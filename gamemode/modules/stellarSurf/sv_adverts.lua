-- Chat notifications/advertisements --

local adverts = {
	[1] = {"You can change your SurfTimer settings using either ", CL.Yellow, "F1", CL.White, " or ", CL.Yellow, "!surftimer"},
	[2] = {"Want to know what rank you are on the server? ", CL.Yellow, "!rank"},
	[3] = {"You can enable experimental server features by using ", CL.Yellow, "!devtools"},
	[4] = {"View your server profile using either ", CL.Yellow, "F3", CL.White, " or ", CL.Yellow, "!profile"},
	[5] = {"Want to watch a replay of the fastest server record? ", CL.Yellow, "!specbot"},
	[6] = {"Consider joining our server discord for server updates and discussions, ", CL.Yellow, "!discord"},
	[7] = {"Spectate other players by using ", CL.Yellow, "F2", CL.White, " or ", CL.Yellow, "!spectate"},
	[8] = {"Be sure to read our server rules using ", CL.Yellow, "!rules"},
	[9] = {"Having an issue with the server or have suggestions? You can report it using ", CL.Yellow, "!report"},
	[10] = {"VIPs have extra features to help with speedrunning maps. Interested in becoming a VIP? Contact the server owner"},
	[11] = {"You can save/restore your timer and stage using ", CL.Yellow, "!save", CL.White, "/", CL.Yellow, "!restore"},
	[12] = {"You can watch every stage/bonus bot you want with ", CL.Yellow, "!mbot"},
	[13] = {"Is the current map a bit too hard? Try ", CL.Yellow, "!100", CL.White, " or ", CL.Yellow, "!wicked"},
	[14] = {"Are you new to surf? Watch our tutorial with ", CL.Yellow, "!tutorial"},
}

local function BroadcastAdvert()
	local indice = math.random(1, #adverts)
	local advert = adverts[indice]
	if !advert then
		BroadcastAdvert()
	return end

	local prefix = "Tips"

	Core:BroadcastColorBase(_C.Prefixes[prefix], "[" .. prefix .. "] - ", CL.White, unpack(advert))
end
timer.Create("surf.Adverts", 60 * 5, 0, BroadcastAdvert)

Surf:Notify( "Success", "Loaded gamemode adverts" )
