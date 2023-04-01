RegisterServerEvent('SecurityPlus:DutyNotification')
AddEventHandler('SecurityPlus:DutyNotification', function()
    local playerPed = GetPlayerPed(source)
    local playerName = GetPlayerName(source)
    TriggerClientEvent('SecurityPlus:GlobalNotification', -1, '~b~' .. playerName .. ' ~w~is now on duty as a security guard!')
end)

RegisterServerEvent('SecurityPlus:PayContract')
AddEventHandler('SecurityPlus:PayContract', function(location)
    local xPlayer = ESX.GetPlayerFromId(source)
    for k,v in pairs(Config.SecurityZones) do
        if v.name == location then
            
        end
    end
end)