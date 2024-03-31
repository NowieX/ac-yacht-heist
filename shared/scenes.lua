local function loadModel(model)
    RequestModel(GetHashKey(model))
    while not HasModelLoaded(GetHashKey(model)) do Citizen.Wait(0) end
end

local function CreateCameraAndRender(posx, posy, posz, heading, fov)
    cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", posx, posy, posz, 0.0 ,0.0, heading, fov, false, 0)
    SetCamActive(cam, true)
    RenderScriptCams(true, true, 1000, true, true)
end

local function StopCameraRender()
    RenderScriptCams(false, true, 1000, true, true)
    SetCamActive(cam, false)
end

RegisterNetEvent('ac-yacht-heist:client:StartHackCamera', function()
    exports.ox_target:removeZone(Hacking_Zone)
    local playerPed = PlayerPedId()
    local scene_coords = Config.HeistLocations.Security_panel_hack_scene.scene_location
    local rotation = Config.HeistLocations.Security_panel_hack_scene.scene_rotation
    local animDict = "anim@heists@ornate_bank@hack"
    
    RequestAnimDict(animDict)
    while not HasAnimDictLoaded(animDict) do Citizen.Wait(10) end
    
    local sceneObjects = {
        'hei_prop_hei_securitypanel',
        'hei_prop_hst_laptop',
        'hei_p_m_bag_var22_arm_s',
        'hei_prop_heist_card_hack_02',
        'lr_prop_suitbag_01',
    }

    for i=1, #sceneObjects do
        loadModel(sceneObjects[i])
    end

    local security_panel = CreateObject(`hei_prop_hei_securitypanel`, scene_coords.x, scene_coords.y, scene_coords.z, true, true, false)
    SetEntityHeading(security_panel, Config.HeistLocations.Security_panel_hack_scene.scene_rotation.z)

    local scene_coords = GetOffsetFromEntityInWorldCoords(security_panel, 0.0, 0.0, 0.0)

    CreateCameraAndRender(973.6738, -2995.3264, -47.5518, 142.6543, 60.0)

    local hacker_laptop = CreateObject(`hei_prop_hst_laptop`, scene_coords.x, scene_coords.y, scene_coords.z, true, true, false)
    local grinder_bag = CreateObject(`hei_p_m_bag_var22_arm_s`, scene_coords.x, scene_coords.y, scene_coords.z, true, true, false)
    local hacker_card = CreateObject(`hei_prop_heist_card_hack_02`, scene_coords.x, scene_coords.y, scene_coords.z, true, true, false)
    local suit_bag = CreateObject(`hei_prop_heist_card_hack`, scene_coords.x, scene_coords.y, scene_coords.z, true, true, false)

    
    local start_hacking_scene = NetworkCreateSynchronisedScene(scene_coords.x, scene_coords.y, scene_coords.z, rotation.x, rotation.y, rotation.z, 2, true, false, 1065353216, 0, 1065353216)
    
    NetworkAddPedToSynchronisedScene(playerPed, start_hacking_scene, animDict, "hack_enter", 1.5, -4.0, 2, 16, 1148846080, 0)
    NetworkAddEntityToSynchronisedScene(hacker_laptop, start_hacking_scene, animDict, "hack_enter_laptop", 1.0, 1.0, 1)
    NetworkAddEntityToSynchronisedScene(grinder_bag, start_hacking_scene, animDict, "hack_enter_bag", 1.0, 1.0, 1)
    NetworkAddEntityToSynchronisedScene(hacker_card, start_hacking_scene, animDict, "hack_enter_card", 1.0, 1.0, 1)
    NetworkAddEntityToSynchronisedScene(suit_bag, start_hacking_scene, animDict, "hack_enter_suit_bag", 1.0, 1.0, 1)
    
    NetworkStartSynchronisedScene(start_hacking_scene)
    
    local first_hacking_scene_timer = GetAnimDuration(animDict, "hack_enter") * 1000
    Citizen.Wait(first_hacking_scene_timer)
    
    local hack_looping_scene = NetworkCreateSynchronisedScene(scene_coords.x, scene_coords.y, scene_coords.z, rotation.x, rotation.y, rotation.z, 2, true, true, 1065353216, 0, 1065353216)
    
    NetworkAddPedToSynchronisedScene(playerPed, hack_looping_scene, animDict, "hack_loop", 1.5, -4.0, 2, 16, 1148846080, 0)
    NetworkAddEntityToSynchronisedScene(hacker_laptop, hack_looping_scene, animDict, "hack_loop_laptop", 1.0, 1.0, 1)
    NetworkAddEntityToSynchronisedScene(grinder_bag, hack_looping_scene, animDict, "hack_loop_bag", 1.0, 1.0, 1)
    NetworkAddEntityToSynchronisedScene(hacker_card, hack_looping_scene, animDict, "hack_loop_card", 1.0, 1.0, 1)
    NetworkAddEntityToSynchronisedScene(suit_bag, hack_looping_scene, animDict, "hack_loop_suit_bag", 1.0, 1.0, 1)
    
    NetworkStartSynchronisedScene(hack_looping_scene)
    
    local looping_scene_timer = GetAnimDuration(animDict, "hack_loop") * 1000
    Citizen.Wait(looping_scene_timer)

    local hack_closing_scene = NetworkCreateSynchronisedScene(scene_coords.x, scene_coords.y, scene_coords.z, rotation.x, rotation.y, rotation.z, 2, true, true, 1065353216, 0, 1065353216)
    
    NetworkAddPedToSynchronisedScene(playerPed, hack_closing_scene, animDict, "hack_exit", 1.5, -4.0, 2, 16, 1148846080, 0)
    NetworkAddEntityToSynchronisedScene(hacker_laptop, hack_closing_scene, animDict, "hack_exit_laptop", 1.0, 1.0, 1)
    NetworkAddEntityToSynchronisedScene(grinder_bag, hack_closing_scene, animDict, "hack_exit_bag", 1.0, 1.0, 1)
    NetworkAddEntityToSynchronisedScene(hacker_card, hack_closing_scene, animDict, "hack_exit_card", 1.0, 1.0, 1)
    NetworkAddEntityToSynchronisedScene(suit_bag, hack_closing_scene, animDict, "hack_exit_suit_bag", 1.0, 1.0, 1)

    NetworkStartSynchronisedScene(hack_closing_scene)

    local closing_scene = GetAnimDuration(animDict, "hack_exit") * 1000
    Citizen.Wait(closing_scene)

    NetworkStopSynchronisedScene(hack_closing_scene)

    StopCameraRender()
    DeleteEntity(hacker_laptop)
    DeleteEntity(grinder_bag)
    DeleteEntity(hacker_card)
    DeleteEntity(suit_bag)

    TriggerEvent("ac-yacht-heist:client:ExitCameraBuilding")

    Citizen.Wait(3000)
    DeleteEntity(security_panel)
end, false)