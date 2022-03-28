ESX = nil
Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(10)
    end
end)

RegisterCommand("scoreboard", function()
    SendNUIMessage({
        type = "open",
    })
    SetNuiFocus(true, true)
end)

RegisterNUICallback("close", function()
    SetNuiFocus(false, false)

end)

RegisterNetEvent("codem-scoreboard:updatejobscores")
AddEventHandler("codem-scoreboard:updatejobscores", function(jobscores)
    SendNUIMessage({
        type = "updatejobscores",
        jobscores = jobscores
    })
end)

RegisterNetEvent("codem-scoreboard:updaterobberyscores")
AddEventHandler("codem-scoreboard:updaterobberyscores", function(robberyscores, copsnum)
    SendNUIMessage({
        type = "updaterobberyscores",
        robberyscores = robberyscores,
        copsnum = copsnum
    })
end)

RegisterNetEvent("codem-scoreboard:updatePlayers")
AddEventHandler("codem-scoreboard:updatePlayers", function(players, maxPlayers)
    SendNUIMessage({
        type = "updatePlayers",
        players = players,
        maxPlayers = maxPlayers
    })
end)

