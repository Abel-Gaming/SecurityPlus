RegisterNetEvent('SecurityPlus:HQMenu')
AddEventHandler('SecurityPlus:HQMenu', function()
    TriggerEvent("nh-context:createMenu", {
        {
            header = "Security Headquarters",
        },
        {
            header = "",
        },
        {
            header = "Toggle Duty",
            event = "SecurityPlus:ToggleDuty"
        },
        {
            header = "Spawn Patrol Vehicle",
            event = "SecurityPlus:SpawnPatrolVehicle"
        },
        {
            header = "View All Contracts",
            event = "SecurityPlus:ViewAllContracts"
        }
    })
end)

RegisterNetEvent('SecurityPlus:SecurityMenu')
AddEventHandler('SecurityPlus:SecurityMenu', function()
    TriggerEvent("nh-context:createMenu", {
        {
            header = "Security Options",
        },
        {
            header = "",
        },
        {
            header = "Stop Closest Ped",
            event = "SecurityPlus:StopClosestPed"
        },
        {
            header = "Releases Closest Ped",
            event = "SecurityPlus:ReleaseClosestPed"
        }
    })
end)