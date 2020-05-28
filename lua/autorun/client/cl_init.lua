//----------------Silent Raid----------------------
//
//Silently notifies admins of the starting of a raid
//
//
//commit 07-18-17
//by Mikomi Hooves, Deven Ronquillo
//-------------------------------------------------


//-------------------------------------------------
//			FAdmin Auto complete start
//-------------------------------------------------
function SR_AddCommands( )
	FAdmin.StartHooks["Chatting"] = function()
    FAdmin.Commands.AddCommand("raid", nil, "<Player>")
    FAdmin.Commands.AddCommand("over", nil)

    FAdmin.Access.AddPrivilege("SilentRaid", 2)
	print("Created SR commands")
end

end
timer.Simple( 10, SR_AddCommands )


//-------------------------------------------------
//	Notifying players with pretty colors
//	The cl_init almost exclusivly is for this 
//	purpose.. so things look pretty
//-------------------------------------------------

--Notification to the raider
function SR_RaidStart_player()
	local raider = net.ReadEntity(srRaider)
	local target = net.ReadEntity(srTarget)

	chat.AddText( Color( 255, 255, 255 ), "[", Color(130, 0, 0), "RAID", Color( 255, 255, 255 ), "] You have started a raid on ", Color(130, 0, 0), target:Nick(), Color( 255, 255, 255 ), ". The raid must end in less than 5 minutes." )

	timer.Create("SR_RaidTimer", 350, 0, function()//-----------------------------------------------------------------------------------------------------EDIT BY DEVEN: Changed time from 60 to 350 secs, or five min.
		chat.AddText( Color( 255, 255, 255 ), "[", Color(130, 0, 0), "RAID", Color( 255, 255, 255 ), "] The raid on ", Color(130, 0, 0), target:Nick(), Color( 255, 255, 255 ), " has now ended. If you are alive you must vacate the premise." )
		
		net.Start("SR_Timer_End")
			net.WriteEntity(raider)
			net.WriteEntity(target)
		net.SendToServer()

	end)

end
net.Receive("SR_RaidStart_player", SR_RaidStart_player)


--Admin notification, denoted with RAID-ADMIN
function SR_RaidStart_admin()
	sr_Raider = net.ReadEntity(srRaider)
	local target = net.ReadEntity(srTarget)

	chat.AddText( Color( 255, 255, 255 ), "[", Color(255, 0, 67), "RAID-ADMIN", Color( 255, 255, 255 ), "] ", Color(255, 0, 67), sr_Raider:Nick(), Color( 255, 255, 255 ), " has started a raid on ", Color(255, 0, 67), target:Nick(), Color( 255, 255, 255 ), ". The raid will end in 5 minutes." )

end
net.Receive("SR_RaidStart_admin", SR_RaidStart_admin)


--LEt the player know the raid is over
function SR_RaidOver_player()
	local raider = net.ReadEntity(srRaider)
	local target = net.ReadEntity(srVictim)

	chat.AddText( Color( 255, 255, 255 ), "[", Color(130, 0, 0), "RAID", Color( 255, 255, 255 ), "] The raid on ", Color(130, 0, 0), target:Nick(), Color( 255, 255, 255 ), " has now ended. If you are alive you must vacate the premise." )

end
net.Receive("SR_RaidOver_player", SR_RaidOver_player)


--Let the admins know the raid has ended
function SR_RaidOver_admin()

	local raider = net.ReadEntity(srPlayer)
	local target = net.ReadEntity(srVictim)

	chat.AddText( Color( 255, 255, 255 ), "[", Color(255, 0, 67), "RAID-ADMIN", Color( 255, 255, 255 ), "] The raid by ", Color( 255, 0, 67 ), raider:Nick(), Color( 255, 255, 255 ), " on ", Color(255, 0, 67), target:Nick(), Color(255, 255, 255), " has ended." )

	local raider = nil

end
net.Receive("SR_RaidOver_admin", SR_RaidOver_admin)

function SR_RaidOver_adminnet()

	local raider = net.ReadEntity(srNetRaider)
	local target = net.ReadEntity(srNetTarget)

	chat.AddText( Color( 255, 255, 255 ), "[", Color(255, 0, 67), "RAID-ADMIN", Color( 255, 255, 255 ), "] The raid by ", Color( 255, 0, 67 ), raider:Nick(), Color( 255, 255, 255 ), " on ", Color(255, 0, 67), target:Nick(), Color(255, 255, 255), " has ended." )

	SR_RemoveTimer()//------------------------------------------------------------------------------------------------------------ADDED BY DEVEN: if no one died nor said the raid was over then a loop ocours which ends here. killing the timer here will prevent the loop from happening.

end
net.Receive("SR_RaidOver_adminnet", SR_RaidOver_adminnet)


--Safety exit the program and notify the player there was a problem
function SR_NoRaid(  )
	chat.AddText( Color( 255, 255, 255 ), "[", Color(130, 0, 0), "RAID", Color( 255, 255, 255 ), "] There is no active raid, or an error has occured" )
end
net.Receive("SR_NoRaid", SR_NoRaid)


--Another safety exit if they are in a raid, sorta prevents spam and such
function SR_AlreadyRaid(  )
	chat.AddText( Color( 255, 255, 255 ), "[", Color(130, 0, 0), "RAID", Color( 255, 255, 255 ), "] You must end your current raid before starting a new one, or an error has occured." )
end
net.Receive("SR_AlreadyRaid", SR_AlreadyRaid )

//function SR_Timesup()
//	local raider =	net.ReadEntity(srRaiderTimer)
//	local target =	net.ReadEntity(srTargetTimer)
//
//	chat.AddText( Color( 255, 255, 255 ), "[", Color(130, 0, 0), "RAID", Color( 255, 255, 255 ), "] The raid on ", Color(130, 0, 0), target:Nick(), Color( 255, 255, 255 ), " has now ended. If you are alive you must vacate the premise." )
//
//end


function SR_RemoveTimer(  )
	timer.Remove("SR_RaidTimer")
end
net.Receive( "SR_RemoveTimer", SR_RemoveTimer )

sr_FunnyJoke = 0
function SR_SelfRaid( )

	
print(sr_FunnyJoke)
	if sr_FunnyJoke == 0 then
		sr_FunnyJoke = 1
		chat.AddText( Color( 255, 255, 255 ), "[", Color(130, 0, 0), "RAID", Color( 255, 255, 255 ), "] Why are you trying to raid yourself? What did you expect was going to happen?" )
		print(sr_FunnyJoke)
	elseif sr_FunnyJoke == 1 then
	sr_FunnyJoke = 2
		chat.AddText( Color( 255, 255, 255 ), "[", Color(130, 0, 0), "RAID", Color( 255, 255, 255 ), "] Honestly... Nothing good is going to come from doing this." )


	elseif sr_FunnyJoke == 2 then
	sr_FunnyJoke = 3
		chat.AddText( Color( 255, 255, 255 ), "[", Color(130, 0, 0), "RAID", Color( 255, 255, 255 ), "] There is other things to do on here you know? You can buy a car, raid the bank, be a cop, and so much more... Why do you insist on doing this instead?" )

		print(sr_FunnyJoke)
	elseif sr_FunnyJoke == 3 then
	sr_FunnyJoke = 4
		chat.AddText( Color( 255, 255, 255 ), "[", Color(130, 0, 0), "RAID", Color( 255, 255, 255 ), "] You should stop now... You dont know what might happen if you keep going on this path." )

		print(sr_FunnyJoke)
	elseif sr_FunnyJoke == 4 then
		local srjoke = LocalPlayer()
		chat.AddText( Color( 255, 255, 255 ), "[", Color(130, 0, 0), "RAID", Color( 255, 255, 255 ), "] I tried to warn you... You just wouldnt listen." )
		sr_FunnyJoke = 0
		net.Start("SR_FunnyJoke")
			net.WriteEntity(srjoke)
		net.SendToServer()
	end
end

net.Receive("SR_SelfRaid", SR_SelfRaid)

function SR_WrongJob( )
	chat.AddText( Color( 255, 255, 255 ), "[", Color(130, 0, 0), "RAID", Color( 255, 255, 255 ), "] You are not bad to the pone enough to use this." )
end
net.Receive("SR_WrongJob", SR_WrongJob)