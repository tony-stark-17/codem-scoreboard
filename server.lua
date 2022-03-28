ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
local jobScores = {}
local robberyScores = {}

function GetJobScoresData()
    local json_data = LoadResourceFile(GetCurrentResourceName(),  './jobscores.json')
    if(json_data == '')then
        json_data = {}
    else
        json_data = json.decode(json_data)
    end
    return json_data
end

function GetRobberyScoresData()
    local json_data = LoadResourceFile(GetCurrentResourceName(),  './robberyscores.json')
    if(json_data == '')then
        json_data = {}
    else
        json_data = json.decode(json_data)
    end
    return json_data
end
function SaveToJobScoresData(data)
    SaveResourceFile(GetCurrentResourceName(),'jobscores.json', json.encode(data), -1)
end

function SaveToRobberyScoresData(data)
    SaveResourceFile(GetCurrentResourceName(),'robberyscores.json', json.encode(data), -1)
end


Citizen.CreateThread(function()
    jobScores = GetJobScoresData()
    robberyScores = GetRobberyScoresData()
    Citizen.Wait(1000)
    for _,v in pairs(GetPlayers()) do
        TriggerClientEvent("codem-scoreboard:updaterobberyscores", v, robberyScores, CalculateOnlineJobPlayers("police"))
        TriggerClientEvent("codem-scoreboard:updatejobscores", v, jobScores)
        TriggerClientEvent("codem-scoreboard:updatePlayers", v, CalculatePlayers(), GetConvarInt("sv_maxclients", 64))

    end
end)

function ArgsToString(prefix, rawCommand, job)
	local length = string.len(prefix)

    local jobLength = string.len(job)
    
	local message = rawCommand:sub((length+jobLength) + 2)
    if message:gsub("%s+", "") ~= "" then
        return  message
    else
        return ""
    end
end

RegisterCommand("addjobscore", function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.getGroup() == "superadmin" then
        local job = args[1]
        if not ESX.DoesJobExist(job, 0) then
            return
        end
        local icon = ArgsToString("addjobscore", rawCommand, job)
        if icon == "" then
            return
        end
        if jobScores[job] == nil then
            jobScores[job] = {}
        end
  
       jobScores[job] =  {icon = icon, job = job, players = 0}
        SaveToJobScoresData(jobScores)
        TriggerClientEvent("codem-scoreboard:updatejobscores", -1, jobScores)
    end
end)

function GetScore(rawCommand)
    local score = rawCommand:sub(#rawCommand - 1)
    return score
end


function GetLabel(rawCommand, prefix, remove)
    local length = string.len(prefix)
    
    local message = rawCommand:sub(length + 1, remove)

    return message
end

RegisterCommand("addrobberyscore", function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.getGroup() == "superadmin" then
        local label = GetLabel(rawCommand, "addrobberyscore",  -2)
        local score = GetScore(rawCommand)
        if robberyScores[string.gsub(label, "%s+", "")] == nil then
            robberyScores[string.gsub(label, "%s+", "")] = {}
        end
        
        robberyScores[string.gsub(label, "%s+", "")] = {label = label, score = score}
        SaveToRobberyScoresData(robberyScores)
        TriggerClientEvent("codem-scoreboard:updaterobberyscores", -1, robberyScores, CalculateOnlineJobPlayers("police"))
    end
end)

RegisterCommand("removerobberyscore", function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.getGroup() == "superadmin" then
        local label = GetLabel(rawCommand, "removerobberyscore", -1)

        if robberyScores[string.gsub(label, "%s+", "")] == nil then
            return
        else
            robberyScores[string.gsub(label, "%s+", "")] = nil
        end
        SaveToRobberyScoresData(robberyScores)
        TriggerClientEvent("codem-scoreboard:updaterobberyscores", -1, robberyScores, CalculateOnlineJobPlayers("police"))
    end
end)

RegisterCommand("removejobscore", function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.getGroup() == "superadmin" then
        local job = args[1]
        if jobScores[job] == nil then
            return
        else
            jobScores[job] = nil
        end

        SaveToJobScoresData(jobScores)
        TriggerClientEvent("codem-scoreboard:updatejobscores", -1, jobScores)
    end
end)

function CalculateOnlineJobPlayers(job)
    local total = 0
    for k,v in pairs(GetPlayers()) do
        local xPlayer = ESX.GetPlayerFromId(v)
        if xPlayer.job.name == job then
            total = total + 1
        end
    end
    if jobScores[job] then
        jobScores[job].players = total
        TriggerClientEvent("codem-scoreboard:updatejobscores", -1, jobScores)
    end
    return total
end

function CalculatePlayers()
    return GetPlayers()
end

AddEventHandler("esx:setJob", function(source, job, lastJob)
    Citizen.Wait(1000)
    CalculateOnlineJobPlayers(job.name)
    CalculateOnlineJobPlayers(lastJob.name)
    TriggerClientEvent("codem-scoreboard:updaterobberyscores", -1, robberyScores, CalculateOnlineJobPlayers("police"))

end)

AddEventHandler("esx:playerLoaded", function(src)
    local xPlayer = ESX.GetPlayerFromId(source)
    CalculateOnlineJobPlayers(xPlayer.job.name)
    TriggerClientEvent("codem-scoreboard:updaterobberyscores", src, robberyScores, CalculateOnlineJobPlayers("police"))
    TriggerClientEvent("codem-scoreboard:updatejobscores", src, jobScores)
    TriggerClientEvent("codem-scoreboard:updatePlayers", -1, CalculatePlayers(), GetConvarInt("sv_maxclients", 64))
end)


AddEventHandler('playerDropped', function (reason)
    TriggerClientEvent("codem-scoreboard:updatePlayers", -1, CalculatePlayers(), GetConvarInt("sv_maxclients", 64))
end)
  
