function ShowHelpNotification(message, makeSound, duration)
	BeginTextCommandDisplayHelp("THREESTRINGS")
	AddTextComponentSubstringPlayerName(message)
    EndTextCommandDisplayHelp(0, false, makeSound, duration)
end

function DrawGroundMarker(x, y, z)
	DrawMarker(25, x, y, z - 1, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 5.0, 5.0, 5.0, 3, 15, 250, 75, false, true, 2, nil, nil, false)
end

function ShowNotification(message)
	SetNotificationTextEntry('STRING')
	AddTextComponentSubstringPlayerName(message)
	DrawNotification(false, true)
end

function DrawText3D(coords, text, scale, font, align)
    local x2, y2, z2 = table.unpack(coords)
    local onScreen, _x, _y = World3dToScreen2d(x2, y2, z2)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    local dist = #(vector3(px, py, pz) - vector3(x2, y2, z2))
    local scale = (scale / dist) * 2
    local fov = (1 / GetGameplayCamFov()) * 100
    local scale = scale * fov

    if onScreen then
        SetTextScale(scale, scale)
        SetTextFont(font)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 255)
        SetTextDropshadow(0, 0, 0, 0, 255)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextCentre(align)
        SetTextEntry("STRING")
        SetTextCentre(true)
        AddTextComponentString(text)
        DrawText(_x,_y)
    end
end

function SpawnVehicle(vehicleModel, Coords, Heading)
    if not IsModelInCdimage(vehicleModel) then return end
    RequestModel(vehicleModel)
    while not HasModelLoaded(vehicleModel) do
        Wait(0)
    end
    local Vehicle = CreateVehicle(vehicleModel, Coords, Heading, true, false)
    SetModelAsNoLongerNeeded(vehicleModel)
    TaskWarpPedIntoVehicle(PlayerPedId(), Vehicle, -1)
end