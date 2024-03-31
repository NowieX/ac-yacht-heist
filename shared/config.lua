Config = {}

Config.Debugger = false

Config.GeneralTargetDistance = 1.5

Config.HeistNPC = {
    {
        -- location = vec4(1247.4257, -2891.4165, 9.3193, 359.3845),
        location = vec4(-295.7075, 6388.8911, 30.6137, 128.7009),
        model = 's_m_y_dockwork_01',
        target_distance = 1.5
    },
}

Config.Webhook = {
    hacker_log = "",
    item_log = "",
}

Config.HeistInformation = {
    ['HeistCooldownTimer'] = 30, -- Minuten
    ['PoliceNumberRequired'] = 0,
    ['BlackScreenTimer'] = 1000 -- Tijd hoelang het duurt voordat een speler in het camera gebouw is
}

Config.Notifies = {
    timer = 7500,
    position = "center-right"
}

Config.RequiredWeapons = {
    'weapon_pistol',
    'weapon_pistol_mk2',
}

Config.HeistLocations = {
    HackerBuilding = {
        location = vec3(-297.19287109375, 6391.78564453125, 30.80292510986328),
        target_label = "Gebouw ingaan",
    },

    Security_panel_hack_scene = {
        scene_location = vec3(972.4680, -2997.1530, -47.4558),
        scene_rotation = vec3(0.0, 0.0, 89.09815),
        target_label = "Camera's hacken"
    },

    Boat_Pickup_Location = {
        spawn_location = vec4(3392.1477, 5697.4932, 0.2093, 112.7311),
        
    }
}

Config.Translations = {
    ['BossInformation'] = {
        boss_title = "Willem | Jacht overval",
        target_label = "Jacht overval",
        introduction_round = {
            message = "Volg de route op je GPS en ga bij het gebouw naar binnen. Daar moet je gebruik maken van het hackerstoestel wat je hebt.",
            timer = 20000
        }
    },

    ["HeistStart"] = {

        heist_occupied = {
            label = "Er is al iemand bezig met de jacht overval",
            timer = 10000
        },

        heist_recently_done = {
            label = "Iemand heeft te recentelijk al de jacht overval gedaan. Wacht nog %s seconden!", -- %s erin laten, deze formateerd het aantal seconden dat iemand moet wachten voor een nieuwe heist
            timer = 10000
        },
        
        not_enough_police = {
            label = "Er is niet genoeg politie in dienst, er moet minimaal %s politie in dienst zijn.", -- %s erin laten, deze formateerd het aantal seconden dat iemand moet wachten voor een nieuwe heist
            timer = 10000
        },

        not_a_threat = {
            label = "Je vormt geen bedreiging om de jacht te kunnen overvallen.",
            timer = 10000
        },
    },

    ["FirstPreperation"] = {
        target_label = "Hacken",

        hack_security_camera = {
            label = "Hack de security camera's binnen.",
            timer = 10000
        }
    }
}