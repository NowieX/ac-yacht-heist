local gold_tables = require "client.gold_tables"

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

local function PlayerIsInRange(player, coords)
    while true do
        Citizen.Wait(1500)
        local player_coords = GetEntityCoords(player)
        local distance = #(coords - player_coords)

        if distance < 400 then
            return true
        end
    end
end

local function TeleportPlayerToLocation(player_coords, player_heading)
    local playerPed = GetPlayerPed(-1)
    DoScreenFadeOut(Config.HeistInformation['BlackScreenTimer'])
    Citizen.Wait(Config.HeistInformation['BlackScreenTimer'])
    SetEntityHeading(playerPed, player_heading)
    SetEntityCoords(playerPed, player_coords.x, player_coords.y, player_coords.z, true, false, false, false)
    Citizen.Wait(Config.HeistInformation['BlackScreenTimer'])
    DoScreenFadeIn(Config.HeistInformation['BlackScreenTimer'])
end

local gold_picking_zones = {}

local function CreateGoldTables(coords, heading, target_name)
    local table_object = CreateObject(`h4_prop_h4_table_isl_01a`, coords.x, coords.y, coords.z, true, true, false)
    SetEntityHeading(table_object, heading)
    
    local gold_object_coords = GetOffsetFromEntityInWorldCoords(table_object, 0.0, -0.2, -0.053)
    local gold_object = CreateObject(`h4_prop_h4_gold_stack_01a`, gold_object_coords.x, gold_object_coords.y, gold_object_coords.z, true, true, false)
    SetEntityHeading(gold_object, heading)
    PlaceObjectOnGroundProperly(table_object)

    Gold_picking_Zone = exports.ox_target:addBoxZone({
        coords = vec3(gold_object_coords.x, gold_object_coords.y, gold_object_coords.z),
        size = vec3(1, 1, 1),
        rotation = 360,
        debug = Config.Debugger,
        options = {
            {
                onSelect = function ()
                    local zone = gold_picking_zones[target_name]
                    if zone then
                        exports.ox_target:removeZone(zone)
                        gold_picking_zones[target_name] = nil
                    end
                    TriggerEvent('ac-yacht-heist:client:StartPickingGoldScene', {table_object, gold_object, gold_object_coords, heading})
                end,
                distance = Config.GeneralTargetDistance,
                icon = 'fa fa-sack-dollar',
                label = Config.HeistLocations.Yacht_location.target_label,
                name = target_name,
            },
        }
    })
    gold_picking_zones[target_name] = Gold_picking_Zone
end


CreateThread(function()
    AddDoorToSystem(`door_camera_building`, `v_ilev_rc_door2`, 1005.2922363281, -2998.2661132812, -47.496891021729, false, false, false)
    DoorSystemSetDoorState(`door_camera_building`, 1, false, true)

    local heist_npc = Config.HeistNPC

    RequestModel(GetHashKey(heist_npc.model))
    while not HasModelLoaded(GetHashKey(heist_npc.model)) do
        Wait(1)
    end

    npc = CreatePed(2, heist_npc.model, heist_npc.location.x, heist_npc.location.y, heist_npc.location.z - 1, heist_npc.heading,  false, true)

    SetPedFleeAttributes(npc, 0, 0)
    SetPedDropsWeaponsWhenDead(npc, false)
    SetPedDiesWhenInjured(npc, false)
    SetEntityInvincible(npc , true)
    FreezeEntityPosition(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)

    TaskStartScenarioInPlace(npc, 'WORLD_HUMAN_GUARD_STAND_FACILITY', 0, true)

    exports.ox_target:addBoxZone({
        coords = vec3(heist_npc.location.x, heist_npc.location.y, heist_npc.location.z),
        size = vec3(1, 1, 1),
        rotation = 360,
        debug = Config.Debugger,
        options = {
            {
                serverEvent = 'ac-yacht-heist:server:PassAllChecks',
                distance = Config.GeneralTargetDistance,
                icon = 'fa fa-ship',
                label = Config.HeistNPC.target_label,
            },
        }
    })
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

    lib.notify({
        title = Config.HeistNPC.boss_title,
        description = Config.HeistNPC.introduction_round.message,
        duration = Config.HeistNPC.introduction_round.timer, 
        position = Config.Notifies.position,
        type = 'info'
    })

    local hack_building_entrance_blip = CreateBlip(Config.HeistLocations.HackerBuilding.entrance.coords.x, Config.HeistLocations.HackerBuilding.entrance.coords.y, Config.HeistLocations.HackerBuilding.entrance.coords.z, 472, 1.0, 59, true, "Camera's hacken")
    
    Camera_Building_Zone = exports.ox_target:addBoxZone({
        coords = vec3(Config.HeistLocations.HackerBuilding.entrance.coords.x, Config.HeistLocations.HackerBuilding.entrance.coords.y, Config.HeistLocations.HackerBuilding.entrance.coords.z),
        size = vec3(1, 1, 1),
        rotation = 360,
        debug = Config.Debugger,
        options = {
            {
                onSelect = function ()
                    TriggerEvent('ac-yacht-heist:client:EnterCameraBuilding', hack_building_entrance_blip)
                end,
                distance = Config.GeneralTargetDistance,
                icon = 'fa fa-door-open',
                label = Config.HeistLocations.HackerBuilding.entrance.target_label,
            },
        }
    })
end)

RegisterNetEvent("ac-yacht-heist:client:EnterCameraBuilding", function (entrance_blip)
    RemoveBlip(entrance_blip)
    local security_panel_coords = Config.HeistLocations.Security_panel_hack_scene.scene_location
    exports.ox_target:removeZone(Camera_Building_Zone)

    TeleportPlayerToLocation(vec3(1004.1747, -2997.6816, -47.6471), 82.7456)

    security_panel = CreateObject(`hei_prop_hei_securitypanel`, security_panel_coords.x, security_panel_coords.y, security_panel_coords.z, true, true, false)
    SetEntityHeading(security_panel, Config.HeistLocations.Security_panel_hack_scene.scene_rotation.z)

    Hacking_Zone = exports.ox_target:addBoxZone({
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

RegisterNetEvent("ac-yacht-heist:client:ExitCameraBuilding", function ()

    lib.notify({
        title = Config.HeistNPC.boss_title,
        description = Config.HeistLocations.Security_panel_hack_scene.notification.label,
        duration = Config.HeistLocations.Security_panel_hack_scene.notification.timer, 
        position = Config.Notifies.position,
        type = 'info'
    })

    Hacking_Zone = exports.ox_target:addBoxZone({
        coords = vec3(Config.HeistLocations.HackerBuilding.exit.coords.x, Config.HeistLocations.HackerBuilding.exit.coords.y, Config.HeistLocations.HackerBuilding.exit.coords.z),
        size = vec3(1, 1, 1),
        rotation = 360,
        debug = Config.Debugger,
        options = {
            {
                onSelect = function ()
                    DeleteEntity(security_panel)
                    TeleportPlayerToLocation(vec3(-297.6677, 6391.5552, 30.6124), 123.6319)
                    dinghy_blip = CreateBlip(Config.HeistLocations.Boat_Pickup_Location.boat_coords.x, Config.HeistLocations.Boat_Pickup_Location.boat_coords.y, Config.HeistLocations.Boat_Pickup_Location.boat_coords.z, 404, 1.2, 59, true, "Dinghy")
                    TriggerServerEvent("ac-yacht-heist:server:SpawnBoatToSteal")
                end,
                distance = Config.GeneralTargetDistance,
                icon = 'fa fa-door-open',
                label = Config.HeistLocations.HackerBuilding.exit.target_label,
            },
        }
    })
end)

RegisterNetEvent("ac-yacht-heist:client:GoToYacht", function (NetworkId)
    Wait(100) -- Wait for the vehicle to be created, then pass the NetworkId to the client and convert it to an entity id
    local playerPed = GetPlayerPed(-1)
    RemoveBlip(dinghy_blip)

    local boat = NetworkGetEntityFromNetworkId(NetworkId)
    SetBoatAnchor(boat, true)
    
    while true do
        Citizen.Wait(2000)
        local player_coords = GetEntityCoords(playerPed)
        local closest_vehicle = ESX.Game.GetClosestVehicle(player_coords)
        
        if closest_vehicle and GetVehiclePedIsIn(playerPed, false) == boat then
            break
        end
    end

    yacht_blip = CreateBlip(Config.HeistLocations.Yacht_location.yacht_coords.x, Config.HeistLocations.Yacht_location.yacht_coords.y, Config.HeistLocations.Yacht_location.yacht_coords.z, 455, 1.3, 59, false, "Jacht")

    lib.notify({
        title = Config.HeistNPC.boss_title,
        description = Config.HeistLocations.Boat_Pickup_Location.notification.label,
        duration = Config.HeistLocations.Boat_Pickup_Location.notification.timer, 
        position = Config.Notifies.position,
        type = 'info'
    })

    if PlayerIsInRange(playerPed, Config.HeistLocations.Yacht_location.yacht_coords) then
        for index=1, #gold_tables do
            CreateGoldTables(gold_tables[index].coords, gold_tables[index].heading, gold_tables[index])
        end
    end
end)

RegisterCommand('test_yacht', function ()
    if PlayerIsInRange(GetPlayerPed(-1), Config.HeistLocations.Yacht_location.yacht_coords) then
        for index=1, #gold_tables do
            CreateGoldTables(gold_tables[index].coords, gold_tables[index].heading, gold_tables[index])
        end
    end
end, false)