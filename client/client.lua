--- @param blip_x number
--- @param blip_y number
--- @param blip_z number
--- @param sprite number
--- @param scale number
--- @param colour number
--- @param route boolean
--- @param blip_name string
function CreateBlip(blip_x, blip_y, blip_z, sprite, scale, colour, route, blip_name)
    local blip = AddBlipForCoord(blip_x, blip_y, blip_z)
    SetBlipSprite(blip, sprite)
    SetBlipScale(blip, scale)
    SetBlipColour(blip, colour)
    SetBlipRoute(blip, route)
    BeginTextCommandSetBlipName('STRING')
    AddTextComponentSubstringPlayerName(blip_name)
    EndTextCommandSetBlipName(blip)
    return blip
end

--- @param player number
--- @param message string
--- @param message_head string
function CreatePoliceReport(player, message, message_head)
    local player_coords = GetEntityCoords(player)
    local alert = {
        message = message,
        location = player_coords,
    }

    TriggerServerEvent('qs-smartphone:server:sendJobAlert', alert, "police") 
    TriggerServerEvent('qs-smartphone:server:AddNotifies', {
        head = message_head, 
        msg = message,
        app = 'business'
    })
end

CreateThread(function()
    for _, value in pairs(Config.HeistNPC) do
        RequestModel(GetHashKey(value.model))
        while not HasModelLoaded(GetHashKey(value.model)) do
            Wait(1)
        end

        npc = CreatePed(2, value.model, value.location.x, value.location.y, value.location.z - 1, value.location.w,  false, true)

        SetPedFleeAttributes(npc, 0, 0)
        SetPedDropsWeaponsWhenDead(npc, false)
        SetPedDiesWhenInjured(npc, false)
        SetEntityInvincible(npc , true)
        FreezeEntityPosition(npc, true)
        SetBlockingOfNonTemporaryEvents(npc, true)

        TaskStartScenarioInPlace(npc, 'WORLD_HUMAN_GUARD_STAND_FACILITY', 0, true)

        exports.ox_target:addBoxZone({
            coords = vec3(value.location.x, value.location.y, value.location.z),
            size = vec3(1, 1, 1),
            rotation = 360,
            debug = Config.Debugger,
            options = {
                {
                    serverEvent = 'ac-yacht-heist:server:PassAllChecks',
                    distance = Config.GeneralTargetDistance,
                    icon = 'fa fa-ship',
                    label = Config.Translations['BossInformation'].target_label,
                },
            }
        })
    end
end)

RegisterNetEvent('ac-yacht-heist:client:OpenMenuHeist', function ()
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "open",
    })
end)

RegisterNUICallback('ac-yacht-heist:client:CloseMenuHeist', function ()
    SetNuiFocus(false, false)
end)

RegisterNUICallback("ac-yacht-heist:client:StartHackingPreperation", function ()
    TriggerServerEvent("ac-yacht-heist:server:HeistStarted")
    SetNuiFocus(false,false)
    local playerPed = PlayerPedId()

    lib.notify({
        title = Config.Translations["BossInformation"].boss_title,
        description = Config.Translations['BossInformation'].introduction_round.message,
        duration = Config.Translations['BossInformation'].introduction_round.timer, 
        position = Config.Notifies.position, 
        type = 'info'
    })

    local hack_building_entrance_blip = CreateBlip(Config.HeistLocations.HackerBuilding.location.x, Config.HeistLocations.HackerBuilding.location.y, Config.HeistLocations.HackerBuilding.location.z, 472, 1.0, 59, true, "Camera's hacken")
    
    Camera_Building_Zone = exports.ox_target:addBoxZone({
        coords = vec3(Config.HeistLocations.HackerBuilding.location.x, Config.HeistLocations.HackerBuilding.location.y, Config.HeistLocations.HackerBuilding.location.z),
        size = vec3(1, 1, 1),
        rotation = 360,
        debug = Config.Debugger,
        options = {
            {
                onSelect = function ()
                    TriggerEvent('ac-yacht-heist:client:EnterCameraBuilding', hack_building_entrance_blip)
                end,
                distance = Config.GeneralTargetDistance,
                icon = 'fa fa-network-wired',
                label = Config.HeistLocations.HackerBuilding.target_label,
            },
        }
    })
end)

RegisterNetEvent("ac-yacht-heist:client:EnterCameraBuilding", function (entrance_blip)
    RemoveBlip(entrance_blip)
    local security_panel_coords = Config.HeistLocations.Security_panel_hack_scene.scene_location
    exports.ox_target:removeZone(Camera_Building_Zone)
    DoScreenFadeOut(Config.HeistInformation['BlackScreenTimer'])
    Citizen.Wait(Config.HeistInformation['BlackScreenTimer'])
    local playerPed = GetPlayerPed(-1)
    SetEntityHeading(playerPed, 82.7456)
    SetEntityCoords(playerPed, 1004.1747, -2997.6816, -47.6471, true, false, false, false)
    local security_panel = CreateObject(`hei_prop_hei_securitypanel`, security_panel_coords.x, security_panel_coords.y, security_panel_coords.z, true, true, false)
    SetEntityHeading(security_panel, Config.HeistLocations.Security_panel_hack_scene.scene_rotation.z)
    Citizen.Wait(Config.HeistInformation['BlackScreenTimer'])
    DoScreenFadeIn(Config.HeistInformation['BlackScreenTimer'])

    Camera_Building_Zone = exports.ox_target:addBoxZone({
        coords = vec3(security_panel_coords.x, security_panel_coords.y, security_panel_coords.z),
        size = vec3(1, 1, 1),
        rotation = 360,
        debug = Config.Debugger,
        options = {
            {
                event = 'ac-yacht-heist:client:StartHackCamera',
                distance = Config.GeneralTargetDistance,
                icon = 'fa fa-camera',
                label = Config.HeistLocations.Security_panel_hack_scene.target_label,
            },
        }
    })
end)