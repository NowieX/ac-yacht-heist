local heistPlayers = {}
local heist_started = false
local timer_running = false

local function sendDiscordMessage(message, webhookUrl)
    local source = source
    local identifiers = GetPlayerIdentifiers(source)
    local steamName = GetPlayerName(source)
    local steamid = identifiers[1]
    local discordID = identifiers[2]
    local embedData = {{
        ['title'] = GetCurrentResourceName(),
        ['color'] = 0,
        ['footer'] = {
            ['icon_url'] = ""
        },
        ['description'] = message,
        ['fields'] = {
            {
                name = "",
                value = "",
            },

            {
                name = "ID",
                value = "SpelerID: "..tostring(source),
            },

            {
                name = "",
                value = "",
            },


            {
                name = "Steam Identifier",
                value = "Steam"..tostring(steamid),
                inline = true
            },

            {
                name = "",
                value = "",
            },

            {
                name = "Steam Naam",
                value = "Steamnaam: "..tostring(steamName),
            },

            {
                name = "",
                value = "",
            },

            {
                name = "Discord Identifier",
                value = discordID,
            },
        },
    }}

    PerformHttpRequest(webhookUrl, nil, 'POST', json.encode({
        username = GetCurrentResourceName()..' logs',
        embeds = embedData
    }), {
        ['Content-Type'] = 'application/json'
    })
end

local function StartHeistCooldownTimer()
    cooldown_timer = Config.HeistInformation['HeistCooldownTimer']* 60

    timer_running = true
    while cooldown_timer > 0 do
        Citizen.Wait(1000)
        cooldown_timer = cooldown_timer - 1
    end

    timer_running = false
end

--- @param xPlayer number
local function CheckIfPlayerHasWeapon(xPlayer)
    for weapon=1, #Config.RequiredWeapons do
        local get_weapon_player = xPlayer.getInventoryItem(Config.RequiredWeapons[weapon])

        if get_weapon_player.count >= 1 then
            return true
        end
    end
    return false
end

--- @param xPlayer number
---@param coords vector3
local function PlayerIsInRange(xPlayer, coords)
    while true do
        Citizen.Wait(1000)
        local player_coords = xPlayer.getCoords(true)
        local distance = #(coords - player_coords)

        if distance < 200 then
            return true
        end
    end
end

local function CheckForPlayersInHeist(src, xPlayer)
    if next(heistPlayers) == nil then
        xPlayer.kick("Trigger Protectie AquaCity 📸")
        sendDiscordMessage("***Speler met informatie hieronder is gekickt vanwege een trigger protectie.***", Config.Webhook.hacker_log)
        return true
    end

    for player_id, player_identifier in pairs(heistPlayers) do
        if player_id ~= src or player_identifier ~= xPlayer.getIdentifier() then
            xPlayer.kick("Trigger Protectie AquaCity 📸")
            sendDiscordMessage("***Speler met informatie hieronder is gekickt vanwege een trigger protectie.***", Config.Webhook.hacker_log)
            return true
        else
            break
        end
    end
end

RegisterNetEvent('esx:playerDropped', function(playerId, reason)
    local xPlayer = ESX.GetPlayerFromId(playerId)
    
    for player_id in pairs(heistPlayers) do
        if xPlayer == player_id then
            heistPlayers[player_id] = nil
            heist_started = false
        end
    end

    TriggerClientEvent("ac-yacht-heist:client:RemoveTablesAndBlips", playerId)
end)

RegisterNetEvent("ac-yacht-heist:server:PassAllChecks", function ()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local PolicePlayers = ESX.GetExtendedPlayers('job', 'police')

    if not CheckIfPlayerHasWeapon(xPlayer) then
        TriggerClientEvent('ox_lib:notify', src, {title = Config.HeistNPC.boss_title, description = Config.GlobalTranslations["HeistStart"].not_a_threat.label, duration = Config.GlobalTranslations["HeistStart"].not_a_threat.timer, position = Config.Notifies.position, type = 'error'})
        return
    end

    if timer_running then
        TriggerClientEvent('ox_lib:notify', src, {title = Config.HeistNPC.boss_title, description = Config.GlobalTranslations["HeistStart"].heist_recently_done.label:format(cooldown_timer), duration = Config.GlobalTranslations["HeistStart"].heist_recently_done.timer, position = Config.Notifies.position, type = 'error'})
        return
    end

    if #PolicePlayers < Config.HeistInformation['PoliceNumberRequired'] then
        TriggerClientEvent('ox_lib:notify', src, {title = Config.HeistNPC.boss_title, description = Config.GlobalTranslations["HeistStart"].not_enough_police.label:format(Config.HeistInformation['PoliceNumberRequired']), duration = Config.GlobalTranslations["HeistStart"].not_enough_police.timer, position = Config.Notifies.position, type = 'error'})
        return
    end

    if not heist_started then
        TriggerClientEvent("ac-yacht-heist:client:OpenMenuHeist", src)
    else
        TriggerClientEvent('ox_lib:notify', src, {title = Config.HeistNPC.boss_title, description = Config.GlobalTranslations['HeistStart'].heist_occupied.label, duration = Config.GlobalTranslations['HeistStart'].heist_occupied.timer, position = Config.Notifies.position, type = 'warning'})
    end
end)

RegisterNetEvent("ac-yacht-heist:server:SpawnBoatToSteal", function ()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local boat = Config.HeistLocations.Boat_Pickup_Location
    
    if PlayerIsInRange(xPlayer, boat.boat_coords) then
        ESX.OneSync.SpawnVehicle(boat.BoatModel, boat.boat_coords, boat.boat_heading, {fuelLevel = 100}, function(NetworkId)
            TriggerClientEvent('ac-yacht-heist:client:GoToYacht', src, NetworkId)
        end)
    end
end)

RegisterNetEvent("ac-yacht-heist:server:HeistStarted", function ()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local player_coords = xPlayer.getCoords(true) 
    local distance = #(Config.HeistNPC.location - player_coords)

    if distance > Config.HeistNPC.target_distance + 1.0 then
        xPlayer.kick("Trigger Protectie AquaCity 📸")
        sendDiscordMessage("***Speler met informatie hieronder is gekickt vanwege een trigger protectie.***", Config.Webhook.hacker_log)
        return
    end
    
    heist_started = true
    heistPlayers[src] = xPlayer.getIdentifier()
end)

RegisterNetEvent("ac-yacht-heist:server:RemoveActivePlayersFromTable", function ()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if CheckForPlayersInHeist(src, xPlayer) then return end
    
    heistPlayers = {}
    StartHeistCooldownTimer()
end)

RegisterNetEvent("ac-yacht-heist:server:GivePlayerReward", function (coords, prop_name)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    if CheckForPlayersInHeist(src, xPlayer) then return end

    while true do
        Citizen.Wait(150)
        local player_coords = xPlayer.getCoords(true)
        local distance = #(player_coords - coords)

        if distance < Config.GeneralTargetDistance + 1.0 then
            break
        end
    end

    if prop_name == "cash" then
        prop_name = Config.HeistRewardItems.cash
    elseif prop_name == "gold" then
        prop_name = Config.HeistRewardItems.gold_bar
    else
        print("That's not a valid item. Please contact the script owner for support.")
        return
    end

    xPlayer.addInventoryItem(prop_name.item, prop_name.amount)
end)