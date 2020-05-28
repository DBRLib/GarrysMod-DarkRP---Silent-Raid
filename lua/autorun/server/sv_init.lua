//----------------Silent Raid----------------------
//
//Silently notifies admins of the starting of a raid
//
//
//commit 07-19-17
//by Mikomi Hooves, Deven Ronquillo
//-------------------------------------------------

//-------------------------------------------------
//					BLogs Setup
//-------------------------------------------------

function SR_initalize( )
	bLogs.CreateCategory("Silent Raid", Color(165, 0, 55, 255))
	bLogs.DefineLogger("Raid Start", "Silent Raid")
	bLogs.DefineLogger("Raid Over", "Silent Raid")


end

if (bLogsInit) then
 	SR_initalize()
 else
 	hook.Add("bLogsInit","SR_initalize",SR_initalize)
end


//-------------------------------------------------
//					ULib Setup
//-------------------------------------------------


ULib.ucl.registerAccess( "Silent Raid", ULib.ACCESS_ADMIN, "Allows player to see raid notifications", "Other" )-- Create ULX catagory for easy assignemnt of who can see this shit notification


//-------------------------------------------------
//			Network stuff
//-------------------------------------------------
util.AddNetworkString( "SR_RaidOver_admin" )
util.AddNetworkString( "SR_RaidStart_admin" )
util.AddNetworkString( "SR_RaidOver_player" )
util.AddNetworkString( "SR_RaidStart_player" )
util.AddNetworkString( "SR_NoRaid" )
util.AddNetworkString( "SR_AlreadyRaid" )
util.AddNetworkString( "SR_Timeup" )
util.AddNetworkString( "SR_Timer_End" )
util.AddNetworkString( "SR_RaidOver_adminnet" )
util.AddNetworkString( "SR_RemoveTimer" )
util.AddNetworkString( "SR_SelfRaid" )
util.AddNetworkString( "SR_WrongJob" )
util.AddNetworkString( "SR_FunnyJoke" )


//-------------------------------------------------
//			Silent Raid Functions
//-------------------------------------------------


srTable = {}
srTable.raider = {}
srTable.target = {}
srTable.raidAllowed = { "Mane-iac","Mane-iac's Sergeant", "Mane-iac's Goon", "The Mysterious Mare Do Well" }



//This is shouldnt have to change much to make things work as all its doing is getting a list of admins and notifying them when a raid starts/ends
function SR_AdminNotify_start( srRaider, srVictim, ply ) 
	local srAdmins = {}

	//Find players with the ulx perm for seeing the notification
	for k, v in pairs( player.GetAll() ) do 
		if ULib.ucl.query( v, "Silent Raid", true ) then
			srAdmins[ #srAdmins + 1 ] = v
		end
	end
		
	net.Start("SR_RaidStart_admin")
		net.WriteEntity(srRaider)
		net.WriteEntity(srTarget)
	net.Send(srAdmins)

		
		bLogs.Log({
			module 		= "Raid Start",
			log			= bLogs.GetName(srRaider) .. " Has began a raid on " .. bLogs.GetName(srTarget) .. ".",
			involved	= {srRaider, srTarget},
			})
		
end


function SR_AdminNotify_end( srRaider, ply ) 
	local srAdmins = {}

	//Find players with the ulx perm for seeing the notification
	for k, v in pairs( player.GetAll() ) do 
		if ULib.ucl.query( v, "Silent Raid", true ) then
			srAdmins[ #srAdmins + 1 ] = v
		end
	end	


		net.Start("SR_RaidOver_admin")
			net.WriteEntity(srPlayer)
			net.WriteEntity(srVictim)
		net.Send(srAdmins)

		bLogs.Log({
			module 		= "Raid Over",
			log			= "A Raid by " .. bLogs.GetName(srPlayer) .. " on " .. bLogs.GetName(srVictim) .. " has ended.",
			involved	= {srPlayer, srVictim},
			})
end


function SR_AdminNotify_endnet( srRaider, srVictim, ply ) 
	local srAdmins = {}
	local srNetRaider = net.ReadEntity(raider)
	local srNetTarget = net.ReadEntity(target)
	//Find players with the ulx perm for seeing the notification
	for k, v in pairs( player.GetAll() ) do 
		if ULib.ucl.query( v, "Silent Raid", true ) then
			srAdmins[ #srAdmins + 1 ] = v
		end
	end	

		net.Start("SR_RaidOver_adminnet")
			net.WriteEntity(srNetRaider)
			net.WriteEntity(srNetTarget)
		net.Send(srAdmins)

		table.RemoveByValue(srTable.raider, srNetRaider)
		table.RemoveByValue(srTable.target, srNetTarget)
		
		bLogs.Log({
			module 		= "Raid Over",
			log			= "A Raid by " .. bLogs.GetName(srNetRaider) .. " on " .. bLogs.GetName(srNetTarget) .. " has ended.",
			involved	= {srNetRaider, srNetTarget},
			})
end
net.Receive("SR_Timer_End", SR_AdminNotify_endnet)
//Need to begin writing values to a table for current raiders and targets and matching them up by pairs
//Most likely will just do this by comparing keys for the two tables, as long as they are added and removed at the same time then life should be good

function SR_RaidStart( ply, text, team, args )

	sr_activeRaid = false
	srRaider = ply
	if IsValid( ply ) and ply:IsPlayer() then -- Check for player beacuse console and all that jazz can chat, mind you it would be neat to see the console raid someone... anyway...
		local target = string.lower(text)
		local text = string.lower( string.Left( text, 5 ) )
		
		
		// This will check for the player saying the command, this will likely be changed for a more indepth command
		// with auto complete of player names, and a req for a player name to be entered or it will error
		// ... ill do it later

		if text == "/raid" then

			local match = nil


			for k,v in pairs( srTable.raidAllowed ) do
				if ply:getJobTable().name == v then
					match = 1
				end
			end

			if !match then 

				net.Start("SR_WrongJob")
				net.Send(srRaider)
				return ""
			end


			if table.HasValue(srTable.raider, ply) then
				net.Start("SR_AlreadyRaid")
				net.Send(srRaider)
				return "" 
			end

			
			//local srPossTargets = {} I think this is depreciated I cant remember but it doesnt seem im using it, might have been planning to though
			//Ill leave it for now


			//This is going to have to be overhauled to write the target and raider to a table rather than a veriable, while being careful to match keys
			for k, v in pairs(player.GetAll()) do
	
				local vSM = string.lower(v:Nick())
				local vCheck = string.Explode(" ", vSM)
				local targExp = string.Explode(" ", target)

				if targExp[2] == nil then break end

				srTarget = string.match(targExp[2], vCheck[1])

				if !srTarget then 
					srTarget = string.match(vCheck[1], targExp[2])
				end
				

				if srTarget then
					sr_activeRaid = true
					srTarget = v
					if v == ply then 
						net.Start("SR_SelfRaid")
						net.Send(srRaider)
					return ""
					end
					srTable.target[ #srTable.target +1 ] = v
					srTable.raider[	#srTable.raider +1 ] = ply
					hook.Add( "PlayerDeath", tostring(srRaider), SR_RaiderDead)

					net.Start("SR_RaidStart_player")
						net.WriteEntity(srRaider)
						net.WriteEntity(srTarget)
					net.Send(srRaider)

					SR_AdminNotify_start( ply )



					break
				end
			end

		return ""
		end

	end

end 
hook.Add( "PlayerSay", "SR_RaidStart", SR_RaidStart)

//To be used if the raider calls /over
//Ill fix this up once I have the tables ready and then this can just check them and remove the value when a raid is over
//Might acutally redo all the ending functions so that the various outcomes just call a singal function as to make things
//abit cleaner... in short ignore this for now... All of it

function SR_RaidOver( ply, text, team )

	if IsValid( ply ) and ply:IsPlayer() then -- Check for player beacuse console and all that jazz can chat, mind you it would be neat to see the console raid someone... anyway...

		local text = string.lower( string.Left( text, 5 ) )
		
		if text == "/over" and !table.HasValue(srTable.raider, ply) then
			//For safety if there is no raid we dont let the user end the raid beacuse there will be no information for the CL chat print

			net.Start("SR_NoRaid")
			net.Send(ply)

			return ""

		elseif text == "/over" and table.HasValue(srTable.raider, ply) then
			srPlayer = nil
			srPlayer = ply

			for k,v in pairs(srTable.raider) do
				if ply == v then
					srKey = k
				end
			end

			for k,v in pairs(srTable.target) do
				if srKey == k then 
					srVictim = v
				end
			end



			net.Start("SR_RaidOver_player")
				net.WriteEntity(srPlayer)
				net.WriteEntity(srVictim)
			net.Send(ply)

			table.RemoveByValue(srTable.raider, srPlayer)
			table.RemoveByValue(srTable.target, srVictim)

			net.Start("SR_RemoveTimer")
			net.Send(ply)

			SR_AdminNotify_end( )

			return ""
		end
	end

end 
hook.Add( "PlayerSay", "SR_RaidOver", SR_RaidOver)

//End the raid if the raider is dead

function SR_RaiderDead( ply )


	if table.HasValue(srTable.raider, ply) then 
		srPlayer = nil
		srPlayer = ply
		for k,v in pairs(srTable.raider) do
			if ply == v then
			srKey = k
			end
		end

		for k,v in pairs(srTable.target) do
			if srKey == k then 
			srVictim = v
			end
		end

		hook.Remove(tostring(ply))

		net.Start("SR_RaidOver_player")
			net.WriteEntity(srPlayer)
			net.WriteEntity(srVictim)
		net.Send(ply)

		table.RemoveByValue(srTable.raider, srPlayer)
		table.RemoveByValue(srTable.target, srVictim)

		net.Start("SR_RemoveTimer")
		net.Send(ply)

		SR_AdminNotify_end( )

	end

end


//for the lols
function SR_FunnyJoke(  )
local srjokekill = net.ReadEntity(srjoke)

srjokekill:Kill()

end
 net.Receive("SR_FunnyJoke", SR_FunnyJoke)