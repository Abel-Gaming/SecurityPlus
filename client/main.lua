local onDuty = false
local onPatrol = false
local panelOpen = false
local PatrolEventPed = nil
local pendingContractCoords = nil
local SecurityZoneBlips = {}
local generatedPeds = {}
local pedBlips = {}

----- COMMANDS -----
RegisterCommand('+forceduty', function(source, args, rawCommand)
	ToggleDuty()
end, false)

RegisterCommand('+securitymenu', function(source, args, rawCommand)
	TriggerEvent('SecurityPlus:SecurityMenu')
end, false)

RegisterCommand('+securitypanelshow', function(source, args, rawCommand)
	-- Tell NUI to display HUD
	SendNUIMessage({
		type = 'display',
		showUI = true
	})

	-- Send Info
	SendNUIMessage({
		type = 'trialData',
		header = 'Security Panel'
	})
end, false)

----- EVENTS -----
RegisterNetEvent('SecurityPlus:GlobalNotification')
AddEventHandler('SecurityPlus:GlobalNotification', function(text)
	ShowNotification(text)
end)

RegisterNetEvent('SecurityPlus:ToggleDutyEvent')
AddEventHandler('SecurityPlus:ToggleDutyEvent', function()
	ToggleDuty()
end)

RegisterNetEvent('SecurityPlus:ToggleDuty')
AddEventHandler('SecurityPlus:ToggleDuty', function()
	ToggleDuty()
end)

RegisterNetEvent('SecurityPlus:SpawnPatrolVehicle')
AddEventHandler('SecurityPlus:SpawnPatrolVehicle', function()
	if onDuty then
		SpawnVehicle(Config.PatrolCar, Config.HQCarSpawn, Config.HQCarSpawnHeading)
	else
		ShowNotification('~r~[ERROR]~w~ You are not on duty!')
	end
end)

RegisterNetEvent('SecurityPlus:ViewAllContracts')
AddEventHandler('SecurityPlus:ViewAllContracts', function()
	ShowAllContracts()
end)

RegisterNetEvent('SecurityPlus:StopClosestPed')
AddEventHandler('SecurityPlus:StopClosestPed', function()
	StopPed()
end)

RegisterNetEvent('SecurityPlus:ReleaseClosestPed')
AddEventHandler('SecurityPlus:ReleaseClosestPed', function()
	ReleasePed()
end)

----- BLIPS -----
if Config.EnableBlips then
	Citizen.CreateThread(function()
		local blip = AddBlipForCoord(Config.HQCoords)
		SetBlipSprite(blip, 67)
		SetBlipColour(blip, 11)
		SetBlipScale(blip, 1.0)
		SetBlipDisplay(blip, 4)
		SetBlipAsShortRange(blip, true)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString("Security HQ")
		EndTextCommandSetBlipName(blip)
	end)
end

----- INTERACTION OPTIONS FUNCTIONS -----
function StopPed()
	if DoesEntityExist(PatrolEventPed) then
		ClearPedTasksImmediately(PatrolEventPed)
		TaskStandStill(ped, -1)
		ShowNotification('Ped has been stopped')
	else
		if Config.EnableDebug then
			print('The ped you tried to stop does not exist')
		end
	end
end

function ReleasePed()
	if DoesEntityExist(PatrolEventPed) then
		ClearPedTasksImmediately(PatrolEventPed)
		ShowNotification('Ped has been released')
	end
end

----- FUNCTIONS -----
function timer(timeAmount, Paid, Payout, Location)
	Citizen.CreateThread(function()
		local time = timeAmount
		while (time ~= 0) do
			Wait( 1000 )
			time = time - 1
		end
		ShowNotification('[INFO] Your patrol time for the area has ended.')
		if Paid then
			TriggerServerEvent('SecurityPlus:PayContract', Location)
			for k,v in pairs(pedBlips) do
				RemoveBlip(value)
			end
			for k,v in pairs(generatedPeds) do
				DeletePed(v)
			end
			generatedPeds = {}
			pedBlips = {}
			onPatrol = false
		else
			for k,v in pairs(pedBlips) do
				RemoveBlip(value)
			end
			for k,v in pairs(generatedPeds) do
				DeletePed(v)
			end
			generatedPeds = {}
			pedBlips = {}
			onPatrol = false
		end
	end)
end

function PatrolEvents(WaitTime, coords)
	Citizen.Wait(WaitTime * 1000)
	local RandomEvents = {"None", "Loitering"}
	local ChosenEvent = (RandomEvents[math.random(1, #RandomEvents)])
	if Config.EnableDebug then
		ShowNotification('[DEBUG] The random event chosen was: ' .. ChosenEvent)
	end
	if ChosenEvent == 'None' then
		
	elseif ChosenEvent == 'Loitering' then
		ShowHelpNotification('[INFO] Reports of a person loitering on the property. Please find them and address them.')
		LoiteringPerson(coords)
	end
end

function DrawBlip(coord)
	local blip = AddBlipForCoord(coord)
	table.insert(SecurityZoneBlips, blip)
	SetBlipSprite(blip, 487)
	SetBlipColour(blip, 11)
	SetBlipScale(blip, 1.0)
	SetBlipDisplay(blip, 4)
	SetBlipAsShortRange(blip, true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("Security Zone")
	EndTextCommandSetBlipName(blip)
end

function DeleteBlip(blipID)
	RemoveBlip(blipID)
	SecurityZoneBlips = {}
end

function ToggleDuty()
	if onDuty then
		onDuty = false
		ShowNotification('You are now off duty!')
		for k,v in pairs(SecurityZoneBlips) do
			DeleteBlip(v)
		end
	else
		onDuty = true
		ShowNotification('You are now on duty!')
		TriggerServerEvent('SecurityPlus:DutyNotification')
		for k,v in pairs(Config.SecurityZones) do
			if v.blip == true then
				DrawBlip(v.coord)
			end
		end
	end
end

function KeyboardInput(TextEntry, ExampleText, MaxStringLenght)
	AddTextEntry('FMMC_KEY_TIP1', TextEntry)
	DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", ExampleText, "", "", "", MaxStringLenght)
	blockinput = true

	while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do
		Citizen.Wait(0)
	end
		
	if UpdateOnscreenKeyboard() ~= 2 then
		local result = GetOnscreenKeyboardResult()
		Citizen.Wait(500)
		blockinput = false
		-- DO ACTION
	else
		Citizen.Wait(500)
		blockinput = false
		return nil
	end
end

function ShowAllContracts()
	-- Tell NUI to display HUD
	SendNUIMessage({
		type = 'displayAll',
		showUI = true
	})

	-- Set Focus
	SetNuiFocus(true, true)

	-- Send Info
	SendNUIMessage({
		type = 'allContracts',
		contracts = Config.SecurityZones
	})
end

----- DRAW HQ MARKER -----
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		DrawMarker(25, Config.HQCoords.x, Config.HQCoords.y, Config.HQCoords.z - 0.98, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.5, 1.5, 1.5, 0, 255, 0, 155, false, true, 2, nil, nil, false)
	end
end)

----- DRAW PATROL AREA MARKER -----
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(1)
		if onDuty then
			for k,v in pairs(Config.SecurityZones) do
				DrawMarker(25, v.startCoord.x, v.startCoord.y, v.startCoord.z - 0.98, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.5, 1.5, 1.5, 0, 255, 0, 155, false, true, 2, nil, nil, false)
			end
		end
	end
end)

----- CHECK PATROL AREA MARKER -----
Citizen.CreateThread(function()
	while not NetworkIsSessionStarted() do
		Wait(500)
	end

	while true do
		Citizen.Wait(1)
		if onDuty then
			for k,v in pairs(Config.SecurityZones) do
				while #(GetEntityCoords(PlayerPedId()) - v.startCoord) <= 1.0 do
					Citizen.Wait(0)
					if Config.Use3DText then
						DrawText3D(v.startCoord, "Press ~y~[E]~s~ to view contact offer", 0.5, 0.2, 0.2)
					else
						ShowHelpNotification('Press ~INPUT_CONTEXT~ to view contact offer')
					end
					if IsControlJustReleased(0, 51) then
						if onPatrol then
							ShowNotification('[ERROR] You are already on another patrol!')
						else
							--- NUI START ---

							-- Tell NUI to display HUD
							SendNUIMessage({
								type = 'display',
								showUI = true
							})

							-- Send Info
							SendNUIMessage({
								type = 'contractData',
								time = v.PatrolTime,
								pay = v.Payout,
								name = v.name,
								isPaid = v.PaidContract
							})

							-- Set NUI Focus
							SetNuiFocus(true, true)

							-- Set Coords for Pending Contract
							pendingContractCoords = v.startCoord

							--- NUI END ---
						end
					end
				end
			end
		end
	end
end)

----- CHECK HQ MARKER -----
Citizen.CreateThread(function()
	while not NetworkIsSessionStarted() do
		Wait(500)
	end

	while true do
		Citizen.Wait(1)
		while #(GetEntityCoords(PlayerPedId()) - Config.HQCoords) <= 1.0 do
			Citizen.Wait(0)
			if Config.Use3DText then
				DrawText3D(Config.HQCoords, "Press ~y~[E]~s~ to enter HQ", 0.5, 0.2, 0.2)
			else
				ShowHelpNotification('Press ~INPUT_CONTEXT~ to enter HQ')
			end
			if IsControlJustReleased(0, 51) then
				TriggerEvent('SecurityPlus:HQMenu')
			end
		end
	end
end)

----- PATROL EVENTS -----
function LoiteringPerson(coords)
	RequestModel( GetHashKey( "S_M_Y_Dealer_01" ) )
	while ( not HasModelLoaded( GetHashKey( "S_M_Y_Dealer_01" ) ) ) do
    	Citizen.Wait( 1 )
	end
	local radius = 20.0
	local x = coords.x + math.random(-radius, radius)
	local y = coords.y + math.random(-radius, radius)
	local ped = CreatePed(0, GetHashKey('S_M_Y_Dealer_01'), x, y, coords.z, GetEntityHeading(PlayerPedId()), true, false)
	local pedBlip = AddBlipForEntity(ped)
	PatrolEventPed = ped
	table.insert(pedBlips, pedBlip)
	table.insert(generatedPeds, ped)
	ClearPedTasksImmediately(ped)
	TaskWanderStandard(ped, 10.0, 10)
end

----- NUI CALLBACKS -----
RegisterNUICallback('acceptContract', function(data, cb)
	-- Send Callback
	cb({})

	-- Set NUI Focus
	SetNuiFocus(false, false)

	-- Hide NUI
	SendNUIMessage({
		type = 'display',
		showUI = false
	})

	-- Show Notification
	ShowNotification('[INFO] Your area patrol has started! Please patrol the area for ' .. data.time .. ' seconds')
	
	-- Set Patrol Bool
	onPatrol = true
	
	-- Start Timer
	timer(data.time, data.isPaid, data.pay, data.name)

	-- Get Random Event Time
	halfTime = data.time / 3

	-- Start Patrol Event
	PatrolEvents(halfTime, pendingContractCoords)
end)

RegisterNUICallback('declineContract', function(data, cb)
	-- Send Callback
	cb({})

	-- Set NUI Focus
	SetNuiFocus(false, false)

	-- Hide NUI
	SendNUIMessage({
		type = 'display',
		showUI = false
	})
end)

RegisterNUICallback('closeAllContracts', function(data, cb)
	-- Send Callback
	cb({})

	-- Set NUI Focus
	SetNuiFocus(false, false)

	-- Hide NUI
	SendNUIMessage({
		type = 'displayAll',
		showUI = false
	})
end)