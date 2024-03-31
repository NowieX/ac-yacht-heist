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
        ['title'] = "nw-cartracker",
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
                value = "SpelerID: "..source,
            },

            {
                name = "",
                value = "",
            },


            {
                name = "Steam Identifier",
                value = "Steam"..steamid,
                inline = true
            },

            {
                name = "",
                value = "",
            },

            {
                name = "Steam Naam",
                value = "Steamnaam: "..steamName,
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

local function CheckIfPlayerHasWeapon(xPlayer)
    for weapon=1, #Config.RequiredWeapons do
        local get_weapon_player = xPlayer.getInventoryItem(Config.RequiredWeapons[weapon])

        if get_weapon_player.count >= 1 then
            return true
        end
    end
    return false
end

RegisterNetEvent("ac-yacht-heist:server:PassAllChecks", function ()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local PolicePlayers = ESX.GetExtendedPlayers('job', 'police')

    -- if not CheckIfPlayerHasWeapon(xPlayer) then
    --     TriggerClientEvent('ox_lib:notify', src, {title = Config.Translations['BossInformation'].boss_title, description = Config.Translations["HeistStart"].not_a_threat.label, duration = Config.Translations["HeistStart"].not_a_threat.timer, position = Config.Notifies.position, type = 'error'})
    --     return
    -- end

    -- if timer_running then
    --     TriggerClientEvent('ox_lib:notify', src, {title = Config.Translations['BossInformation'].boss_title, description = Config.Translations["HeistStart"].heist_recently_done.label:format(cooldown_timer), duration = Config.Translations["HeistStart"].heist_recently_done.timer, position = Config.Notifies.position, type = 'error'})
    --     return
    -- end

    -- if #PolicePlayers < Config.HeistInformation['PoliceNumberRequired'] then
    --     TriggerClientEvent('ox_lib:notify', src, {title = Config.Translations['BossInformation'].boss_title, description = Config.Translations["HeistStart"].not_enough_police.label:format(Config.HeistInformation['PoliceNumberRequired']), duration = Config.Translations["HeistStart"].not_enough_police.timer, position = Config.Notifies.position, type = 'error'})
    --     return
    -- end

    if not heist_started then
        TriggerClientEvent("ac-yacht-heist:client:OpenMenuHeist", src)
    else
        TriggerClientEvent('ox_lib:notify', src, {title = Config.Translations['BossInformation'].boss_title, description = Config.Translations['HeistStart'].heist_occupied.label, duration = Config.Translations['HeistStart'].heist_occupied.timer, position = Config.Notifies.position, type = 'warning'})
    end
end)

RegisterNetEvent("ac-yacht-heist:server:HeistStarted", function ()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)


    -- Controleren of de distance niet te groot is, als dat wel zo is moet de speler gekickt worden en moet er een discord message gestuurd worden
    if Config.HeistNPC[1].target_distance then
        heist_started = true
        heistPlayers[src] = xPlayer.getIdentifier()
    end
end)

RegisterNetEvent("ac-yacht-heist:server:RemoveActivePlayersFromTable", function ()
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)

    for player_id, player_identifier in pairs(heistPlayers) do
        if player_identifier ~= xPlayer.getIdentifier() or player_id ~= src then
            xPlayer.kick("Trigger Protectie, groetjes AquaCity 📸")
            sendDiscordMessage("***Speler met informatie hieronder is gekickt vanwege een trigger protectie.***", Config.Webhook.hacker_log)
            return
        else
            break
        end
    end
    
    heistPlayers = {}
    StartHeistCooldownTimer()
end)
